require_relative "./ibeacon_config"

class Ibeacon 
  def start
    system "sudo hciconfig #{BLE_DEVICE} up"
    system "sudo hciconfig #{BLE_DEVICE} noleadv"
    system "sudo hciconfig #{BLE_DEVICE} noscan"
    system "sudo hciconfig #{BLE_DEVICE} leadv"
    system "sudo hcitool -i #{BLE_DEVICE} cmd 0x08 0x0008 1E 02 01 1A 1A FF 4C 00 02 15 #{UUID_FCU} #{MAJOR} #{MINOR} #{POWER} 00"
  end

  def stop
    system "sudo hciconfig #{BLE_DEVICE} noleadv"
  end

  def change(input)
    current_signal = ""

    case input
    when "R"
      current_signal = "00 01"
    when "Y"
      current_signal = "00 02"
    when "G"
      current_signal = "00 03"
    else
      current_signal = MINOR
    end

    system "sudo hcitool -i #{BLE_DEVICE} cmd 0x08 0x0008 1E 02 01 1A 1A FF 4C 00 02 15 #{UUID_FCU} #{MAJOR} #{current_signal} #{POWER} 00"
  end
end






