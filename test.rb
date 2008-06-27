#!/usr/bin/env ruby
# TODO: make this into a proper testing framework  :)

$TEST = false
$TEST_HTML = File.open("tests/test1.html")

require "lib/stoker"

stoker = Net::Stoker.new("10.1.1.8", :connection => "http")

puts "Getting data..."
stoker.get

# 530000112A584E30: Yellow
# 440000112A621E30: Pit Temp
# 0E0000112A5D1630: Blue
# 9C00001195DEE430: Red

# 140000002AA65105: Fan

puts "Listing blowers:"
stoker.blowers.each do |blower|
  puts "#{blower.serial_number}, #{blower.name}, #{blower.sensor.name rescue ''}"
end

puts "Listing sensors:"
stoker.sensors.each do |sensor|
  puts "#{sensor.serial_number}, #{sensor.name}, #{sensor.temp}, #{sensor.target}, #{sensor.alarm}, #{sensor.low}, #{sensor.high}, #{sensor.blower.name rescue ''}"
end

sensor = stoker.sensor("530000112A584E30")
res = sensor.update_attributes(:name => "Yellow Foo", :blower_serial_number => stoker.blower("140000002AA65105").serial_number)
puts res.to_s

# name = sensor.name
# serial_number = sensor.serial_number
# 
# puts "#{serial_number} was #{name} changing to Test"
# sensor.name = "Test"
# 
# puts "name is now #{sensor.name}"
# 
# puts "Getting data..."
# stoker.get
# 
# sensor = stoker.sensor(serial_number)
# puts "#{sensor.serial_number} is now #{sensor.name} changing back to #{name}"
# sensor.update_attributes :name => name
# 
# puts "name is now #{sensor.name}"
# 
# puts "Getting data..."
# stoker.get
# 
# sensor = stoker.sensor(serial_number)
# puts "#{sensor.serial_number} is now back to #{sensor.name}"

# 
# puts "Red: #{stoker.sensor("Red").temp}"
# puts "9C00001195DEE430: #{stoker.sensor("9C00001195DEE430").name}"
# puts "Pit Temp Blower: #{stoker.sensor("pit temp").blower.name}"
# 
# puts "Fan Sensor: #{stoker.blower("Fan").sensor.name}"
# puts "140000002AA65105: #{stoker.blower("140000002AA65105").name}"

# stoker.sensor("Red").update_attributes :name => "Rouge", :target => 123, :blower => stoker.blower("Fan")
# stoker.sensor("Red").update_attributes :name => "Rouge", :target => "100"

# stoker.sensor("Red").name = "Rouge"
# stoker.blower("Fan").name = "Blower"

# stoker.sensor("Pit Temp").target = 42
# stoker.sensor("Pit Temp").alarm = "none"

# stoker.sensor("Pit Temp").target = 100
# stoker.sensor("Pit Temp").alarm = "fire"
# stoker.sensor("Pit Temp").low = 90
# stoker.sensor("Pit Temp").high = 110

# puts
# 
# stoker.sensor("Red").blower = stoker.blower("Fan")
# 
# puts stoker.sensor("Pit Temp").blower_serial_number
# puts stoker.sensor("Red").blower_serial_number
# puts stoker.blower("Fan").sensor.name
# 
# puts
# 
# stoker.blower("Fan").sensor = stoker.sensor("Pit Temp")
# 
# puts stoker.sensor("Pit Temp").blower_serial_number
# puts stoker.sensor("Red").blower_serial_number
# puts stoker.blower("Fan").sensor.name

# ideas:

# puts stoker.meat_sensor.temp

# stoker.blower("main").on
# stoker.blower("main").off
# stoker.blower("main").on?

# stoker.meat_sensor.keep_warm # => when meat sensor approaches target, sets the target of fire sensor to target of meat sensor

# stoker.monitor(:frequency => 60) do |event|
#   puts "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}: #{event.name} - #{event.temp}"
# end
