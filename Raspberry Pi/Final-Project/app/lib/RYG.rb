# ibeacon controller
require_relative 'ibeacon'
# config interface
require_relative 'config'
# traffic lights class
require_relative 'lights'

begin
  run = true
  Config.path("./config/config")
  @config = Config.get
  ibeacon = Ibeacon.new(@config)
  lights1 = Lights.new(4,5,6)
  lights2 = Lights.new(7,8,9)

  # make time of traffic lights logical : Rs = Gs + Ys
  traffic_time = {
    r_g: @config["Gs"].to_i,
    r_y: @config["Ys"].to_i
  }
  
  # let linux signal TERM turn to Interrupt
  Signal.trap("TERM"){
    puts "get a Terminate"
    raise Interrupt
  }
  puts "Ready"
  ibeacon.start
  loop {
    lights1.red
    lights2.green
    ibeacon.minor="01 02"
    puts "Lights1 : Red, Lights2 : Green"
    sleep(traffic_time[:r_g])

    lights1.red
    lights2.yellow
    ibeacon.minor="01 03"
    puts "Lights1 : Red, Lights2 : Yellow"
    sleep(traffic_time[:r_y])

    lights1.green
    lights2.red
    ibeacon.minor="02 01"
    puts "Lights1 : Green, Lights2 : Red"
    sleep(traffic_time[:r_g])

    lights1.yellow
    lights2.red
    ibeacon.minor="03 01"
    puts "Lights1 : Yellow, Lights2 : Red"
    sleep(traffic_time[:r_y])
  }
rescue Interrupt => e
  puts "ibeacon Interrupt"
  lights1.off
  lights2.off
  ibeacon.stop
rescue Errno::EPIPE
  puts "ibeacon didn't down"
ensure
  # Reset GPIO and ibeacon
  puts "RYG End"
end