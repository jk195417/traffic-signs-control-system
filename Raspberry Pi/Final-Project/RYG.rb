# Ruby GPIO lib
require 'pi_piper'
include PiPiper
# ibeacon controller
require_relative "./ibeacon"

ibeacon = Ibeacon.new
run = true
Rs = 10
Ys = 2
Gs = 10
red_led = PiPiper::Pin.new(:pin => 4, :direction => :out)
yellow_led = PiPiper::Pin.new(:pin => 5, :direction => :out)
green_led = PiPiper::Pin.new(:pin => 6, :direction => :out)

# Enter "exit" to interrupt loop
thr = Thread.new{
  input = ""
  while run
    input = gets.chomp
    input == "exit" ? run = false : run = true
  end
}

# Init ibeacon
puts "準備就緒"
ibeacon.start

while run
  # Red LED
  red_led.on
  yellow_led.off
  green_led.off
  ibeacon.change("R")
  puts "紅燈"
  sleep(Rs)

  # Green LED
  red_led.off
  yellow_led.off
  green_led.on
  ibeacon.change("G")
  puts "綠燈"
  sleep(Gs)

  # Yellow LED
  red_led.off
  yellow_led.on
  green_led.off
  ibeacon.change("Y")
  puts "黃燈"
  sleep(Ys)
end
thr.join
# Reset GPIO and ibeacon
red_led.off
yellow_led.off
green_led.off
ibeacon.stop
puts "結束"

