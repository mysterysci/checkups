# frozen_string_literal: true

module Checkups
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end
  end

  def self.configure
    yield(configuration)
  end

  class Configuration
    attr_accessor :notifier, :logger

    def initialize
      @notifier = Checkups::SlackNotifier.new
      @logger = Logger.new(IO::NULL)
    end
  end
end
