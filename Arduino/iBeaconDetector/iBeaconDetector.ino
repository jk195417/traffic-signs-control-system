#include <SoftwareSerial.h>
#define CHAR_MAX 128
#define UUID 32
#define MAJOR 4
#define MINOR 4

// SoftwareSerial(rxPin, txPin, inverse_logic)
// RX Pin 10 for Receive,TX Pin 9 for Send
SoftwareSerial hm_10(10, 9);
// temp for char
char chr;
static int i,resSize,reqSize;

void setup(){
  Serial.begin(115200);
  hm_10.begin(115200);
  Serial.println("HM-10 is begin listening"); 
}

void loop(){
  char response[CHAR_MAX],request[CHAR_MAX],temp[8];
  char uuid[UUID+1],major[MAJOR+1],minor[MINOR+1];
  
  // 在response中找尋的iBeacon關鍵字串
  const char searchCondi[16] = "OK+DISC:4C000215";
  
  // when Serial Monitor receive command
  while(Serial.available() > 0){
    // Read from Serial Monitor
    chr = Serial.read();
    request[reqSize] = chr;
    reqSize++;
    // Write command to Bluetooth
    hm_10.print(chr);
  }
  
  // when Bluetooth receive data
  while(hm_10.available()>0){
    // Read from Bluetooth
    chr = hm_10.read();
    response[resSize] = chr;
    resSize++;
    // delay(1); // 9600baud率時硬體會跟不上程式，所以加上這行
  }
  // Write data to Serial Monitor
  if(resSize>0){
    // Serial.print(String("")+"response = "+response+" size = "+resSize+"\n");
    // Serial.flush();
    // delay(1); // 9600baud率時硬體會跟不上程式，所以加上這行
    
    // 處理response字串，確認回傳字串是否為目標字串
    if(strncmp(response, searchCondi, 16)==0){
      // get uuid major minor from response
      strncpy (uuid, response+17, UUID);
      uuid[UUID]='\0';
      strncpy (major, response+50, MAJOR);
      major[MAJOR]='\0';
      strncpy (minor, response+54, MINOR);
      minor[MINOR]='\0';
      
      // Serial.print(String("")+"UUID = "+uuid+"\n");
      // Serial.print(String("")+"Major = "+major+"\n");
      // Serial.print(String("")+"Minor = "+minor+"\n");

      //判斷紅綠燈
      if(strncmp(minor, "0001", 4)==0){
        Serial.print(String("")+"Red"+"\n");
      }else if(strncmp(minor, "0002", 4)==0){
        Serial.print(String("")+"Yellow"+"\n");
      }else if(strncmp(minor, "0003", 4)==0){
        Serial.print(String("")+"Green"+"\n");
      }else{
        Serial.print(String("")+"others"+"\n");
      }

      // 清除字串暫存
      memset(uuid,0,UUID+1);
      memset(major,0,MAJOR+1);
      memset(minor,0,MINOR+1);
    }
    
    // 清除字串暫存
    resSize=0;
    memset(response,0,CHAR_MAX);
  }
  // 查詢附近iBeacon
  if(!hm_10.available()){
    i++;
    delay(1); // 硬體會跟不上程式，所以加上這行
    if(i%1000==0){ // 1*1000 = 1，每1秒查詢一次
      hm_10.print("AT+DISI?");
      hm_10.flush();
      i=0;
    }
  }
}
