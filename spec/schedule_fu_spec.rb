require File.dirname(__FILE__) + '/spec_helper'
require 'schedule_fu'

describe ScheduleFu do
  before(:all) do
    class ExtendsCalendar
      extend ScheduleFu
    end
  end

  describe "parse_dates method" do
    it "on Saturdays" do
      ExtendsCalendar.parse_dates('Saturdays').should == 
        { :weekday => 6, :monthweek => nil }
    end

    it "on Every Friday" do
      ExtendsCalendar.parse_dates('Every Friday').should ==
        { :weekday => 5, :monthweek => nil }
    end

    it "on every 3rd tuesday" do
      ExtendsCalendar.parse_dates('every 3rd tuesday').should ==
        { :weekday => 2, :monthweek => 2 }
    end

    it "on 2nd and 4th Fridays of the month" do
      ExtendsCalendar.parse_dates('2nd and 4th Fridays of the month').should ==
        { :weekday => 5, :monthweek => [1, 3] }
    end

    it "on foo" do
      ExtendsCalendar.parse_dates('foo').should be_nil
    end

    it "on 5/13/2008" do
      ExtendsCalendar.parse_dates('5/13/2008').should ==
        ExtendsCalendar.parse_date('2008-05-13')
    end

    it "on 5/13, 5/15, 5/17" do
      ExtendsCalendar.parse_dates('5/13/08, 5/15/08, 5/17/08').should == 
        ["2008-05-13", "2008-05-15", "2008-05-17"].map do |value|
          ExtendsCalendar.parse_date(value)
        end
    end

    it "on jan 1st - jan 31st" do
      ExtendsCalendar.parse_dates('jan 1st - jan 31st').should ==
        (ExtendsCalendar.parse_date("jan 1st") .. ExtendsCalendar.parse_date("jan 31st"))
    end
  end

  describe "parse method" do
    before(:all) do
      @strings = ['2008-01-01', '2008-01-15', '2008-01-31']
      @dates = @strings.map {|string| ExtendsCalendar.parse_date(string) }
    end

    it "on a string date" do
      ExtendsCalendar.parse(@strings.first).should == @dates.first
    end

    it "on a date date" do
      ExtendsCalendar.parse(@dates.first).should == @dates.first
    end

    it "on an var array of string dates" do
      ExtendsCalendar.parse(*@strings).should == @dates
    end

    it "on an var array of dates" do
      ExtendsCalendar.parse(*@dates).should == @dates
    end

    it "on a two argument var array of string dates" do
      ExtendsCalendar.parse(@strings.first, @strings.last).should == 
        (@dates.first .. @dates.last)
    end

    it "on a two argument var array of dates" do
      ExtendsCalendar.parse(@dates.first, @dates.last).should == 
        (@dates.first .. @dates.last)
    end
  end
end
