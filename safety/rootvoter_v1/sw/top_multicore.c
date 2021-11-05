#include <stdio.h>
#include <stdlib.h>
#include <bcc/bcc.h>
#include <stdint.h>
#include "RootVoter.h"
#include "kernel.h"



/* some stack for your processors */
uint64_t thestack[16][4096];

volatile int * RES_PTR;
int RES_ARR[3][RES_ITEMS];
RootVoterDescriptor RVC0;


int main(void)
{
	int ret;
	int ncpu;
	int i, j;
	RVC0 = (RootVoterDescriptor) {.id =0, .base_adr = (uint64_t*)RVC0_BASE, .timeout = (uint64_t)10000, .cell_type = 1, .state = 0};
	VoteResult res;
	
	ncpu = bcc_get_cpu_count();	
	
        	
        if (ncpu < 4) {
                printf("This workload requires 4 processors\n");
                exit(0);
        }
		
	RES_PTR = &(RES_ARR[0]); //memalign(4096, ncpu*RES_ITEMS*sizeof(int));
	
        for (int i = 1; i < ncpu; i++) {
                __bcc_startinfo[i].pc = &mkernel;
                __bcc_startinfo[i].sp = (uintptr_t) &thestack[i+1][0];
        }



	printf("%s (0x%X): start kernel on cores\n", __func__, &mkernel);

	RVC_reset(&RVC0);
	ret = bcc_start_processor(1);
	ret = bcc_start_processor(2);
	ret = bcc_start_processor(3);
	res = RVC_vote(&RVC0);
	print_vote_result(&res);
				
	printf("Finished\n");	
       
	
	return(0);
}

