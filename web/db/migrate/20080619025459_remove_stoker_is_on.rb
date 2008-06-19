class RemoveStokerIsOn < ActiveRecord::Migration
  def self.up
    remove_column :stokers, :is_on
  end

  def self.down
    add_column :stokers, :is_on, :boolean, :default => false
  end
end
