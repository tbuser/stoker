class AddSocketSupport < ActiveRecord::Migration
  def self.up
    add_column :stokers, :connection_type, :string
    add_column :stokers, :output_port, :integer
    add_column :stokers, :telnet_port, :integer
    
    Stoker.update_all("connection_type = 'http'")
  end

  def self.down
    remove_column :stokers, :connection_type
    remove_column :stokers, :output_port
    remove_column :stokers, :telnet_port
  end
end
