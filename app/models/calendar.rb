class Calendar < ActiveRecord::Base
  include ScheduleFu::Finder
  
  has_many :events, :class_name=>'CalendarEvent', :dependent => :destroy
  
  def max_events_per_day_without_time_set(*args)
    conditions = conditions_for_date_finders(*args)
    conditions[0] << ' AND (calendar_event_dates.start_time IS NULL OR calendar_event_dates.end_time IS NULL) AND calendars.id = ?'
    conditions << self.id
    row = CalendarEvent.count({:joins => [:calendar, :dates], 
        :conditions => conditions, :group => 'calendar_date_id', 
        :order => 'count_all DESC', :limit => 1})
    row.empty? ? 0 : row.first[1]
  end
    
  def to_ical
    ical = Icalendar::Calendar.new
    ical.prodid = 'ScheduleFu'
    ical.name = 'Foo'
    ical.to_ical
    events.each do |event|
      ical.event do
      end
    end
  end
end
