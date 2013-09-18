class String
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

  def parse_for_time
    return nil unless include? ">>"
    split(">>")[1].convert_to_datetime
  end

  def is_num?
    nums = (0..9).to_a
    split('').all?{ |char| nums.include?(char.to_i) }
  end

  def convert_to_datetime
    return two_part_date if is_two_part_date?
    return three_part_date if is_three_part_date?
    return to_i.days.from_now if is_num?
  rescue
    return nil
  end

  def is_two_part_date?
    split('/').count == 2 && split('/').all?(&:is_num?)
  end

  def two_part_date
    month, day, year = [split('/')[0], split('/')[1], Time.now.year].map(&:to_i)
    Date.new(year.to_s.normalized, month, day)
  end

  def is_three_part_date?
    split('/').count == 3 && split('/').all?(&:is_num?)
  end

  def three_part_date
    month, day, year = [split('/')[0], split('/')[1], split('/')[2]].map(&:to_i)

    Date.new(year.to_s.normalized, month, day)
  end

  # Treats '14 like 2014, and reverts past numbers to this year
  def normalized
    expanded = length == 2 ? "20#{self}".to_i : self.to_i # Assume no 3-digit years
    expanded >= Time.now.year ? expanded : Time.now.year
  end
end