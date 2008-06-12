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

# stoker.sensor("meat").low = 180
# stoker.sensor("meat").high = 220
# stoker.sensor("meat").target = 200
# stoker.sensor("meat").alarm = "food"

# stoker.blower("140000002AA65105").name = "main"

# stoker.blower("main").control("meat")

# puts stoker.meat_sensor.temp

# stoker.blower("main").on
# stoker.blower("main").off
# stoker.blower("main").on?

# stoker.monitor(:frequency => 60) do |event|
#   puts "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}: #{event.name} - #{event.temp}"
# end
