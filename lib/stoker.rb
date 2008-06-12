#!/usr/bin/env ruby -wKU

require "rubygems"
require "hpricot"
require "open-uri"
require "net/telnet"
include Net

class Stoker
  attr_accessor :host, :user, :pass, :http_port, :telnet_port
  
  attr_reader :telnet, :sensors, :blowers
  
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
    @telnet = Telnet.new("Host" => @host, "Port" => @telnet_port)
    @telnet.login(@user, @pass)
    # bbq -k
    # gc
    # bbq -t
  end
  
  def disconnect
    @telnet.close
  end
  
  def find_sensors(html = nil)
    @sensors  = []
    @blowers  = []
    doing     = ""
    
    doc = Hpricot(html || open("http://#{@host}:#{@http_port}"))

    (doc/"td.ser_num").each do |td|
      ["Blower", "Temp Sensor"].each do |which|
        doing = which if td.to_s.include?(which)
      end
      
      unless td.inner_html.include?("<b>")
        
        case doing
        when "Blower"
          @blowers << Blower.new(@stoker, td.inner_html)
        when "Temp Sensor"
          @sensors << Sensor.new(@stoker, td.inner_html)
        end
      end
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
    
  end
end

