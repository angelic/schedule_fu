class CalendarEvent < ActiveRecord::Base
  belongs_to :calendar

  # discrete event occurrences
  has_and_belongs_to_many(:occurrences, 
    {:class_name=>'CalendarDate', :join_table=>'calendar_occurrences'})

  # recurring date patterns
  has_many(:recurrences, {:class_name=>'CalendarRecurrence'})

  has_many :calendar_event_dates, :readonly => true

  # actual dates, including occurrences and recurrences
  has_many :dates, :through => :calendar_event_dates, :readonly => true

  validates_presence_of :calendar

  named_scope :with_time_set, :conditions => 'start_time IS NOT NULL AND end_time IS NOT NULL'
  named_scope :without_time_set, :conditions => 'start_time IS NULL OR end_time IS NULL'
  
  def to_rrules
    return nil unless recurrences
    rrules = []
    weekly = []
    recurrences.each do |recurrence|
      if recurrence.monthly?
        rrules << (params = {'FREQ' => 'MONTHLY'})
        if !recurrence.weekly?
          params['BYMONTHDAY'] = recurrence.monthday.to_s
        else
          icalmw = ((mw = recurrence.monthweek) >= 0) ? mw + 1 : mw
          icaldc = Icalendar::DAYCODES[recurrence.weekday]
          params['BYDAY'] = icalmw.to_s + icaldc
        end
      else
        weekly << recurrence.weekday
      end
    end
    if !weekly.empty?
      rrules << {'FREQ' => 'WEEKLY',
        'BYDAY' => weekly.map {|w| Icalendar::DAYCODES[w]}.join(',')}
    end
    rrules
  end
end
