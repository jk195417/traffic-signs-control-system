#include <stdio.h>
#include <wiringPi.h>


#define LED_R 4
#define LED_Y 5
#define LED_G 6

int main (void){
    wiringPiSetup () ;
    pinMode (LED_R, OUTPUT);
    pinMode (LED_Y, OUTPUT);
    pinMode (LED_G, OUTPUT);
    digitalWrite(LED_R, LOW);     
    digitalWrite(LED_Y, LOW);
    digitalWrite(LED_G, LOW);
    return 0 ;
}
// $ gcc -Wall -o clearRYG clearRYG.c -lwiringPi
// $ sudo ./clearRYG