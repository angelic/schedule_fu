# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120121220057) do

  create_table "calendar_dates", :force => true do |t|
    t.date    "value",                                     :null => false
    t.integer "weekday",   :limit => 1,                    :null => false
    t.integer "monthweek", :limit => 1,                    :null => false
    t.integer "monthday",  :limit => 1,                    :null => false
    t.integer "month",     :limit => 1,                    :null => false
    t.boolean "lastweek",               :default => false, :null => false
  end

  add_index "calendar_dates", ["value"], :name => "index_calendar_dates_on_value", :unique => true

  create_table "calendar_event_dates", :id => false, :force => true do |t|
    t.integer "calendar_event_id",                           :default => 0
    t.integer "calendar_date_id",                            :default => 0, :null => false
    t.integer "calendar_event_mod_id",                       :default => 0
    t.date    "date_value",                                                 :null => false
    t.time    "start_time"
    t.time    "end_time"
    t.text    "desc",                  :limit => 2147483647
    t.text    "long_desc",             :limit => 2147483647
    t.integer "added"
    t.integer "removed"
    t.integer "modified"
  end

  create_table "calendar_event_mods", :force => true do |t|
    t.integer "calendar_event_id",                    :null => false
    t.integer "calendar_date_id",                     :null => false
    t.time    "start_time"
    t.time    "end_time"
    t.text    "desc"
    t.text    "long_desc"
    t.boolean "removed",           :default => false, :null => false
  end

  add_index "calendar_event_mods", ["calendar_event_id", "calendar_date_id"], :name => "calendar_event_mods_for_event_and_date", :unique => true

  create_table "calendar_event_types", :force => true do |t|
    t.string "name"
    t.string "desc"
  end

  create_table "calendar_events", :force => true do |t|
    t.integer "calendar_id",                               :null => false
    t.integer "calendar_event_type_id"
    t.boolean "by_day_of_month",        :default => false, :null => false
    t.date    "start_date"
    t.date    "end_date"
    t.time    "start_time"
    t.time    "end_time"
    t.text    "desc"
    t.text    "long_desc"
  end

  create_table "calendar_recurrences", :force => true do |t|
    t.integer "calendar_event_id",              :null => false
    t.integer "weekday",           :limit => 1
    t.integer "monthweek",         :limit => 1
    t.integer "monthday",          :limit => 1
    t.integer "month",             :limit => 1
  end

  create_table "calendars", :force => true do |t|
    t.text "desc"
  end

end
