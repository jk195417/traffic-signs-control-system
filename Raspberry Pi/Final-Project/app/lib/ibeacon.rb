class Ibeacon
  def initialize(config)
    @config = {}
    @ble_devise = ""
    @uuid = ""
    @major = ""
    @minor = ""
    @power = ""
    setting(config)
    # puts "ble_devise:#{@ble_devise}"
    # puts "uuid:#{@uuid}"
    # puts "major:#{@major}"
    # puts "minor:#{@minor}"
    # puts "power:#{@power}"
    # puts "config:#{@config}"
  end
  def start
    `sudo hciconfig #{@ble_devise} up`
    stop
    `sudo hciconfig #{@ble_devise} noscan`
    `sudo hciconfig #{@ble_devise} leadv`
    broadcast
  end
  def stop
    `sudo hciconfig #{@ble_devise} noleadv`
  end
  def minor=(input)
    @minor = input
    broadcast
  end
  def setting(conf)
    conf.delete_if {|key, value| value == ""}
    # puts "config:#{conf}"
    @config.merge!(conf)
    variables = []
    self.instance_variables.each { |e| variables << e[1..-1] }
    @config.delete_if {|key, value| !variables.include?(key)}
    @ble_devise = @config["ble_devise"]
    @uuid = @config["uuid"]
    @major = @config["major"]
    @minor = @config["minor"]
    @power = @config["power"]
  end
  def broadcast
    `sudo hcitool -i #{@ble_devise} cmd 0x08 0x0008 1E 02 01 1A 1A FF 4C 00 02 15 #{@uuid} #{@major} #{@minor} #{@power} 00`
  end
end