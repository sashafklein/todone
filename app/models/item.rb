# == Schema Information
#
# Table name: items
#
#  id          :integer          not null, primary key
#  description :string(255)
#  archived    :boolean
#  archived_at :datetime
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Item < ActiveRecord::Base
  attr_accessible :archived, :archived_at, :description, :user_id

  belongs_to :user

  validate :recent_uniqueness, on: :create

  scope :this_week, -> { where('created_at > ?', 1.week.ago) }

  def recent_uniqueness
    Item.where(user_id: self.user.id).this_week.each do |item|
      if self.sufficiently_similar_to?(item)
        errors[:base] << "ITEM #{item.description} ALREADY EXISTS" # customize (TBD)
      end
    end
  end

  def sufficiently_similar_to?(item)
    tests = [:identical?, :word_overlap?, :character_overlap?]
    results = tests.map{ |method| self.send(method, item) }
    results.include?(true)
  end

  def identical?(item)
    self.squished_description == item.squished_description
  end

  #Returns true if two descriptions share 60% of their words
  def word_overlap?(item)
    first_array = self.clean_description.split
    second_array = self.clean_description.split

    first_array.percentage_similarity_to(second_array) > 60 ? true : false
  end

  #Returns true if two descriptions share 60% of their characteres
  def character_overlap?(item)
    first_array = self.squished_description.split('')
    second_array = self.squished_description.split('')
    
    first_array.percentage_similarity_to(second_array) > 60 ? true : false
  end

  # Depunctuated and downcased, but not squished
  def clean_description 
    description.downcase.gsub(/[^0-9a-z ]/i, '')
  end

  def squished_description
    clean_description.split.join('')
  end

end
