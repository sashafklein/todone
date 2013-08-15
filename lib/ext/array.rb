class Array

  def percentage_similarity_to(second_array)
    if self.length > second_array.length
      long = self.dup
      short = second_array.dup
    else
      long = second_array.dup
      short = self.dup
    end

    numerator = 0
    denomenator = long.length
    
    short.each do |el| 
      if long.include?(el)
        numerator += 1 
        long.delete_at(long.index(el))
      end
    end  

    numerator.to_f / denomenator.to_f * 100
  end
  
end