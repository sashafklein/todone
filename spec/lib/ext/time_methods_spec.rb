require 'spec_helper'

describe TimeMethods do
  describe "#convert" do
    it "converts a date, time, or datetime object to datetime in UTC" do
      time_array = [Date.today, Time.now.beginning_of_day, DateTime.now.beginning_of_day]
      time_array.each do |time| 
        converted = time.convert
        converted.class.should == DateTime
        converted.zone.should == "+00:00" # UTC Time Zone
      end
    end
  end

  describe ".utc_beginning_of_day" do
    it "takes all time objects and returns identical utc datetime" do
      time_array = [Date, Time, DateTime]
      new_array = time_array.map{ |time_class| time_class.utc_beginning_of_day }
      new_array.all?{ |time| time == new_array[0] }.should be_true
    end
  end

  describe '#utc_day' do
    context 'with "western date string" argument, ("12/24/2013")' do
      it "returns the beginning of that day in UTC datetime" do
        by_date     = Date.utc_day('12/24/2013')
        by_time     = Time.utc_day('12/24/2014')
        
        by_date.class.should == DateTime
        by_time.zone.should == '+00:00'

        (by_time - by_date).to_i == 365 # days
      end
    end

    context "without an arugment" do
      it "just returns the utc_beginning_of_day" do
        Date.utc_beginning_of_day.should == Time.utc_day
      end
    end
  end

  describe "one-to-one comparison methods" do
    context "with different time classes" do
      it "returns a bool giving correct relation" do
        a = Time.now - 1.minute
        b = DateTime.now
        a.before?(b).should be_true
        a.after?(b).should be_false
      end

      it "does not validate identical times unless specififed" do
        a = Time.utc_beginning_of_day
        b = Date.utc_beginning_of_day
        a.before?(b).should be_false
        b.after?(a).should be_false
      end

      it 'does validate identical times when specified' do
        a = Time.utc_beginning_of_day
        b = Date.utc_beginning_of_day
        c = DateTime.utc_beginning_of_day.tomorrow
        
        a.on_or_before?(b).should be_true
        a.on_or_after?(b).should be_true
        
        a.on_or_after?(c).should be_false
        a.on_or_before?(c).should be_true
      end
    end
  end

  describe "between methods" do
    it "returns a bool giving the correct relation" do
      yesterday = Time.utc_beginning_of_day - 1.day
      today = Date.utc_beginning_of_day
      tomorrow = DateTime.utc_beginning_of_day.tomorrow

      today.strictly_between?(yesterday, tomorrow).should be_true
      yesterday.strictly_between?(today, tomorrow).should be_false
    end

    it "does not ordinarily accomodate equality" do
      today = Time.utc_beginning_of_day
      also_today = Date.utc_beginning_of_day
      tomorrow = DateTime.utc_beginning_of_day.tomorrow

      today.strictly_between?(also_today, tomorrow).should be_false
      today.inclusively_between?(also_today, tomorrow).should be_true
    end
  end

end