class String
  def squish
    split(' ').join('')
  end

  def clean
    gsub(/[^0-9a-z ]/i, '')
  end
end