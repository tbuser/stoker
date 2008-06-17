# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 5) do

  create_table "blowers", :force => true do |t|
    t.string   "serial_number"
    t.string   "name"
    t.integer  "stoker_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cooks", :force => true do |t|
    t.string   "name"
    t.integer  "stoker_id"
    t.text     "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.integer  "stoker_id"
    t.integer  "sensor_id"
    t.integer  "temp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "stokers", :force => true do |t|
    t.string   "host"
    t.integer  "port"
    t.string   "name"
    t.boolean  "is_on",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
