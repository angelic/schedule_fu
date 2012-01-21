FactoryGirl.define do
  factory :calendar_event do
    association :calendar, :factory => :calendar
    start_date 5.days.from_now
    end_date 5.weeks.from_now
    desc 'some event description'
  end

  factory :calendar_event_norepeat, :parent => :calendar_event do
    calendar_event_type_id 1
  end

  factory :calendar_event_weekdays, :parent => :calendar_event do
    calendar_event_type_id 2
  end

  factory :calendar_event_daily, :parent => :calendar_event do
    calendar_event_type_id 3
  end

  factory :calendar_event_weekly, :parent => :calendar_event do
    repeat_3 '1'
    calendar_event_type_id 4
  end

  factory :calendar_event_monthly, :parent => :calendar_event do
    calendar_event_type_id 5
    by_day_of_month true
  end

  factory :calendar_event_yearly, :parent => :calendar_event do
    calendar_event_type_id 6
    by_day_of_month true
  end
end
