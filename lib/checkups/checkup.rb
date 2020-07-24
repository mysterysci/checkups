# frozen_string_literal: true

# TODO: flesh out a manager class that can keep better track of the Checkup classes
# TODO: \ and if they're being executed, so if something gets skipped for some reason
# TODO: \ maybe it has a chance of being discovered instead of silently just never
# TODO: \ being executed.
module Checkups
  class Checkup
    attr_reader :status_message, :status, :verbose, :name, :url

    def self.hourly
      checkups_by_frequency(:hourly)
    end

    def self.daily
      checkups_by_frequency(:daily)
    end

    # TODO: Remove verbose from method signature
    def self.checkups_by_frequency(frequency, _verbose: false)
      checkup_classes = ObjectSpace.each_object(::Class).select { |klass| klass < self }
      checkup_classes.select { |klass| klass.frequency == frequency }
    end

    def self.frequency
      :never
    end

    def initialize(verbose: false)
      @notify_frequency = :always
      @verbose = verbose
      @name = nil
      ok
    end

    def check_and_notify!(&block)
      check(&block)
      send_notification
    rescue => e # rubocop:disable Style/RescueStandardError
      handle_error(e)
    end

    def passed?
      case check
      when nil, :ok, :info
        true
      when :warning, :error
        false
      else
        raise "Unknown status: #{check}"
      end
    end

    def check
      ok
    end

    def notify_message
      "Checkup #{@status.to_s.capitalize}: " + @status_message
    end

    protected

    def ok
      set_status(:ok, nil)
    end

    def info(message)
      set_status(:info, message)
    end

    def warning(message)
      set_status(:warning, message)
    end
    alias warn warning

    def error(message)
      set_status(:error, message)
    end

    def send_notification
      puts "#{status}#{status_message ? ': ' + status_message : ''}" if verbose

      notifier.notify(self) if need_notification?
    end

    def notifier
      @notifier ||= Checkups.configuration.notifier
    end

    def logger
      @logger ||= Checkups.configuration.logger
    end

    def need_notification?
      @status_message && NotificationTimer.new(@notify_frequency, @status).now?
    end

    def set_status(status, message)
      @status_message = message
      @status = status
    end

    # rubocop:disable Style/RescueStandardError
    def handle_error(error)
      message = "Error running Checkup class #{self.class.name}: #{error.message} #{error.backtrace[0]}"
      set_status(:fatal, message)
      notifier.notify(self)
    rescue
      # Last chance for gas
      logger.error("Checkup handle_error error! #{error.message}") rescue nil # rubocop:disable Style/RescueModifier
    end
    # rubocop:enable Style/RescueStandardError
  end
end
