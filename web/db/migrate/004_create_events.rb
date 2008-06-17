class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :stoker_id
      t.integer :sensor_id
      t.integer :temp

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
