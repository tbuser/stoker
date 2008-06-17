class Blower < ActiveRecord::Base
  belongs_to :stoker
  has_one :sensor
  
  validates_presence_of :serial_number, :name
  validates_uniqueness_of :name, :scope => :stoker_id, :unless => Proc.new {|b| b.stoker_id.to_s == ""}
end
