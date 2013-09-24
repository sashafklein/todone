module TimeMethods

  module ClassMethods
    def utc_beginning_of_day
      DateTime.now.beginning_of_day.utc.beginning_of_day
    end

    def utc_day(western_date_string = nil) # eg, 12/24/2013
      return self.utc_beginning_of_day unless western_date_string.present? && western_date_string.is_three_part_date?
      month, day, year = western_date_string.split('/').map(&:to_i)
      DateTime.new(year, month, day)
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

  # All class temporarily convert to datetime in UTC for comparison

  def after?(time)
    self.convert > time.convert
  end

  def utc_beginning_of_day
    convert.now.beginning_of_day.utc.beginning_of_day
  end

  def before?(time)
    self.convert < time.convert
  end

  def on_or_after?(time)
    self.convert >= time.convert
  end

  def on_or_before?(time)
    self.convert <= time.convert
  end

  def strictly_between?(time_a, time_b)
    self.convert > time_a.convert && self.convert < time_b.convert
  end

  def inclusively_between?(time_a, time_b)
    self.convert >= time_a.convert && self.convert <= time_b.convert
  end

  def convert
    to_datetime.utc
  end
end