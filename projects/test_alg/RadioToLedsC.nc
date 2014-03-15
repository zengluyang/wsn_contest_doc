#include "Timer.h"
#include "printf.h"

typedef struct digit_pattern {
	uint16_t frag[4];
}digit_pattern_t;

const digit_pattern_t PATTERN[10] = {
    {0x0, 0x7f, 0x9027, 0xf800},
    {0x0, 0x0, 0x1fe0, 0x0},
    {0x0, 0x78, 0x9224, 0xf800},
    {0x0, 0x7f, 0x9224, 0x8800},
    {0x0, 0x7f, 0x8207, 0x8000},
    {0x0, 0x4f, 0x9227, 0x8800},
    {0x0, 0x4f, 0x9227, 0xf800},
    {0x0, 0x7f, 0x9004, 0x0},
    {0x0, 0x7f, 0x9227, 0xf800},
    {0x0, 0x7f, 0x9227, 0x8800},
};

const uint8_t mote_arr[10][5] = {
	{9,19,29,39,49},
	{8,18,28,38,48},
	{7,17,27,37,47},
	{6,16,26,36,46},
	{5,15,25,35,45},
	{5,15,25,35,45},
	{3,13,23,33,43},
	{2,12,22,32,42},
	{1,11,21,31,41},
	{0,10,20,30,40}
};


module RadioToLedsC {
	uses {
		interface Boot;
		interface Timer<TMilli>	as Timer0;
	}
}

implementation {

	event void Boot.booted() {
		printf("TestAlgoC BOOT\n");
		call Timer0.startPeriodic(5000);
	}

	event void Timer0.fired() {
		int number,i,j,on;
		for(number=0;number<10;number++) {
			for(i=0;i<10;i++) {
				for(j=0;j<5;j++) {
					int id = mote_arr[i][j];
					on = (PATTERN[number].frag[3-(id/16)%4]) & (0x1<<(id%16));
					if(on!=0) {
						printf("*");
					} else {
						printf("`");
					}
					printf(" ");
				}
				printf("\n");
			}
			printf("_______________________________\n");
			printf("_______________________________\n");
		}
		printfflush();
	}
}