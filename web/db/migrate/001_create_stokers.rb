class CreateStokers < ActiveRecord::Migration
  def self.up
    create_table :stokers do |t|
      t.string :host
      t.integer :port
      t.string :name
      t.boolean :is_on, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :stokers
  end
end
