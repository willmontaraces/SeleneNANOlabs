/* 
	RootVoter test application (baremetal single core)
 */
 
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include "RootVoter.h"

#define DSIZE 10
volatile uint64_t data[DSIZE];


int main()
{

	RootVoterDescriptor RVC0 = {.id =1, .base_adr = (uint64_t*)RVC0_BASE, .timeout = (uint64_t)1000, .cell_type = 1, .state = 0};
	RootVoterDescriptor RVC3 = {.id =3, .base_adr = (uint64_t*)RVC3_BASE, .timeout = (uint64_t)1000, .cell_type = 3, .state = 0};
	VoteResult res;


	printf("Test-1: RVC_0 (2oo3) expected: pass : pass/pass/pass \n");	
	RVC_reset(&RVC0);	
	RVC_load_dataset(&RVC0, 0, 0xf1f2f3f4cafebabe);	//assume core-0, core-1 and core-2 have loaded their datasets
	RVC_load_dataset(&RVC0, 1, 0xf1f2f3f4cafebabe);	
	RVC_load_dataset(&RVC0, 2, 0xf1f2f3f4cafebabe);	
	res = RVC_vote(&RVC0);
	print_vote_result(&res);




	printf("Test-2: RVC_0 (2oo3) expected: pass : pass/pass/timeout \n");	
	RVC_reset(&RVC0);	
	RVC_load_dataset(&RVC0, 0, 0xa1a2a3a4a5a6a7a8);	//assume only core-0 and core-1 have loaded their datasets
	RVC_load_dataset(&RVC0, 1, 0xa1a2a3a4a5a6a7a8);	
	res = RVC_vote(&RVC0);
	print_vote_result(&res);
	
	
	

	printf("Test-3: RVC_0 (2oo3) expected: fail : timeout/fail/timeout \n");		
	RVC_reset(&RVC0);
	RVC_load_dataset(&RVC0, 1, 0xc1c2c3c4c5c6c7c8);	//assume only core-1 has loaded its dataset
	res = RVC_vote(&RVC0);
	print_vote_result(&res);
	
	



	printf("Test-4: RVC_0 (2oo3) expected: pass : pass/fail/pass \n");	
	RVC_reset(&RVC0);	
	RVC_load_dataset(&RVC0, 0, 0xf1f2f3f4f5f6f7f8);	//assume core-0, core-1 and core-2 have loaded their datasets
	RVC_load_dataset(&RVC0, 1, 0x1112131415161718);	//assume core-1 loads invalid dataset 
	RVC_load_dataset(&RVC0, 2, 0xf1f2f3f4f5f6f7f8);	
	res = RVC_vote(&RVC0);
	print_vote_result(&res);
	


	printf("Test-5: RVC_3 (7oo9) expected: pass : pass/fail/fail/pass/pass/pass/pass/fail/pass \n");	
	RVC_reset(&RVC3);	
	RVC_load_dataset(&RVC3, 0, 0xf1f2f3f4cafebabe);	
	RVC_load_dataset(&RVC3, 1, 0xcccccccccccccccc);	
	RVC_load_dataset(&RVC3, 2, 0xa1a2a3a4a5a6a7a8);	
	RVC_load_dataset(&RVC3, 3, 0xf1f2f3f4cafebabe);	
	RVC_load_dataset(&RVC3, 4, 0xf1f2f3f4cafebabe);	
	RVC_load_dataset(&RVC3, 5, 0xf1f2f3f4cafebabe);	
	RVC_load_dataset(&RVC3, 6, 0xf1f2f3f4cafebabe);	
	RVC_load_dataset(&RVC3, 7, 0xc1c2c3c4c5c6c7c8);	
	RVC_load_dataset(&RVC3, 8, 0xf1f2f3f4cafebabe);	
	res = RVC_vote(&RVC3);
	print_vote_result(&res);


	return 0;
}
