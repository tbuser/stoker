class Cook < ActiveRecord::Base
  belongs_to :stoker

  has_many :sensors, :through => :stoker
  has_many :adjustments

  validates_presence_of :stoker_id, :name, :start_time
  before_create :add_initial_adjustments
  
  def self.active
    find(:all, :conditions => ["start_time <= ? AND (end_time >= ? OR end_time IS NULL)", Time.now, Time.now])
  end
  
  def running?
    (self.start_time <= Time.now) && ((self.end_time.to_s == "") || (self.end_time > Time.now))
  end
  
  def status
    case true
    when self.running?
      "Running"
    when self.start_time > Time.now
      "Not Started"
    when self.end_time.to_s != ""
      if self.end_time <= Time.now
        "Finished"
      else
        "Unknown"
      end
    else
      "Unknown"
    end
  end
  
  def sensors
    if self.running?
      self.stoker.sensors
    else
      []
    end
  end
  
  private
  
  def add_initial_adjustments
    Stoker.no_update do
      Cook.transaction do
        begin
          puts "--------------> #{self.sensors.size}"
          self.sensors.each do |sensor|
            adjustment = self.adjustments.build(
              :sensor_id  => sensor.id,
              :alarm      => sensor.alarm,
              :low        => sensor.low,
              :high       => sensor.high,
              :target     => sensor.target,
              :note       => "Starting Cook"
            )
            adjustment.save!
          end
          true
        rescue Exception => e
          errors.add_to_base "Failed to create initial adjustments #{e.message}"
          false
        end
      end
    end
  end
  
end
