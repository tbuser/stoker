#!/usr/bin/env ruby -wKU

require "rubygems"
require "hpricot"
require "net/http"
# require "mechanize"
require "cgi"
require "open-uri"
require "net/telnet"

require File.join(File.dirname(__FILE__), 'sensor')
require File.join(File.dirname(__FILE__), 'blower')

class Float
  def to_fahrenheit
    (self * 9 / 5 + 32).round
  end
  
  def to_celsius
    (self - 32 * 5 / 9).round
  end
end

class Integer
  def to_fahrenheit
    self.to_f.to_fahrenheit
  end
  
  def to_celsius
    self.to_f.to_celsius
  end
end

module Net
  class Stoker
    attr_accessor :host, :port, :timeout, :connection, :telnet_port, :output_port, :user, :pass
  
    attr_reader :sensors, :blowers, :sensor_opts, :blower_opts, :socket, :output_socket, :telnet
  
    ALARMS = ["None", "Food", "Fire"]
  
    def initialize(host = nil, options = {})
      @host       = host
      @timeout    = options[:timeout] || 30
      @connection = options[:connection].to_s.downcase || "http"
      
      raise "Unknown connection type: #{@connection}" unless ["http", "socket"].include?(@connection)
      
      if options[:port]
        @port = options[:port]
      else
        case @connection
        when "http"
          @port = 80
        when "socket"
          @port = 44444
        else
          raise "No default port for connection type: #{@connection}"
        end
      end

      @output_port = options[:output_port]  || 55555
      @telnet_port = options[:telnet_port]  || 23
      @user        = options[:user]         || "root"
      @pass        = options[:pass]         || "tini"
      
      @sensors = []
      @blowers = []
      
      if @connection == "socket"
        # warn "Connecting to #{@host} on port #{@telnet_port}"
        # @telnet = Net::Telnet.new(
        #   "Host" => @host, 
        #   "Port" => @telnet_port,
        #   "Timeout" => @timeout, 
        #   "Prompt" => /tini091cbc \/> /
        # )
        # 
        # warn "Logging into telnet"
        # # @telnet.login(@user, @pass) {|c| print c}
        # @telnet.waitfor(/login:/)
        # @telnet.puts @user
        # @telnet.waitfor(/password:/)
        # @telnet.cmd @pass {|c| print c}
        
        # restart_bbq

        warn "Connecting to #{@host} on port #{@port}"
        @socket = Net::Telnet.new("Host" => @host, "Port" => @port, "Timeout" => @timeout, "Prompt" => /ok\:0/)
        @socket.cmd("op=#{@output_port}") {|c| print c}
        
        warn "Connecting to #{@host} on port #{@output_port}"
        @output_socket = Net::Telnet.new("Host" => @host, "Port" => @output_port, "Timeout" => @timeout)
      end
    end

    # For use with socket connection, this restarts the stoker's internal bbq process so that it will
    # stream the temp data to the output socket.
    def restart_bbq(state = "-t")
      warn "Killing bbq process"      
      response = @telnet.cmd("bbq -k") {|c| print c}
      raise "Failed to kill bbq process" unless response =~ /stkcmd: stop/ or response =~ /stkcmd: not started/
      
      warn "Collecting garbage on stoker"
      response = @telnet.cmd("gc") {|c| print c}
      
      until response =~ /stkcmd: start/
        warn "Starting bbq process"
        response = @telnet.cmd("bbq #{state}".strip) {|c| print c}
      end
      # raise "Failed to start bbq process" unless response =~ /stkcmd: start/
      sleep 5
    end
  
    def get
      self.send("get_#{@connection}")
    end

    def get_socket
      @sensors      = []
      @blowers      = []
      @sensor_opts  = []
      @blower_opts  = []

      response      = @socket.cmd("zx") {|c| print c}
      sensor_ids    = response[/^SensorID:(.*)BlowerID:.*$/, 1].split(/ /) rescue []
      blower_ids    = response[/BlowerID:(.*)$/, 1].split(/ /) rescue []

      blower_ids.each do |i|
        response = @socket.cmd("ge#{i}") {|c| print c}
        response =~ /^Name:(.*) Sensor:(.*)$/
        @blower_opts << {
          :serial_number  => i,
          :name           => $1.strip
        }
      end
      
      sensor_ids.each do |i|
        response = @socket.cmd("ge#{i}") {|c| print c}
        response =~ /^Name:(.*) Blower:(.*) Alarm Mode:(.*) Alarm Hi:(.*) Alarm Lo:(.*) Target:(.*)$/
        blower_serial_number = $2 == "null" ? nil : @blower_opts.find{|bo| bo[:name] == $2.strip}[:serial_number]
        @sensor_opts << {
          :serial_number        => i,
          :name                 => $1.strip,
          :blower_serial_number => blower_serial_number,
          :alarm                => $3,
          :high                 => $4.to_f.to_fahrenheit,
          :low                  => $5.to_f.to_fahrenheit,
          :target               => $6.to_f.to_fahrenheit
        }
      end

      @sensor_opts.size.times do
        line = @output_socket.readline
        # puts line
        parts = line.split(" ", 11)
        parts[0] = parts[0].chop
        @sensor_opts.find{|so| so[:serial_number] == parts[0]}[:temp] = parts[8].to_f.to_fahrenheit
      end

      @sensor_opts.each do |s|
        @sensors << Net::Sensor.new(self, s)
      end

      @blower_opts.each do |b|
        @blowers << Net::Blower.new(self, b)
      end
    end
  
    def get_http(attempt = 1)
      warn "Requesting http://#{@host}:#{@port}"

      @sensors    = []
      @blowers    = []
      html        = $TEST_HTML if $TEST
      html      ||= open("http://#{@host}:#{@port}")
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
          @sensor_opts[for_sensor][:alarm] = Net::Stoker::ALARMS[val.to_i]
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
        @sensors << Net::Sensor.new(self, s)
      end

      @blower_opts.each do |b|
        @blowers << Net::Blower.new(self, b)
      end

    rescue Net::HTTPBadResponse
      if attempt > 4
        raise "Web page output corrupt.  Tried too many times, giving up."
      else
        attempt += 1
        warn "Warning: Web page output corrupt.  Retrying... attempt #{attempt}"
        get_http(attempt)
      end
    end

    def post(params = {})
      self.send("post_#{@connection}", params)
    end
  
    def post_socket(params = {})
      queries = []

      params.each do |k,v|
        queries << "#{k}=#{CGI::escape(v.to_s)}"
      end

      q = queries.join("&")

      warn "Posting #{q}"

      @socket.cmd(q) {|c| print c}
    end
  
    def post_http(params = {})
      post_url = "http://#{@host}:#{@port}/stoker.Post_Handler"
    
      queries = []

      params.each do |k,v|
        queries << "#{k}=#{CGI::escape(v.to_s)}"
      end

      q = queries.join("&")

      warn "Posting #{post_url}?#{q}"

      # agent = WWW::Mechanize.new
      # agent.read_timeout = 120
      # page = agent.post(post_url, params)
      # puts page.body

      # res = HTTP.post_form(URI.parse(post_url), params)
      url = URI.parse(post_url)
      req = Net::HTTP::Post.new(url.path)
      # req["Keep-Alive"] = false
      # req["Keep-Alive"] = 300
      # req["Connection"] = "keep-alive"
      # req["Referer"] = "http://#{@host}:#{@port}/index.html"
      req.set_form_data(params)
      http = Net::HTTP.new(url.host, url.port)
      # http.read_timeout = 0
      res = http.start {|http| http.request(req)}
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        # puts res.body
        true
      else
        res.error!
      end
    rescue Exception => e
      warn e.message
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
      
    def to_s
      @name || @host
    end    
  end
end