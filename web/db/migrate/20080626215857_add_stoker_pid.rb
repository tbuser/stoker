class AddStokerPid < ActiveRecord::Migration
  def self.up
    add_column :stokers, :pid, :integer
  end

  def self.down
    remove_column :stokers, :pid
  end
end
