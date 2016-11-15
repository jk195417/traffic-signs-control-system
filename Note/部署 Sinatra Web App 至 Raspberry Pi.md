# 部署 Sinatra Web App 至 Raspberry Pi

## 1.安裝Passenger&Apache
下載並安裝

~~~sh
gem install passenger
sudo apt-get update
sudo apt-get install libcurl4-openssl-dev
sudo apt-get install apache2-mpm-worker
sudo apt-get install libapr1-dev
sudo apt-get install libaprutil1-dev
sudo apt-get install apache2-threaded-dev
passenger-install-apache2-module
~~~

## 2.設定Passenger

~~~sh
passenger-config about ruby-command
~~~

取得目前使用的ruby command path 等等設定apache會用到

## 3.設定Apache

### 基礎設定

設定檔放置在`/etc/apache2/apache2.conf`

~~~sh
sudo nano /etc/apache2/apache2.conf 
~~~

設定檔內容，把其他Directory註解掉

~~~
LoadModule passenger_module /home/pi/.rvm/gems/ruby-2.3.0/gems/passenger-5.0.30/buildout/apache2/mod_passenge$
<IfModule mod_passenger.c>
    PassengerRoot /home/pi/.rvm/gems/ruby-2.3.0/gems/passenger-5.0.30
    PassengerDefaultRuby /home/pi/.rvm/gems/ruby-2.3.0/wrappers/ruby
</IfModule>

# 把其他Directory註解掉
<VirtualHost *:80>
    ServerName localhost

    # Tell Apache and Passenger where your app's 'public' directory is
    DocumentRoot /home/pi/Final-Project/app/public

    PassengerRuby /home/pi/.rvm/gems/ruby-2.3.0/wrappers/ruby

    # Relax Apache security settings
    <Directory /home/pi/Final-Project/app/public>
      Allow from all
      Options -MultiViews
      # Uncomment this if you're on Apache > 2.4:
      #Require all granted
    </Directory>
</VirtualHost>
~~~

設定完後執行

~~~sh
sudo apache2ctl restart
~~~

但是會報錯

~~~
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1. Set the 'ServerName' directive globally to suppress this message
~~~

### 設定Servername

~~~sh
sudo nano /etc/apache2/conf-available/servername.conf
~~~

在`/etc/apache2/conf-available/servername.conf`寫入

~~~
ServerName localhost
~~~

讓apache啟用設定檔

~~~sh
sudo a2enconf servername
sudo service apache2 reload
~~~

這時候再重啟就不會報錯了

~~~sh
sudo apache2ctl restart
~~~

## 設定Web app
在app path:`/home/pi/Final-Project/app`處新增兩個資料夾`public``tmp`，與一個rackup檔案`config.ru`

~~~sh
mkdir public
mkdir tmp
nano config.ru
~~~

`config.ru`內容

~~~ruby 
require "./app.rb"
run Sinatra::Application
~~~

這樣一來 當訪問pi的ip`192.168.1.113` 就能看到我們的web app了


## 參考資料
- [http://recipes.sinatrarb.com/p/deployment/apache_with_passenger?#article](http://recipes.sinatrarb.com/p/deployment/apache_with_passenger?#article)  
- [https://www.phusionpassenger.com/library/deploy/apache/deploy/ruby/](https://www.phusionpassenger.com/library/deploy/apache/deploy/ruby/)  
- [http://askubuntu.com/questions/256013/could-not-reliably-determine-the-servers-fully-qualified-domain-name](http://askubuntu.com/questions/256013/could-not-reliably-determine-the-servers-fully-qualified-domain-name)  
- [http://stackoverflow.com/questions/3371208/how-to-setup-a-sinatra-app-under-apache-with-passenger](http://stackoverflow.com/questions/3371208/how-to-setup-a-sinatra-app-under-apache-with-passenger)