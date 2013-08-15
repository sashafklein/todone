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

  validates_presence_of :first_name, :last_name, :email
  
  def name
    "#{first_name} #{last_name}"
  end

end
