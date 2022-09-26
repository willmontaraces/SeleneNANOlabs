#include <stdio.h>
#include "util.h"
#include "pmu_test.h"
#include "SafeDE_driver.h"
#include "fac.h"

volatile unsigned int *shared_flag = (unsigned int*) 0x40900200;
volatile int *core1_passed = (int*) 0x40900100;

void thread_entry(int cid, int nc)
{
        return;
}


int main(void)
{
    int volatile i = 0;
    int core;
    int core2_passed;
    int comparison_passed;


    if (__CORE__ == 1) {

          SafeDE_softreset();
          SafeDE_enable(); 
          SafeDE_min_max_thresholds(10,15);
          //set_min_threshold(10);

          *shared_flag = 1;

          SafeDE_start_criticalSec(1);

          //Tacle-bench
          for (i=0 ; i < 30; i++) {
            fac_init();
            fac_main();
          }
          
          SafeDE_finish_criticalSec(1);

          *core1_passed = fac_return();

          *shared_flag = 0;

          while(1);


    } else {


          *shared_flag = 0;

          while (*shared_flag == 0);

          SafeDE_start_criticalSec(2);

          for (i=0 ; i < 30; i++) {
            fac_init();
            fac_main();
          }

          SafeDE_finish_criticalSec(2);

          while (*shared_flag == 1);

          core2_passed = fac_return(); 
 
          printf("Result core1: %d\n", *core1_passed);

          printf("Result core2: %d\n", core2_passed);

          
          printf("Result comparison:");
          if (*core1_passed == core2_passed) {
              comparison_passed = 0;
              printf(" PASSED\n"); 
          } else {
              comparison_passed = 1;
              printf(" FAILED\n" ); 
          }
          

          printf("Result lockstep:");
          if ((*core1_passed != 0 || core2_passed != 0) && comparison_passed == 0) {
              printf(" FAILED\n"); 
          } else {
              printf(" PASSED\n"); 
          }
             
          for (i=0 ; i<100 ; i++);

          //SafeDE_report();

    }
    return(0);
}
