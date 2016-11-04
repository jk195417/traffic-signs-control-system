#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>


#define LED_R 4
#define LED_Y 5
#define LED_G 6

#define Rs 10
#define Ys 2
#define Gs 10

int main (void)
{
	int i=0;
	wiringPiSetup () ;
	pinMode (LED_R, OUTPUT);
	pinMode (LED_Y, OUTPUT);
	pinMode (LED_G, OUTPUT);

	for (;;){
	// 綠燈
	printf("G\n");
  digitalWrite(LED_R, LOW);     
  digitalWrite(LED_Y, LOW);
  digitalWrite(LED_G, HIGH);
  system("bash /home/pi/ibeacon/changeiBeacon.sh G");

	delay(1000*Gs-3000);      //綠燈時間-綠燈閃爍3秒
	// 綠燈閃爍3秒
  for(i=1;i<=3;i++){ 
  	digitalWrite(LED_G, LOW);
  	delay(500);
  	digitalWrite(LED_G,HIGH);
  	delay(500);
  }
  // 黃燈
	printf("Y\n");
	digitalWrite(LED_R, LOW);   
	digitalWrite(LED_Y, HIGH);
	digitalWrite(LED_G, LOW);
	system("bash /home/pi/ibeacon/changeiBeacon.sh Y");
	delay(1000*Ys);     //黃燈時間
	// 紅燈
	printf("R\n");
	digitalWrite(LED_R, HIGH);
	digitalWrite(LED_Y, LOW);
	digitalWrite(LED_G, LOW);
	system("bash /home/pi/ibeacon/changeiBeacon.sh R");   
	delay(1000*Rs);     //紅燈時間
	}
	return 0 ;
}
// $ gcc -Wall -o RYG RYG.c -lwiringPi
// $ sudo ./RYG