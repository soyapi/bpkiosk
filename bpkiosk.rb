require 'sinatra'
#require 'sinatra/base'
require 'active_record'
require 'national_patient_id'
require 'serialport'
require 'rack'
require 'logger'

require Sinatra::Application.root + '/lib/client'
require Sinatra::Application.root + '/lib/reading'
require Sinatra::Application.root + '/lib/bpmachine'
require Sinatra::Application.root + '/lib/controller'
  
class BPKiosk
  
  configure do
    set :title, 'Open BP Kiosk'
    set :device, '/dev/ttyUSB0' #TODO: move to a config yaml
    set :baud, 2400
    db_config = {:adapter => 'sqlite3',
                 :database => Sinatra::Application.root + '/db/bpkiosk.db'}
    
    ActiveRecord::Base.establish_connection(db_config)
  end    
end
