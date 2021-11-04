#include <stdio.h> 
#include <stdint.h>
#include "util.h"

#include "pmu_test.h"

#include "asm.h"


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

    int *p1 = (int * ) (0x60000000);
    volatile int iterations = 10000;
    int i;

    while(1){
        //ld_l1hit(p, iterations);
        ld_l1miss(p1, iterations);
        //st_l1miss(p, iterations);
        //l1miss_ic(iterations);
    }
}

// This function enables the PMU and RDC
__attribute__((always_inline)) inline void ini_test_RDC(void) 
{
    //select_test_mode(0);  
    reset_counters();
    reset_RDC();
    zero_all_pmu_regs ();
    enable_RDC();
    enable_counters();
}

// This function disables the PMU and RDC
__attribute__((always_inline)) inline void end_test_RDC(void) 
{
    disable_counters();
    disable_RDC();
    report_pmu();
}

//Each one of the cores gets a different binary with the __CORE__ variable set 
//to te core ID of the processor. This is handled with a flag in the Makefile
//when doing make mulicore_exe

int main(void)
{


#ifdef __CORE__
    switch (__CORE__) {
        case 1: ;
	   

            int *p = (int * ) (0x50000000);
            volatile int iterations = 10000;

	    /*************************** ld_l1miss execution *******************************/
	    printf("\n\n ********* uTESTBENCH LD_L1MISS ********* \n\n"); 
        ini_test_RDC();
        ld_l1miss(p, iterations);
        end_test_RDC();
	    
	    /************************ end of ld_l1miss execution****************************/


            /*************************** ld_l1hit execution *******************************/
	    printf("\n\n ********* uTESTBENCH LD_L1HIT ********* \n\n"); 
        ini_test_RDC();
	    ld_l1hit(p, iterations);     
        end_test_RDC();
	    /************************ end of ld_l1hit execution****************************/


            /*************************** st_l1 execution *******************************/
	    printf("\n\n ********* uTESTBENCH ST_L1 ********* \n\n"); 
        ini_test_RDC();
	    st_l1(p, iterations);    
        end_test_RDC(); 
	    /************************ end of st_l1 execution****************************/
	    

            /*************************** l1miss_ic_1set execution *******************************/
	    printf("\n\n ********* uTESTBENCH L1MISS_IC_1SET ********* \n\n"); 
        ini_test_RDC();
	    l1miss_ic_1set(iterations);    
        end_test_RDC();
	    /************************ end of l1miss_ic_1set execution****************************/


            break;

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



