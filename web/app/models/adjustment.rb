class Adjustment < ActiveRecord::Base
  belongs_to :cook
  belongs_to :sensor
  belongs_to :blower
  
  validates_presence_of :cook_id, :stoker_id, :sensor_id
  validates_inclusion_of :alarm, :in => Sensor::ALARMS
end
