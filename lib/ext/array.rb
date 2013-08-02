class Array

  def percentage_similarity_to(second_array)
    numerator = 0
    denomenator = self.length
    
    self.each do |word| 
      if second_array.include?(word)
        numerator += 1 
        second_array.delete_at(second_array.index(word))
      end
    end  

    numerator.to_f / denomenator.to_f * 100
  end

end