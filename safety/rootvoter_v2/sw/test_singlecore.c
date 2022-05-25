/*  Description:
        RootVoter test application (baremetal multicore)
            
    Author / Developer: 
        Ilya Tuzov (Universitat Politecnica de Valencia)

*/ 
 
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include "RootVoter.h"

#define DSIZE 10
volatile uint64_t data[DSIZE];


int main()
{
    


    RootVoterDescriptor RVC0;
    RVC_sync(&RVC0, RVC0_BASE);
    printf("Features of RootVoter Cell version %d:\n\tBase address %08x:\n\tid=%2d\n\tMaxDatasets=%2d\n\tcount_matches=%2s\n\tlist_matches=%2s\n\tlist_failures=%2s\n",
            RVC0.inf.version,
            RVC0.base_adr,
            RVC0.inf.id,
            RVC0.inf.max_sets,
            RVC0.inf.count_matches==1?"YES":"NO",
            RVC0.inf.list_matches ==1?"YES":"NO",
            RVC0.inf.list_failures==1?"YES":"NO");


    
    VoteResult res;
    
    printf("\n\nTest-1: RVC (id=%2d) (2oo3) expected: pass/pass/pass \n", RVC0.inf.id);    
    RVC_reset(&RVC0, 0x23, 1000);    
    RVC_load_dataset(&RVC0, 0, 0xf1f2f3f4cafebabe);    //assume core-0, core-1 and core-2 have loaded their datasets
    RVC_load_dataset(&RVC0, 1, 0xf1f2f3f4cafebabe);    
    RVC_load_dataset(&RVC0, 2, 0xf1f2f3f4cafebabe);    
    res = RVC_vote(&RVC0);
    print_vote_result(&res);




    printf("\n\nTest-2: RVC (id=%2d) (2oo3) expected: pass/pass/timeout \n", RVC0.inf.id);    
    RVC_reset(&RVC0, 0x23, 1000);    
    RVC_load_dataset(&RVC0, 0, 0xa1a2a3a4a5a6a7a8);    //assume only core-0 and core-1 have loaded their datasets
    RVC_load_dataset(&RVC0, 1, 0xa1a2a3a4a5a6a7a8);    
    res = RVC_vote(&RVC0);
    print_vote_result(&res);
    
    
    

    printf("\n\nTest-3: RVC (id=%2d) (2oo3) expected:  timeout/fail/timeout \n", RVC0.inf.id);        
    RVC_reset(&RVC0, 0x23, 1000);
    RVC_load_dataset(&RVC0, 1, 0xc1c2c3c4c5c6c7c8);    //assume only core-1 has loaded its dataset
    res = RVC_vote(&RVC0);
    print_vote_result(&res);
    
    



    printf("\n\nTest-4: RVC (id=%2d) (2oo3) expected: pass/fail/pass \n", RVC0.inf.id);    
    RVC_reset(&RVC0, 0x23, 1000);    
    RVC_load_dataset(&RVC0, 0, 0xf1f2f3f4f5f6f7f8);    //assume core-0, core-1 and core-2 have loaded their datasets
    RVC_load_dataset(&RVC0, 1, 0x1112131415161718);    //assume core-1 loads invalid dataset 
    RVC_load_dataset(&RVC0, 2, 0xf1f2f3f4f5f6f7f8);    
    res = RVC_vote(&RVC0);
    print_vote_result(&res);
    


    return 0;
}
