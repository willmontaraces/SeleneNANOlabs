#include <stdio.h> 
#include <stdint.h>
#include "util.h"
#include "binarysearch.h"
#include "asm.c"
//#include <time.h> 
#include "pmu_test.h"



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

                                              



void contender(void){

    //Desactivate software interruption
    volatile unsigned int *p;
    p = (unsigned int *) 0xE0100004;
    *p = 0x0;

    int *p1 = (int * ) (0x50000000);
    volatile int iterations = 20;
    int i;

    for (i = 0 ; i<2 ; i++){
    //while(1){
        //ld_l1hit(p, iterations);
        ld_l1miss(p1, iterations);
        //st_l1miss(p, iterations);
        //l1miss_ic(iterations);
    }
}



//Each one of the cores gets a different binary with the __CORE__ variable set 
//to te core ID of the processor. This is handled with a flag in the Makefile
//when doing make mulicore_exe

int main(void)
{
	    //mtvec, mie and mstatus are written in crt.S
//mtvec contains the direction of handle_trap, defined in syscalls.c
//when an interrupt is asserted, this function is executed
write_csr(mtvec, &contender);
printf("\nmtve: %x\n", read_csr(mtvec));

//Interruptions are activated in crt.S
//mie csr register activates each kind of interrupts separately
printf("\nmip: %x\n", read_csr(mie));

//Through mstatus interrupts are activated globally
printf("\nmstatus: %x\n", read_csr(mstatus));


#ifdef __CORE__
    switch (__CORE__) {
        case 1: ;

            volatile unsigned int *p;
            p = (unsigned int *) 0xE0100004;

            select_test_mode(0);  /*inputs from SoC*/
            reset_counters();
            reset_RDC();
            enable_RDC();
            enable_counters();

	    /*************************** binaryserach execution *******************************/
	    printf("\n\n ********* TESTBENCH BINARYSEARCH ********* \n\n"); 
            // This throuhgs a software interruption to CPU2 through plic module
            *p = 0x1;

	    binarysearch_all();

            disable_counters();
            disable_RDC();
            report_pmu();
	    /************************ end of binaryserach execution****************************/


	    /*************************** binaryserach execution *******************************/
	    printf("\n\n ********* TESTBENCH BINARYSEARCH ********* \n\n"); 
            // This throuhgs a software interruption to CPU2 through plic module
            *p = 0x1;

	    binarysearch_all();

            disable_counters();
            disable_RDC();
            report_pmu();
	    /************************ end of binaryserach execution****************************/

	    while(1);

            break;

        case 2:
            //printf("Hello from core: %d \n",__CORE__);
	    
	    while(1);


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



