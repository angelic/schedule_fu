ActiveRecord::Schema.define(:version => 0) do 
  def self.create_event_type(name, desc)
    CalendarEventType.create(:name => name, :desc => desc)
  end

  create_table :calendars do |t|
    t.column :desc, :text
  end
  Calendar.create
  
  create_table :calendar_dates do |t|
    t.column :value, :date, :null=>false
    t.column :weekday, :integer, :limit => 1, :null=>false
    t.column :monthweek, :integer, :limit => 1, :null=>false
    t.column :monthday, :integer, :limit => 1, :null=>false
    t.column :month, :integer, :limit => 1, :null=>false
    t.column :lastweek, :boolean, :null=>false, :default=>false
  end
  add_index :calendar_dates, :value, :unique => true

  create_table :calendar_event_types do |t|
    t.column :name, :string
    t.column :desc, :string
  end
  norepeat_id = create_event_type("norepeat", "Does not repeat").id
  weekdays_id = create_event_type("weekdays", "Weekdays (M-F)").id
  daily_id = create_event_type("daily", "Daily").id
  weekly_id = create_event_type("weekly", "Weekly").id
  monthly_id = create_event_type("monthly", "Monthly").id
  yearly_id = create_event_type("yearly", "Yearly").id

  create_table :calendar_events do |t|
    t.column :calendar_id, :integer, :null=>false
    t.column :calendar_event_type_id, :integer
    t.column :by_day_of_month, :boolean, :null => false, :default => false
    t.column :start_date, :date
    t.column :end_date, :date
    t.column :start_time, :time
    t.column :end_time, :time
    t.column :desc, :text
    t.column :long_desc, :text
  end

  create_table :calendar_event_mods do |t|
    t.column :calendar_event_id, :integer, :null=>false
    t.column :calendar_date_id, :integer, :null=>false
    t.column :start_time, :time
    t.column :end_time, :time
    t.column :desc, :text
    t.column :long_desc, :text
    t.column :removed, :boolean, :null=>false, :default=>false
  end

  create_table :calendar_recurrences do |t|
    t.column :calendar_event_id, :integer, :null=>false
    t.column :weekday, :integer, :limit => 1
    t.column :monthweek, :integer, :limit => 1
    t.column :monthday, :integer, :limit => 1
    t.column :month, :integer, :limit => 1
  end

  monthly_and_yearly_where_sql = <<-END_SQL
    (
      ce.by_day_of_month = false 
      AND cr.weekday = cd.weekday
      AND (
        cr.monthweek = cd.monthweek
        OR (
          cr.monthweek = -1
          AND cd.lastweek = true
        )
      )
    ) OR (
      ce.by_day_of_month = true AND cr.monthday = cd.monthday
    )
  END_SQL 

  execute <<-END_SQL
    CREATE VIEW calendar_event_dates AS
    SELECT
      ce.id 
        AS calendar_event_id,
      cd.id 
        AS calendar_date_id,
      cd.value 
        AS date_value,
      COALESCE(cem.start_time, ce.start_time) 
        AS start_time,
      COALESCE(cem.end_time, ce.end_time) 
        AS end_time,
      COALESCE(cem.desc, ce.desc) 
        AS 'desc',
      COALESCE(cem.long_desc, ce.long_desc) 
        AS long_desc,
      cr.id IS NULL
        AS added,
      (cem.id IS NOT NULL AND cem.removed = true) 
        AS removed,
      (cem.id IS NOT NULL AND cem.removed = false AND
         (cem.start_time IS NOT NULL OR cem.end_time IS NOT NULL
          OR cem.desc IS NOT NULL OR cem.long_desc IS NOT NULL))
        AS modified
    FROM calendar_dates cd
    INNER JOIN calendar_events ce ON
      (ce.start_date IS NULL OR cd.value >= ce.start_date)
      AND (ce.end_date IS NULL OR cd.value <= ce.end_date)
    LEFT OUTER JOIN calendar_event_mods cem
      ON cem.calendar_event_id = ce.id
      AND cem.calendar_date_id = cd.id
    LEFT OUTER JOIN calendar_recurrences cr ON cr.calendar_event_id = ce.id
      AND ce.calendar_event_type_id IN (#{weekly_id},#{monthly_id},#{yearly_id})
    WHERE 
      (
        cd.id IS NOT NULL OR cem.id IS NOT NULL 
      ) AND (
        cem.id IS NOT NULL 
        OR (
          ce.calendar_event_type_id = #{norepeat_id} 
          AND ce.start_date = cd.value
        ) OR (
          ce.calendar_event_type_id = #{weekdays_id} AND cd.weekday in (1,2,3,4,5)
        ) OR (
          ce.calendar_event_type_id = #{daily_id}
        ) OR (
          ce.calendar_event_type_id = #{weekly_id} 
          AND cr.weekday = cd.weekday
        ) OR (
          ce.calendar_event_type_id = #{monthly_id}
          AND (
            #{monthly_and_yearly_where_sql}
          ) OR (
            ce.calendar_event_type_id = #{yearly_id}
            AND cd.month = cr.month 
            AND (
              #{monthly_and_yearly_where_sql}
            )
          )
        )
      );
  END_SQL
end
