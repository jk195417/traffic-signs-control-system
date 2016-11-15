# Ruby GPIO lib
require 'pi_piper'
include PiPiper
# ibeacon controller
require_relative 'ibeacon'
# config interface
require_relative 'config'

run = true
Config.path("./config/config")
@config = Config.get
ibeacon = Ibeacon.new(@config)
Rs = @config["Rs"].to_i
Ys = @config["Ys"].to_i
Gs = @config["Gs"].to_i
red_led = PiPiper::Pin.new(:pin => 4, :direction => :out)
yellow_led = PiPiper::Pin.new(:pin => 5, :direction => :out)
green_led = PiPiper::Pin.new(:pin => 6, :direction => :out)

begin
  # Init ibeacon
  puts "Ready"
  ibeacon.start

  loop {
    # Red LED
    red_led.on
    yellow_led.off
    green_led.off
    ibeacon.minor="00 01"
    puts "Red"
    sleep(Rs)

    # Green LED
    red_led.off
    yellow_led.off
    green_led.on
    ibeacon.minor="00 03"
    puts "Green"
    sleep(Gs)

    # Yellow LED
    red_led.off
    yellow_led.on
    green_led.off
    ibeacon.minor="00 02"
    puts "Yellow"
    sleep(Ys)
  }
rescue Interrupt => e
  puts "ibeacon Interrupt"
  red_led.off
  yellow_led.off
  green_led.off
  ibeacon.stop
rescue Errno::EPIPE
  puts "ibeacon doen"
ensure
  # Reset GPIO and ibeacon
  puts "RYG End"
end


