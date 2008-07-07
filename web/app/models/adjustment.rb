class Adjustment < ActiveRecord::Base
  belongs_to :cook
  belongs_to :sensor
  belongs_to :blower  
  
  validates_presence_of :cook_id, :sensor_id
  validates_inclusion_of :alarm, :in => Sensor::ALARMS
  
  before_create :update_sensor
  
  def differences
    differences = {}

    last_adjustment = self.sensor.adjustments.find(:first, :conditions => ["created_at < ?", self.created_at], :order => "created_at DESC")
    
    [:target, :alarm, :low, :high, :blower].each do |setting|
      if last_adjustment
        if self.send(setting) != last_adjustment.send(setting)
          differences[setting] = {:old => last_adjustment.send(setting), :new => self.send(setting)}
        end
      else
        differences[setting] = {:old => "unknown", :new => self.send(setting)} unless self.send(setting) == nil
      end
    end

    differences
  end
  
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
