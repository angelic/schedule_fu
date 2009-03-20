class CalendarEvent < ActiveRecord::Base
  belongs_to :calendar
  belongs_to :event_type, :class_name => 'CalendarEventType', 
      :foreign_key => :calendar_event_type_id

  has_many :mods, :class_name => 'CalendarEventModification'
  has_many :recurrences, :class_name=>'CalendarRecurrence', :dependent => :destroy
  has_many :event_dates, :class_name=>'CalendarEventDate', :readonly => true
  has_many :dates, :through => :event_dates, :readonly => true

  (0..6).each do |n|
     attr_accessor "_repeat_#{n}".to_sym
     
     define_method "repeat_#{n}=" do |*args|
       sym = "@_repeat_#{n}".to_sym
       selected = args.first == '1'|| args.first == true
       self.instance_variable_set(sym, selected)
     end
     
     define_method "repeat_#{n}" do
       var = self.instance_variable_get("@_repeat_#{n}".to_sym)
       return var unless var.nil?
       return recurrences.find_by_weekday(n) ? true : false
     end
   end
  
  validates_presence_of :calendar, :start_date, :calendar_event_type_id
  before_save :create_dates_for_range
  # after_save :add_occurrences
  after_save :add_recurrences

  named_scope :with_time_set, :conditions => 'start_time IS NOT NULL AND end_time IS NOT NULL'
  named_scope :without_time_set, :conditions => 'start_time IS NULL OR end_time IS NULL'
  
  # def to_rrules
  #   return nil unless recurrences
  #   rrules = []
  #   weekly = []
  #   recurrences.each do |recurrence|
  #     if recurrence.monthly?
  #       rrules << (params = {'FREQ' => 'MONTHLY'})
  #       if !recurrence.weekly?
  #         params['BYMONTHDAY'] = recurrence.monthday.to_s
  #       else
  #         icalmw = ((mw = recurrence.monthweek) >= 0) ? mw + 1 : mw
  #         icaldc = Icalendar::DAYCODES[recurrence.weekday]
  #         params['BYDAY'] = icalmw.to_s + icaldc
  #       end
  #     else
  #       weekly << recurrence.weekday
  #     end
  #   end
  #   if !weekly.empty?
  #     rrules << {'FREQ' => 'WEEKLY',
  #       'BYDAY' => weekly.map {|w| Icalendar::DAYCODES[w]}.join(',')}
  #   end
  #   rrules
  # end
  
  def date_range
    e_date = self.end_date.blank? ? self.start_date : self.end_date
    self.start_date.to_date..e_date.to_date
  end

  def event_type_matches?(*event_types)
    return false unless event_type
    name = event_type.name.to_sym
    event_types.each {|et| return true if et.to_sym == name }
    return false
  end

  def any_weekday_selected?
    (0..6).each do |n|
      return true if weekday_selected?(n)
    end
    return false
  end

  def weekday_selected?(n)
    self.send("repeat_#{n}") == true
  end
  
  protected
  def create_dates_for_range
    CalendarDate.get_and_create_dates(self.date_range)
  end
  
  # def add_occurrences
  #   if event_type.name == "norepeat"
  #     self.recurrences = []
  #     self.occurrences = []
  #     date_range.each {|d| self.occurrences << CalendarDate.by_values(d) }
  #   end
  # end
  
  def add_recurrences
    unless event_type.name == "norepeat"
      (0..6).each {|n| self.send("repeat_#{n}=", self.send("repeat_#{n}"))}
      self.recurrences = []
      # self.occurrences = []
      self.recurrences.create(parse_recurrence_params_by_type)
    end
  end
  
  def parse_recurrence_params_by_type
    if event_type_matches?(:weekly)
      arr = []
      (0..6).each {|n| arr << {:weekday => n} if weekday_selected?(n) }
      arr
    elsif event_type_matches?(:monthly, :yearly)
      {:monthday => start_date.mday, :weekday => start_date.wday, 
       :monthweek => (start_date.mday - 1) / 7}
    end
  end
end
