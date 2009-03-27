class CalendarEventMod < ActiveRecord::Base
  belongs_to :event, :class_name => 'CalendarEvent', :foreign_key => 'calendar_event_id'
  belongs_to :date, :class_name => 'CalendarDate', :foreign_key => 'calendar_date_id'
  has_one :event_date, :class_name => 'CalendarEventDate', :foreign_key => 'calendar_event_mod_id'

  validates_presence_of :calendar_event_id, :calendar_date_id
  validates_uniqueness_of :calendar_event_id, :scope => :calendar_date_id
end
