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

require "spec_helper"

describe Item do
  describe "#recent_uniqueness" do

    before(:all) { 
      @user = User.create!(
        first_name: "Bob", 
        last_name: "Sanchez", 
        email: "bob#{rand(50)}@sanchez.com",
        password: "password", 
        password_confirmation: "password"
        )
      @a = @user.items.create(description: 1.upto(10).to_a.join(" ")) 
    }

    xit "blocks submissions with > 60 percent word similarity" do
      b = @user.items.new(description: 1.upto(7).to_a.join(" "))
      expect{ b.save! }.to raise_error
    end

    xit "blocks submission with > 60 percent letter similarity" do
      b = @user.items.new(description: 1.upto(7).to_a.join("") )
      expect{ b.save! }.to raise_error
    end

    xit "does not block asimilar items" do
      b = @user.items.new(description: 1.upto(6).to_a.join("") )
      expect{ b.save! }.not_to raise_error
    end
    
    xit "does not run similarity checks on old items" do
      @a.update_attribute(:created_at, 2.weeks.ago)
      b = @user.items.new(description: 1.upto(7).to_a.join("") )
      expect{ b.save! }.not_to raise_error
    end

    xit "does run similarity checks on archived items" do
      @a.update_attribute(:archived, true)
      b = @user.items.new(description: 1.upto(7).to_a.join("") )
      expect{ b.save! }.to raise_error
    end
    
  end
end
