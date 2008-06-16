#!/usr/bin/env ruby -wKU

require "rubygems"
require "hpricot"
require "net/http"
require "open-uri"
require "net/telnet"
# include Net

class Stoker
  attr_accessor :host, :user, :pass, :http_port, :telnet_port
  
  attr_reader :telnet, :sensors, :blowers
  
  ALARMS = ["None", "Food", "Fire"]
  
  def initialize(host = nil, options = {})
    @host         = host
    @http_port    = options[:http_port]   || 80
    @telnet_port  = options[:telnet_port] || 23
    @user         = options[:user]        || "root"
    @pass         = options[:pass]        || "tini"
    @telnet       = nil
    @sensors      = []
    @blowers      = []
    
    find_sensors(options[:html])
  end
  
  def connect(txt = nil)
    @telnet = Net::Telnet.new("Host" => @host, "Port" => @telnet_port)
    @telnet.login(@user, @pass)
    # bbq -k
    # gc
    # bbq -t
  end
  
  def disconnect
    @telnet.close
  end
  
  def find_sensors(html = nil, attempt = 1)
    @sensors    = []
    @blowers    = []
    html      ||= open("http://#{@host}:#{@http_port}")
    contents    = html.read
    
    doc = Hpricot(contents)

    (doc/"td.ser_num/b[text() = 'Blower']:first/../../../tr").each do |row|
      unless (row/"td:first/b").size > 0
        blower      = Blower.new(self, row.at("td[1]").inner_html)
        blower.name = row.at("td[2]/input")['value'].strip
        @blowers << blower
      end
    end
    
    (doc/"td.ser_num/b[text() = 'Temp Sensor']:first/../../../tr").each do |row|
      unless (row/"td:first/b").size > 0
        sensor        = Sensor.new(self, row.at("td[1]").inner_html)
        sensor.name   = row.at("td[2]/input")['value'].strip
        sensor.temp   = row.at("td[3]").inner_html
        sensor.target = row.at("td[4]/input")['value'].strip
        # sensor.alarm  = row.at("td[5]/select/option[@selected='selected']").inner_html rescue "None"
        sensor.low    = row.at("td[6]/input")['value'].strip
        sensor.high   = row.at("td[7]/input")['value'].strip
        # sensor.blower = row.at("td[8]/select/option[@selected='selected']").inner_html rescue "None"
        @sensors << sensor
      end
    end
    
    if contents =~ /sel = \[(.*)\];$/
      blower_alarm_string = $1
    end
    
    count       = 0
    for_sensor  = 0
    blower_alarm_string.split(",").each do |val|
      case count
      when 0
        @sensors[for_sensor].alarm = Stoker::ALARMS[val.to_i]
        count += 1
      when 1
        @sensors[for_sensor].blower = val.gsub(/\"/,'')
        count = 0
        for_sensor += 1
      end
    end
    
  rescue Net::HTTPBadResponse
    if attempt > 4
      raise "Web page output corrupt.  Tried too many times, giving up."
    else
      attempt += 1
      puts "Warning: Web page output corrupt.  Retrying... attempt #{attempt}"
      find_sensors(html, attempt)
    end
  end
end

class Sensor
  attr_accessor :name, :serial_number, :temp, :target, :alarm, :low, :high, :blower

  attr_reader :stoker
  
  def initialize(stoker, serial_number, name = nil)
    @stoker         = stoker
    @serial_number  = serial_number
    @name           = name || serial_number
  end
  
  def name=(str)
    @name = str
    # TODO: update stoker
  end
  
  def blower=(blower_serial_number)
    @blower = @stoker.blowers.find{|b| b.serial_number == blower_serial_number}
    # TODO: update stoker
  end
end

class Blower
  attr_accessor :name, :serial_number

  attr_reader :stoker
  
  def initialize(stoker, serial_number, name = nil)
    @stoker         = stoker
    @serial_number  = serial_number
    @name           = name || serial_number
  end
  
  def name=(str)
    @name = str
    # TODO: update stoker
  end
  
  def sensor
    stoker.sensors.find{|s| s.blower.serial_number == self.serial_number}
  end
end

