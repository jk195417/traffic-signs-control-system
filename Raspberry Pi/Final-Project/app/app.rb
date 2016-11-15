require 'sinatra'
require_relative('config')

set :config, settings.root + '/config'
set :config, settings.root + '/config'
Config.path(settings.config+'/config')

get '/' do
  erb :index
end
get '/restart' do
  if $pid && $ps
    Process.kill("INT", $pid)
    $ps.close
  end
  $ps = IO.popen("rvmsudo ruby RYG.rb")
  $pid = $ps.pid
  erb :restart
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