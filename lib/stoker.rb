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
    type        = ""
    processing  = nil
    get_next    = 0
    doing_cell  = 0
    on_header   = false
    
    doc = Hpricot(html || open("http://#{@host}:#{@http_port}"))

    # (doc/"td.ser_num/..").each do |row|
    # (doc/"td.ser_num/b[text() = 'Blower']:first/../..").each do |row|
    (doc/"td.ser_num/b[text() = 'Temp Sensor']:first/../../../tr").each do |row|
      unless (row/"td:first/b").size > 0
        puts "--------------"
        puts row.at("td[1]").inner_html
        puts row.at("td[2]/input")['value'].strip
        puts row.at("td[3]").inner_html
        puts row.at("td[4]/input")['value'].strip
        puts row.at("td[5]/select").inspect
        puts row.at("td[6]/input")['value'].strip
        puts row.at("td[7]/input")['value'].strip
        puts row.at("td[8]/select").inspect
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

