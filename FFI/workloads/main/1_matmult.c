#include <stdio.h>
#include <stdlib.h>
#include "workload.h"

#define ROW 4
#define COL 5
#define N 8

 int M1[ROW][N] = {
	{4927, 	-8612, 	28290, 	-3954, 	22031, 	-12981, -910, 	27877},
	{-15230, 7, 	-11659, 19600, 	9630, 	0, 	7872, 	141},
	{-5803, -14, 	9533, 	-915, 	11249, 	500, 	-5, 	1211},
	{20115, 3783, 	-7469, 	1023, 	-12071, 127, 	-1445,	511}
};

 int M2[N][COL] = {
	{-11484, 	4000, 	79, 	7311, 	256},
	{19598, 	503, 	674, 	-32210, 4010},
	{9580, 		-107, 	-808, 	-4475, 	-656},
	{-1, 		-39, 	128, 	1793, 	-255},	
	{-6092, 	299, 	5309, 	1024, 	701},
	{-25212, 	-130, 	0, 	-1964, 	10371},
	{12381, 	-450, 	765, 	1793, 	2318},
	{-7252, 	-1700, -422, 	-4475, 	5369}	
};



void matmult(volatile int* res_ptr){
	int i, j, k;
	for(i=0; i < ROW; i++){
		for(j=0; j < COL; j++){
			volatile int * item_ptr = res_ptr + i*COL + j;
			*(item_ptr) = 0;
			for(k = 0; k < N; k++){
				*(item_ptr) += (M1[i][k] * M2[k][j]);
			};
		};
	};	
}


void mkernel(int mhartid)
{

	for(int i=0;i<CORE_DELAY*mhartid;i++){
		__asm("nop");
	}
	
	matmult(RES_PTR + mhartid*RES_ITEMS);


	//stall all harts but hart-0 (main core)
	while(mhartid>0){ };
}



