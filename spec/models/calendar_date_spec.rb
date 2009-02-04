require File.dirname(__FILE__) + '/../spec_rails_plugin_helper'

describe CalendarDate do
  describe "all dates", :shared => true do
    it "should be valid" do
      @date.valid?.should be_true
    end
  
    it "should have a calendar" do
      @date.calendar.class.should == Calendar
    end
  
    it "should have occurrences" do
      @date.occurrences.should_not be_nil
    end
  
    it "should have events" do
      @date.events.should_not be_nil
    end
  
    it "should have a value" do
      @date.value.class.should == Date
    end
  
    it "should have a weekday between 0 and 6" do
      (0..6).include?(@date.weekday).should be_true
    end
  
    it "should have a monthday between 1 and 31" do
      (1..31).include?(@date.monthday).should be_true
    end
  
    it "should have a monthweek between 0 and 4" do
      (0..4).include?(@date.monthweek).should be_true
    end

    it "should have a lastweek of -1 or 0" do
      (-1..0).include?(@date.lastweek).should be_true
    end

    it "should have lastweeks in the last week of the month" do
      if @date.lastweek == -1
        (@date.value + 7).month.should == 
          (@date.value.month < 12 ? @date.value.month + 1 : 1)
      end
    end
  end

  (Date.parse('2008-01-01') .. Date.parse('2008-12-31')).each do |value|
    describe "on date #{value}" do
      before(:all) do
        @date = Factory(:calendar_date, :value => value)
      end

      it_should_behave_like "all dates"
    end
  end
end
