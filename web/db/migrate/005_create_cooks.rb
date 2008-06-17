class CreateCooks < ActiveRecord::Migration
  def self.up
    create_table :cooks do |t|
      t.string :name
      t.integer :stoker_id
      t.string :name
      t.text :description
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end

  def self.down
    drop_table :cooks
  end
end
