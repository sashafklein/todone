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

  # validate :recent_uniqueness, on: :create

  scope :live, -> { unarchived.from_last_in_days(3)}
  scope :unarchived, -> { where archived: false }
  scope :archived, -> { where archived: true }
  scope :this_week, -> { where 'created_at > ?', 1.week.ago.beginning_of_day }
  scope :from_last_in_days, lambda { |num_days| where 'created_at >= ?', num_days.days.ago.beginning_of_day }
  scope :older_than_in_days, lambda { |num_days| where 'created_at < ?', num_days.days.ago.beginning_of_day }
  scope :begun, -> { where 'created_at > ?', Time.now }
  default_scope -> { order('created_at DESC') }

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

  #Returns truthy if two descriptions share too many words
  def word_overlap?(item)
    first_array = self.clean_description.split.declutter
    second_array = item.clean_description.split.declutter

    first_array.percentage_similarity_to(second_array) > 85 ? "Too much word overlap" : false
  end

  #Returns truthy if two descriptions share too many characteres
  def character_overlap?(item)
    first_array = self.decluttered_and_squished_description.split('')
    second_array = item.decluttered_and_squished_description.split('')
    
    first_array.percentage_similarity_to(second_array) > 80 ? "Too much character overlap" : false
  end

  def clean_description 
    description.downcase.clean
  end

  def squished_description
    clean_description.squish
  end

  def decluttered_and_squished_description
    clean_description.split(' ').declutter.join.squish
  end

  def days_left
    3 - ( (Time.now - self.created_at) / 1.day ).to_i
  end

  def email_days_left
    days_left <= 0 ? 0 : days_left
  end

  def toggle!(value = true)
    self.archived = value
    self.archived_at = value ? Time.now : nil
    self.save!
  end

  def unarchive!
    toggle!(false)
  end

  def archive!
    toggle!
  end

  def self.batch_subtract(description_array, user_id)
    user_items = unarchived.where(user_id: user_id)
    description_array.map(&:strip_up_to_text).each do |item_description|
      archive_by_description(item_description, user_items)
    end
  end

  def self.archive_by_description(item_description, item_relation)
    if item_relation.where(description: item_description).any?
      item_relation.find_by_description(item_description).archive!
    end
  end

  def self.batch_add(description_array, user_id)
    description_array.map(&:strip_up_to_text).each do |item_description|
      build_and_time_release_item(item_description, user_id)
    end
  end

  def self.build_and_time_release_item(item_description, user_id)
    time = item_description.parse_for_time || Time.now
    cleaned_description = item_description.split('>>')[0]
    Item.create!(user_id: user_id, description: cleaned_description, created_at: time)
  end
end
