# frozen_string_literal: true

module Checkups
  class NotificationTimer
    def initialize(frequency, status)
      @frequency = frequency
      @status = status
    end

    def now?
      case @status
      when :warning, :error
        true
      else
        case @frequency
        when :always
          true
        when /times_a_day/
          word = @frequency.to_s.scan(/(.*)_times_a_day/).join
          IntervalChecker.is_hour_at_day_interval?(word)
        end
      end
    end
  end

  class IntervalChecker
    # rubocop:disable Naming/PredicateName
    def self.is_hour_at_day_interval?(daily_frequency, time = Time.now.utc)
      frequency = word_to_number(daily_frequency) || 1
      hourly_interval = 24 / frequency
      time.utc.hour.divmod(hourly_interval)[1].zero?
    end
    # rubocop:enable Naming/PredicateName

    def self.word_to_number(word)
      case word
      when String
        {
          "two" => 2,
          "three" => 3,
          "four" => 4,
          "six" => 6,
          "eight" => 8,
        }[word]
      else
        word
      end
    end
  end
end
