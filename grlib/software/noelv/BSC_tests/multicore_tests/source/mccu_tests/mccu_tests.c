#include <stdio.h> 
#include <stdint.h>
#include "util.h"
#include "asm.h"
//#include <time.h> 
#include "pmu_test.h"

#include "binarysearch.h"
#include "bitonic.h"
#include "ludcmp.h"
#include "matrix1.h"
#include "lms.h"

#define PLIC_BASE 0x84000000



//This defines are set by the makefile, but for single core when running 
//make mp_ubench.exe a value is required
#ifndef __CORE__
    #define __CORE__ 1
#endif

//Function that overrides the crt.S function to allow more than one thread
void thread_entry(int cid, int nc)
{
        return;
}
//Functions that executes the contender and the benchmarks
void contender(void);
void init_test(void);
void finish_test(void);
void machine_external_interrupt(void);
void interrupt_handler(void);

                                              
void init_test(void) {
    reset_RDC();
    reset_counters();
    volatile unsigned int *p;
    //Clear previous interrupts
    //
    //hold quota and counters
    p = (unsigned int*)(0x80200000);
    *p = 0x00000012;
    //release reset counters and quota
    p = (unsigned int*)(0x80200000);
    *p = 0x00000000;
    // hold reset MCCU
    p = (unsigned int*)(0x80200074); 
    *p = 0b10;
    //set weigths. Measured CCS is assigned to each Data miss of the contenders.
        //Do not assing the measured weights of the CSS to CSS signals since this signals measure 
        //real contention weight will be 1. If CSS and datamiss weights are active at the same time
        //for MCCU quota will be substracted twice, since the root cause of the CSS is the Dmiss.
    p = (unsigned int*)(0x80200098); 
    *p = 0x00006060;
    p = (unsigned int*)(0x8020009c); 
    *p = 0x00000000;
    //set limits
    //unsigned max_contention_ahb = (max_allowed_time-baseline)/N_contenders;
    // for cachebuster
        // baseline = Clock_cycles:,1597
        // max_allowed_time = 3 * baseline
        // N_contenders = __MAX_CORES__ -1 
    //Maximum quota allowed 
    //unsigned quota_core = max_contention_ahb/(__MAX_CORES__-1); 
    //unsigned quota_core = (22336587*2)/(__MAX_CORES__-1); 
    unsigned int quota_core = 200;
        //c0
    p = (unsigned int*)(0x80200078); 
    *p = quota_core;
        //c1
    p = (unsigned int*)(0x8020007c); 
    *p = 0xffffffff;
        //c2
    p = (unsigned int*)(0x80200080); 
    *p = 0xffffffff;
        //c3
    p = (unsigned int*)(0x80200084); 
    *p = 0xffffffff;
    // update quota MCCU
    p = (unsigned int*)(0x80200074); 
    *p = 0b0111100;
    // enable MCCU
    p = (unsigned int*)(0x80200074);
    *p = 0b01;
    enable_RDC();
    enable_counters();
}

void finish_test(void) {
    volatile unsigned int *quota;
    quota= (unsigned int *) (0x80200000 + 37*4);
    printf("\nQuota left4: %u\n", *quota); 
    //Free contenders from IDLE loop of IRQ
    volatile unsigned int *p;
    disable_RDC();
    disable_counters();
    // Stop MCCU
    p = (unsigned int*)(0x80200074);
    *p = 0b00;

    p = (unsigned int*)(PLIC_BASE + 0x001000);
    *p = 0;
    printf("\npending bits: %x\n", *p); 
    
    report_pmu(); 

}

void contender(void){


    int *p1 = (int * ) (0x50000000);
    volatile int iterations = 50000;
    int i;

    while(1){
        //ld_l1hit(p, iterations);
        ld_l1miss(p1, iterations);
        //st_l1miss(p, iterations);
        //l1miss_ic(iterations);
    }
}


void interrupt_handler(void){
   int i;
    unsigned int int_num;
    volatile unsigned int csr_mip;
    volatile unsigned int *p;
    
    printf("\nCORE: %u\n", __CORE__); 
    printf("\nmcause: %u\n", read_csr(mcause)); 

    //clear miep
    printf("\nmip: %u\n", read_csr(mip)); 
    csr_mip = read_csr(mip) & ~(1 << 11);
    printf("\nmip: %u\n", csr_mip); 
    write_csr(mip, csr_mip); 

    //stop mccu
    p = (unsigned int*)(0x80200074);
    *p = 0b00;

    p = (unsigned int*)(PLIC_BASE + 0x001000);
    printf("\npending bits: %x\n", *p); 

    for (i=0 ; i<1 ; i++){
    	p = (unsigned int*)(PLIC_BASE + 0x020004 + 0x1000*i); //Claim/complete register context 0
    	//p = (unsigned int*)(PLIC_BASE + 0x021004); //Claim/complete register context 1
    	int_num = *p;
    	printf("\nInterrupt source: %u\n", *p); 
    }

    *p = 5; //int_num; ack

    machine_external_interrupt();


    p = (unsigned int*)(PLIC_BASE + 0x001000);
    printf("\npending bits: %x\n", *p); 

}

void machine_external_interrupt()
{
    printf("\nhola desde el plic\n");

    volatile unsigned int *p;
    volatile unsigned int *quota;
    quota= (unsigned int *) (0x80200000 + 34*4);
    printf("\nQuota left1: %u\n", *quota); 
    quota= (unsigned int *) (0x80200000 + 35*4);
    printf("\nQuota left2: %u\n", *quota); 
    quota= (unsigned int *) (0x80200000 + 36*4);
    printf("\nQuota left3: %u\n", *quota); 
    
    // update quota MCCU
    p = (unsigned int*)(0x80200074); 
    *p = 0b0111100;
    printf("\nQuota left3: %u\n", *quota); 

    quota= (unsigned int *) (0x80200000 + 37*4);
    printf("\nQuota left4: %u\n", *quota); 


    ////get the highest priority pending PLIC interrupt
    //uint32_t int_num = plic.claim_comlete;
    ////branch to handler
    //plic_handler[int_num]();
    ////complete interrupt by writing interrupt number back to PLIC
    //plic.claim_complete = int_num;
}
//Each one of the cores gets a different binary with the __CORE__ variable set 
//to te core ID of the processor. This is handled with a flag in the Makefile
//when doing make mulicore_exe

int main(void)
{

    //define the interrupt handler
    write_csr(mtvec, &interrupt_handler);

    //plic: activate external interrupts
    volatile unsigned int *p;

    p = (unsigned int*)(PLIC_BASE + 0x001000);
    printf("\npending bits: %x\n", *p); 


    p = (unsigned int*)(PLIC_BASE + 0x002000); //context 0
    //p = (unsigned int*)(PLIC_BASE + 0x002080); //context 1
    *p = 0xffffffff;

    //p = (unsigned int*)(PLIC_BASE + 4*3);
    //*p = 7;

    //p = (unsigned int*)(PLIC_BASE + 4*4);
    //*p = 7;

    p = (unsigned int*)(PLIC_BASE + 4*7);
    *p = 7;

    //p = (unsigned int*)(PLIC_BASE + 4*7);
    //*p = 7;

#ifdef __CORE__
    switch (__CORE__) {
        case 2: ;
	   
	    int result;

	    /*************************** binaryserach execution *******************************/
	    printf("\n\n ********* TESTBENCH BINARYSEARCH ********* \n\n"); 

            //select_test_mode(0);  /*inputs from SoC*/
            //reset_counters();
            //reset_RDC();
            //enable_RDC();
            //enable_counters();

            init_test();

	    result=binarysearch_all();

            finish_test();

	    //print result
	    if (result == 0) 
	            printf("\n------ TEST PASSED ------\n");
            else
	            printf("\n------ TEST FAILED ------\n");

	    
	    /************************ end of binaryserach execution****************************/



            while(1);

            break;


        case 1:
            //printf("Hello from core: %d \n",__CORE__);
	    //contention 
	    while(1)
            	contender();


            break;

    }
#else
    //This shall never be reached if makefile is setup propperly
    while(1){
    printf("__CORE__ not defined\n");
    }
#endif
    return(0);
}



