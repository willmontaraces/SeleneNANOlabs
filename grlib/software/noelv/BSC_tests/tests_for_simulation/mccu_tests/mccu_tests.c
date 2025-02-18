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
    *p = 0x00000000;
    p = (unsigned int*)(0x8020009c); 
    *p = 0x00000001;
    //set limits
    //unsigned max_contention_ahb = (max_allowed_time-baseline)/N_contenders;
    // for cachebuster
        // baseline = Clock_cycles:,1597
        // max_allowed_time = 3 * baseline
        // N_contenders = __MAX_CORES__ -1 
    //Maximum quota allowed 
    //unsigned quota_core = max_contention_ahb/(__MAX_CORES__-1); 
    //unsigned quota_core = (22336587*2)/(__MAX_CORES__-1); 
    unsigned quota_core = 100;
        //c1
    p = (unsigned int*)(0x8020007c); 
    *p = 0;
        //c2
    p = (unsigned int*)(0x80200080); 
    *p = quota_core;
        //c3
    p = (unsigned int*)(0x80200084); 
    *p = 0;
    // update quota MCCU
    p = (unsigned int*)(0x80200074); 
    *p = 0b0111100;
    // enable MCCU
    p = (unsigned int*)(0x80200074);
    *p = 0b01;
}

void finish_test(void) {
    //Free contenders from IDLE loop of IRQ
    volatile unsigned int *p;
    // Stop MCCU
    p = (unsigned int*)(0x80200074);
    *p = 0b00;

    //Clear previous interrupts
    
    report_pmu(); 

}

void contender(void){

    //Desactivate software interruption
    volatile unsigned int *p;
    p = (unsigned int *) 0xE0100004;
    *p = 0x0;

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
    machine_external_interrupt();
}

void machine_external_interrupt()
{
    printf("\nholaaaaaa desde el plic\n");
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

write_csr(mtvec, &interrupt_handler);

#ifdef __CORE__
    switch (__CORE__) {
        case 1: ;
	   
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

            report_pmu();
	    
	    /************************ end of binaryserach execution****************************/


//	    /*************************** bitonic execution *******************************/
//	    printf("\n\n\n\n ********* TESTBENCH BITONIC ********* \n\n"); 
//	    select_test_mode(0);  /*inputs from SoC*/
//            reset_counters();
//            reset_RDC();
//            enable_RDC();
//            enable_counters();
//
//	    result=bitonic_all();
//
//            disable_counters();
//            disable_RDC();
//
//	    //print result
//	    if (result == 0) 
//		    printf("\n------ TEST PASSED ------\n");
//            else
//		    printf("\n------ TEST FAILED ------\n");
//
//            report_pmu();
//	    /************************ end of bitonic execution****************************/
//
//
//	    /*************************** ludcmp execution *******************************/
//	    printf("\n\n\n\n ********* TESTBENCH LUDCMP ********* \n\n"); 
//	    select_test_mode(0);  /*inputs from SoC*/
//            reset_counters();
//            reset_RDC();
//            enable_RDC();
//            enable_counters();
//
//	    result=ludcmp_all();
//
//            disable_counters();
//            disable_RDC();
//
//	    //print result
//	    if (result == 0) 
//		    printf("\n------ TEST PASSED ------\n");
//            else
//		    printf("\n------ TEST FAILED ------\n");
//	    
//            report_pmu();
//	    /************************ end of ludcmp execution****************************/
//
//
//	    /*************************** matrix1 execution *******************************/
//	    printf("\n\n\n\n ********* TESTBENCH MATRIX1 ********* \n\n"); 
//	    select_test_mode(0);  /*inputs from SoC*/
//            reset_counters();
//            reset_RDC();
//            enable_RDC();
//            enable_counters();
//
//	    result=matrix1_all();
//
//            disable_counters();
//            disable_RDC();
//
//	    //print result
//	    if (result == 0) 
//		    printf("\n------ TEST PASSED ------\n");
//            else
//		    printf("\n------ TEST FAILED ------\n");
//	    
//            report_pmu();
//	    /************************ end of matrix1 execution****************************/
//
//
//	    /*************************** lms execution *******************************/
//	    printf("\n\n\n\n ********* TESTBENCH LMS ********* \n\n"); 
//	    select_test_mode(0);  /*inputs from SoC*/
//            reset_counters();
//            reset_RDC();
//            enable_RDC();
//            enable_counters();
//
//	    result=lms_all();
//
//            disable_counters();
//            disable_RDC();
//
//	    //print result
//	    if (result == 0) 
//		    printf("\n------ TEST PASSED ------\n");
//            else
//		    printf("\n------ TEST FAILED ------\n");
//	    
//            report_pmu();
//	    /************************ end of lms execution****************************/
//	    
//
//




            break;

            while(1);

        case 2:
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



