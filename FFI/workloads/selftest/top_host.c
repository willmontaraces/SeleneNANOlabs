#include "workload.h"
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>


volatile int * RES_PTR;
volatile int * REFERENCE_PTR;


int main(void)
{
	int ret;
	int ncpu;
	int i, j;
	
	ncpu =4;
	RES_PTR = memalign(4096, ncpu*RES_ITEMS*sizeof(int));
	for(i=0; i<ncpu*RES_ITEMS; i++){
		*(RES_PTR + i) = 0;
	}
        	
        
	printf("%s (0x%X): running on host\n", __func__, &main);
	printf("%s (0x%X): starting kernel\n", __func__, &mkernel);

	mkernel(0);
       

	int mismatches =0;
	for(i=0; i < RES_ITEMS; i++){
		if( *(RES_PTR + i) != *(REFERENCE_PTR + i) ){ 
			mismatches++;
		}
	}		
	printf("Test Completed: %s, mismatches = %2d\n", mismatches==0 ? "passed" : "failed", mismatches);
	
	printf("Core-0 Result at: 0x%X, Core-1 Result at: 0x%X, Core-2 Result at: 0x%X\n", RES_PTR, RES_PTR+1*RES_ITEMS, RES_PTR+2*RES_ITEMS);	
	for(i=0; i < RES_ITEMS; i++){
		printf("0x%08X:", *(RES_PTR + i) );
	}
	return(0);
}

