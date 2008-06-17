class Sensor
  attr_accessor :name, :serial_number, :temp, :target, :alarm, :low, :high, :blower_serial_number, :blower

  attr_reader :stoker

  FORM_PREFIXES = {
    "name"    => "n1",
    "alarm"   => "al",
    "target"  => "ta",
    "high"    => "th",
    "low"     => "tl",
    "blower"  => "sw"
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

  def blower_serial_number=(str)
    if @blower_serial_number = @stoker.blower(str)
      # TODO: update stoker
    else
      raise "Blower not found"
    end
  end
  
  def blower=(b)
    @blower_serial_number = b.serial_number
    # TODO: update stoker
  end
  
  def blower
    @stoker.blower(self.blower_serial_number)
  end
  
  def form_variable(type)
    "#{FORM_PREFIXES[type]}#{self.serial_number}"
  end
end
