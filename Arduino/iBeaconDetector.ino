#include <SoftwareSerial.h>
#define CHAR_MAX 128

// SoftwareSerial(rxPin, txPin, inverse_logic)
// RX Pin 10 for Receive,TX Pin 9 for Send
SoftwareSerial hm_10(10, 9);
// temp for char
char chr;
static int i,resSize,reqSize;

void setup(){
  Serial.begin(9600);
  hm_10.begin(9600);
  Serial.println("HM-10 is begin listening"); 
}

void loop(){
  char response[CHAR_MAX],request[CHAR_MAX],temp[8];
  // 在response中找尋字串
  const char searchCondi[8] = "OK+DISC:";
  
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
    delay(1);
  }
  // Write data to Serial Monitor
  if(resSize>0){
    // Serial.print(String("")+"response = "+response+" size = "+resSize+"\n");
    // Serial.flush();
    // delay(1);
    // 處理response字串
    // 回傳字串是否為目標字串
    if(strncmp(response, searchCondi, 8)==0){
      Serial.print(String("")+"response = "+response+" size = "+resSize+"\n");
      Serial.flush();
    }
    // 清除字串暫存
    resSize=0;
    memset(response,0,CHAR_MAX);
  }
  
  if(!hm_10.available()){
    i++;
    delay(2);
    if(i%1500==0){
      hm_10.print("AT+DISI?");
      i=0;
    }
  }



















  
}
