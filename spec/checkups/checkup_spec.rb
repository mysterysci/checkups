# frozen_string_literal: true

require "spec_helper"
require "timecop"

RSpec.describe Checkups::Checkup do
  it "should find hourly classes" do
    expect(Checkups::Checkup.hourly).to include TestHourlyCheckup
  end

  it "should have reasonable defaults" do
    Checkups::Checkup.new.tap do |checkup|
      expect(checkup.passed?).to be_truthy
      expect(checkup.check).to eq :ok
      expect(checkup.status).to eq :ok
      expect(checkup.status_message).to be_nil
    end
  end

  it "subclassing works" do
    TestHourlyCheckup.new.tap do |checkup|
      checkup.on_check(:error, "He's dead, Jim")
      expect(checkup.passed?).to be_falsey
      expect(checkup.check).to eq :error
      expect(checkup.status_message).to eq "He's dead, Jim"
    end
  end

  it "can have info status" do
    TestHourlyCheckup.new.tap do |checkup|
      checkup.on_check(:info, "Jazz is cool")
      expect(checkup.passed?).to be_truthy
      expect(checkup.check).to eq :info
      expect(checkup.status_message).to eq "Jazz is cool"
    end
  end

  describe Checkups::IntervalChecker do
    def with_test_table(*expected_true)
      table = (0..23).to_a.each_with_object({}) { |hour, h| h[hour] = false }
      expected_true.each { |hour| table[hour] = true }
      table.each { |hour, expected| yield hour, expected }
    end

    def check(daily_frequency, time)
      Checkups::IntervalChecker.is_hour_at_day_interval?(daily_frequency, time)
    end

    it "does one job" do
      [
        {freq: "two", expected_true: [0, 12]},
        {freq: "three", expected_true: [0, 8, 16]},
        {freq: "four", expected_true: [0, 6, 12, 18]},
        {freq: "six", expected_true: [0, 4, 8, 12, 16, 20]},
        {freq: "eight", expected_true: [0, 3, 6, 9, 12, 15, 18, 21]},
      ].each do |args|
        with_test_table(*args[:expected_true]) do |hour, expected|
          freq = args[:freq]
          message = "frequency: #{freq} times a day, at_hour: #{hour}, expected: #{expected}"
          # puts message # <= enable to visually inspect
          expect(check(freq, at_hour(hour))).to eq(expected), message
        end
      end
    end
  end

  describe "notifications" do
    it "can find the default notification class" do
      # yes, a real production bug :facepalm:
      expect(subject.send(:notifier)).to_not be_nil
    end

    it "notifies at midnight, 8 times a day" do
      Timecop.freeze(at_hour(0)) do
        checkup = TestNotifications.new
        checkup.notify_frequency = :eight_times_a_day
        checkup.check_and_notify!
        expect(checkup.notified).to eq(true)
      end
    end

    it "does not notify at 1 am, 8 times a day" do
      Timecop.freeze(at_hour(1)) do
        checkup = TestNotifications.new
        checkup.notify_frequency = :eight_times_a_day
        checkup.check_and_notify!
        expect(checkup.notified).to eq(nil)
      end
    end

    it "does notify at 1 am, 8 times a day, if warning or error" do
      Timecop.freeze(at_hour(1)) do
        checkup = TestNotifications.new
        checkup.notify_frequency = :eight_times_a_day
        checkup.check_result = :warning
        checkup.check_and_notify!
        expect(checkup.notified).to eq(true)

        checkup.check_result = :error
        checkup.check_and_notify!
        expect(checkup.notified).to eq(true)
      end
    end

    it "does notify at 1 am, always" do
      Timecop.freeze(at_hour(1)) do
        checkup = TestNotifications.new
        checkup.notify_frequency = :always
        checkup.check_and_notify!
        expect(checkup.notified).to eq(true)
      end
    end
  end

  describe "error handling" do
    it "should handle an error" do
      notifier = FakeNotifier.new
      Checkups.configure { |c| c.notifier = notifier }
      checkup = TestErrorHandling.new
      checkup.check_and_notify!
      notification = notifier.sends.first
      expect(notification[:status]).to eq(:fatal)
      expect(notification[:message]).to include("uh-oh")
    end

    it "should log if handle_error itself has an error" do
      notifier = BadNotifier.new
      logger = FakeLogger.new
      Checkups.configure do |c|
        c.notifier = notifier
        c.logger = logger
      end
      checkup = TestErrorHandling.new
      checkup.check_and_notify!
      expected_hash = {message: "Checkup handle_error error! uh-oh",
                       severity: "ERROR"}
      expect(logger.log_lines.first).to include(expected_hash)
    end

    it "should silently fail if logger errors" do
      notifier = BadNotifier.new
      logger = BadLogger.new
      Checkups.configure do |c|
        c.notifier = notifier
        c.logger = logger
      end
      checkup = TestErrorHandling.new
      checkup.check_and_notify!
      # expect no exceptions to be raised and nothing in logger
      expect(logger.log_lines).to eq([])
    end
  end
end
