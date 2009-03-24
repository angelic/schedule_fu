require File.dirname(__FILE__) + '/../test_helper'

class CalendarEventTest < ActiveSupport::TestCase
  should_validate_presence_of :calendar, :start_date, :calendar_event_type_id
end
