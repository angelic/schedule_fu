class CalendarEventDate < ActiveRecord::Base
  belongs_to :event, :class_name => 'CalendarEvent', :foreign_key => 'calendar_event_id'
  belongs_to :date, :class_name => 'CalendarDate', :foreign_key => 'calendar_date_id'
end
