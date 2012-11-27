require 'serialport'

class BPMachine
  @@TIMEOUT = 60
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
      start_time = Time.now
      data = ''
      sleep 30
      while resp.length < 64 #&& (Time.now - start_time) < @@TIMEOUT
        data = sp.getc
        next if data.chr[0] != 22 and resp.length <= 1
        next if data.chr[0] != 1 and resp.length == 2
        #next if data.chr[0] != 0 and ([3,4].include? resp.length)
        #next if data.chr[0] != 2 and resp.length == 5
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
    if @last_resp 
      {:systolic  => "#{@last_resp[34..36].join}".to_i,
       :diastolic => "#{@last_resp[44..46].join}".to_i,
       :pulse     => "#{@last_resp[49..51].join}".to_i,
       :time      => "#{@last_resp[13..22].join}".to_i}
    else
      {:systolic => nil, :diastolic => nil, :pulse => nil, :time => nil}
    end
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
  
  def self.test
    Logger.class_eval { alias :write :'<<' }
    logger = Logger.new 'log/app.log'
    
    use Rack::CommonLogger, logger
    
    if BPMachine.current
      bpmachine = BPMachine.current
    else
      bpmachine = BPMachine.new settings.device, settings.baud
      BPMachine.current = bpmachine
    end
      
    bpmachine.start
    sleep 30
    resp = bpmachine.read

    logger.info "Response: #{resp.join(' ')}"
      
    bpmachine.last_reading
  end
end