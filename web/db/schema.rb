# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080624192005) do

  create_table "adjustments", :force => true do |t|
    t.integer  "cook_id"
    t.integer  "sensor_id"
    t.integer  "target"
    t.string   "alarm"
    t.integer  "low"
    t.integer  "high"
    t.integer  "blower_id"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "adjustments", ["blower_id"], :name => "index_adjustments_on_blower_id"
  add_index "adjustments", ["sensor_id"], :name => "index_adjustments_on_sensor_id"
  add_index "adjustments", ["cook_id"], :name => "index_adjustments_on_cook_id"

  create_table "blowers", :force => true do |t|
    t.string   "serial_number"
    t.string   "name"
    t.integer  "stoker_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blowers", ["stoker_id"], :name => "index_blowers_on_stoker_id"
  add_index "blowers", ["name"], :name => "index_blowers_on_name"
  add_index "blowers", ["serial_number"], :name => "index_blowers_on_serial_number"

  create_table "cooks", :force => true do |t|
    t.string   "name"
    t.integer  "stoker_id"
    t.text     "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cooks", ["end_time"], :name => "index_cooks_on_end_time"
  add_index "cooks", ["start_time"], :name => "index_cooks_on_start_time"
  add_index "cooks", ["name"], :name => "index_cooks_on_name"
  add_index "cooks", ["stoker_id"], :name => "index_cooks_on_stoker_id"

  create_table "events", :force => true do |t|
    t.integer  "stoker_id"
    t.integer  "sensor_id"
    t.integer  "temp"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alarm",      :default => "None"
  end

  add_index "events", ["alarm"], :name => "index_events_on_alarm"
  add_index "events", ["created_at"], :name => "index_events_on_created_at"
  add_index "events", ["sensor_id"], :name => "index_events_on_sensor_id"
  add_index "events", ["stoker_id"], :name => "index_events_on_stoker_id"

  create_table "sensors", :force => true do |t|
    t.string   "serial_number"
    t.string   "name"
    t.integer  "target"
    t.string   "alarm",         :default => "None"
    t.integer  "low"
    t.integer  "high"
    t.integer  "blower_id"
    t.integer  "stoker_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sensors", ["alarm"], :name => "index_sensors_on_alarm"
  add_index "sensors", ["blower_id"], :name => "index_sensors_on_blower_id"
  add_index "sensors", ["stoker_id"], :name => "index_sensors_on_stoker_id"
  add_index "sensors", ["name"], :name => "index_sensors_on_name"
  add_index "sensors", ["serial_number"], :name => "index_sensors_on_serial_number"

  create_table "stokers", :force => true do |t|
    t.string   "host"
    t.integer  "port"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stokers", ["name"], :name => "index_stokers_on_name"

end
