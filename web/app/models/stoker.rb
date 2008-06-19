class Stoker < ActiveRecord::Base
  has_many :sensors
  has_many :blowers
  has_many :events
  
  validates_presence_of :host, :port, :name
  validates_uniqueness_of :name
  validates_uniqueness_of :host, :scope => :port

  def self.do_update
    @do_update ||= true
  end

  def self.no_update
    @do_update = false
    yield
    @do_update = true
  end
  
  def net
    @net ||= Net::Stoker.new(host, :http_port => port)
  end
  
  def sync!
    Stoker.transaction do

      self.blowers.clear
      self.sensors.clear
      self.save!
      
      net_stoker = self.net
      net_stoker.read_sensors

      Stoker.no_update do
        net_stoker.blowers.each do |nb|
          if blower = Blower.find_or_create_by_serial_number(nb.serial_number)
            blower.update_attributes!(
              :name   => nb.name,
              :stoker => self
            )
          else
            raise "Failed to find or create blower #{nb.serial_number}"
          end
        end

        net_stoker.sensors.each do |ns|
          if sensor = Sensor.find_or_create_by_serial_number(ns.serial_number)
            sensor.update_attributes!(
              :name   => ns.name,
              :target => ns.target,
              :alarm  => ns.alarm,
              :low    => ns.low,
              :high   => ns.high,
              :stoker => self
            )

            if ns.blower_serial_number.to_s != ""
              sensor.blower = Blower.find_by_serial_number(ns.blower_serial_number)
              sensor.save!
            end
        
            Event.create!(
              :stoker => self,
              :sensor => sensor,
              :temp   => ns.temp
            )
          else
            raise "Failed to find or create sensor #{ns.serial_number}"
          end
        end
      end

    end
  end
  
  def status
    if self.events.find(:first, :conditions => ["created_at >= ?", Time.now - 2.minutes])
      "Running"
    else
      "Stopped"
    end
  end
end
