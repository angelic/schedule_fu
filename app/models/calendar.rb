class Calendar < ActiveRecord::Base
  extend ScheduleFu::Parser
  include ScheduleFu::Finder
  
  has_many(:dates, 
    {:class_name=>'CalendarDate', :order=>'value', :dependent=>:delete_all}) do
    include ScheduleFu::Finder
    
    def values
      map {|d| d.value}
    end

    def find_by_value(value)
      find(:first, :conditions => { :value => value })
    end
    
    def find_by_dates(*args)
      find(:all, :conditions => conditions_for_date_finders(*args))
    end
  end

  has_many(:events, {:class_name=>'CalendarEvent', :dependent=>:destroy}) do
    include ScheduleFu::Finder
    
    def create_for(*args)
      dates = Calendar.parse(*args)
      event = create
      process_dates(dates, event)
      event
    end

    def find_by_dates(*args)
      find(:all, { :joins => :dates, :conditions => conditions_for_date_finders(*args) })
    end
    
    def process_dates(dates, event)
      case dates
        when Date then event.occurrences << event.calendar.dates.find_by_value(dates)
        when Hash then event.recurrences.create(dates)
        when Enumerable
          dates.each do |date|
            raise ArgumentError if date.kind_of?(Enumerable)
            process_dates(date, event)
          end
        else
          raise ArgumentError
      end
    end
  end
  
  def self.create_for_dates(start_date = nil, end_date = nil)
    calendar = create()
    start_date ||= Date.today
    end_date ||= 5.years.since(start_date)
    calendar.fill_dates(start_date .. end_date)
    calendar
  end

  def fill_dates(values)
    values.each { |date| dates.create(:value => date) }
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
