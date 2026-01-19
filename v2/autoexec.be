# Battery Emulator for Tasmota (Berry)
# SOC from analog input

import json

class BatteryEmu
  var ser
  var addr
  var soc
  var lastTimePacket

  def init()
    self.addr = bytes().fromhex("31CE")
    
    # Serial: GPIO 14=RX, 13=TX, 38400 Baud, 8E1 (0x18)
    self.ser = serial(14, 13, 38400, serial.SERIAL_8E1)
    print("BMS: Emulator gestartet (38400 8E1)")

    self.lastTimePacket = 0
  end

  # helper function to get SOC
  def get_analog_soc()
    var sensors = json.load(tasmota.read_sensors())
    self.soc = sensors['ANALOG']['Range1']
    if (self.soc > 100) self.soc = 100 end
    if (self.soc < 0) self.soc = 0 end
    return self.soc
  end

  def calc_cs(p)
    var sum = 0
    for i:0..p.size()-1
      sum += p[i]
    end
    return sum & 0xFF
  end

  def apply_offset(p)
    var out = bytes()
    for i:0..p.size()-1
      out.add((p[i] + 0x33) & 0xFF)
    end
    return out
  end

  def send_response(ctrl, raw_payload)
    var payload = self.apply_offset(raw_payload)
    var frame = bytes().fromhex("68") + self.addr + bytes().fromhex("68")
    frame.add(ctrl)
    frame.add(payload.size())
    frame += payload
    frame.add(self.calc_cs(frame))
    frame.add(0x16)
    
    tasmota.delay(70) 
    self.ser.write(frame)
  end

  def handle_request()
    if self.ser.available() > 0
      var b = self.ser.read()
      if b.size() >= 4 && b[0] == 0x68 && b[1..2] == self.addr && b[3] == 0x68
        var ctrl = b[4]
        
        if ctrl == 0x02  # Status / SOC
          var current_soc = self.get_analog_soc()
          
          var data = bytes().fromhex("00000000000000000000") # Header
          data.add(current_soc) # Dynamischer SOC vom Poti!
          data += bytes().fromhex("00010F") + bytes(5, 0x15) 
          
          # Zellspannungen (hier statisch 4.0V zur Demonstration)
          for i:1..13 data += bytes().fromhex("0FA0") end
          
          self.send_response(0x82, data)
          print("BMS: TX Status - SOC:", current_soc, "%")

          # get last bms request
          self.lastTimePacket = tasmota.rtc()['local']

        elif ctrl == 0x06  # Zeitstempel
          var rtc = tasmota.rtc()
          var time_raw = bytes().fromhex("000000")
          time_raw.add(rtc['year'] % 100)
          time_raw.add(rtc['month'])
          time_raw.add(rtc['day'])
          time_raw.add(rtc['hour'])
          time_raw.add(rtc['min'])
          time_raw.add(rtc['sec'])
          self.send_response(0x86, time_raw)
        end
      end
    end
    # check if deep sleep
    var diff = tasmota.rtc()['local'] - self.lastTimePacket
    if diff > 30
      # go to deep sleep
      print('Going to sleep...')
      load('runulp.be')
    end
  end
end

battery = BatteryEmu()
tasmota.add_fast_loop(def () battery.handle_request() end)
