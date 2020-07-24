# frozen_string_literal: true

require "spec_helper"
require "timecop"

RSpec.describe Checkups::Performance do
  it "defaults warning to half an hour" do
    Timecop.freeze do
      p = Checkups::Performance.new(name: "warn-after-half-hour")
      p.check do
        Timecop.travel(minutes_in_seconds(31))
      end
      expect(p.status).to eq :warning
      expect(p.status_message).to eq "warn-after-half-hour took longer than 1800s: 1860s"
    end
  end

  it "defaults error to one hour" do
    Timecop.freeze do
      p = Checkups::Performance.new(name: "error-after-one-hour")
      p.check do
        Timecop.travel(minutes_in_seconds(61))
      end
      expect(p.status).to eq :error
      expect(p.status_message).to eq "error-after-one-hour took longer than 3600s: 3660s"
    end
  end

  it "status is ok under the warn limit" do
    Timecop.freeze do
      p = Checkups::Performance.new
      p.check do
        Timecop.travel(60)
      end
      expect(p.status).to eq :ok
    end
  end

  it "has configurable warning" do
    Timecop.freeze do
      p = Checkups::Performance.new(warning_limit: 30)
      p.check do
        Timecop.travel(60)
      end
      expect(p.status).to eq :warning
    end
  end

  it "has configurable error" do
    Timecop.freeze do
      p = Checkups::Performance.new(error_limit: 30)
      p.check do
        Timecop.travel(60)
      end
      expect(p.warning_limit).to eq 1800 # interesting but acceptable artifact? error can be earlier than warning.
      expect(p.status).to eq :error
    end
  end

  def minutes_in_seconds(minutes)
    minutes * 60
  end
end
