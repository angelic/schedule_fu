require File.dirname(__FILE__) + '/../spec_rails_plugin_helper'

describe CalendarRecurrence do
  it "should allow weekly events" do
    recurrence = Factory(:calendar_recurrence, { :weekday => 0 })
    recurrence.weekly?.should be_true
    recurrence.monthly?.should be_false
    recurrence.valid?.should be_true
  end

  it "should not allow weekly events with weekday < 0" do
    lambda { Factory(:calendar_recurrence, { :weekday => -1 }) }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should not allow weekly events with weekday > 6" do
    lambda { Factory(:calendar_recurrence, { :weekday => 7 }) }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should allow weekly events that happen once a month" do
    recurrence = Factory(:calendar_recurrence, { :weekday => 0, :monthweek => 0 })
    recurrence.weekly?.should be_false
    recurrence.monthly?.should be_true
    recurrence.valid?.should be_true
  end

  it "should allow not weekly events that happen once a month with a monthweek < -1" do
    lambda { Factory(:calendar_recurrence, { :weekday => 0, :monthweek => -2 }) }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should allow not weekly events that happen once a month with a monthweek > 4" do
    lambda { Factory(:calendar_recurrence, { :weekday => 0, :monthweek => 5 }) }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should allow monthly events" do
    recurrence = Factory(:calendar_recurrence, { :monthday => 1 })
    recurrence.weekly?.should be_false
    recurrence.monthly?.should be_true
    recurrence.valid?.should be_true
  end

  it "should allow not allow monthly events with monthday < 0" do
    lambda { Factory(:calendar_recurrence, { :monthday => -1 }) }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should allow not allow monthly events with monthday > 31" do
    lambda { Factory(:calendar_recurrence, { :monthday => 32 }) }.should raise_error(ActiveRecord::RecordInvalid)
  end
end
