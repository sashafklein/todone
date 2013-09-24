class String
  require_relative './date_parser'
  include DateParser

  def squish
    split(' ').join('')
  end

  def clean
    gsub(/[^0-9a-z ]/i, '')
  end

  def strip_up_to_text
    self[1..-1].split.join(" ")
  end

  # Trims emails of the format 'First Last <whatever@example.com>'
  def strip_email
    include?("<") ? self[self.index("<")+1..self.index(">")-1] : self
  end
end