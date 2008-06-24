class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :blowers, :serial_number
    add_index :blowers, :name
    add_index :blowers, :stoker_id

    add_index :cooks, :stoker_id
    add_index :cooks, :name
    add_index :cooks, :start_time
    add_index :cooks, :end_time
    
    add_index :events, :stoker_id
    add_index :events, :sensor_id
    add_index :events, :created_at
    add_index :events, :alarm

    add_index :sensors, :serial_number
    add_index :sensors, :name
    add_index :sensors, :stoker_id
    add_index :sensors, :blower_id
    add_index :sensors, :alarm

    add_index :stokers, :name
  end

  def self.down
    remove_index :blowers, :serial_number
    remove_index :blowers, :name
    remove_index :blowers, :stoker_id

    remove_index :cooks, :stoker_id
    remove_index :cooks, :name
    remove_index :cooks, :start_time
    remove_index :cooks, :end_time
    
    remove_index :events, :stoker_id
    remove_index :events, :sensor_id
    remove_index :events, :created_at
    remove_index :events, :alarm
    
    remove_index :sensors, :serial_number
    remove_index :sensors, :name
    remove_index :sensors, :stoker_id
    remove_index :sensors, :blower_id
    remove_index :sensors, :alarm

    remove_index :stokers, :name
  end
end
