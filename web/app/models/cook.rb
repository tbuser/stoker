class Cook < ActiveRecord::Base
  belongs_to :stoker
  
  validates_presence_of :stoker_id, :name, :start_time
end
