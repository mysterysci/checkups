# frozen_string_literal: true

if defined?(Sidekiq)
  require "sidekiq"
  require "active_support/core_ext/string/inflections"

  module Checkups
    class SidekiqWorker
      include Sidekiq::Worker

      sidekiq_options retry: 3

      # :hourly or :daily, spread them out over time
      def perform(frequency, verbose = false)
        Checkup.checkups_by_frequency(frequency.to_sym).each_with_index do |klass, i|
          OneCheckupWorker.perform_in(i * 10, klass.name, verbose)
        end
      end
    end

    class OneCheckupWorker
      include Sidekiq::Worker

      sidekiq_options retry: 3

      # :hourly or :daily
      def perform(klass, verbose = false)
        klass.constantize.new(verbose: verbose).tap do |checkup|
          printf "Checkup: #{klass}..." if verbose
          checkup.check_and_notify!
        end
      end
    end
  end
end
