class Cook < ActiveRecord::Base
  belongs_to :stoker

  has_many :sensors, :through => :stoker
  has_many :adjustments

  validates_presence_of :stoker_id, :name, :start_time
  after_create :add_initial_adjustments
  
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

  def events
    # FIXME: need a better way to associate specific sensors to a cook...
    # Event.find(:all,
    #   :conditions => ["stoker_id = ? AND sensor_id IN (?) AND (created_at >= ? AND created_at <= ?)", 
    #     self.stoker_id, self.sensors.collect{|s| s.id}, self.start_time, (self.end_time || Time.now)], 
    #   :order => "created_at"
    # )
    Event.find(:all,
      :conditions => ["created_at >= ? AND created_at <= ?", 
        self.start_time, (self.end_time || Time.now)], 
      :order => "created_at"
    )
  end

  def stop!
    Cook.transaction do
      self.sensors.each do |s|
        s.reset!
      end

      self.end_time = Time.now
      self.save!
    end
  end
  
  private
  
  def add_initial_adjustments
    Stoker.no_update do
      Cook.transaction do
        begin
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
