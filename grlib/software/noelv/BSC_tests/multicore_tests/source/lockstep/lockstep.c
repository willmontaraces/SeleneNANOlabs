#include <stdio.h> 
#include <stdint.h>
#include "util.h"
#include "binarysearch.h"
//#include <time.h> 
#include "pmu_hw.h"
#include "SafeDE_driver.h"

//#define __UART__


//This defines are set by the makefile, but for single core when running 
//make mp_ubench.exe a value is required
#ifndef __MAX_CORES__
    #define __MAX_CORES__ 1
#endif
#ifndef __CORE__
    #define __CORE__ 1
#endif

void thread_entry(int cid, int nc)
{
        return;
}

//Units are imprecise, if number_of_seconds == 1 the actual delay  is much   
//smaller than one second                                                    
void delay(int number_of_executions)                                            
{                                                                            
	int i;
	for(i=0 ; i<number_of_executions ; i++){
	}
}                                                                            


//Main task
void main_process(void){
    binarysearch_init();
    binarysearch_main();

}


//Each one of the cores gets a different binary with the __CORE__ variable set 
//to te core ID of the processor. This is handled with a flag in the Makefile
//when doing make mulicore_exe

int main(void)
{
#ifdef __CORE__
    switch (__CORE__) {
        case 1:
	    //start PMU
	    select_test_mode(0);  /*inputs from SoC*/
	    //reset_counters();
	    enable_counters();

	    //start lockstep
	    //activate_lockstep(10, 100);

#ifdef __UART__
            printf("Total cores: %d;  Core %d setup: done \n", __MAX_CORES__, __CORE__);
#endif
            main_process();

	    //stop lockstep
            //stop_lockstep();

	    //stop-PMU
	    disable_counters();

	    //delay(10000);
	    //print PMU results
	    report_pmu();
	    reset_counters();

	    //print lockstep results
	    //print_results();

            //print results
            //if (( binarysearch_return() - ( -1 ) != 0 ) == 0 ) 
            //    printf("\n----------------------- TEST PASSED ------------------------------\n");
            //else
            //    printf("\n----------------------- TEST FAILED ------------------------------\n");


	    while(1);

            break;

        case 2:
#ifdef __UART__
            printf("Hello from core: %d \n",__CORE__);
#endif
	    while(1){
            	main_process();
	    }
            //TODO: problems with both cores accessing the UART
             //print results
            if (( binarysearch_return() - ( -1 ) != 0 ) == 0 ) 
                printf("\n ----------------------- TEST PASSED ------------------------------ \n");
            else
                printf("\n ----------------------- TEST FAILED ------------------------------ \n");

	    while(1);
    }
#else
    //This shall never be reached if makefile is setup propperly
    while(1){
#ifdef __UART__
        printf("__CORE__ not defined\n");
#endif
    }
#endif
    return(0);
}



