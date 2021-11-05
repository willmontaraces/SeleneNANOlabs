#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include "RootVoter.h"


//Synchronizes with RV cell at address BASEADR
//Retrieves RV cell features from state register
//Checks the validity of RV configuration and saves it to RVC descriptor
//Returns: 0 if init successful, 1 otherwise
int RVC_sync(RootVoterDescriptor* RVC, uint64_t BASEADR){
    RVC->base_adr = (uint64_t*)BASEADR;
    //sync and read RVC confguration 
    volatile uint64_t* voter_base = RVC->base_adr;    
    volatile uint64_t state_reg = *(voter_base+19);
    uint64_t sync = (state_reg>>32)&0xFFFFFFFF;
    if(sync != 0x55555555){
        printf("RVC_sync: sync failure\n");
        return(1);
    }
    //parse RVC configuration (supported RVC features)
    RVC->inf.id            = (state_reg >> 8)  & 0xF;
    RVC->inf.max_sets      = (state_reg >> 12) & 0x1F;
    RVC->inf.list_failures = (state_reg >> 17) & 0x1;
    RVC->inf.list_matches  = (state_reg >> 18) & 0x1;
    RVC->inf.count_matches = (state_reg >> 19) & 0x1;
        
    return(0);
}


//Clears RV cell registers
//Sets RV configuration (voting mode and timeout)
//after execution RV cell remains in wait_datasets state
//Returns: 0 if reset successful, 1 otherwise
int RVC_reset(RootVoterDescriptor* RVC, uint8_t mode, uint64_t max_wait_time){    
    volatile uint64_t* voter_base = RVC->base_adr;
    //reset command (clears configuration register and datasets)
    *(voter_base+31) = 0xF;        
    //ensure that RVC state =idle
    volatile uint64_t state_reg = *(voter_base+19);
    uint8_t FSM_state = state_reg&0x1F;
    if(FSM_state != 0x1){
        printf("RVC_reset: FSM reset failure\n");
        return(1);
    }
    
    //Check the validity of requested RVC configuration
    uint8_t N =  mode    &0xF;
    uint8_t M = (mode>>4)&0xF;   
    if( (N <= RVC->inf.max_sets) && (M <= N) && (M >= 2) ) {
        RVC->mode = mode;
    }
    else{
        printf("RVC_reset: unsupported RVC configuration: M=%d, N=%d, max_sets=%d\n", M, N, RVC->inf.max_sets);
        return(1);
    }    
    RVC->timeout = max_wait_time;    
    
    //Load RVC configuration to the config register
    *(voter_base+0) = ((RVC->timeout << 8)&0xFFFFFFFF00) | (RVC->mode & 0xFF);
    
    //From here on (during next <timeout> clock cycles) RV cell is waiting for datasets 
    return(0);
}




//Loads a dataset to the set[dataset_id] register of RVC
int RVC_load_dataset(RootVoterDescriptor* RVC, uint8_t dataset_id, uint64_t dataset){
    volatile uint64_t* voter_base = RVC->base_adr;
    if( dataset_id <= RVC->inf.max_sets){
        *(voter_base+1+dataset_id) = dataset;
    }
    else{
        printf("RVC_load_dataset failure: incorrect dataset_id\n");
        return(1);
    }
    return(0);
}




VoteResult RVC_vote(RootVoterDescriptor* RVC){
    volatile uint64_t* voter_base = RVC->base_adr;
    volatile uint64_t read_offset = 17;    //registers 0-16 are used as RVCELL inputs, registers 17-21 used as outputs 
    volatile uint64_t status = 0;
    volatile uint64_t ready = 0;
            
    volatile VoteResult res = {    
                    .mode       = RVC->mode, 
                    .failvec    = 0x0,
                    .timeout    = 0x0,
                    .agreement  = 0x0,
                    .matchvec_p1= 0x0,
                    .matchvec_p2= 0x0
                    };    

    
    //poll RVC ready (status[0:0])
    do{
        status = *(voter_base + read_offset + 3);
        ready = status & 0x1;
    }while(ready  == 0);  

    //parse timeout flags (16 bits - one per dataset)
    res.timeout = (status >> 8) & 0xFFFF;


    //parse failure flags (16 bits - one per dataset)
    if(RVC->inf.list_failures){
        res.failvec = (status >> 24) & 0xFFFF;
    }
    
    //read match counters (64 bits - 4 per dataset)
    if(RVC->inf.count_matches){
        res.match_cnt = *(voter_base + read_offset + 4);
    }

    //derive agreement flag
    uint8_t N =  RVC->mode    &0xF;
    uint8_t M = (RVC->mode>>4)&0xF;
    for(int i=0; i<N; i++){
        if(RVC->inf.list_failures){
            if( ((res.failvec>>i)&0x1) == 0){ 
                res.agreement=1;
                break;
            }
        }
        else if(RVC->inf.count_matches){
            if( ((res.match_cnt>>(4*i))&0xF) >= (M-1) ){
                res.agreement=1;
                break;
            }
        }
    }   
    return(res);
}



void print_vote_result(VoteResult* v){
    uint8_t N =  v->mode    &0xF;
    uint8_t M = (v->mode>>4)&0xF;    
    printf("RVC Mode = %d/%d, Timeout=%04x, Failvec=%04x, Agreement=%s\n", M, N, v->timeout, v->failvec, v->agreement?"YES":"NO");
    for(int i=0;i<N;i++){
        uint8_t fail    = (v->failvec>>i)&0x1;
        uint8_t timeout = (v->timeout>>i)&0x1;
        uint8_t cnt     = (v->match_cnt>>(4*i))&0xF;
        printf("set[%2d]: result = %s, cnt = %2d\n", 
                i,
                timeout>0 ? "Timeout" : (fail>0 ? "Fail" : "Pass"),
                cnt);
    }
}



