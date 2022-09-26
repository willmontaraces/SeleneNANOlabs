#include <stdio.h>
#include "util.h"

#include "SafeDE_driver.h"
#include "fac.h"

volatile unsigned int *shared_flag = (unsigned int*) 0x4100fe00;
volatile int *core1_passed = (int*) 0x4100ffe0;

//Avoids cores different thant one from getting stack
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

    printf("here we are\n");
    core=read_csr(0xf14);

    if (core == 0) {

          //Configure SafeDE
          SafeDE_softreset();
          SafeDE_enable(); 
          SafeDE_min_max_thresholds(20,30);
          //set_min_threshold(10);

          //Change shared flat so the core2 can start the 
          //benchmark execution
          *shared_flag = 1;

          //Indicate SafeDE the core1 is entering the critical task
          SafeDE_start_criticalSec(1);
          //Tacle-bench execution
          fac_init();
          fac_main();
          //Indicate SafeDE the core1 finished the critical task
          SafeDE_finish_criticalSec(1);

          //Check if the result is the spected one and save it in a 
          //shared variable
          *core1_passed = fac_return();

          //Change the shared flag to indicate core2 that it can 
          //print the results
          *shared_flag = 0;

          //Wait for the core2 to finish the execution
          while(1);


    } else {


          *shared_flag = 0;

          while (*shared_flag == 0);

          //Indicate SafeDE the core2 is entering the critical task
          SafeDE_start_criticalSec(2);
          //Tacle-bench execution
          fac_init();
          fac_main();
          //Indicate SafeDE the core2 finished the critical task
          SafeDE_finish_criticalSec(2);

          while (*shared_flag == 1);

          //Check if the result is the correct one in the core 2
          core2_passed = fac_return(); 
 
          //Print results
          printf("Result core1: %d\n", *core1_passed);
          printf("Result core2: %d\n", core2_passed);

          
          //Compare results to check if they are equal between cores
          printf("Result comparison:");
          if (*core1_passed == core2_passed) {
              comparison_passed = 0;
              printf(" PASSED\n"); 
          } else {
              comparison_passed = 1;
              printf(" FAILED\n" ); 
          }
          

          //If results are equal between cores but different from the spected result SafeDE failed
          printf("Result lockstep:");
          if ((*core1_passed != 0 || core2_passed != 0) && comparison_passed == 0) {
              printf(" FAILED\n"); 
          } else {
              printf(" PASSED\n"); 
          }
             
          //Give it time to do the memory dump
          for (i=0 ; i<50 ; i++);

          SafeDE_report();

    }
    return(0);
}
