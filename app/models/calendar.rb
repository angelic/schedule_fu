class Calendar < ActiveRecord::Base
  extend ScheduleFu

  has_many(:dates, 
    {:class_name=>'CalendarDate', :order=>'value', :dependent=>:delete_all}) do
    def values
      map {|d| d.value}
    end

    def find_by_value(value)
      find(:first, :conditions => { :value => value })
    end
  end

  has_many(:events, {:class_name=>'CalendarEvent', :dependent=>:destroy}) do
    def create_for(*args)
      dates = Calendar.parse(*args)
      event = create
      case dates
        when Date then event.occurrences << event.calendar.dates.find_by_value(dates)
        when Hash then event.recurrences.create(dates)
        when Enumerable
          dates.each do |date|
            event.occurrences << event.calendar.dates.find_by_value(date)
          end
        else
          raise ArgumentError
      end
      event
    end

    def find_by_dates(*args)
      dates = Calendar.parse(*args)
      conditions = case dates
        when Date then ['value = ?', dates]
        when Range then ['value BETWEEN ? AND ?', dates.first, dates.last]
        when Enumerable then ['value IN (?)', dates]
        else
          raise ArgumentError
      end
      find(:all, { :joins => :dates, :conditions => conditions })
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
