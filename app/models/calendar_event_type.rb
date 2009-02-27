class CalendarEventType < ActiveRecord::Base
  has_many :calendar_events
end