module DateParser

  def parse_for_time
    return nil unless include? ">>"
    split(">>")[1].convert_to_date
  end

  def convert_to_date
    is_slash_date? ? string_to_date : nil
  rescue
    nil
  end

  def is_num?
    nums = (0..9).to_a
    split('').all?{ |char| nums.include?(char.to_i) }
  end

  # Treats '14 like 2014, and reverts past numbers to this year
  def normalized
    expanded = length == 2 ? "20#{self}".to_i : self.to_i # Assume no 3-digit years
    expanded >= Time.now.year ? expanded : Time.now.year
  end
  
  private 

  def is_slash_date?
    array = split('/')
    (array.count > 1) && (array.count <= 3) && ( array.all?(&:is_num?) )
  end

  def string_to_date
    array = split('/')
    array[2] ||= Time.now.year.to_s.normalized
    month, day, year = array.map(&:to_i)
    date = Date.new(year, month, day)
  end

end