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

end
