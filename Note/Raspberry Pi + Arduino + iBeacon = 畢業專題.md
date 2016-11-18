# Raspberry Pi + Arduino + iBeacon = 畢業專題
透過 Raspberry Pi 發出 ibeacon 廣播的交通號誌，並且可以用網頁控制開關與參數設定，再以 Arduino + HM-10 晶片接收廣播將當前號誌輸出至LED

## 材料

1. Raspberry Pi 2 Model B
    1. microSD 16GB
    2. WiFi USB Dongle
    3. Bluetooth4.0 USB Dongle
    4. 紅綠黃LED各一
    5. 10k電阻三個
2. Arduino Uno
    1. HM-10
    2. 紅綠黃LED各1
    3. 10k電阻3個
3. 其他
    1. 線材
    2. 行動電源2個 

## Raspberry Pi

### 安裝 Raspbian 作業系統

參考 [http://www.botsheet.com/cht/raspberry-pi-tutorial-install-raspbian-windows/](http://www.botsheet.com/cht/raspberry-pi-tutorial-install-raspbian-windows/)

### 安裝與設定 Ruby RVM

參考 rvm 官網 : [https://rvm.io/](https://rvm.io/)

#### Install RVM :

```sh
$ sudo apt-get update
$ sudo apt-get upgrade
$ gpg --keyserver hkp://keys.gnupg.net --recv-keys \
$ 409B6B1796C275462A1703113804BB82D39DC0E3
$ \curl -sSL https://get.rvm.io | bash -s stable
```

成功後重開終端機

#### Install Ruby 2.3 with RVM :

```sh
$ rvm install 2.3
```
會有點久，還要等下載的Ruby編譯，在 Pi 這種效能不高的微電腦上可能需要1個小時,成功後重開終端機
將 RVM 的 Ruby 2.3 設為預設使用的 Ruby

```sh
$ rvm use 2.3 --default
```

再次重開終端機，完成!

### 藍芽 dongle 與安裝 BlueZ

#### BlueZ

官方 BlueZ 安裝網址：[http://www.bluez.org/download/](http://www.bluez.org/download/)  
>我們使用的版本是 **bluez-5.40**  

下載與解壓縮

~~~sh
$ cd ~
$ wget http://www.kernel.org/pub/linux/bluetooth/bluez-5.40.tar.xz`
$ unxz bluez-5.40.tar.xz && tar xvf bluez-5.40.tar
~~~

安裝 bluez 要求的 lib

~~~sh
$ sudo apt-get update
$ sudo apt-get install -y libusb-dev libdbus-1-dev libglib2.0-dev \
$ libudev-dev libical-dev libreadline-dev
~~~

進入解完壓縮的bluez資料夾，執行安裝前的設定檔

~~~sh
$ cd bluez-5.40
$ ./configure
~~~

產生安裝檔和安裝

~~~sh
$ make
$ sudo make install
~~~

確認安裝是否完成

~~~sh
$ systemctl status bluetooth
~~~    

得到以下結果：

~~~
● bluetooth.service - Bluetooth service
   Loaded: loaded (/lib/systemd/system/bluetooth.service; enabled)
   Active: active (running) since 一 2016-09-26 15:36:03 CST; 2 weeks 1 days ago
     Docs: man:bluetoothd(8)
 Main PID: 379 (bluetoothd)
   Status: "Running"
   CGroup: /system.slice/bluetooth.service
           └─379 /usr/local/libexec/bluetooth/bluetoothd
~~~
  
Active：active 表示藍芽成功啟動

沒啟動的話會像下面這樣：

~~~
● bluetooth.service - Bluetooth service
   Loaded: loaded (/lib/systemd/system/bluetooth.service; enabled)
   Active: inactive (dead) since 二 2016-10-11 23:17:58 CST; 1s ago
     Docs: man:bluetoothd(8)
  Process: 379 ExecStart=/usr/local/libexec/bluetooth/bluetoothd \
  (code=exited, status=0/SUCCESS)
 Main PID: 379 (code=exited, status=0/SUCCESS)
   Status: "Quitting"
~~~

>統整一下藍芽開關的指令

~~~sh
# 查看狀態
$ systemctl status bluetooth

# 啟動
$ sudo systemctl start bluetooth

# 關閉
$ sudo systemctl stop bluetooth

# 重啟
$ sudo systemctl restart bluetooth
~~~

#### 藍芽 dongle

將 Bluetooth4.0 USB Dongle 插上 Pi  
我們使用的是 **SeeHot 嘻哈部落V4.0 藍牙傳輸器(SBD-40)**  
官方網站：[http://www.seehot.com.tw/products-detail.php?id=120](http://www.seehot.com.tw/products-detail.php?id=120)  
購買網站：[http://24h.pchome.com.tw/prod/DGBT33-A74355576](http://24h.pchome.com.tw/prod/DGBT33-A74355576)  

將藍芽Usb插入樹莓派後，確認目前USB裝置啟動：

~~~sh
$ lsusb

# 確認藍牙啟動
$ hciconfig
~~~

會得到下面這些資訊

~~~
hci0:	Type: BR/EDR  Bus: USB
BD Address: 00:15:83:EA:D0:79  ACL MTU: 310:10  SCO MTU: 64:8
DOWN 
RX bytes:742 acl:0 sco:0 events:58 errors:0
TX bytes:1954 acl:0 sco:0 commands:58 errors:0
~~~

可以看到系統已經啟動藍牙裝置，並且命名為 **hci0**

~~~sh
# 啟動 hci0
$ sudo hciconfig hci0 up

# 輸入下列指令來查看更多hciconfig指令
$ hciconfig -h

# 關閉掃描其他裝置的功能
$ sudo hciconfig hci0 noscan

# 啟動 BLE 訊息廣播功能
$ sudo hciconfig hci0 leadv

# 發送 iBeacon 廣播
$ sudo hcitool -i hci0 cmd 0x08 0x0008 1E 02 01 1A 1A FF 4C 00 02 15 \
$ E2 C5 6D B5 DF FB 48 D2 B0 60 D0 F5 A7 10 96 E0 \
$ 00 00 00 00 C8 00
~~~

封包結構是由 **UUID**(16byte) + **Major**(2byte) + **Minor**(2byte) + **Tx Power**
  
我們試著來解讀剛剛發送的封包內容

~~~sh
$ sudo hcitool -i hci0 cmd 0x08 0x0008 1E 02 01 1A 1A FF 4C 00 02 15 \
E2 C5 6D B5 DF FB 48 D2 B0 60 D0 F5 A7 10 96 E0 \
00 00 \
00 00 \
C8 00
~~~

- iBeacon固定格式 `02 01 1A 1A FF 4C 00 02 15`  
- UUID : `E2 C5 6D B5 DF FB 48 D2 B0 60 D0 F5 A7 10 96 E0`  
- Major : `00 00`  
- Minor : `00 00`  
- Tx Power : `C8`

再一個例子

~~~sh
$ sudo hcitool -i hci0 cmd 0x08 0x0008 1e 02 01 1a 1a ff 4c 00 02 15 \
aa aa aa aa bb bb cc cc dd dd ee ee ee ee ee ee \
01 00 \
01 00 \
c5
~~~

- iBeacon固定格式 `02 01 1A 1A FF 4C 00 02 15`
- UUID : `aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee`   
- Major : `01 00`
- Minor : `01 00` 
- Tx Power : c5


### ibeacon.rb

這支程式內包含了一個 `Ibeacon` Class，能夠藉由傳入的參數設定 ibeacon，並且發出command 啟動/暫停/廣播 ibeacon

#### 類別結構 :

```rb
class Ibeacon
  # 類別初始化
  def initialize
    # 宣告類別實例變數，並且調用 setting method 設定變數值
  end
  # 類別實例變數
  @config       # 以下實例變數的 hash 集合
  @ble_devise   # ble_devise
  @uuid         # uuid
  @major        # major
  @minor        # minor
  @power        # power
  # 類別實例方法
  def start
    # 發出 commands 準備廣播前初始化後開始廣播
  end
  def stop
    # 發出 command 暫停廣播
  end
  def broadcast
    # 發出 command 開始廣播
  end
  def minor=(new_minor)
    # @minor 的 setter
  end
  def setting
    # @config 的 setter
  end
end
```
#### 使用方法 :

在 RYG.rb 中 require 這個類別，建立一個類別實例，傳入初始化所需的 hash 設定，並且在程式內適當的調用它

```rb
ibeacon = Ibeacon.new(my_config)
ibeacon.start
ibeacon.stop
```

### config.rb 與 config.json

#### config.rb 模組結構 :

```rb
# 需要用到 json lib 幫我們解析 json 檔的資料
require "json"
module Config
  # 在此 block 內的成員，會變成模組的共享成員
  class << self             
    # 模組變數
    @path   # 放置要讀取的 json 檔位於電腦的哪個位置但不包含副檔名.json
    @config # 將json檔內的資料以hash存放於此變數
    # 模組方法
    def path(path)
      # @path 的 setter，並且若是找不到 檔名.json
      # 就會呼叫 get_default 方法改尋找 檔名_default.json
    end             
    def reset
      # 將 檔名.json 的內容還原成 檔名_default.json 的內容
    end
    def update
      # 將@config的值寫回 檔名.json 中
    end
    def get
      # @config 的 getter 
      # 如果 @config不存在就使用 get_default 方法的回傳值
    end
    def set(conf)
      # @config 的 setter，只會更新非空字串的值
    end
    private
    def get_default
      # 回傳檔名_default.json的值，若不存在回傳空hash
    end
  end
end
```

#### config.json 資料結構 :

```json
{
  // ibeacon config
  "ble_devise": "hci0",
  "uuid": "fc 00 00 ac e0 00 10 50 00 00 00 00 00 00 00 00",
  "major": "00 01",
  "minor": "00 00",
  "power": "c8",
  // traffic lights times config
  "Rs": "10",
  "Gs": "10",
  "Ys": "2"
}
```

#### 使用方法 :

在 RYG.rb 與 app.rb 中 require 這個模組，使用此模組的第一步，設定要讀取的json檔的path

```rb
# config.json 在 app/config/config.json
# RYG.rb 與 app.rb 在app/下，所以正確的使用方法為
Config.path("./config/config")
Config.get # 可以取得 config.json 的資料內容 hash
```

### 安裝 Pi_piper



### RYG.rb



### GPIO 與 LED 線路



### 安裝 Sinatra



### app.rb 



### 安裝與設定 Passenger



### 安裝與設定 Apache



## Arduino

### HM-10晶片接線



### LED燈接線



### 主程式

1. 透過嵌入在主程式中的 AT Command 查詢附近 iBeacon
2. 操作字元取得iBeacon狀態
3. 條件判斷LED燈亮暗

## 參考資料

- 安裝 Raspbian 作業系統  
[http://www.botsheet.com/cht/raspberry-pi-tutorial-install-raspbian-windows/](http://www.botsheet.com/cht/raspberry-pi-tutorial-install-raspbian-windows/)

- RVM 官網  
[https://rvm.io/](https://rvm.io/)

- SeeHot 嘻哈部落V4.0 藍牙傳輸器(SBD-40)  
官方網站：[http://www.seehot.com.tw/products-detail.php?id=120](http://www.seehot.com.tw/products-detail.php?id=120)  
購買網站：[http://24h.pchome.com.tw/prod/DGBT33-A74355576](http://24h.pchome.com.tw/prod/DGBT33-A74355576)

- Raspberry Pi 發送 iBeacon  
[http://cheng-min-i-taiwan.blogspot.tw/2015/03/raspberry-pi-40ibeacon.html](http://cheng-min-i-taiwan.blogspot.tw/2015/03/raspberry-pi-40ibeacon.html)



