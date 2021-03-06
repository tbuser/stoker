class Blower < ActiveRecord::Base
  belongs_to :stoker
  belongs_to :sensor
  
  has_many :adjustments
  
  validates_presence_of :serial_number, :name
  validates_uniqueness_of :name, :scope => :stoker_id, :unless => Proc.new {|b| b.stoker_id.to_s == ""}

  before_update :update_net_stoker

  def to_s
    self.name
  end

  def update_net_stoker
    if !Stoker.skip_update and (self.changed & ["name", "sensor_id"]).size > 0
      # spawn do
        begin
          params = {}
          
          ["name", "sensor_id"].each do |field|
            if self.changed.include?(field)
              if field == "sensor_id"
                if self.sensor_id.to_s == ""
                  params[:sensor_serial_number] = nil
                else
                  params[:sensor_serial_number] = self.sensor.serial_number
                end
              else
                params[field] = self.send(field)
              end
            end
          end
      
          self.stoker.net.blower(self.serial_number).update_attributes(params)
        rescue Exception => e
          raise "#{e.message}\n#{e.backtrace.to_yaml}"
        end
      # end
    end
  end

end
