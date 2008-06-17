class Stoker < ActiveRecord::Base
  has_many :sensors
  has_many :blowers
  has_many :events
  
  validates_presence_of :host, :port, :name
  validates_uniqueness_of :name
  validates_uniqueness_of :host, :scope => :port
  
  def net
    @net ||= Net::Stoker.new(host, :http_port => port)
  end
end
