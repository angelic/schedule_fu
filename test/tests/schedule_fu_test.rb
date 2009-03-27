require File.dirname(__FILE__) + '/../test_helper'

class ScheduleFuTest < ActiveSupport::TestCase
  context "yearly calendar event" do
    setup do
      @event = Factory(:calendar_event_yearly_by_day_of_month_with_two_event_dates)
      @recurrence = @event.recurrences.first
    end

    should "have one recurrence" do
      assert_equal 1, @event.recurrences.count
    end

    should "have two event dates" do
      assert_equal 2, @event.event_dates.count
    end 

    should "have the correct day of month" do
      @event.dates.each do |d|
        assert_equal @recurrence.monthday, d.monthday
      end
    end

    should "have the correct month" do
      @event.dates.each do |d|
        assert_equal @recurrence.month, d.month
      end
    end
  end
end
