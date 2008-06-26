module Net
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
      if @sensor_serial_number = @stoker.sensor(str).serial_number
        @stoker.blowers.each do |b|
          if b.sensor_serial_number == @sensor_serial_number
            s.change_without_update("blower_serial_number", nil) unless b == self
          end
        end
        self.sensor.blower = self
        # setting sensor blower will cause an update of stoker
      else
        raise "Sensor not found"
      end
    end

    def sensor=(s)
      self.sensor_serial_number = s.serial_number
    end

    def sensor
      raise "Blower not associated with a sensor" if self.sensor_serial_number.nil?
      @stoker.sensor(self.sensor_serial_number)
    end

    def form_variable(type)
      "#{FORM_PREFIXES[type]}#{self.serial_number}"
    end

    # updates internal state of object variable without posting an update to the stoker
    def change_without_update(var, val)
      eval("@#{var} = val")
    end

    def update_attributes(params)
      variables = {}
      params.each do |k,v|
        if k.to_s == "sensor"
          k = v.form_variable("blower")
          v = self.serial_number
        else
          k = self.form_variable(k.to_s)
        end
        variables[k] = v unless k.to_s == "serial_number"
        
        if k.to_s == "sensor"
          @stoker.blowers.each do |b|
            if b.sensor_serial_number == v
              b.change_without_update("sensor_serial_number", nil) unless b == self
            end
          end
          self.change_without_update("sensor_serial_number", v)
        else
          self.change_without_update(k, v)
        end
      end
      @stoker.post(variables)
    end
  end
end