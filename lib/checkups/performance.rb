# frozen_string_literal: true

module Checkups
  class Performance < Checkup
    def self.frequency
      :never
    end

    attr_reader :error_limit, :warning_limit

    def initialize(verbose: false, name: nil, warning_limit: 1800, error_limit: 3600)
      super(verbose: verbose)
      @name = name
      @warning_limit = warning_limit
      @error_limit = error_limit
      ok
    end

    def check
      start_time = Time.now.to_i
      yield
      check_elapsed(Time.now.to_i - start_time)
    end

    def check_elapsed(elapsed)
      if warning_limit <= elapsed && elapsed < error_limit
        warning "#{name} took longer than #{warning_limit}s: #{elapsed}s"
      elsif error_limit <= elapsed
        error "#{name} took longer than #{error_limit}s: #{elapsed}s"
      else
        ok
      end
    end
  end
end
