require 'sinatra'
require_relative('lib/config')

use Rack::Auth::Basic, "Restricted Area" do |username, password|
    [username, password] == ['admin', 'admin']  
end

set :config, settings.root + '/config'
Config.path(settings.config+'/config')

get '/' do
  erb :index
end

get '/start' do
  if $pid.nil?
    $pid = spawn("rvmsudo ruby lib/RYG.rb")
    @message = "Traffic lights start success"
    @success = true
    @status = "start"
  else
    @message = "Traffic lights is started already"
    @success = false
    @status = "stop"
  end
  erb :led_action, :locals => {:message => @message, :success => @success, :status => @status}
end

get '/stop' do
  if $pid
    # `sudo kill #{$pid}` 
    # 只殺掉了 main process，其衍生 child process 都還在
    # 由於 start 呼叫 main process 的 child process 才是我們執行的主程式
    # 故須改成下列 script 才能刪掉整個 process 樹
    `sudo pkill -P #{$pid}`
    $pid = nil
    @message = "Traffic lights stop success"
    @success = true
  else
    @message = "Traffic lights is stoped already"
    @success = false
  end
  @status = "stop"
  erb :led_action, :locals => {:message => @message, :success => @success, :status => @status}
end

get '/restart' do
  if $pid
    `sudo pkill -P #{$pid}`
    $pid = spawn("rvmsudo ruby lib/RYG.rb")
    @message = "Traffic lights restart success"
    @success = true
  else
    @message = "Traffic lights can't restart, maybe there is no traffic lights running"
    @success = false
  end
  @status = "start"
  erb :led_action, :locals => {:message => @message, :success => @success, :status => @status}
end

get '/config' do
  @config = Config.get
  erb :config, :locals => {:config => @config}
end

post '/config' do
  config = params[:config]
  # make time of traffic lights logical : Rs = Gs + Ys
  config["Rs"] = (config["Ys"].to_i+config["Gs"].to_i).to_s
  Config.set(config)
  Config.update
  redirect to('/config')
end

get '/config/default' do
  Config.reset
  Config.update
  redirect to('/config')
end

# 參考http://stackoverflow.com/questions/14635318/having-a-io-popen-command-be-killed-when-the-caller-process-is-killed