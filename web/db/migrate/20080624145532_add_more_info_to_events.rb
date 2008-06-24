class AddMoreInfoToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :alarm, :string, :default => "None"
    
    Event.find(:all, :include => :sensor, :conditions => "sensors.name IN ('Pit Temp','Yellow')").each do |e|
      e.alarm = "Fire"
      e.save
    end

    Event.find(:all, :include => :sensor, :conditions => "sensors.name IN ('Blue','Red')").each do |e|
      e.alarm = "Food"
      e.save
    end
  end

  def self.down
    remove_column :events, :alarm
  end
end
