#include "asm.c"
#include "util.h"
#include <stdint.h>
#include <stdio.h>
#include <pmu_test.h>


int main( void ) {
    int * p = (int * ) (0x50000000);
    volatile int iterations = 20;
    int i;

    volatile unsigned int *var;
    volatile unsigned int reader;


    select_test_mode(0);  /*inputs from SoC*/
    reset_counters();
    reset_RDC();
    enable_counters();
    enable_RDC();

    //var=(unsigned int*)(0x80200000+29*4);
    //reader=*var;

    //printf("address:%x ,               RDC_config: %10x\n",var,reader);

    for (i = 0 ; i<1 ; i++){
    //while(1){
        //ld_l1hit(p, iterations);
        ld_l1miss(p, iterations);
        //st_l1(p, iterations);
        //l1miss_ic(iterations);
    }


    disable_RDC();
    disable_counters();
    report_pmu();

    return 0;

}

