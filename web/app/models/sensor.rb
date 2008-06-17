class Sensor < ActiveRecord::Base
  ALARMS = ["None", "Food", "Fire"]
  
  belongs_to :stoker
  belongs_to :blower
  
  has_many :events
  
  validates_presence_of :serial_number, :name, :alarm
  validates_inclusion_of :alarm, :in => ALARMS
  validates_uniqueness_of :serial_number
  validates_uniqueness_of :name, :scope => :stoker_id, :unless => Proc.new {|s| s.stoker_id.to_s == ""}
end
