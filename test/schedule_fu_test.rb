require 'test_helper'

class ScheduleFuTest < ActiveSupport::TestCase
  load_schema

  def test_schema_loaded
    assert_equal [], CalendarEvent.all
  end
end
