class Sensor < ActiveRecord::Base
  ALARMS = ["None", "Food", "Fire"]
  
  belongs_to :stoker
  belongs_to :blower
  
  has_many :events
  
  validates_presence_of :serial_number, :name, :alarm
  validates_inclusion_of :alarm, :in => ALARMS
  validates_uniqueness_of :serial_number
  validates_uniqueness_of :name, :scope => :stoker_id, :unless => Proc.new {|s| s.stoker_id.to_s == ""}
  
  after_update :update_net_stoker
  
  def temp
    self.events.find(:first, :order => "created_at DESC").temp rescue nil
  end

  def update_net_stoker
    if Stoker.do_update and (self.changed & ["name", "target", "alarm", "high", "low", "blower_id"]).size > 0
      warn ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> #{Stoker.do_update}"
      spawn do
        begin
          self.stoker.net.read_sensors
      
          params = {}
          
          ["name", "target", "alarm", "high", "low", "blower_id"].each do |field|
            if self.changed.include?(field)
              if field == "blower_id"
                if self.blower_id.to_s == ""
                  params[:blower] = nil
                else
                  params[:blower] = self.stoker.net.blower(self.blower.serial_number)
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
      end
    end
  end
  
end
