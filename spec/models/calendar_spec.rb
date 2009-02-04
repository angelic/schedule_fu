require File.dirname(__FILE__) + '/../spec_rails_plugin_helper'

describe Calendar, "when empty" do
  before(:each) do
    @calendar = Factory(:calendar)
  end

  it "should have no dates" do
    @calendar.dates.should == []
    @calendar.dates.values.should == []
  end

  it "should have no events" do
    @calendar.events.should == []
  end

  it "should fill with dates" do
    dates = (Date.parse('2008-01-01') .. Date.parse('2008-01-02'))
    @calendar.fill_dates(dates)
    @calendar.dates.values.should == dates.to_a
  end
end

describe Calendar, "when created for certain dates" do
  before(:each) do
    @dates = (Date.today .. 6.days.since(Date.today))
    @calendar = Calendar.create_for_dates(@dates.first, @dates.last)
  end

  it "should have those dates" do
    @calendar.dates.values.should == @dates.to_a
  end

  it "should find no events for one date" do
    @calendar.events.find_by_dates(@dates.first).should == []
  end

  it "should find no events for a range of dates" do
    @calendar.events.find_by_dates(@dates.first, @dates.last).should == []
  end

  it "should find an event on the first date" do
    event = @calendar.events.create
    event.occurrences << @calendar.dates.find_by_value(@dates.first)
    @calendar.events.find_by_dates(@dates.first).should == [event]
  end

  it "should find an event on the first and last dates" do
    events = [@dates.first, @dates.last].map do |date|
      event = @calendar.events.create
      event.occurrences << @calendar.dates.find_by_value(date)
      event
    end
    @calendar.events.find_by_dates(@dates.first, @dates.last).should == events
  end

  it "should create single date events" do
    event = @calendar.events.create_for(@dates.first)
    event.dates.map {|cdate| cdate.value}.should == [@dates.first]
  end

  it "should create date range events" do
    event = @calendar.events.create_for(@dates.first, @dates.last)
    event.dates.map {|cdate| cdate.value}.should == 
      (@dates.first .. @dates.last).to_a
  end

  it "should create multi-day events from enumerables" do
    event = @calendar.events.create_for(@dates)
    event.dates.map {|cdate| cdate.value}.should == @dates.to_a
  end

  it "should create multi-day events from varargs" do
    event = @calendar.events.create_for(*@dates)
    event.dates.map {|cdate| cdate.value}.should == @dates.to_a
  end
end
