#include "workload.h"
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>


#define SYNC_BUF_ADR 0x1000000

volatile int * RES_PTR;
volatile int * SYNC_BUF;


int main(void)
{
	int ret;
	int ncpu;
	int i, j;
    SYNC_BUF = (int *) SYNC_BUF_ADR;
    
    
	ncpu =4;
	RES_PTR = memalign(4096, ncpu*RES_ITEMS*sizeof(int));    
    *SYNC_BUF = 0x0;

    printf("Core-0 Result at: 0x%X, Core-1 Result at: 0x%X, Core-2 Result at: 0x%X\n", RES_PTR, RES_PTR+1*RES_ITEMS, RES_PTR+2*RES_ITEMS);	  
    
    while(1){
        while(*SYNC_BUF == 0x0){ };
        *SYNC_BUF = 0x0;
        
        for(i=0; i<ncpu*RES_ITEMS; i++){
            *(RES_PTR + i) = 0;
        }
        
        mkernel(0);
        
	}
    


        //print-out the results from both core-0 and core-1
      
	

/*
	for(i=0; i < RES_ITEMS; i++){
		printf("%08X:", *(RES_PTR + i) );
	}
	printf(" Core-0 Completed\n");
*/

        return 0;
}

