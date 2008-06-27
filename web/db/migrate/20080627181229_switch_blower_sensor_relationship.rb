class SwitchBlowerSensorRelationship < ActiveRecord::Migration
  def self.up
    remove_column :sensors, :blower_id
    add_column :blowers, :sensor_id, :integer
  end

  def self.down
    add_column :sensors, :blower_id, :integer
    remove_column :blowers, :sensor_id
  end
end
