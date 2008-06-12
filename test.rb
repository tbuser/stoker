#!/usr/bin/env ruby

require "lib/stoker"

stoker = Stoker.new("10.1.1.8", :html => File.open("tests/test1.html"))

puts "Listing sensors:"
stoker.sensors.each do |sensor|
  puts "#{sensor.serial_number}: #{sensor.name}"
end

puts "Listing blowers:"
stoker.blowers.each do |blower|
  puts "#{blower.serial_number}: #{blower.name}"
end

# ideas:

# stoker.sensor("440000112A621E30").name = "meat"

# stoker.sensor("meat").alarm = "food"
# stoker.sensor("meat").low = 180 # => low and high is ignored if alarm = food, only used with fire
# stoker.sensor("meat").high = 220 # => low and high is ignored if alarm = food, only used with fire
# stoker.sensor("meat").target = 200

# stoker.blower("140000002AA65105").name = "main"

# stoker.blower("main").control("meat")

# puts stoker.meat_sensor.temp

# stoker.blower("main").on
# stoker.blower("main").off
# stoker.blower("main").on?

# stoker.meat_sensor.keep_warm # => when meat sensor approaches target, sets the target of fire sensor to target of meat sensor

# stoker.monitor(:frequency => 60) do |event|
#   puts "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}: #{event.name} - #{event.temp}"
# end
