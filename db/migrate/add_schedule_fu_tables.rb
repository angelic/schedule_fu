class AddScheduleFuTables < ActiveRecord::Migration
  def self.up
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
      t.column :lastweek, :integer, :limit => 1, :null=>false, :default=>0
      t.column :holiday, :boolean, :null=>false, :default=>false
    end
    add_index :calendar_dates, :value, :unique => true
 
    create_table :calendar_events do |t|
      t.column :calendar_id, :integer, :null=>false
      t.column :start_date, :date
      t.column :end_date, :date
      t.column :start_time, :time
      t.column :end_time, :time
      t.column :desc, :text
      t.column :long_desc, :text
    end
 
    create_table :calendar_occurrences, :id => false do |t|
      t.column :calendar_event_id, :integer, :null=>false
      t.column :calendar_date_id, :integer, :null=>false
    end
 
    create_table :calendar_recurrences do |t|
      t.column :calendar_event_id, :integer, :null=>false
      t.column :weekday, :integer, :limit => 1
      t.column :monthweek, :integer, :limit => 1
      t.column :monthday, :integer, :limit => 1
      t.column :month, :integer, :limit => 1
    end
 
    # FIXME - quote embedded holiday parameter
    execute "
CREATE VIEW calendar_event_dates AS
SELECT
  ce.id AS calendar_event_id,
  cd.id AS calendar_date_id
FROM calendar_dates cd
INNER JOIN calendar_events ce ON cd.holiday = 'f' 
  AND (ce.start_date IS NULL OR cd.value >= ce.start_date)
  AND (ce.end_date IS NULL OR cd.value <= ce.end_date)
LEFT OUTER JOIN calendar_occurrences co
  ON co.calendar_event_id = ce.id
  AND co.calendar_date_id = cd.id
LEFT OUTER JOIN calendar_recurrences cr ON cr.calendar_event_id = ce.id
  AND (cr.month IS NULL OR cr.month = cd.month)
  AND ((cr.monthday IS NOT NULL AND cd.monthday = cr.monthday)
  OR (cr.monthday is NULL AND cr.weekday IS NULL)
  OR (cr.monthday IS NULL AND cr.weekday IS NOT NULL
    AND cd.weekday = cr.weekday
    AND (cr.monthweek IS NULL OR cd.monthweek = cr.monthweek 
    OR (cr.monthweek = -1 AND cd.lastweek = -1))
)
)
WHERE cr.id IS NOT NULL OR co.calendar_event_id IS NOT NULL
"
  end
 
  def self.down
    execute "DROP VIEW calendar_event_dates"
    drop_table :calendar_recurrences
    drop_table :calendar_occurrences
    drop_table :calendar_events
    remove_index :calendar_dates, :value
    drop_table :calendar_dates
    drop_table :calendars
  end
end
