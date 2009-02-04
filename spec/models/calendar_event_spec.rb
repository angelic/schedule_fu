require File.dirname(__FILE__) + '/../spec_rails_plugin_helper'

module CalendarEventHelperMethods
  def cdates
    @dates.map { |value| cdate(value) }
  end

  def cdate(value)
    CalendarDate.find(:first, :conditions => { :value => value, :calendar_id => @calendar })
  end
end

describe CalendarEvent do
  describe "all events", :shared => true do
    it "should have a calendar" do
      @event.calendar.class.should == Calendar
    end

    it "should have occurrences" do
      @event.occurrences.all? {|e| e.class == CalendarDate}.should be_true
    end

    it "should have recurrences" do
      @event.recurrences.all? {|e| e.class == CalendarRecurrence}.should be_true
    end

    it "should have dates" do
      @event.dates.all? {|e| e.class == CalendarDate}.should be_true
    end
  end

  describe "an empty event" do
    before(:all) do
      @event = Factory(:calendar_event)
    end

    it_should_behave_like "all events"
  end

  describe "events with dates", :shared => true do
    include CalendarEventHelperMethods

    before(:all) do
    end

    it "should have the expected dates" do
      @event.dates.should == cdates
    end
  end

  describe "a 3 month calendar" do
    before(:all) do
      @calendar = Calendar.create_for_dates(Date.parse('2008-01-01'), Date.parse('2008-03-31'))
    end

    describe "with specific occurrences" do
      before(:all) do
        @event = Factory(:calendar_event, :calendar => @calendar)
        @dates = ['2008-01-18', '2008-01-20', '2008-01-25']
        cdates.each { |cdate| @event.occurrences << cdate }
      end
  
      it_should_behave_like "all events"
      it_should_behave_like "events with dates"
    end
  
    describe "with weekly recurrences" do
      before(:all) do
        @event = Factory(:calendar_event, :calendar => @calendar)
        @event.recurrences.create({ :weekday => 3 })
        @dates = ['2008-01-02', '2008-01-09', '2008-01-16', '2008-01-23', '2008-01-30', '2008-02-06', '2008-02-13', '2008-02-20', '2008-02-27', '2008-03-05', '2008-03-12', '2008-03-19', '2008-03-26']
      end
  
      it_should_behave_like "all events"
      it_should_behave_like "events with dates"
    end
  
    describe "when it has monthly day of month recurrences" do
      before(:all) do
        @event = Factory(:calendar_event, :calendar => @calendar)
        @event.recurrences.create({ :monthday => 15 })
        @dates = ['2008-01-15', '2008-02-15', '2008-03-15']
      end
  
      it_should_behave_like "all events"
      it_should_behave_like "events with dates"
    end

    describe "when it has monthly day of week recurrences" do
      before(:all) do
        @event = Factory(:calendar_event, :calendar => @calendar)
        @event.recurrences.create({ :weekday => 6, :monthweek => 0 })
        @dates = ['2008-01-05', '2008-02-02', '2008-03-01']
      end
  
      it_should_behave_like "all events"
      it_should_behave_like "events with dates"
    end

    describe "when it has monthly day of last week recurrences" do
      before(:all) do
        @event = Factory(:calendar_event, :calendar => @calendar)
        @event.recurrences.create({ :weekday => 6, :monthweek => -1 })
        @dates = ['2008-01-26', '2008-02-23', '2008-03-29']
      end
  
      it_should_behave_like "all events"
      it_should_behave_like "events with dates"
    end

  end
end
