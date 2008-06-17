class Blower
  attr_accessor :name, :serial_number, :sensor_serial_number, :sensor

  attr_reader :stoker
  
  FORM_PREFIXES = {
    "name"    => "n2"
  }
  
  def initialize(stoker, options = {})
    @stoker         = stoker
    options.each do |k,v|
      eval("@#{k} = options[:#{k}]")
    end
  end
  
  def name=(str)
    @name = str
    @stoker.post(self.form_variable("name") => str)
  end
  
  def sensor_serial_number=(str)
    if @sensor_serial_number = @stoker.sensor(str)
      self.sensor.blower = self
      # setting sensor blower will cause an update of stoker
    else
      raise "Sensor not found"
    end
  end
  
  def sensor=(s)
    @sensor_serial_number = s.serial_number
    self.sensor.blower = self
    # setting sensor blower will cause an update of stoker
  end
  
  def sensor
    @stoker.sensor(self.sensor_serial_number)
  end
  
  def form_variable(type)
    "#{FORM_PREFIXES[type]}#{self.serial_number}"
  end
end
