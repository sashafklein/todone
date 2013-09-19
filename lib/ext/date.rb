class Date
  require_relative './time_methods'
  include TimeMethods

  def self.today_as_a_string
    today.strftime("%B %d, %Y")
  end
end