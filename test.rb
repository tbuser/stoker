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

