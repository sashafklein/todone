# == Schema Information
#
# Table name: items
#
#  id          :integer          not null, primary key
#  description :string(255)
#  archived    :boolean          default(FALSE)
#  archived_at :datetime
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Item < ActiveRecord::Base

  belongs_to :user

  validate :recent_uniqueness, on: :create

  scope :live, -> { unarchived.from_last_three_days}
  scope :unarchived, -> { where archived: false }
  scope :archived, -> { where archived: true }
  scope :this_week, -> { where 'created_at > ?', 1.week.ago.beginning_of_day }
  scope :from_last_three_days, -> { where 'created_at >= ?', 3.days.ago.beginning_of_day }

  def recent_uniqueness
    Item.where(user_id: self.user.id).this_week.each do |item|
      if e = self.sufficiently_similar_to?(item)
        errors[:base] << "#{e} with '#{item.description.truncate(30)}'!"
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
    second_array = item.clean_description.split

    first_array.percentage_similarity_to(second_array) > 60 ? "Too much word overlap" : false
  end

  #Returns true if two descriptions share 60% of their characteres
  def character_overlap?(item)
    first_array = self.squished_description.split('')
    second_array = item.squished_description.split('')
    
    first_array.percentage_similarity_to(second_array) > 80 ? "Too much character overlap" : false
  end

  # Depunctuated and downcased, but not squished
  def clean_description 
    description.downcase.gsub(/[^0-9a-z ]/i, '')
  end

  def squished_description
    clean_description.split.join('')
  end

  def days_left
    3 - ( (Time.now - self.created_at) / 1.day ).to_i
  end

end
