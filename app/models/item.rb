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

  default_scope where(archived: false)
  scope :this_week, -> { where('created_at > ?', 1.week.ago.beginning_of_day) }
  scope :from_last_three_days, -> { where('created_at >= ?', 3.days.ago.beginning_of_day) }

  def recent_uniqueness
    Item.where(user_id: self.user.id).this_week.each do |item|
      if e = self.sufficiently_similar_to?(item)
        errors[:base] << "#{e} - ITEM: #{item.description}"
      end
    end
  end

  def sufficiently_similar_to?(item)
    e = self.character_overlap?(item)
    e ||= self.word_overlap?(item)
    e
  end

  def identical?(item)
    self.squished_description == item.squished_description
  end

  #Returns true if two descriptions share 60% of their words
  def word_overlap?(item)
    first_array = self.clean_description.split
    second_array = self.clean_description.split

    first_array.percentage_similarity_to(second_array) > 60 ? "ERROR: Too much word overlap" : false
  end

  #Returns true if two descriptions share 60% of their characteres
  def character_overlap?(item)
    first_array = self.squished_description.split('')
    second_array = self.squished_description.split('')
    
    first_array.percentage_similarity_to(second_array) > 60 ? "ERROR: Too much character overlap" : false
  end

  # Depunctuated and downcased, but not squished
  def clean_description 
    description.downcase.gsub(/[^0-9a-z ]/i, '')
  end

  def squished_description
    clean_description.split.join('')
  end

end
