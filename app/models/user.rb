# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  first_name      :string(255)
#  last_name       :string(255)
#  email           :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  password_digest :string(255)
#  subscribed      :boolean          default(TRUE)
#

class User < ActiveRecord::Base
  has_many :items
  has_secure_password

  before_save { self.email = email.downcase }

  scope :subscribed, -> { where(subscribed: true) }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates_presence_of :first_name, :last_name, :email
  validates :password, length: { minimum: 6 }
  validates_confirmation_of :password, if: lambda { |m| m.password.present? }
  validates :email, 
            uniqueness: { case_sensitive: false }, 
            length: { minimum: 5, maximum: 25 }, 
            format: { with: VALID_EMAIL_REGEX }
  
  def name
    "#{first_name} #{last_name}"
  end

  def self.email_in_db?(email)
    if email.include?("<") # Trims emails of the format 'First Last <whatever@example.com>'
      email = email[email.index("<")+1..email.index(">")-1]
    end
    where(email: email).any?
  end

  def send_out_morning_email!
    if items.unarchived.count > 0
      UserMailer.seeded_morning_email(self, self.items.unarchived).deliver
    else
      UserMailer.blank_morning_email(self).deliver
    end
  end

  def add_and_subtract_items!(additions, subtractions)
    additions.each do |description|
      create_new_item(description)
    end

    subtractions.each do |item_id|
      archive_item(item_id)
    end
  end

  def create_new_item(description)
    items.create!(description: description)
  end

  def archive_item(item_id)
    return nil unless has_item?(item_id)
    
    items.find(item_id).archive!
  end

  def has_item?(item_id)
    items.where(id: item_id).any?
  end

  def resubscribe!
    self.subscribed = true
    self.save!
  end

  def unsubscribe!
    self.subscribed = false
    self.save!
  end
end
