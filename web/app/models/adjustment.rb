class Adjustment < ActiveRecord::Base
  belongs_to :cook
  belongs_to :sensor
  belongs_to :blower  
  
  validates_presence_of :cook_id, :sensor_id
  validates_inclusion_of :alarm, :in => Sensor::ALARMS
  
  before_create :update_sensor
  
  private
  
  def update_sensor
    if self.sensor.update_attributes(
        :target => self.target,
        :alarm => self.alarm,
        :low => self.low,
        :high => self.high,
        :blower => self.blower)
      true
    else
      errors.add_to_base "Failed to update sensor"
      false
    end
  end
end
