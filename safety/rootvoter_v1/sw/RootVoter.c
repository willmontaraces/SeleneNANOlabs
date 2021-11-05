#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include "RootVoter.h"




int RVC_reset(RootVoterDescriptor* RVC){
    volatile uint64_t* voter_base = RVC->base_adr;
    *(voter_base+31) = 0xF;                         //reset command (clears configuration register and datasets)
    volatile uint64_t state_reg = *(voter_base+19);
	uint64_t sync = (state_reg>>32)&0xFFFFFFFF;
	if(sync != 0x55555555){
        printf("RVC_reset: sync failure\n");
        return(1);		
	}
	RVC->state = state_reg&0x1F;             		//ensure that state_reg == idle
    if(RVC->state != 0x1){
        printf("RVC_reset: reset failure\n");
        return(1);
    }	
	*(voter_base+0) = (RVC->timeout << 2)&0x3FFFC | (RVC->cell_type)&0x3;    //{timeout_counter[15:0]}, {cell_type[1:0]}
    return(0);
}


//dataset_id = 0(set_a) / 1(set_b) / ....
int RVC_load_dataset(RootVoterDescriptor* RVC, uint64_t dataset_id, uint64_t dataset){
    volatile uint64_t* voter_base = RVC->base_adr;
    if( (RVC->cell_type==0x0 && dataset_id >= 2) || 
        (RVC->cell_type==0x1 && dataset_id >= 3) ||
        (RVC->cell_type==0x2 && dataset_id >= 7) ||
        (RVC->cell_type==0x2 && dataset_id >= 9)    )
        {
            printf("RVC_load_dataset failure: incorrect dataset_id\n");
            return(1);
        }
    else{
        *(voter_base+1+dataset_id) = dataset;        
    }
    return(0);
}




VoteResult RVC_vote(RootVoterDescriptor* RVC){
    volatile uint64_t* voter_base = RVC->base_adr;
    volatile uint64_t read_offset = 10;    //registers 0-9 are used as RVCELL inputs, registers 10-20 used as RVCELL outputs 
    volatile uint64_t status = 0;
    volatile uint64_t ready = 0;
    	
	
    //poll RVC ready (status[0:0])
    do{
        status = *(voter_base + read_offset + 10);
        ready = status & 0x1;
    }while(ready  == 0);  


        
    volatile VoteResult res = {    
                    .mode = RVC->cell_type, 
                    .agreement=0x0, 
                    .status_a = 0, .status_b = 0, .status_c = 0, .status_d = 0, .status_e = 0, .status_f = 0, .status_g = 0, .status_h = 0, .status_i = 0, 
                    .res_a = 0,    .res_b = 0,    .res_c= 0,     .res_d = 0,    .res_e = 0,    .res_f = 0,    .res_g = 0,    .res_h = 0,    .res_i = 0};    



    //2oo2
    if(RVC->cell_type == 0){
        res.res_a = *(voter_base+read_offset+0);
        res.res_b = *(voter_base+read_offset+1);
        //timeout=2 : matches/mismatches majority of datasets (pass=1/fail=0)
        res.status_a = (status >> 1)&0x1 ? 2 : res.res_a > 0;     
        res.status_b = (status >> 2)&0x1 ? 2 : res.res_b > 0;     
        //agreement reached when any dataset macthes majority of datasets
        if(res.status_a==1 || res.status_b==1){        
            res.agreement = 0x1;
        }
    }
    
    //2oo3
    else if(RVC->cell_type == 1){
        res.res_a = *(voter_base+read_offset+0);
        res.res_b = *(voter_base+read_offset+1);
        res.res_c = *(voter_base+read_offset+2);        
        //timeout=2 : matches/mismatches majority of datasets (pass=1/fail=0)
        res.status_a = (status >> 1)&0x1 ? 2 : res.res_a >= 1;     
        res.status_b = (status >> 2)&0x1 ? 2 : res.res_b >= 1 ;     
        res.status_c = (status >> 3)&0x1 ? 2 : res.res_c >= 1;     
        //agreement reached when any dataset macthes majority of datasets
        if(res.status_a==1 || res.status_b==1 || res.status_c==1){        
            res.agreement = 0x1;
        }
    }
    
    //4oo7
    else if(RVC->cell_type == 2){
        res.res_a = *(voter_base+read_offset+0);
        res.res_b = *(voter_base+read_offset+1);
        res.res_c = *(voter_base+read_offset+2);    
        res.res_d = *(voter_base+read_offset+3);
        res.res_e = *(voter_base+read_offset+4);
        res.res_f = *(voter_base+read_offset+5);
        res.res_g = *(voter_base+read_offset+6);
        //timeout=2 : matches/mismatches majority of datasets (pass=1/fail=0)
        res.status_a = (status >> 1)&0x1 ? 2 : res.res_a >= 3;     
        res.status_b = (status >> 2)&0x1 ? 2 : res.res_b >= 3;     
        res.status_c = (status >> 3)&0x1 ? 2 : res.res_c >= 3;
        res.status_d = (status >> 4)&0x1 ? 2 : res.res_d >= 3;
        res.status_e = (status >> 5)&0x1 ? 2 : res.res_e >= 3;
        res.status_f = (status >> 6)&0x1 ? 2 : res.res_f >= 3;
        res.status_g = (status >> 7)&0x1 ? 2 : res.res_g >= 3;
        //agreement reached when any dataset macthes majority of datasets
        if(res.status_a==1 || res.status_b==1 || res.status_c==1 || res.status_d==1 || res.status_e==1 || res.status_f==1 || res.status_g==1){        
            res.agreement = 0x1;
        }        
    }
    
    
    //5oo9
    else if(RVC->cell_type == 3){
        res.res_a = *(voter_base+read_offset+0);
        res.res_b = *(voter_base+read_offset+1);
        res.res_c = *(voter_base+read_offset+2);    
        res.res_d = *(voter_base+read_offset+3);
        res.res_e = *(voter_base+read_offset+4);
        res.res_f = *(voter_base+read_offset+5);
        res.res_g = *(voter_base+read_offset+6);
        res.res_h = *(voter_base+read_offset+7);
        res.res_i = *(voter_base+read_offset+8);
        //timeout=2 : matches/mismatches majority of datasets (pass=1/fail=0)
        res.status_a = (status >> 1)&0x1 ? 2 : res.res_a >= 4;     
        res.status_b = (status >> 2)&0x1 ? 2 : res.res_b >= 4;     
        res.status_c = (status >> 3)&0x1 ? 2 : res.res_c >= 4;
        res.status_d = (status >> 4)&0x1 ? 2 : res.res_d >= 4;
        res.status_e = (status >> 5)&0x1 ? 2 : res.res_e >= 4;
        res.status_f = (status >> 6)&0x1 ? 2 : res.res_f >= 4;
        res.status_g = (status >> 7)&0x1 ? 2 : res.res_g >= 4;
        res.status_h = (status >> 8)&0x1 ? 2 : res.res_h >= 4;
        res.status_i = (status >> 9)&0x1 ? 2 : res.res_i >= 4;    
        //agreement reached when any dataset macthes majority of datasets
        if(res.status_a==1 || res.status_b==1 || res.status_c==1 || res.status_d==1 || res.status_e==1 || res.status_f==1 || res.status_g==1 || res.status_h==1 || res.status_i==1){        
            res.agreement = 0x1;
        }
    }        
    return(res);
}


void print_vote_result(VoteResult* v){
   if(v->mode == 0x1){
    printf("2oo3 Agreement: %d (%s); By core: core-0: %d (%s), core-1: %d (%s), core-2: %d (%s) \n", 
                v->agreement, v->agreement > 0 ? "pass" : "fail",
                v->status_a, v->status_a==2 ? "timeout" : (v->status_a==1 ? "pass" : "fail"),
                v->status_b, v->status_b==2 ? "timeout" : (v->status_b==1 ? "pass" : "fail"),
                v->status_c, v->status_c==2 ? "timeout" : (v->status_c==1 ? "pass" : "fail"));
   }
   else if(v->mode == 0x3){
    printf("5oo9 Agreement: %d (%s); By core: core-0: %d (%s), core-1: %d (%s), core-2: %d (%s), core-3: %d (%s), core-4: %d (%s), core-5: %d (%s), core-6: %d (%s), core-7: %d (%s), core-8: %d (%s) \n", 
                v->agreement, v->agreement > 0 ? "pass" : "fail",
                v->status_a, v->status_a==2 ? "timeout" : (v->status_a==1 ? "pass" : "fail"),
                v->status_b, v->status_b==2 ? "timeout" : (v->status_b==1 ? "pass" : "fail"),
                v->status_c, v->status_c==2 ? "timeout" : (v->status_c==1 ? "pass" : "fail"),
                v->status_d, v->status_d==2 ? "timeout" : (v->status_d==1 ? "pass" : "fail"),
                v->status_e, v->status_e==2 ? "timeout" : (v->status_e==1 ? "pass" : "fail"),
                v->status_f, v->status_f==2 ? "timeout" : (v->status_f==1 ? "pass" : "fail"),
                v->status_g, v->status_g==2 ? "timeout" : (v->status_g==1 ? "pass" : "fail"),
                v->status_h, v->status_h==2 ? "timeout" : (v->status_h==1 ? "pass" : "fail"),
                v->status_i, v->status_i==2 ? "timeout" : (v->status_i==1 ? "pass" : "fail")
                );
       
       
   }
}



