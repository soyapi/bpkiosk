require 'serialport'

class BPMachine
  @@TIMEOUT = 120
  @@commands = {:start => "\x16\x16\x01\x30\x20\x02\x53\x54\x03\x07\x0D\x0A",
                :stop  => "\x16\x16\x01\x30\x20\x02\x53\x50\x03\x03\x0D\x0A",
                :read  => "\x16\x16\x01\x30\x30\x02\x52\x42\x03\x10\x0D\x0A"}
               
  @@current = nil
  attr_reader :port, :device, :baud, :last_resp
  
  def initialize(device, baud)
    @device = device
    @baud   = baud
  end
  
  def self.current
    @@current
  end
  
  def self.current=(machine)
    @@current = machine
  end
  
  def read
    resp = []
    SerialPort.open(@device, @baud) do |sp|
      sp.write @@commands[:read].to_s
      start_time = Time.now
      data = ''
      while resp.length < 64 #(Time.now - start_time) < @@TIMEOUT
        data = sp.getc
        resp << data.chr
      end
    end
    
    
    # resp[13..14] year
    # 15,16 MM
    # 17,18 DD
    # 19,20 HH
    # 21,22 Min
    # 34..36 Systolic
    # 44..46 Diastolic
    # 49..51 Pulse
    @last_resp = resp
  end
  
  def last_reading
    #"Systolic:  #{@last_resp[34..36].join}
    # Diastolic: #{@last_resp[44..46].join}
    # Pulse:     #{@last_resp[49..51].join}/min"
    
    #y1,y2,y3,
     
    {:systolic  => "#{@last_resp[34..36].join}".to_i,
     :diastolic => "#{@last_resp[44..46].join}".to_i,
     :pulse     => "#{@last_resp[49..51].join}".to_i,
     :time      => "#{@last_resp[13..22].join}".to_i}
  end
  
  def start
    self.run :start
  end
  
  def stop
    self.run :stop
  end
  
  def run(cmd)
    cmd_hex = @@commands[cmd.to_sym]
    raise ArgumentError, "Unsupported command '#{cmd}'" unless cmd_hex
    
    SerialPort.open(@device, @baud) do |sp|
      sp.write cmd_hex.to_s
    end
  end
  
  def commands
    @@commands
  end
end