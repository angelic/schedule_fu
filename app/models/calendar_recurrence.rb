class CalendarRecurrence < ActiveRecord::Base
  belongs_to :event, :class_name=>'CalendarEvent', :foreign_key => :calendar_event_id

  validates_presence_of :event
  validates_inclusion_of :weekday, :in => 0..6, :allow_nil => true
  validates_inclusion_of :monthday, :in => 1..31, :allow_nil => true
  validates_inclusion_of :monthweek, :in => -1..4, :allow_nil => true
  validates_inclusion_of :month, :in => 1..12, :allow_nil => true
end
