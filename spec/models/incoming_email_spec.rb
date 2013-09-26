require "spec_helper"

describe IncomingEmail do
  
  before(:each) { 
    User.find_each(&:destroy)
    Item.find_each(&:destroy)
    @user = subscribed_user 
  }

  describe "unsubscribing in body" do
    it "unsubscribes the user" do
      IncomingEmail.process(
        "email@fake.com", 
        "+here's some body\n-and_more\nUNSUBSCRIBE ME",
        "I want to unsubscribe"
      )
      @user.reload.subscribed?.should be_false
    end
  end

  describe "unsubscribing in subject" do
    it "unsubscribes the user" do
      IncomingEmail.process(
        "email@fake.com", 
        "+here's some body\n-and_more",
        "UNSUBSCRIBE ME"
      )
      @user.reload.subscribed?.should be_false
    end
  end

  describe "resubscribing in subject" do
    it "resubscribes the user" do
      IncomingEmail.process(
        "email@fake.com", 
        "+here's some body\n-and_more",
        "RESUBSCRIBE ME"
      )
      @user.reload.subscribed?.should be_true
    end
  end

  describe "adding/subtracting lines" do
    it "adds each line with a plus sign" do
      IncomingEmail.process(
        "email@fake.com",
        "+first item\n+second item\n+third item",
        "Testing additions"
      )
      @user.items.count.should == 3
      @user.items.map(&:description).should include "first item"
    end

    it "archives lines led by -" do
      IncomingEmail.process(
        "email@fake.com",
        "+first item\n+second item\n+third item",
        "Testing additions"
      )
      IncomingEmail.process(
        "email@fake.com",
        "+fourth item\n+fifth item\n-third item",
        "Testing additions"
      )
      @user.items.count.should == 5
      @user.items.unarchived.count.should == 4
      @user.items.unarchived.map(&:description).should include "fifth item"
      @user.items.unarchived.map(&:description).should_not include "third item"
    end
  end
end


def subscribed_user
  User.create!(
    first_name: "First",
    last_name: "Second", 
    email: "email@fake.com", 
    password: "password",
    password_confirmation: "password",
    subscribed: true
  )
end