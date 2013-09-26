module DateParser

  def parse_for_time
    return nil unless include? ">>"
    split(">>")[1].strip_up_to_text.convert_to_date
  end

  def convert_to_date
    if is_slash_date? 
      string_to_date
    elsif is_num?
      to_i.days.from_now.to_date
    else
      nil
    end
  rescue
    nil
  end

  def is_num?
    nums = (0..9).to_a.map(&:to_s)
    split('').all?{ |char| nums.include?(char) }
  end

  # Treats '14 like 2014, and reverts past numbers to this year
  def normalized
    expanded = length == 2 ? "20#{self}".to_i : self.to_i # Assume no 3-digit years
    expanded >= Time.now.year ? expanded : Time.now.year
  end

  def is_slash_date?
    array = split('/')
    (array.count > 1) && (array.count <= 3) && ( array.all?(&:is_num?) )
  end

  def string_to_date
    array = split('/')
    array[2] ||= Time.now.year
    month, day, year = array.map(&:to_i)
    date = Date.new(year.to_s.normalized, month, day)
  end

end