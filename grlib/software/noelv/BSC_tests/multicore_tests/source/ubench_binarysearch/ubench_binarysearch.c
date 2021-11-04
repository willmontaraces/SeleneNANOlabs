#include <stdio.h> 
#include <stdint.h>
#include "util.h"
#include "binarysearch.h"
#include "asm.c"
//#include <time.h> 
#include "pmu_test.h"

//#define __UART__


//This defines are set by the makefile, but for single core when running 
//make mp_ubench.exe a value is required
#ifndef __MAX_CORES__
    #define __MAX_CORES__ 1
#endif
#ifndef __CORE__
    #define __CORE__ 1
#endif


void contender(void);
void main_process(void);

//Units are imprecise, if number_of_seconds == 1 the actual delay  is much   
//smaller than one second                                                    
//void delay(int number_of_seconds)                                            
//{                                                                            
//    // Converting time into milli_seconds                                    
//    int milli_seconds = 1000 * number_of_seconds;                            
//                                                                             
//    // Storing start time                                                    
//    clock_t start_time = clock();                                            
//                                                                             
//    // looping till required time is not achieved                            
//    while (clock() < start_time + milli_seconds);                            
//}                                                                            

void thread_entry(int cid, int nc)
{
        return;
}


//Main task
void contender(void){

    //Desactivate software interruption
    volatile unsigned int *p;
    p = (unsigned int *) 0xE0100004;
    *p = 0x0;

    //printf("Hello from core: %d, from main_process \n",__CORE__);


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

    //if (( binarysearch_return() - ( -1 ) != 0 ) == 0 ) 
    //    printf("\n ----------------------- TEST PASSED ------------------------------ \n");
    //else
    //    printf("\n ----------------------- TEST FAILED ------------------------------ \n");


}

void main_process(void) {
    binarysearch_init();
    binarysearch_main();
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

#ifdef __UART__
            printf("Total cores: %d;  Core %d setup: done \n", __MAX_CORES__, __CORE__);
#endif


            select_test_mode(0);  /*inputs from SoC*/
            reset_counters();
            reset_RDC();
            enable_RDC();
            enable_counters();


            // This throuhgs a software interruption to CPU2 through plic module
            *p = 0x1;

	    main_process();

            disable_counters();
            disable_RDC();
            report_pmu();

	    while(1);

            break;

        case 2:
#ifdef __UART__
            printf("Hello from core: %d \n",__CORE__);
#endif
	    while(1);


            break;

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



