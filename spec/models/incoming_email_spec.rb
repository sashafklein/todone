require "spec_helper"

describe IncomingEmail do
  
  before(:each) { 
    User.find_each(&:destroy)
    Item.find_each(&:destroy)
    @user = subscribed_user 
  }

  describe "unsubscribing in body" do
    it "unsubscribes the user" do
      send!(body: "+here's some body\n-and_more\nUNSUBSCRIBE ME")
      @user.reload.subscribed?.should be_false
    end
  end

  describe "unsubscribing in subject" do
    it "unsubscribes the user" do
      send!(subject: "UNSUBSCRIBE ME")
      @user.reload.subscribed?.should be_false
    end
  end

  describe "resubscribing in subject" do
    it "resubscribes the user" do
      send!(subject: "RESUBSCRIBE ME")
      @user.reload.subscribed?.should be_true
    end
  end

  describe "adding/subtracting lines" do
    it "adds each line with a + sign" do
      send!(body: "+first item\n+second item\n+third item")
      @user.items.count.should == 3
      @user.items.map(&:description).should include "first item"
    end

    it "archives lines led by -" do
      send!(body: "+first item\n+second item\n+third item")
      send!(body: "+fourth item\n+fifth item\n-third item")
      @user.items.count.should == 5
      @user.items.unarchived.count.should == 4
      @user.items.unarchived.map(&:description).should include "fifth item"
      @user.items.unarchived.map(&:description).should_not include "third item"
    end
  end

  describe "time-stamping items on creation" do
    it "defaults to created_at time" do
      send!
      @user.items.count.should == 1
      @user.items.first.description.should == "here's some body"
      @user.items.first.created_at.to_date.should == @user.items.first.updated_at.to_date
    end

    it "accepts 2-part time stamps and cuts the time stamp" do
      send!(body: "+christmas item >> 12/25")
      @user.items.count.should == 1
      @user.items.first.description.should == "christmas item "
      @user.items.first.created_at.should == DateTime.new(2013,12,25)
    end

    it "accepts 3-part time stamps" do
      send!(body: "+next christmas item >> 12/25/14")
      @user.items.count.should == 1
      @user.items.first.description.should == "next christmas item "
      @user.items.first.created_at.should == DateTime.new(2014,12,25)
    end

    it "accepts day-distance time stamps" do
      send!(body: "+two days off >> 2")
      @user.items.count.should == 1
      @user.items.first.description.should == "two days off "
      @user.items.first.created_at.should be_before DateTime.new(Time.now.year, Time.now.month, 3.days.from_now.day)
      puts @user.items.first.created_at
      @user.items.first.created_at.should be_after DateTime.new(Time.now.year, Time.now.month, 1.day.from_now.day)
    end
  end
end

def send!(options = {})
  args = { 
    email: "email@fake.com", 
    body: "+here's some body\n-and_more", 
    subject: "Here's a subject"
  }
  IncomingEmail.process args.merge(options)
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