#include <wiringPi.h>


#define LED1_R 0 // wiringPi對應腳位 11
#define LED1_Y 2 // wiringPi對應腳位 13
#define LED1_G 3 // wiringPi對應腳位 15

#define LED2_R 4 // wiringPi對應腳位 16
#define LED2_Y 5 // wiringPi對應腳位 18
#define LED2_G 6 // wiringPi對應腳位 22
//Ground 接地	 // wiringPi對應腳位 20

#define G_R_Time 10
#define Y_RGTime 2
#define R_RTime 1
#define GBlinkTime 3

void trafficSignOn(int Rs,int Ys,int Gs,int GBs);

int main (void)
{
	char exit_key;
	wiringPiSetup () ;
	pinMode (LED1_R, OUTPUT) ;
	pinMode (LED1_Y, OUTPUT) ;
	pinMode (LED1_G, OUTPUT) ;

	pinMode (LED2_R, OUTPUT) ;
	pinMode (LED2_Y, OUTPUT) ;
	pinMode (LED2_G, OUTPUT) ;

	while(1){
		trafficSignOn(G_R_Time,Y_RGTime,R_RTime,GBlinkTime);	
	}
	
	return 0 ;
}
void trafficSignOn(int G_R,int Y_R,int R_R,int GB){
	int i;

	//  LED1紅燈
	digitalWrite(LED1_R, HIGH);
	digitalWrite(LED1_Y, LOW);
	digitalWrite(LED1_G, LOW);
	//  LED2紅燈
	digitalWrite(LED2_R, HIGH);
	digitalWrite(LED2_Y, LOW);
	digitalWrite(LED2_G, LOW);
	delay(1000*R_R); 

	//	LED1綠燈 
    digitalWrite(LED1_R, LOW);     
    digitalWrite(LED1_Y, LOW);
    digitalWrite(LED1_G, HIGH);
    //  LED2紅燈 
    digitalWrite(LED2_R, HIGH);     
    digitalWrite(LED2_Y, LOW);
    digitalWrite(LED2_G, LOW);
  	delay(1000*(G_R-GB));      
		//	LED1綠燈閃爍
	  	for(i=1;i<=GB;i++){ 
	  	digitalWrite(LED1_G, LOW);
	  	delay(500);
	  	digitalWrite(LED1_G, HIGH);
	  	delay(500);
	  	}

  	//	LED1黃燈
	digitalWrite(LED1_R, LOW);   
	digitalWrite(LED1_Y, HIGH);
	digitalWrite(LED1_G, LOW);
	//  LED2紅燈  	
	digitalWrite(LED2_R, HIGH);     
    digitalWrite(LED2_Y, LOW);
    digitalWrite(LED2_G, LOW);
	delay(1000*Y_R);

	//  LED1紅燈
	digitalWrite(LED1_R, HIGH);
	digitalWrite(LED1_Y, LOW);
	digitalWrite(LED1_G, LOW);
	//  LED2紅燈
	digitalWrite(LED2_R, HIGH);
	digitalWrite(LED2_Y, LOW);
	digitalWrite(LED2_G, LOW);
	delay(1000*R_R); 

	//	LED1紅燈
	digitalWrite(LED1_R, HIGH);
	digitalWrite(LED1_Y, LOW);
	digitalWrite(LED1_G, LOW);
	//	LED2綠燈 
	digitalWrite(LED2_R, LOW);     
    digitalWrite(LED2_Y, LOW);
    digitalWrite(LED2_G, HIGH);
	delay(1000*(G_R-GB));      
		//	LED2綠燈閃爍
	  	for(i=1;i<=GB;i++){ 
	  	digitalWrite(LED2_G, LOW);
	  	delay(500);
	  	digitalWrite(LED2_G, HIGH);
	  	delay(500);
	  	}

	//	LED1紅燈
	digitalWrite(LED1_R, HIGH);   
	digitalWrite(LED1_Y, LOW);
	digitalWrite(LED1_G, LOW);
	//  LED2黃燈  	
	digitalWrite(LED2_R, LOW);     
    digitalWrite(LED2_Y, HIGH);
    digitalWrite(LED2_G, LOW);
	delay(1000*Y_R);

}
// $ gcc -Wall -o RYG RYG.c -lwiringPi
// $ sudo ./RYG