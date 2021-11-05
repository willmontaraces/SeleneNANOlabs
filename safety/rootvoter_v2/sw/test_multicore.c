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
    VoteResult res;
    
    RVC_sync(&RVC0, RVC0_BASE);
    printf("Features of RootVoter Cell at base address %08x:\n\tid=%2d\n\tMaxDatasets=%2d\n\tcount_matches=%2s\n\tlist_matches=%2s\n\tlist_failures=%2s\n",
            RVC0.base_adr,
            RVC0.inf.id,
            RVC0.inf.max_sets,
            RVC0.inf.count_matches==1?"YES":"NO",
            RVC0.inf.list_matches ==1?"YES":"NO",
            RVC0.inf.list_failures==1?"YES":"NO");
        
    
    
    ncpu = bcc_get_cpu_count();    
                
    if (ncpu < 4) {
        printf("This workload requires 4 processors\n");
        exit(0);
    }
    

    for (int i = 1; i < ncpu; i++) {
        __bcc_startinfo[i].pc = &mkernel;
        __bcc_startinfo[i].sp = (uintptr_t) &thestack[i+1][0];
    }

    printf("%s (0x%X): start kernel on cores 1-%d\n", __func__, &mkernel, ncpu);



    RVC_reset(&RVC0, 0x23, 10000);
    ret = bcc_start_processor(1);
    ret = bcc_start_processor(2);
    ret = bcc_start_processor(3);
    res = RVC_vote(&RVC0);
    print_vote_result(&res);
                
    printf("Finished\n");    
       
    
    return(0);
}

