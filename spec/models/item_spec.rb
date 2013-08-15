require "spec_helper"

describe Item do
  describe "#recent_uniqueness" do

    before { 
      @user = User.create(first_name: "Bob", last_name: "Sanchez", email: "bob@sanchez.com")
      @a = @user.items.create(description: 1.upto(10).to_a.join(" ")) 
    }

    it "blocks submissions with > 60 percent word similarity" do
      b = @user.items.new(description: 1.upto(7).to_a.join(" "))
      expect{ b.save! }.to raise_error
    end

    it "blocks submission with > 60 percent letter similarity" do
      b = @user.items.new(description: 1.upto(7).to_a.join("") )
      expect{ b.save! }.to raise_error
    end

    it "does not block asimilar items" do
      b = @user.items.new(description: 1.upto(6).to_a.join("") )
      expect{ b.save! }.not_to raise_error
    end
    
    it "does not run similarity checks on old items" do
      @a.update_attribute(:created_at, 2.weeks.ago)
      b = @user.items.new(description: 1.upto(7).to_a.join("") )
      expect{ b.save! }.not_to raise_error
    end

    it "does run similarity checks on archived items" do
      @a.update_attribute(:archived, true)
      b = @user.items.new(description: 1.upto(7).to_a.join("") )
      expect{ b.save! }.to raise_error
    end
    
  end
end
