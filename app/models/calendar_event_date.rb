class CalendarEventDate < ActiveRecord::Base
  belongs_to :event, :class_name => 'CalendarEvent', :foreign_key => 'calendar_event_id'
  belongs_to :date, :class_name => 'CalendarDate', :foreign_key => 'calendar_date_id'
  belongs_to :mod, :class_name => 'CalendarEventMod', :foreign_key => 'calendar_event_mod_id'

  named_scope :removed, :conditions => {:removed => true}, :order => 'date_value'
  named_scope :not_removed, :conditions => {:removed => false}, :order => 'date_value'

  def mod_or_build
    mod || build_mod(:calendar_event_id => calendar_event_id, 
        :calendar_date_id => calendar_date_id)
  end
end
