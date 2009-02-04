class CalendarDate < ActiveRecord::Base
  belongs_to :calendar

  # discrete event occurrences
  has_and_belongs_to_many(:occurrences,
    {:class_name=>'CalendarEvent', :join_table=>'calendar_occurrences'})

  has_many :calendar_event_dates

  # actual events, including occurrences and recurrences
  has_many :events, :through => :calendar_event_dates, :readonly => true

  validates_presence_of :calendar
  validates_presence_of :value
  validates_inclusion_of :weekday, :in => 0..6
  validates_inclusion_of :monthday, :in => 1..31
  validates_inclusion_of :monthweek, :in => 0..4

  before_validation_on_create :derive_date_parts

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
