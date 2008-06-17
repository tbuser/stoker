#!/usr/bin/env ruby -wKU

require "rubygems"
require "hpricot"
require "net/http"
require "cgi"
require "open-uri"
require "net/telnet"

module Net
  class Stoker
    
    require File.join(File.dirname(__FILE__), 'sensor')
    require File.join(File.dirname(__FILE__), 'blower')
  
    attr_accessor :host, :user, :pass, :http_port, :telnet_port
  
    attr_reader :telnet, :sensors, :blowers, :sensor_opts, :blower_opts
  
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
    
      # read_sensors
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
      html        = $TEST_HTML if $TEST
      html      ||= open("http://#{@host}:#{@http_port}")
      contents    = html.read
      @sensor_opts = []
      @blower_opts = []
    
      doc = Hpricot(contents)

      (doc/"td.ser_num/b[text() = 'Blower']:first/../../../tr").each do |row|
        unless (row/"td:first/b").size > 0
          @blower_opts << {
            :serial_number  => row.at("td[1]").inner_html,
            :name           => row.at("td[2]/input")['value'].strip
          }
        end
      end
    
      (doc/"td.ser_num/b[text() = 'Temp Sensor']:first/../../../tr").each do |row|
        unless (row/"td:first/b").size > 0
          @sensor_opts << {
            :serial_number  => row.at("td[1]").inner_html,
            :name           => row.at("td[2]/input")['value'].strip,
            :temp           => row.at("td[3]").inner_html,
            :target         => row.at("td[4]/input")['value'].strip,
            :low            => row.at("td[6]/input")['value'].strip,
            :high           => row.at("td[7]/input")['value'].strip
          }
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
          @sensor_opts[for_sensor][:alarm] = Stoker::ALARMS[val.to_i]
          count += 1
        when 1
          @sensor_opts[for_sensor][:blower_serial_number] = val.gsub(/\"/,'') unless val == '""'
          count = 0
          for_sensor += 1
        end
      end

      @sensor_opts.each do |s|
        if s[:blower_serial_number].to_s != ""
          @blower_opts.each do |b|
            if b[:serial_number] == s[:blower_serial_number]
              b[:sensor_serial_number] = s[:serial_number]
            end
          end
        end
      end

      @sensor_opts.each do |s|
        @sensors << Sensor.new(self, s)
      end

      @blower_opts.each do |b|
        @blowers << Blower.new(self, b)
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
      raise "Sensor not specified" if str.nil?
      str = str.downcase
      @sensors.find{|s| s.name.downcase == str or s.serial_number.downcase == str}
    end

    def blower(str)
      raise "Blower not specified" if str.nil?
      str = str.downcase
      @blowers.find{|b| b.name.downcase == str or b.serial_number.downcase == str}
    end
  
    def post(params = {})
      post_url = "http://#{@host}:#{@http_port}/stoker.Post_Handler"
    
      queries = []

      if $TEST
        params.each do |k,v|
          queries << "#{k}=#{CGI::escape(v)}"
        end

        q = queries.join("&")

        warn "#{post_url}?#{q}"
      else
        # stoker http doesn't like keep alive, so have to do post request the long way
        # res = HTTP.post_form(URI.parse(post_url), params)
        url = URI.parse(post_url)
        req = Net::HTTP::Post.new(url.path)
        req["Keep-Alive"] = false
        req.set_form_data(params)
        res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
        case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          # puts res.body
          true
        else
          res.error!
        end
      end
    end
  end
end