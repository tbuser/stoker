module Net
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

    def form_variable(type)
      "#{FORM_PREFIXES[type]}#{self.serial_number}"
    end

    def name=(str)
      @name = str
      @stoker.post(self.form_variable("name") => str)
    end

    def target=(num)
      @target = num.to_i
      @stoker.post(self.form_variable("target") => num.to_i)
    end

    def alarm=(str)
      if alarm_id = Net::Stoker::ALARMS.index(str.capitalize)
        @alarm = str.capitalize
        @stoker.post(self.form_variable("alarm") => alarm_id)
      else
        raise "Invalid alarm #{str}"
      end
    end

    def low=(num)
      if @alarm == "Fire"
        @low = num.to_i
        @stoker.post(self.form_variable("low") => num.to_i)
      else
        raise "You can only set low temp target when alarm is set to Fire"
      end
    end

    def high=(num)
      if @alarm == "Fire"
        @high = num.to_i
        @stoker.post(self.form_variable("high") => num.to_i)
      else
        raise "You can only set high temp target when alarm is set to Fire"
      end
    end

    def blower_serial_number=(str)
      if @blower_serial_number = @stoker.blower(str).serial_number
        self.blower.change_without_update("sensor_serial_number", @serial_number)
        @stoker.sensors.each do |s|
          if s.blower_serial_number == @blower_serial_number
            s.change_without_update("blower_serial_number", nil) unless s == self
          end
        end
        @stoker.post(self.form_variable("blower") => @blower_serial_number)
      else
        raise "Blower not found"
      end
    end

    def blower=(b)
      self.blower_serial_number = b.serial_number
    end

    def blower
      raise "Sensor not associated with a blower" if self.blower_serial_number.nil?
      @stoker.blower(self.blower_serial_number)
    end

    # updates internal state of object variable without posting an update to the stoker
    def change_without_update(var, val)
      eval("@#{var} = val")
    end
    
    def update_attributes(params)
      variables = {}
      params.each do |k,v|
        if k.to_s == "blower"
          v = v.serial_number
        end
        variables[self.form_variable(k.to_s)] = v unless k.to_s == "serial_number"
        
        if k.to_s == "blower"
          @stoker.sensors.each do |s|
            if s.blower_serial_number == v
              s.change_without_update("blower_serial_number", nil) unless s == self
            end
          end
          self.change_without_update("blower_serial_number", v)
        else
          self.change_without_update(k, v)
        end
      end
      @stoker.post(variables)
    end
  end
end