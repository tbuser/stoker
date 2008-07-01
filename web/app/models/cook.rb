class Cook < ActiveRecord::Base
  belongs_to :stoker

  has_many :adjustments

  validates_presence_of :stoker_id, :name, :start_time
  
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
end
