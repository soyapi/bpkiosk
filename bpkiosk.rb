require 'sinatra'
require 'active_record'
require 'national_patient_id'
require 'serialport'

require Sinatra::Application.root + '/lib/client'
require Sinatra::Application.root + '/lib/reading'
require Sinatra::Application.root + '/lib/bpmachine'
require Sinatra::Application.root + '/lib/controller'
  
class BPKiosk
  
  configure do
    set :title, 'Open BP Kiosk'
    set :device, '/dev/ttyUSB0' #TODO: move to a config yaml
    set :baud, 2400
    #db_config = YAML::load(File.open(File.join(File.dirname(__FILE__),'../','database.yml')))[Sinatra::Application.environment]
    #db_config = YAML::load_file('/home/soyapi/src/pitt/bpkiosk/database.yml')[Sinatra::Application.environment]
    db_config = {:adapter => 'sqlite3', :database => '/home/soyapi/src/pitt/bpkiosk/db/bpkiosk.db'}
    #puts db_config.to_yaml
    ActiveRecord::Base.establish_connection(db_config)
  end    
end
