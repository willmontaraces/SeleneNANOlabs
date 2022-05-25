#include <bcc/bcc.h>
#include "workload.h"
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>



/* some stack for your processors */
uint64_t thestack[16][4096];

volatile int * RES_PTR;



int main(void)
{
	int ret;
	int ncpu;
	int i, j;

	ncpu = bcc_get_cpu_count();	
	printf("%s (0x%X): running on processor 0 / %d \n", __func__, &main, ncpu);
        	
	RES_PTR = memalign(4096, ncpu*RES_ITEMS*sizeof(int));
	for(i=0; i<ncpu*RES_ITEMS; i++){
		*(RES_PTR + i) = 0;
	}
        	
        if (ncpu < 3) {
                printf("This workload requires at least 3 processors\n");
                exit(0);
        }
		

        for (int i = 1; i < ncpu; i++) {
                __bcc_startinfo[i].pc = &mkernel;
                __bcc_startinfo[i].sp = (uintptr_t) &thestack[i+1][0];
        }


        
        printf("%s (0x%X): start processor 1\n", __func__, &mkernel);
        ret = bcc_start_processor(1);
        ret = bcc_start_processor(2);
	
	mkernel(0);
       
    


        //print-out the results from both core-0 and core-1
	printf("Core-0 Result at: 0x%X, Core-1 Result at: 0x%X, Core-2 Result at: 0x%X\n", RES_PTR, RES_PTR+1*RES_ITEMS, RES_PTR+2*RES_ITEMS);	
	for(i=0; i < RES_ITEMS; i++){
		printf("%08X:", *(RES_PTR + i) );
	}
	printf(" Core-0 Completed\n");

	for(i=RES_ITEMS; i < 2*RES_ITEMS; i++){
		printf("%08X:", *(RES_PTR + i) );
	}
	printf(" Core-1 Completed\n");

	for(i=2*RES_ITEMS; i < 3*RES_ITEMS; i++){
		printf("%08X:", *(RES_PTR + i) );
	}
	printf(" Core-2 Completed\n");	
	

        return 0;
}

