class Event < ActiveRecord::Base
  belongs_to :stoker
  belongs_to :sensor
  
  validates_presence_of :stoker_id, :sensor_id, :temp
end
