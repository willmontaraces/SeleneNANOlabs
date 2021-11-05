//    ---------------------------------------------------
//    -- Register Map
//    ---------------------------------------------------
//
//    -- Sources 1 to nsources are implemented
//    -- All other sources registers are tied to 0
//    
//    -- base + 0x000000: Reserved (interrupt source 0 does not exist)
//    -- base + 0x000004: Interrupt source 1 priority
//    -- base + 0x000008: Interrupt source 2 priority
//    -- ...
//    -- base + 0x000FFC: Interrupt source 1023 priority
//    -- base + 0x001000: Interrupt Pending bit 0-31
//    -- base + 0x00107C: Interrupt Pending bit 992-1023
//
//    -- base + 0x002000: Enable bits for sources 0-31 on context 0
//    -- base + 0x002004: Enable bits for sources 32-63 on context 0
//    -- ...
//    -- base + 0x00207F: Enable bits for sources 992-1023 on context 0
//    -- base + 0x002080: Enable bits for sources 0-31 on context 1
//    -- base + 0x002084: Enable bits for sources 32-63 on context 1
//    -- ...
//    -- base + 0x0020FF: Enable bits for sources 992-1023 on context 1
//    -- base + 0x002100: Enable bits for sources 0-31 on context 2
//    -- base + 0x002104: Enable bits for sources 32-63 on context 2
//    -- ...
//    -- base + 0x00217F: Enable bits for sources 992-1023 on context 2
//
//    -- base + 0x020000: Priority threshold for context 0
//    -- base + 0x020004: Claim/complete for context 0
//    -- base + 0x020008: Reserved
//    -- ...
//    -- base + 0x020FFC: Reserved
//    -- base + 0x021000: Priority threshold for context 1
//    -- base + 0x021004: Claim/complete for context 1


#include <stdio.h> 
#include <stdint.h>
#include "util.h"
#include "asm.h"
//#include <time.h> 
#include "pmu_hw.h"

#include "binarysearch.h"
//#include "bitonic.h"
//#include "ludcmp.h"
//#include "matrix1.h"
//#include "lms.h"

#define PLIC_BASE 0x84000000
#define __UART_CORE1__
//#define __UART_CORE2__



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
void configure_interupts(void);

void configure_interupts(void) {

    volatile unsigned int *p;
    
    printf("\n\nCONFIGURE_PLIC:\n\n");

    //define the interrupt handler
    write_csr(mtvec, &interrupt_handler);


    //Check pending bits(32 downto 0) each bit n corresponds with hriq(n) signal
    p = (unsigned int*)(PLIC_BASE + 0x001000);
    printf("\npending bits: %x\n", *p); 


    //Enable interupts from 1 to 32 (interruption 0 does not exist)
    p = (unsigned int*)(PLIC_BASE + 0x002000); //context 0
    //p = (unsigned int*)(PLIC_BASE + 0x002080); //context 1
    *p = 0xffffffff;

    //Gives to the interrupt 7 the biggest possible priority (7)
    //Others interupts have 0 priority
    //Priority threshold is 0 by default
    //Interrupts with a priority level equal or lower than thershold
    //won't cause an interrupt (only 7 interrupt above thershold)
    p = (unsigned int*)(PLIC_BASE + 4*7);
    *p = 7;

}
                                              

void init_test(void) {
	
#ifdef __UART_CORE2__
    printf("\n\nINIT_TEST:\n\n");
#endif

    reset_RDC();
    reset_counters();
    volatile unsigned int *p;
    //Clear previous interupts
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
    volatile unsigned int *p;

#ifdef __UART_CORE2__
    printf("\n\nFINISH_TEST:\n\n");
#endif

    //Stop RDC and counters
    disable_RDC();
    disable_counters();

    // Stop MCCU
    p = (unsigned int*)(0x80200074);
    *p = 0b00;


    //Check the quota left of core0
    quota= (unsigned int *) (0x80200000 + 34*4);
#ifdef __UART_CORE2__
    printf("\nQuota left1: %u\n", *quota); 
#endif

    //Check pending bits(32 downto 0) each bit n corresponds with hriq(n) signal
    p = (unsigned int*)(PLIC_BASE + 0x001000);
    *p = 0;
#ifdef __UART_CORE2__
    printf("\npending bits: %x\n", *p); 
#endif
    
    //print results
#ifdef __UART_CORE2__
    report_pmu(); 
#endif

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
	

    int i=0;
    unsigned int int_num;
    volatile unsigned int csr_mip;
    volatile unsigned int *p;

#ifdef __UART_CORE1__
    printf("\n\nINTERRUPT_HANDLER:\n\n");
    
    printf("\nCORE: %u\n", __CORE__); 
    //if the cause is 11 means that the cause is a global interrupt
    printf("\nmcause: %u\n", read_csr(mcause)); 
#endif

    //PLIC asserts miep when there is a global interrupt
    //clear miep (not sure if it is needed)
#ifdef __UART_CORE1__
    printf("\nmip: %u\n", read_csr(mip)); 
#endif
    csr_mip = read_csr(mip) & ~(1 << 11);
#ifdef __UART_CORE1__
    printf("\nmip: %u\n", csr_mip); 
#endif
    write_csr(mip, csr_mip); 

    //stop mccu
    p = (unsigned int*)(0x80200074);
    *p = 0b00;

    //Check pending bits(32 downto 0) each bit n corresponds with hriq(n) signal
    p = (unsigned int*)(PLIC_BASE + 0x001000);
#ifdef __UART_CORE1__
    printf("\npending bits: %x\n", *p); 
#endif

    //Hart context is a given privilege mode on a given hart
    //Reads claim clomplete register
    //By reading this register the highest priority level active interruption ID should be obatined
    //In this case we should read a '7' instead we read a 0 always in every context which means
    //that no interut is pending. It shouldn't be like this... ¿?
    //for (i=0 ; i<1 ; i++){
    	p = (unsigned int*)(PLIC_BASE + 0x020004 + 0x1000*i); //Claim/complete register context 0
    	//p = (unsigned int*)(PLIC_BASE + 0x021004); //Claim/complete register context 1
    	int_num = *p;
#ifdef __UART_CORE1__
    	printf("\nInterrupt source: %u\n", *p); 
#endif
    //}

    //After a handler has completed service of an interrupt, the associated gateway must be sent an
    //interrupt completion message. This is done writing in the claim/complete register
    *p = int_num; 
    //After this, pending bits register(7) should be 0 but it is not
    //A new global interrupt wont be forwarded until completion is done

    //handle the interruption
    machine_external_interrupt();


    //Check pending bits(32 downto 0) each bit n corresponds with hriq(n) signal
    p = (unsigned int*)(PLIC_BASE + 0x001000);
#ifdef __UART_CORE1__
    printf("\npending bits: %x\n", *p); 
#endif

}

void machine_external_interrupt()
{
#ifdef __UART_CORE1__
    printf("\n\nMACHINE_EXTERNAL_INTERUPT:\n\n");
#endif

    volatile unsigned int *p;
    volatile unsigned int *quota;

#ifdef __UART_CORE1__
    //check the quota that is left in each core
    quota= (unsigned int *) (0x80200000 + 34*4);
    printf("\nQuota left1: %u\n", *quota); 
    quota= (unsigned int *) (0x80200000 + 35*4);
    printf("\nQuota left2: %u\n", *quota); 
    quota= (unsigned int *) (0x80200000 + 36*4);
    printf("\nQuota left3: %u\n", *quota); 
    
    // update quota MCCU
    //p = (unsigned int*)(0x80200074); 
    //*p = 0b0111100;
    //printf("\nQuota left3: %u\n", *quota); 
    //quota= (unsigned int *) (0x80200000 + 37*1);
    //printf("\nQuota left4: %u\n", *quota); 
#endif

}

//Each one of the cores gets a different binary with the __CORE__ variable set 
//to te core ID of the processor. This is handled with a flag in the Makefile


int main(void)
{

    //configure interupts
    configure_interupts();


// Core1 executes the main program while core0 executes the contender 
// Interupt raises in core0 only (I could not raise it in core1)

#ifdef __CORE__
    switch (__CORE__) {
        case 2: ;
	   
	    int result;

	    /*************************** binaryserach execution *******************************/
#ifdef __UART_CORE2__
	    printf("\n\n ********* TESTBENCH BINARYSEARCH ********* \n\n"); 
#endif


            init_test();

	    result=binarysearch_all();

            finish_test();

#ifdef __UART_CORE2__
	    //print result
	    if (result == 0) 
	            printf("\n------ TEST PASSED ------\n");
            else
	            printf("\n------ TEST FAILED ------\n");
#endif

	    
	    /************************ end of binaryserach execution****************************/



            while(1);

            break;


        case 1:
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



