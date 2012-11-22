#enable :sessions
use Rack::Session::Pool, :expire_after => 2592000

helpers do
  
  def print_and_redirect(print_url,
                         redirect_url='/registered',
                         message = "Printing, please wait...", 
                         show_next_button = false, client_id = nil)
    @print_url = print_url
    @redirect_url = redirect_url
    @message = message
    @show_next_button = show_next_button
    @client_id = client_id
    
    erb :print
  end
  
end

get '/' do
  BPMachine.current = BPMachine.new settings.device, settings.baud
  erb :index  
end

get '/read' do
  BPMachine.current = BPMachine.new settings.device, settings.baud
  erb :read  
end

get '/start' do
  if BPMachine.current
    bpmachine = BPMachine.current
  else
    bpmachine = BPMachine.new settings.device, settings.baud
    BPMachine.current = bpmachine
  end
    
  bpmachine.start
  sleep 30
  resp = bpmachine.read
  results = bpmachine.last_reading
  session[:results] = results

  logger.info "Response: #{resp.join(' ')}"
    
  redirect to("/results?systolic=#{results[:systolic]}&" + 
              "diastolic=#{results[:diastolic]}&pulse=#{results[:pulse]}")
end

get '/results' do
  @results = nil
  @last_results = params
  session[:results] = @last_results
  logger.info "Results: #{@last_results}"
  erb :results
end

post '/results' do
  @last_results = session[:results]
  @results = Reading.find_all_by_client_id(session[:client_id])
  
  erb :results
end

get '/consent' do
  erb :consent
end

get '/stop' do
  if BPMachine.current
    bpmachine = BPMachine.current
  else
    bpmachine = BPMachine.new settings.device, settings.baud
    BPMachine.current = bpmachine
  end
  
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
  # create client
  @client = Client.add
  session[:client_id] = @client.id
  
  results = session[:results]
  reading = Reading.create(:systolic_pressure  => results[:systolic],
                           :diastolic_pressure => results[:diastolic],
                           :pulse_rate => results[:pulse_rate],
                           :client_id => @client.id)
                            
  print_and_redirect('/print_client_number?client_id=' + @client.id.to_s)
end               

get '/registered' do
  @client = Client.find session[:client_id]
  erb :registered
end

get '/print_client_number' do
  client = Client.find(params[:client_id])
  label_commands = client.number_label
  File.open('/tmp/label.data', 'w') {|f| f.write label_commands}

  send_file('/tmp/label.data', :type => 'application/label',
            :stream => false,
            :filename => "#{client.id}#{rand(10000)}.lbl",
            :disposition => 'inline')
end

get '/no-controls' do
  File.read(File.join('public', 'no-controls.html'))
end


