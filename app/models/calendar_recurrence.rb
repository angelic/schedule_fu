class CalendarRecurrence < ActiveRecord::Base
  belongs_to :calendar_event

  validates_presence_of :calendar_event
  validates_inclusion_of :weekday, :in => 0..6, :allow_nil => true
  validates_inclusion_of :monthday, :in => 1..31, :allow_nil => true
  validates_inclusion_of :monthweek, :in => -1..4, :allow_nil => true

  validate :validate_pattern

  def validate_pattern
    errors.add_to_base('Invalid pattern') if !(monthly? || weekly?)
  end

  # Just a monthday or a monthweek and a weekday
  def monthly?
    (!monthday.nil? && monthweek.nil? && weekday.nil?) || 
      (monthday.nil? && !monthweek.nil? && !weekday.nil?)
  end

  # No monthday and a weekday
  def weekly?
    monthday.nil? && !weekday.nil? && monthweek.nil?
  end
end
