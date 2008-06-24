class CreateAdjustments < ActiveRecord::Migration
  def self.up
    create_table :adjustments do |t|
      t.integer :cook_id
      t.integer :sensor_id
      t.integer :target
      t.string :alarm
      t.integer :low
      t.integer :high
      t.integer :blower_id
      t.text :note

      t.timestamps
    end
    
    add_index :adjustments, :cook_id
    add_index :adjustments, :sensor_id
    add_index :adjustments, :blower_id
  end

  def self.down
    drop_table :adjustments
    remove_index :adjustments, :cook_id
    remove_index :adjustments, :sensor_id
    remove_index :adjustments, :blower_id
  end
end
