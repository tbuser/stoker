class Sensor < ActiveRecord::Base
  ALARMS = ["None", "Food", "Fire"]
  
  attr_accessor :blower_id
  attr_reader :update_blower
  
  belongs_to :stoker

  has_one :blower
  
  has_many :events
  has_many :adjustments
  
  validates_presence_of :serial_number, :name, :alarm
  validates_inclusion_of :alarm, :in => ALARMS
  validates_uniqueness_of :serial_number
  validates_uniqueness_of :name, :scope => :stoker_id, :unless => Proc.new {|s| s.stoker_id.to_s == ""}

  before_update :set_blower  
  before_update :update_net_stoker
  
  def blower_id
    self.blower.id rescue nil
  end
    
  def temp
    self.events.find(:first, :order => "created_at DESC").temp rescue nil
  end

  def update_net_stoker
    if !Stoker.skip_update and ((self.changed & ["name", "target", "alarm", "high", "low", "blower_id"]).size > 0 or @update_blower)
      # spawn do
        begin      
          params = {}

          ["name", "target", "alarm", "high", "low", "blower_id"].each do |field|
            if self.changed.include?(field) or (field == "blower_id" and @update_blower)
              if field == "blower_id"
                if @blower_id.to_s == ""
                  params[:blower_serial_number] = nil
                else
                  params[:blower_serial_number] = Blower.find(@blower_id).serial_number
                end
              else
                params[field] = self.send(field)
              end
            end
          end
          
          self.stoker.net.sensor(self.serial_number).update_attributes(params)
        rescue Exception => e
          raise "#{e.message}\n#{e.backtrace.to_yaml}"
        end          
      # end
    end
  end

  def alarm_status
    alarm_status = "black"
    
    if ["fire","food"].include?(self.alarm.downcase)
      alarm_status = case self.temp
      when 0..self.low
        "green"
      when self.low..self.high-1
        "yellow"
      else
        "red"
      end
    end
    
    alarm_status
  end

  private
  
  def set_blower
    Stoker.no_update do
      if @blower_id.to_s != ""
        b = Blower.find(@blower_id)
        b.sensor_id = self.id
        b.save!
        @update_blower = true
      else
        if b = Blower.find_by_sensor_id(self.id)
          b.sensor_id = nil
          b.save!
          @update_blower = true
        end
      end
    end
    true
  end
  
end
