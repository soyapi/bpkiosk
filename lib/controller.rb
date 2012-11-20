if test?
  session = {}
else
  enable :sessions
end

@session = session

get '/' do
  BPMachine.current = BPMachine.new settings.device, settings.baud
  erb :index  
end

get '/read' do
  BPMachine.current = BPMachine.new settings.device, settings.baud
  erb :read  
end

get '/start' do
  bpmachine = BPMachine.current
  bpmachine.read
  time = bpmachine.last_reading[:time]
  bpmachine.start
  #while 
  #sleep 60
  redirect to('/results')
end

get '/results' do
  bpmachine = BPMachine.current
  resp = nil
  while resp && resp.length == 64 && resp[62] == "\003" && 
        resp[0..5] == ['\026','\026','\001','0','0','\002']
    resp = bpmachine.read
  end
  @last_results = bpmachine.last_reading
  erb :results
end

get '/consent' do
  erb :consent
end

get '/stop' do
  bpmachine = BPMachine.current
  bpmachine.stop
  redirect to('/')  
end

get '/auth_menu' do
  erb :auth_menu
end

get '/sign_in' do
  erb :sign_in
end

get '/sign_up' do
  erb :registered
end

get '/find_client' do
  client = Client.find_by_client_number params[:client_number]
  if client
    "Client #{client.client_number} found"
  else
    "Client #{params[:client_number]} NOT found"
  end
end

get '/save_reading' do
  # create client
  client = Client.add
  
  bpmachine = BPMachine.current
  last_result = bpmachine.last_reading
  reading = Reading.create(:systolic_pressure  => last_result[:systolic],
                 :diastolic_pressure => last_result[:diastolic],
                 :pulse_rate => last_result[:pulse_rate],
                 :client_id => client.id)
  "Reading created: #{reading.to_yaml}"                 
end

get '/no-controls' do
  File.read(File.join('public', 'no-controls.html'))
end


