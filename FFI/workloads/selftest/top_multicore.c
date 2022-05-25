#include <bcc/bcc.h>
#include "workload.h"
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>



/* some stack for your processors */
uint64_t thestack[16][4096];

volatile int RES[16][RES_ITEMS];
volatile int *RES_PTR;
volatile int *REFERENCE_PTR;

int mismatches[16];

int main(void)
{
	int ret;
	int ncpu;
	int i, j;

	ncpu = bcc_get_cpu_count();	
	printf("%s (0x%X): running on processor 0 / %d \n", __func__, &main, ncpu);
        	
	RES_PTR = &RES[0][0];
	for(i=0; i<ncpu*RES_ITEMS; i++){
		*(RES_PTR + i) = 0;
	}
        			

	for (int i = 1; i < ncpu; i++) {
			__bcc_startinfo[i].pc = &mkernel;
			__bcc_startinfo[i].sp = (uintptr_t) &thestack[i+1][0];
	}


	printf("%s (0x%X): starting processors 1 to %d\n", __func__, &mkernel, ncpu);
	for(int i=1;i<ncpu;i++){
		ret = bcc_start_processor(i);			
	}
	
	mkernel(0);
       
    
	//Check results and diagnose
	int mismatches_total = 0;
	for(i=0; i<ncpu; i++){	
		mismatches[i] = 0;
		for(j=0; j < RES_ITEMS; j++){
			if( *(RES_PTR + i*RES_ITEMS + j) != *(REFERENCE_PTR + j) ){ 
				mismatches[i]++;
				mismatches_total++;
			}
		}	
	}
	
	printf("Test Completed: %s, mismatches: %2d\n", mismatches_total==0 ? "passed" : "failed", mismatches_total);
	for(i=0; i<ncpu; i++){
		printf("core-%1d mismatches: %2d\n", i, mismatches[i]);
	}

	//print-out the results from both core-0 and core-1
	for(int i=0;i<ncpu;i++){	
		printf("Core-%02d Result at addr: 0x%X, res[0:%03d]=%08X...%08X\n", i, RES_PTR+i*RES_ITEMS, RES_ITEMS, RES[i][0], RES[i][RES_ITEMS-1]);
	}


	return(0);
}

