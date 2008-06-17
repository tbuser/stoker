#!/usr/bin/env ruby
# TODO: make this into a proper testing framework  :)

TEST = false
TEST_HTML = File.open("tests/test1.html")
TEST_TELNET = File.open("tests/telnet.txt")

require "lib/stoker"

stoker = Stoker.new("10.1.1.8")

puts "Listing blowers:"
stoker.blowers.each do |blower|
  puts "#{blower.serial_number}, #{blower.name}, #{blower.sensor.name rescue ''}"
end

puts "Listing sensors:"
stoker.sensors.each do |sensor|
  puts "#{sensor.serial_number}, #{sensor.name}, #{sensor.temp}, #{sensor.target}, #{sensor.alarm}, #{sensor.low}, #{sensor.high}, #{sensor.blower.name rescue ''}"
end

puts "Red: #{stoker.sensor("Red").temp}"
puts "9C00001195DEE430: #{stoker.sensor("9C00001195DEE430").name}"
puts "Pit Temp Blower: #{stoker.sensor("pit temp").blower.name}"

puts "Fan Sensor: #{stoker.blower("Fan").sensor.name}"
puts "140000002AA65105: #{stoker.blower("140000002AA65105").name}"

stoker.sensor("Red").name = "Rouge"

# ideas:

# stoker.sensor("440000112A621E30").name = "meat"

# stoker.sensor("meat").alarm = "food"
# stoker.sensor("meat").low = 180 # => low and high is ignored if alarm = food, only used with fire
# stoker.sensor("meat").high = 220 # => low and high is ignored if alarm = food, only used with fire
# stoker.sensor("meat").target = 200

# stoker.blower("140000002AA65105").name = "main"

# puts stoker.meat_sensor.temp

# stoker.blower("main").on
# stoker.blower("main").off
# stoker.blower("main").on?

# stoker.meat_sensor.keep_warm # => when meat sensor approaches target, sets the target of fire sensor to target of meat sensor

# stoker.monitor(:frequency => 60) do |event|
#   puts "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}: #{event.name} - #{event.temp}"
# end
