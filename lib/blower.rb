module Net
  class Blower
    attr_accessor :name, :serial_number, :sensor_serial_number, :sensor

    attr_reader :stoker

    FORM_PREFIXES = {
      "name"    => "n2",
      "sensor_serial_number" => "sw"
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
      if str.to_s == "" or str == "None"
        @stoker.post(@stoker.sensor(self.sensor.serial_number).form_variable("blower") => "None") rescue nil
        @sensor_serial_number = nil
      elsif @sensor_serial_number = @stoker.sensor(str).serial_number
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
      self.sensor_serial_number = s.serial_number rescue nil
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
      eval("@#{var.to_s} = val")
    end

    def update_attributes(params)
      variables = {}

      tp = params
      params = {}
      tp.each{|name,value| params[name.to_s] = value}

      params.each do |name, value|
        case name
        when "sensor"
          name = "sensor_serial_number"
          if value.to_s == ""
            value = "None"
          else
            value = value.serial_number
          end
        when "sensor_serial_number"
          if value.to_s == ""
            value = "None"
          end
        end

        if name == "sensor_serial_number"          
          # update internal state of any other sensors that have this blower
          @stoker.sensors.each do |s|
            s.change_without_update("blower_serial_number", nil) if s.blower_serial_number == self.serial_number
          end

          # set the specific sensor blower to myself
          if value != "None"
            @stoker.sensor(value).blower_serial_number = self.serial_number
          end          
        end
        
        variables[name] = value unless name == "serial_number"
      end

      # update internal state
      variables.each do |name, value|
        self.change_without_update(name, value)
      end
      
      params = {}
      variables.each do |name, value|
        if name == "sensor_serial_number" and value != "None"
          params[self.sensor.form_variable("blower_serial_number")] = self.serial_number
        else
          params[self.form_variable(name)] = value
        end
      end
      
      @stoker.post(params)
    end
    
    def to_s
      @name || @serial_number
    end
  end
end