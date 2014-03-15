#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#define LEN 64

/*
0:11, 12, 13, 14, 15, 16, 17, 18, 21, 28, 31, 32, 33, 34, 35, 36, 37, 38
1:21, 22, 23, 24, 25, 26, 27, 28
2:11, 12, 13, 14, 15, 18, 21, 25, 28, 31, 35, 36, 37, 38
3:11, 15, 18, 21, 25, 28, 31, 32, 33, 34, 35, 36, 37, 38
4:15, 16, 17, 18, 25, 31, 32, 33, 34, 35, 36, 37, 38
5:11, 15, 16, 17, 18, 21, 25, 28, 31, 32, 33, 34, 35, 38
6:11, 12, 13, 14, 15, 16, 17, 18, 21, 25, 28, 31, 32, 33, 34, 35, 38
7:18, 28, 31, 32, 33, 34, 35, 36, 37, 38
8:11, 12, 13, 14, 15, 16, 17, 18, 21, 25, 28, 31, 32, 33, 34, 35, 36, 37, 38
9:11,15,16,17,18,21,25,28,31,32,33,34,35,36,37,38
*/
const int pattern[10][LEN] = 
{
	{11, 12, 13, 14, 15, 16, 17, 18, 21, 28, 31, 32, 33, 34, 35, 36, 37, 38}, 
	{21, 22, 23, 24, 25, 26, 27, 28},
	{11, 12, 13, 14, 15, 18, 21, 25, 28, 31, 35, 36, 37, 38},
	{11, 15, 18, 21, 25, 28, 31, 32, 33, 34, 35, 36, 37, 38},
	{15, 16, 17, 18, 25, 31, 32, 33, 34, 35, 36, 37, 38},
	{11, 15, 16, 17, 18, 21, 25, 28, 31, 32, 33, 34, 35, 38},
	{11, 12, 13, 14, 15, 16, 17, 18, 21, 25, 28, 31, 32, 33, 34, 35, 38},
	{18, 28, 31, 32, 33, 34, 35, 36, 37, 38},
	{11, 12, 13, 14, 15, 16, 17, 18, 21, 25, 28, 31, 32, 33, 34, 35, 36, 37, 38},
	{11,15,16,17,18,21,25,28,31,32,33,34,35,36,37,38},
};



typedef struct digit_pattern {
	uint16_t frag[4];
	/*
	pattern[0]---------|pattern[1]---------|pattern[2]---------|pattern[3]---------|
	0000 0000 0000 0000|0000 0000 0000 0000|0000 0000 0000 0000|0000 0000 0000 0000|

	so if we only want nodes whose TOS_NODE_ID = 11 and 12 on:
		pattern[0]---------|pattern[1]---------|pattern[2]---------|pattern[3]---------|
		0000 0000 0000 0000|0000 0000 0000 0000|0000 0000 0000 0000|0000 1100 0000 0000|
		that woold be:
		digit_pattern_t PATTERN_11_12 = {0x0000,0x0000,0x0000,0x0c00};
	*/
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


const mote_arr[10][5] = {
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

void pattern2hex(const int pattern[]) {
	int i;
	uint16_t out[4] = {0};
	for(i=0;i<LEN;i++) {
		int node_id = pattern[i];
		unsigned int bit_mask;
		if(0<node_id && node_id<=15) {
			bit_mask = 0x1<<(node_id);
			out[3] |= bit_mask;
			//printf("%d ",node_id);
			//printf("0x%x ",bit_mask);
			//printf("0x%x\n", out[0]);					
		} else if (16<= node_id && node_id<=31) {
			bit_mask = 0x1<<(node_id-16);
			out[2] |= bit_mask;	
		} else if (32<= node_id && node_id<=47) {
			bit_mask = 0x1<<(node_id-32);
			out[1] |= bit_mask;
		} else if (48<= node_id && node_id<=63) {
			bit_mask = 0x1<<(node_id-48);
			out[0] |= bit_mask;	
		}
		
	}
	printf("{0x%x, 0x%x, 0x%x, 0x%x}", out[0],out[1],out[2],out[3]);
}

int main()
{
	int i=0;
	int j;
	printf("const digit_pattern_t PATTERN[10] = {\n");
	for(;i<10;i++) {
		printf("    ");
		pattern2hex(pattern[i]);
		printf(",\n");
	}
	printf("};\n");
	printf("PATTERN[0].frag[3] %0x\n",PATTERN[0].frag[3] );
	printf("PATTERN[0].frag[3-(11/16)%%4] %0x\n",PATTERN[0].frag[3-(11/16)%4]);
	printf("0x1<<(11\%16) 0x%x\n",0x1<<(11%16));
	printf("0xf800 & 0x800 %d\n",0xf800 & 0x800);
	int on = (PATTERN[0].frag[3-(11/16)%4]) & (0x1<<(11%16));
	printf("on:%d\n",on);
	int number;
	for(number=0;number<10;number++) {
		for(i=0;i<10;i++) {
			for(j=0;j<5;j++) {
				int TOS_NODE_ID = mote_arr[i][j];
				on = (PATTERN[number].frag[3-(TOS_NODE_ID/16)%4]) & (0x1<<(TOS_NODE_ID%16));
				if(on) {
					putchar('%');
				} else {
					putchar('`');
				}
				putchar(' ');
			}
			putchar('\n');
		}
		putchar('\n');
	}
	system("pause");
	return 0;
}


int isOn(int number, int id) {
	return (PATTERN[number].frag[3-(id/16)%4]) & (0x1<<(id%16));
}

int isOnTwo(int number, int id)  {
	int i = 0;
	for (; i < 64; ++i)
	{
		if(pattern[number%10][i]==id)
			return 1;
	}
	return 0;
}
