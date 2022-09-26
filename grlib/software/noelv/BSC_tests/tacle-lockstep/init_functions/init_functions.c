#include <stdio.h> 
#include <stdint.h>
#include "util.h"
//#include "pmu_test.h"
#include "SafeDE_driver.h"

volatile unsigned int *shared_flag_start = (unsigned int*) 0x41900000;
volatile unsigned int *shared_flag_end = (unsigned int*) 0x41910000;
volatile int *shared_result = (unsigned int*) 0x41920000;

void thread_entry(int cid, int nc)
{
        return;
}



//Executed before the start of the test in core1
inline void __attribute__((always_inline)) init_test_core1(void)  {
    //Lockstep reset and configuration
    SafeDE_softreset();
    SafeDE_enable();
    SafeDE_min_max_thresholds(__MIN_SLACK__ , __MAX_SLACK__); 

    //Parameters of the experiments are printed
    printf("\nNUMBER_OF_CORES: %u", __CORES_NUMBER__);
    printf("\nITERATIONS: %u", __ITERATIONS__);
if (__LOCKSTEP__ == 1) {
    printf("\nLOCKSTEP: YES");
    printf("\nMIN_SLACK: %u", __MIN_SLACK__);
    printf("\nMAX_SLACK: %u", __MAX_SLACK__);
} else {
    printf("\nLOCKSTEP: NO");
}

    //End flag is set to 1 and if core2 is active it will set it to 0 at the beggining 
    //and to 1 at the end
    *shared_flag_end = 1;
    //Set shared result different than 0
    *shared_result = 10000;

    //PMU reset and configuration
    //select_test_mode(0);  /*inputs from SoC*/
    //reset_counters();
    //Start PMU
    //enable_counters();

    //Start flag is set to 1 indicating the second core to start 
    *shared_flag_start = 1;

    //start lockstep
if (__LOCKSTEP__ == 1)
    SafeDE_start_criticalSec(1);
}



//Executed before the start of the test in core2
inline __attribute__((always_inline)) void init_test_core2(void) {
    
    //If only one core is active, Second core waits idle
    if ( __CORES_NUMBER__ == 1)
	    while(1);

    //Start flag is set to 0 waiting for the first core to change its value
    *shared_flag_start = 0;
    while (*shared_flag_start == 0);
    //End flag is set to 0 until the benchmark is finished
    *shared_flag_end = 0;

if (__LOCKSTEP__ == 1)
    // start lockstep
    SafeDE_start_criticalSec(2);
}



inline __attribute__((always_inline)) void end_test_core1(void) {

    SafeDE_finish_criticalSec(1);

    //It waits for the core2 to end
    while (*shared_flag_end == 0);
    //disable_counters();
    //report_pmu();

if (__LOCKSTEP__ == 1)
    SafeDE_report();
}



inline __attribute__((always_inline)) void end_test_core2(void) {
    //When core2 finished sets to 1 end flag
    SafeDE_finish_criticalSec(2);
    *shared_flag_end = 1;

}


