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
  before_create :create_remember_token

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
    where(email: email).any?
  end

  def send_out_morning_email!
    if items.unarchived.begun.count > 0
      UserMailer.seeded_morning_email(self, self.items.unarchived).deliver
    else
      UserMailer.blank_morning_email(self).deliver
    end
  end

  def add_and_subtract_items!(additions, subtractions)
    add(additions)
    subtract(subtractions)
  end

  def add(additions)
    additions.map(&:strip_up_to_text).each do |description|
      build_and_time_release_item(description)
    end
  end

  def build_and_time_release_item(description)
    time = description.parse_for_time
    description = description.split('>>')[0]
    create_new_item(description, time)
  end

  def subtract(subtractions)
    subtractions.map(&:strip_up_to_text).each do |item_id|
      archive_item(item_id)
    end
  end

  def create_new_item(description, time = Time.now)
    items.create!(description: description, created_at: time)
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

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def admin?
    email == "sashafklein@gmail.com"
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end
