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
    @sensors    = []
    @blowers    = []
    
    doc = Hpricot(html || open("http://#{@host}:#{@http_port}"))

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
        sensor.alarm  = row.at("td[5]/select/option[@selected='selected']").inner_html rescue "None"
        sensor.low    = row.at("td[6]/input")['value'].strip
        sensor.high   = row.at("td[7]/input")['value'].strip
        sensor.blower = row.at("td[8]/select/option[@selected='selected']").inner_html rescue "None"
        @sensors << sensor
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
    @name = str
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
end

