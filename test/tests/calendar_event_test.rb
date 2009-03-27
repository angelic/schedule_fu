require File.dirname(__FILE__) + '/../test_helper'

class CalendarEventTest < ActiveSupport::TestCase
  should_validate_presence_of :calendar, :start_date, :calendar_event_type_id

  context "norepeat event" do
    setup do
      @event = Factory(:calendar_event_norepeat, :start_date => 1.day.from_now, 
          :end_date => 2.weeks.from_now)
    end

    should "have no recurrences" do
      assert_equal 0, @event.recurrences.count
    end

    should "have 1 event date that matches the start date" do
      assert_equal 1, @event.dates.count
      assert_equal @event.start_date.to_date, @event.dates.first.value
    end
  end

  context "weekdays event" do
    setup do
      @event = Factory(:calendar_event_weekdays, :start_date => 1.day.from_now, 
          :end_date => 2.weeks.from_now)
      @count_of_weekdays = Hash.new {|hash, key| hash[key] = 0}
      @event.dates.each do |d|
        @count_of_weekdays[d.weekday] += 1
      end
    end

    should "have no recurrences" do
      assert_equal 0, @event.recurrences.count
    end

    should "have 10 event dates" do
      assert_equal 10, @event.event_dates.count
    end

    should "have 2 of each weekday" do
      (1..5).each do |n|
        assert_equal 2, @count_of_weekdays[n]
      end
    end  
    
    should "not have Sunday or Saturday" do
      [0,6].each do |n|
        assert_equal 0, @count_of_weekdays[n]
      end
    end
  end

  context "daily event with 14 event dates" do
    setup do
      @event = Factory(:calendar_event_daily, :start_date => 1.day.from_now,
          :end_date => 2.weeks.from_now)
    end

    should "have no recurrences" do
      assert_equal 0, @event.recurrences.count
    end

    should "have 14 event dates" do
      assert_equal 14, @event.event_dates.count
    end 

    should "be in the correct range" do
      @event.dates.each do |d|
        assert d.value >= @event.start_date.to_date
        assert d.value <= @event.end_date.to_date
      end
    end
  end

  context "weekly event" do
    context "on Monday, Wednesday, and Friday with 6 event dates" do
      setup do
        @event = Factory(:calendar_event_weekly, :repeat_0 => false, :repeat_1 => true,
            :repeat_2 => false, :repeat_3 => true, :repeat_4 => false, 
            :repeat_5 => true, :repeat_6 => false, :start_date => 1.day.from_now,
            :end_date => 2.weeks.from_now)
        @count_of_weekdays = Hash.new {|hash, key| hash[key] = 0}
        @event.dates.each do |d|
          @count_of_weekdays[d.weekday] += 1
        end
      end

      should "have 3 recurrences" do
        assert_equal 3, @event.recurrences.count
      end

      should "have 6 event dates" do
        assert_equal 6, @event.event_dates.count
      end

      should "have 2 each of Monday, Wednesday, and Friday" do
        [1,3,5].each do |n|
          assert_equal 2, @count_of_weekdays[n]
        end
      end  
      
      should "not have Sunday, Tuesday, Thursday, or Saturday" do
        [0,2,4,6].each do |n|
          assert_equal 0, @count_of_weekdays[n]
        end
      end
    end
  end

  context "monthly event" do
    context "by day of month with 6 event dates" do
      setup do
        @event = Factory(:calendar_event_monthly, :by_day_of_month => true,
            :start_date => 1.week.ago, :end_date => 5.months.from_now)
        @recurrence = @event.recurrences.first
      end

      should "have 1 recurrence" do
        assert_equal 1, @event.recurrences.count
      end

      should "have 6 event dates" do
        assert_equal 6, @event.event_dates.count
      end 

      should "have the correct day of month" do
        @event.dates.each do |d|
          assert_equal @recurrence.monthday, d.monthday
        end
      end
    end

    context "by day of week with 6 event dates" do
      setup do
        @event = Factory(:calendar_event_monthly, :by_day_of_month => false,
            :start_date => 1.week.ago, :end_date => 5.months.from_now)
        @recurrence = @event.recurrences.first
      end

      should "have 1 recurrence" do
        assert_equal 1, @event.recurrences.count
      end

      should "have 6 event dates" do
        assert_equal 6, @event.event_dates.count
      end 

      should "have the correct day of week" do
        @event.dates.each do |d|
          assert_equal @recurrence.weekday, d.weekday
        end
      end

      should "have the correct week" do
        @event.dates.each do |d|
          assert_equal @recurrence.monthweek, d.monthweek
        end
      end
    end
  end

  context "yearly event" do
    context "by day of month with 2 event dates" do
      setup do
        @event = Factory(:calendar_event_yearly, :by_day_of_month => true,
            :start_date => 1.month.ago, :end_date => 1.year.from_now)
        @recurrence = @event.recurrences.first
      end

      should "have 1 recurrence" do
        assert_equal 1, @event.recurrences.count
      end

      should "have 2 event dates" do
        assert_equal 2, @event.event_dates.count
      end 

      should "have the correct month" do
        @event.dates.each do |d|
          assert_equal @recurrence.month, d.month
        end
      end

      should "have the correct day of month" do
        @event.dates.each do |d|
          assert_equal @recurrence.monthday, d.monthday
        end
      end
    end

    context "by day of week with 2 event dates" do
      setup do
        @event = Factory(:calendar_event_yearly, :by_day_of_month => false,
            :start_date => 1.month.ago, :end_date => 1.year.from_now)
        @recurrence = @event.recurrences.first
      end

      should "have 1 recurrence" do
        assert_equal 1, @event.recurrences.count
      end

      should "have 2 event dates" do
        assert_equal 2, @event.event_dates.count
      end 

      should "have the correct month" do
        @event.dates.each do |d|
          assert_equal @recurrence.month, d.month
        end
      end

      should "have the correct day of week" do
        @event.dates.each do |d|
          assert_equal @recurrence.weekday, d.weekday
        end
      end

      should "have the correct week" do
        @event.dates.each do |d|
          assert_equal @recurrence.monthweek, d.monthweek
        end
      end
    end
  end
end
