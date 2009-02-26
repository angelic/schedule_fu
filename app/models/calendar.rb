class Calendar < ActiveRecord::Base
  include ScheduleFu::Finder
  
  has_many(:events, {:class_name=>'CalendarEvent', :dependent=>:destroy}) do
    extend ScheduleFu::Parser
    include ScheduleFu::Finder
    
    def create_for(event_type, attribs)
      dates = parse_recurrence_by_type(event_type, {}) # TODO: make recurrence work
      unless dates
        f_date = parse_date(attribs[:from_date])
        t_date = parse_date(attribs[:to_date])
        if f_date && t_date
          CalendarDate.get_and_create_dates(f_date..t_date)
          dates = (f_date..t_date)
        else
          CalendarDate.get_and_create_dates(f_date..f_date)
          dates = parse_date(f_date)
        end
      end
      event = create
      process_dates(dates, event)
      event
    end

    def find_by_dates(*args)
      find(:all, { :joins => :dates, :conditions => conditions_for_date_finders(*args) })
    end
    
    def process_dates(dates, event)
      case dates
        when Date then event.occurrences << CalendarDate.by_values(dates)
        when Hash then event.recurrences.create(dates)
        when Enumerable
          dates.each do |date|
#            raise ArgumentError if date.kind_of?(Enumerable)
            process_dates(date, event)
          end
        when nil
        else
          raise ArgumentError
      end
    end
  end
  
  def max_events_per_day_without_time_set(*args)
    conditions = conditions_for_date_finders(*args)
    conditions[0] << ' AND (start_time IS NULL OR end_time IS NULL) AND calendars.id = ?'
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
