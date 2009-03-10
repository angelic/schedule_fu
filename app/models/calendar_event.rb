class CalendarEvent < ActiveRecord::Base
  belongs_to :calendar
  belongs_to :event_type, :class_name => 'CalendarEventType', 
      :foreign_key => :calendar_event_type_id

  # discrete event occurrences
  has_and_belongs_to_many :occurrences, :class_name => 'CalendarDate', 
      :join_table => 'calendar_occurrences'

  # recurring date patterns
  has_many :recurrences, :class_name=>'CalendarRecurrence', :dependent => :destroy

  has_many :event_dates, :class_name=>'CalendarEventDate', :readonly => true

  # actual dates, including occurrences and recurrences
  has_many :dates, :through => :event_dates, :readonly => true

  attr_writer :repeat_by # valid values are weekday and monthday
  (0..6).each do |n|
     attr_accessor "_repeat_#{n}".to_sym
     
     define_method "repeat_#{n}=" do |*args|
       sym = "@repeat_#{n}".to_sym
       self.instance_variable_set(sym, args.first)
       self.instance_variable_set(sym, args.first)
     end
     
     define_method "repeat_#{n}" do
       var = self.instance_variable_get("@repeat_#{n}".to_sym)
       return var if var
       var = false
       recurrences.each do |r|
         if r.weekday == n
           var = true 
           break
         end
       end
       var
     end
   end
  
  validates_presence_of :calendar, :start_date, :calendar_event_type_id
  before_save :create_dates_for_range
  after_save :add_occurrences
  after_save :add_recurrences

  named_scope :with_time_set, :conditions => 'start_time IS NOT NULL AND end_time IS NOT NULL'
  named_scope :without_time_set, :conditions => 'start_time IS NULL OR end_time IS NULL'
  
  def repeat_by
    var = self.instance_variable_get(:@repeat_by)
    if var
      var
    elsif recurrences.count == 0
    elsif recurrences.first.weekday
      "weekday"
    else 
      "monthday"
    end
  end
  
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
  
  def recurrence_type
    if recurrences.blank?
      :norepeat
    elsif recurrences.size == 5 && 
        ((1..5).to_a - recurrences.collect {|r| r.weekday}).size == 0
      :weekdays
    else 
      recurrence.first.recurrence_type
    end
  end
  
  def date_range
    e_date = self.end_date.blank? ? self.start_date : self.end_date
    self.start_date.to_date..e_date.to_date
  end

  def is_event_type?(t)
    event_type && event_type.name == t
  end
  
  protected
  def create_dates_for_range
    CalendarDate.get_and_create_dates(self.date_range)
  end
  
  def add_occurrences
    if event_type.name == "norepeat"
      self.recurrences = []
      self.occurrences = []
      date_range.each {|d| self.occurrences << CalendarDate.by_values(d) }
    end
  end
  
  def add_recurrences
    unless event_type.name == "norepeat"
      self.recurrences = []
      self.occurrences = []
      self.recurrences.create(parse_recurrence_params_by_type)
    end
  end
  
  def parse_recurrence_params_by_type
    case self.event_type.name.to_sym
      when :daily then {}
      when :weekdays then (1..5).collect {|d| {:weekday => d}}
      when :weekly then parse_weekly_attrs
      when :monthly then parse_monthly_attrs
      when :yearly then parse_yearly_attrs
      when :norepeat then nil
    end
  end
  
  def parse_weekly_attrs
    arr = []
    (0..6).each {|n| arr << {:weekday => n} if self.send("repeat_#{n}").to_s == '1' }
    arr
  end
  
  def parse_monthly_attrs
    return unless self.repeat_by
    case self.repeat_by.to_sym
      when :monthday then {:monthday => start_date.mday}
      when :weekday then {:weekday => start_date.wday, :monthweek => start_date.mday / 7}
    end
  end
  
  def parse_yearly_attrs
    parse_monthly_attrs.merge(:month => start_date.month)
  end
end
