class Cook < ActiveRecord::Base
  belongs_to :stoker

  validates_presence_of :stoker_id, :name, :start_time
  
  def running?
    self.start_time >= Time.now and self.end_time > Time.now
  end
end
