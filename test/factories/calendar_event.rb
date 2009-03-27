Factory.define :calendar_event do |e|
  e.association :calendar, :factory => :calendar
  e.start_date 5.days.from_now
  e.end_date 5.weeks.from_now
  e.desc 'some event description'
end

Factory.define :calendar_event_norepeat, :parent => :calendar_event do |e|
  e.calendar_event_type_id 1
end

Factory.define :calendar_event_weekdays, :parent => :calendar_event do |e|
  e.calendar_event_type_id 2
end

Factory.define :calendar_event_daily, :parent => :calendar_event do |e|
  e.calendar_event_type_id 3
end

Factory.define :calendar_event_weekly, :parent => :calendar_event do |e|
  e.repeat_3 '1'
  e.calendar_event_type_id 4
end

Factory.define :calendar_event_monthly, :parent => :calendar_event do |e|
  e.calendar_event_type_id 5
  e.by_day_of_month true
end

Factory.define :calendar_event_yearly, :parent => :calendar_event do |e|
  e.calendar_event_type_id 6
  e.by_day_of_month true
end
