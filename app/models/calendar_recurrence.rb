class CalendarRecurrence < ActiveRecord::Base
  belongs_to :event, :class_name=>'CalendarEvent', :foreign_key => :calendar_event_id

  validates_presence_of :event
  validates_inclusion_of :weekday, :in => 0..6, :allow_nil => true
  validates_inclusion_of :monthday, :in => 1..31, :allow_nil => true
  validates_inclusion_of :monthweek, :in => -1..4, :allow_nil => true

  validate :validate_pattern

  def validate_pattern
    errors.add_to_base('Invalid pattern') if ((!monthweek.nil? || !monthweek.nil?) && !monthday.nil?)
  end

  def daily?
    weekday.blank? && monthweek.blank? && monthday.blank? && month.blank?
  end
  
  # Just a monthday or a monthweek and a weekday
  def monthly?
    !yearly && ((!monthday.blank? && montheek.blank? && weekday.blank?) || 
        (monthday.blank? && !monthweek.blank? && !weekday.blank?))
  end

  # No monthday and a weekday
  def weekly?
    !yearly? && monthday.blank? && !weekday.blank? && monthweek.blank?
  end
  
  def yearly?
    !month.blank?
  end
  
  def recurrence_type
    if yearly? then :yearly
    elsif daily? then :daily
    elsif weekly? then :weekly
    elsif monthly? then :monthly
    end
  end
end
