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
  sleep 60
  redirect to('/results')
end

get '/results' do
  bpmachine = BPMachine.current
  bpmachine.read
  @last_results = bpmachine.last_reading
  erb :results
end

get '/consent' do
  erb :consent
end

get '/stop' do
  session[:bpmachine].stop
  redirect to('/')  
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


