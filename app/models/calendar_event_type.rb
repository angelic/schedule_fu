class CalendarEventType < ActiveRecord::Base
  has_many :calendar_events
  attr_accessible :name, :desc
end
