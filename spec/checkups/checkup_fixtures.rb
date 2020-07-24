# frozen_string_literal: true

def at_hour(hour)
  now = Time.now
  Time.utc(now.year, now.month, now.day, hour, rand(60), rand(60))
end

class TestCheckup < Checkups::Checkup
  def initialize(status, message, name, url)
    @status, @status_message, @name, @url = status, message, name, url
  end
end

class TestHourlyCheckup < Checkups::Checkup
  def self.frequency
    :hourly
  end

  def on_check(status, message)
    @status_to_return = status
    @message_to_return = message
  end

  def check
    @status_message = @message_to_return
    @status = @status_to_return
  end
end

class TestNotifications < Checkups::Checkup
  attr_reader :notified
  attr_accessor :notify_frequency, :check_result

  def initialize
    super
    @notifier = self
    @notify_with_attachment = false
    @check_result = :info
  end

  def check
    self.send(@check_result, "message")
  end

  def notify(_checkup)
    @notified = true
  end
end

class TestErrorHandling < Checkups::Checkup
  def check
    raise "uh-oh"
  end
end

class FakeNotifier
  def notify(checkup)
    @sends ||= []
    params = {status: checkup.status, message: checkup.status_message}
    @sends << params
  end

  attr_reader :sends
end

class BadNotifier
  def notify(_checkup)
    raise "it's fun to do bad things"
  end
end

class FakeLogger < ::Logger
  attr_reader :log_lines

  def initialize
    @log_lines = []
    @logdev = StringIO.new
    @level = ::Logger::Severity::DEBUG
  end

  def format_message(severity, datetime, progname, msg)
    @log_lines << {
      datetime: datetime,
      severity: severity,
      message: msg,
      progname: progname
    }
  end
end

class BadLogger < ::Logger
  attr_reader :log_lines

  def initialize
    @log_lines = []
    @logdev = StringIO.new
    @level = ::Logger::Severity::DEBUG
  end

  def format_message(_severity, _datetime, _progname, _msg)
    raise "nope nope nope"
  end
end
