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



//Each one of the cores gets a different binary with the __CORE__ variable set 
//to te core ID of the processor. This is handled with a flag in the Makefile
//when doing make mulicore_exe

int main(void)
{


#ifdef __CORE__
    switch (__CORE__) {
        case 1: ;
	   
	    int result;

	    /*************************** binaryserach execution *******************************/
	    printf("\n\n ********* TESTBENCH BINARYSEARCH ********* \n\n"); 

            select_test_mode(0);  /*inputs from SoC*/
            reset_counters();
            reset_RDC();
            enable_RDC();
            enable_counters();

	    result=binarysearch_all();

            disable_counters();
            disable_RDC();

	    //print result
	    if (result == 0) 
	            printf("\n------ TEST PASSED ------\n");
            else
	            printf("\n------ TEST FAILED ------\n");

            report_pmu();
	    
	    /************************ end of binaryserach execution****************************/


	    /*************************** bitonic execution *******************************/
	    printf("\n\n\n\n ********* TESTBENCH BITONIC ********* \n\n"); 
	    select_test_mode(0);  /*inputs from SoC*/
            reset_counters();
            reset_RDC();
            enable_RDC();
            enable_counters();

	    result=bitonic_all();

            disable_counters();
            disable_RDC();

	    //print result
	    if (result == 0) 
		    printf("\n------ TEST PASSED ------\n");
            else
		    printf("\n------ TEST FAILED ------\n");

            report_pmu();
	    /************************ end of bitonic execution****************************/


	    /*************************** ludcmp execution *******************************/
	    printf("\n\n\n\n ********* TESTBENCH LUDCMP ********* \n\n"); 
	    select_test_mode(0);  /*inputs from SoC*/
            reset_counters();
            reset_RDC();
            enable_RDC();
            enable_counters();

	    result=ludcmp_all();

            disable_counters();
            disable_RDC();

	    //print result
	    if (result == 0) 
		    printf("\n------ TEST PASSED ------\n");
            else
		    printf("\n------ TEST FAILED ------\n");
	    
            report_pmu();
	    /************************ end of ludcmp execution****************************/


	    /*************************** matrix1 execution *******************************/
	    printf("\n\n\n\n ********* TESTBENCH MATRIX1 ********* \n\n"); 
	    select_test_mode(0);  /*inputs from SoC*/
            reset_counters();
            reset_RDC();
            enable_RDC();
            enable_counters();

	    result=matrix1_all();

            disable_counters();
            disable_RDC();

	    //print result
	    if (result == 0) 
		    printf("\n------ TEST PASSED ------\n");
            else
		    printf("\n------ TEST FAILED ------\n");
	    
            report_pmu();
	    /************************ end of matrix1 execution****************************/


	    /*************************** lms execution *******************************/
	    printf("\n\n\n\n ********* TESTBENCH LMS ********* \n\n"); 
	    select_test_mode(0);  /*inputs from SoC*/
            reset_counters();
            reset_RDC();
            enable_RDC();
            enable_counters();

	    result=lms_all();

            disable_counters();
            disable_RDC();

	    //print result
	    if (result == 0) 
		    printf("\n------ TEST PASSED ------\n");
            else
		    printf("\n------ TEST FAILED ------\n");
	    
            report_pmu();
	    /************************ end of lms execution****************************/
	    






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



