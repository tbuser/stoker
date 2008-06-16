#!/usr/bin/env ruby -wKU

require "rubygems"
require "hpricot"
require "net/http"
require "cgi"
require "open-uri"
require "net/telnet"
include Net

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
    
    read_sensors
  end
  
  def connect
    @telnet = Net::Telnet.new("Host" => @host, "Port" => @telnet_port)
    @telnet.login(@user, @pass)
    # bbq -k
    # gc
    # bbq -t
  end
  
  def disconnect
    @telnet.close
  end
  
  def read_sensors(attempt = 1)
    @sensors    = []
    @blowers    = []
    html        = TEST_HTML if TEST
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
        @sensors[for_sensor].blower = val.gsub(/\"/,'') unless val == '""'
        count = 0
        for_sensor += 1
      end
    end
    
  rescue Net::HTTPBadResponse
    if attempt > 4
      raise "Web page output corrupt.  Tried too many times, giving up."
    else
      attempt += 1
      warn "Warning: Web page output corrupt.  Retrying... attempt #{attempt}"
      read_sensors(attempt)
    end
  end

  def sensor(str)
    str = str.downcase
    @sensors.find{|s| s.name.downcase == str or s.serial_number.downcase == str}
  end

  def blower(str)
    str = str.downcase
    @blowers.find{|b| b.name.downcase == str or b.serial_number.downcase == str}
  end
  
  def post(params = {})
    post_url = "http://#{@host}:#{@http_port}/stoker.Post_Handler"
    
    queries = []
    
    params.each do |k,v|
      queries << "#{k}=#{CGI::escape(v)}"
    end
    
    q = queries.join("&")

    if TEST
      warn "#{post_url}?#{q}"
    else
      response = HTTP.post_form URI.parse(post_url), {"q" => q}
    end
  end
end

class Sensor
  attr_accessor :name, :serial_number, :temp, :target, :alarm, :low, :high, :blower

  attr_reader :stoker

  FORM_PREFIXES = {
    "name"    => "n1",
    "alarm"   => "al",
    "target"  => "ta",
    "high"    => "th",
    "low"     => "tl",
    "blower"  => "sw"
  }
  
  def initialize(stoker, serial_number, name = nil)
    @stoker         = stoker
    @serial_number  = serial_number
    @name           = name || serial_number
  end
  
  def name=(str)
    @name = str
    @stoker.post(self.form_variable("name") => str)
  end
  
  def blower=(blower_serial_number)
    if @blower = @stoker.blowers.find{|b| b.serial_number.downcase == blower_serial_number.downcase}
      # TODO: update stoker
    else
      raise "Blower not found"
    end
  end
  
  def form_variable(type)
    "#{FORM_PREFIXES[type]}#{self.serial_number}"
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
  
  def sensor=(sensor_serial_number)
    if sensor = @stoker.sensors.find{|s| s.serial_number.downcase == sensor_serial_number}
      sensor.blower = self.serial_number
    else
      raise "Sensor not found"
    end
  end
  
  def sensor
    @stoker.sensors.find{|s| s.blower.serial_number.downcase == self.serial_number.downcase}
  end
end

