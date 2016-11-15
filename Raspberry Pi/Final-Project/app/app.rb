require 'sinatra'
require_relative('config')

set :config, settings.root + '/config'
set :config, settings.root + '/config'
Config.path(settings.config+'/config')

get '/' do
  erb :index
end
get '/start' do
  if $ps.nil? || $ps.closed?
    $ps = IO.popen("rvmsudo ruby RYG.rb")
    $pid = $ps.pid
    @message = "start success"
  else
    @message = "is started already"
  end
  erb :led_action, :locals => {:message => @message}
end
get '/stop' do
  if $pid && $ps && !$ps.closed?
    Process.kill("INT", $pid)
    $ps.close
    @message = "stop success"
  else
    @message = "is stoped already"
  end
  erb :led_action, :locals => {:message => @message}
end
get '/restart' do
  if $pid && $ps && !$ps.closed?
    Process.kill("INT", $pid)
    $ps.close
    $ps = IO.popen("rvmsudo ruby RYG.rb")
    $pid = $ps.pid
    @message = "restart success"
  else
    @message = "can't restart, maybe there is no traffic lights running"
  end
  erb :led_action, :locals => {:message => @message}
end
get '/config' do
  @config = Config.get
  erb :config, :locals => {:config => @config}
end
post '/config' do
  Config.set(params[:config])
  Config.update
  redirect to('/config')
end
get '/config/default' do
  Config.reset
  Config.update
  redirect to('/config')
end

# 參考http://stackoverflow.com/questions/14635318/having-a-io-popen-command-be-killed-when-the-caller-process-is-killed