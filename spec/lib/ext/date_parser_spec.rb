require "spec_helper"

describe DateParser do 
  describe "#convert_to_date" do
    it "converts a three-part date string to a Date object" do
      next_christmas = "12/25/2014"
      as_date = next_christmas.convert_to_date
      as_date.class.should == Date
      as_date.year.should == 2014
      as_date.month.should == 12
      as_date.day.should == 25
    end

    it "assumes current year for 2-part strings" do
      this_christmas = "12/25"
      as_date = this_christmas.convert_to_date
      as_date.should == Date.new(2013, 12, 25)
    end

    it "rescues all errors with a nil" do
      "12-25-2013".convert_to_date.should == nil
      "not/a/date".convert_to_date.should == nil
      "12/25/2013/extra".convert_to_date.should == nil
    end 
  end
end