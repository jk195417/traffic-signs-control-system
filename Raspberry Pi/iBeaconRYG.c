#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wiringPi.h>

#define LEDR 0  // wiringPi對應腳位 11
#define LEDY 2  // wiringPi對應腳位 13
#define LEDG 3  // wiringPi對應腳位 15
// Ground 接地  // wiringPi對應腳位 20
#define Rms 10000
#define Yms 2000
#define Gms 10000

void trafficSignOn(int R,int Y,int G);
void changeiBeacon(const char *p);

int main (void){  
  wiringPiSetup () ;
  pinMode (LEDR, OUTPUT);
  pinMode (LEDY, OUTPUT);
  pinMode (LEDG, OUTPUT);

  for(;;){
    trafficSignOn(Rms,Yms,Gms);
  }
  return 0;
}
void trafficSignOn(int R,int Y,int G){
  // 紅燈
  digitalWrite(LEDR, HIGH);
  digitalWrite(LEDY, LOW);
  digitalWrite(LEDG, LOW);
  changeiBeacon("R");
  delay(R); 

  // 綠燈 
  digitalWrite(LEDR, LOW);     
  digitalWrite(LEDY, LOW);
  digitalWrite(LEDG, HIGH);
  changeiBeacon("G");
  delay(G);
    
  // 黃燈
  digitalWrite(LEDR, LOW);   
  digitalWrite(LEDY, HIGH);
  digitalWrite(LEDG, LOW);
  changeiBeacon("Y");
  delay(Y);
}

void changeiBeacon(const char *p){
  char *command;
  command = strcat("bash /home/pi/ibeacon/changeiBeacon.sh ",p);
  system(command);
}
// $ gcc -Wall -o RYG RYG.c -lwiringPi
// $ sudo ./RYG