require 'set'
class CalendarDate < ActiveRecord::Base
  extend ScheduleFu::Finder
  
  has_many :event_dates, :class_name=>'CalendarEventDate', :readonly => true
  has_many :events, :through => :event_dates

  validates_presence_of :value
  validates_inclusion_of :weekday, :in => 0..6
  validates_inclusion_of :monthday, :in => 1..31
  validates_inclusion_of :monthweek, :in => 0..4
  validates_inclusion_of :month, :in => 1..12

  before_validation :derive_date_parts, :on => :create

  scope :by_dates, lambda {|*args| {:conditions => conditions_for_date_finders(*args)}}
  scope :by_values, lambda{|*args| {:conditions => ["value in (?)", args]}}
  
  def self.find_by_value(value)
    find(:first, :conditions => { :value => value })
  end
  
  def self.create_for_dates(start_date = nil, end_date = nil)
    start_date ||= Date.today
    end_date ||= 5.years.since(start_date)
    range = start_date..end_date
    existing_dates = Set.new
    self.by_dates(range).each {|d| existing_dates << d.value }
    range.each do |date|
      begin
        self.create(:value => date) unless existing_dates.include?(date)
      rescue; end
    end
  end

  def self.create_for_date(date)
    self.create_for_dates(date, date)
  end

  @@create_lock = Mutex.new
  
  def self.get_and_create_dates(range)
    range = range.first.to_date..range.last.to_date
    dates = self.by_dates(range)
    if dates.size < range.to_a.size
      CalendarDate.create_for_dates(range.first, range.last)
      Thread.new do
        start_date = 1.year.ago(range.first).to_date
        end_date = 1.year.since(range.last).to_date
        @@create_lock.synchronize do
          CalendarDate.create_for_dates(start_date, end_date)
        end
      end
      dates = self.by_dates(range)
    end
    dates
  end
  
  private

  def derive_date_parts
    self.weekday = value.wday
    self.monthday = value.mday
    self.monthweek = (monthday - 1) / 7
    date = value
    self.month = date.month
    days_until_next_month = 0
    while date = date.next
      days_until_next_month += 1
      break if date.month != self.month
    end
    if days_until_next_month <= 7
      self.lastweek = true
    end
  end
end
