class CreateSensors < ActiveRecord::Migration
  def self.up
    create_table :sensors do |t|
      t.string :serial_number
      t.string :name
      t.integer :target
      t.string :alarm, :default => "None"
      t.integer :low
      t.integer :high
      t.integer :blower_id
      t.integer :stoker_id

      t.timestamps
    end
  end

  def self.down
    drop_table :sensors
  end
end
