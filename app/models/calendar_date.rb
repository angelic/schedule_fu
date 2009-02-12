class CalendarDate < ActiveRecord::Base
  extend ScheduleFu::Finder
  
  # discrete event occurrences
  has_and_belongs_to_many(:occurrences,
    {:class_name=>'CalendarEvent', :join_table=>'calendar_occurrences'})

  has_many :calendar_event_dates, :readonly => true

  # actual events, including occurrences and recurrences
  has_many :events, :through => :calendar_event_dates

  validates_presence_of :value
  validates_inclusion_of :weekday, :in => 0..6
  validates_inclusion_of :monthday, :in => 1..31
  validates_inclusion_of :monthweek, :in => 0..4

  before_validation_on_create :derive_date_parts

  named_scope :by_dates, lambda {|*args| {:conditions => conditions_for_date_finders(*args)}}
  named_scope :by_values, lambda{|*args| {:conditions => ["value in (?)", args]}}
  
  def self.find_by_value(value)
    find(:first, :conditions => { :value => value })
  end
  
  def self.create_for_dates(start_date = nil, end_date = nil)
    start_date ||= Date.today
    end_date ||= 5.years.since(start_date)
    (start_date .. end_date).each do |date|
      begin
        self.create(:value => date)
      rescue
        next
      end
    end
  end

  def self.get_and_create_dates(range)
    dates = self.by_dates(range)
    if dates.size < range.to_a.size
      CalendarDate.create_for_dates(range.first, range.last)
      Thread.new do
        start_date = 1.year.ago(range.first).to_date
        end_date = 1.year.since(range.last).to_date
        CalendarDate.create_for_dates(start_date, end_date)
      end
      dates = self.by_dates(range)
    end
    dates
  end
  
  private

  def derive_date_parts
    self.weekday = value.wday
    self.monthday = value.mday
    self.monthweek = monthday / 7
    date = value
    month = date.month
    days_until_next_month = 0
    while date = date.next
      days_until_next_month += 1
      break if date.month != month
    end
    if days_until_next_month <= 7
      self.lastweek = -1
    else
      self.lastweek = 0
    end
  end
end
