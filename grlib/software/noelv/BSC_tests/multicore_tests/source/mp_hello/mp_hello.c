#include <stdio.h> 
#include "util.h"
#include "SafeDE_driver.h"

void thread_entry(int cid, int nc)
{
	return;
}


//Units are imprecise, if number_of_seconds == 1 the actual delay  is much 
//smaller than one second
void delay(long number_of_repetitions)
{
    volatile long i;
    volatile long a;

    for ( i = 0 ; i < number_of_repetitions ; i++){
        a = i;
    }
}


//Each one of the cores gets a different binary with the __CORE__ variable set 
//to te core ID of the processor. This is handled with a flag in the Makefile
//when doing make mulicore_exe

//Each core writes to the multicore boot register of the next core and print its
//own ID. The delays are introduced to prevent to get the characters of the 
//printf interleaved. A software lock could be implemented instead of the delays
//but it is out of the scope of this sample code.
int main(void)
{
#ifdef __CORE__

    unsigned int* p;
 

    switch (__CORE__) {
        case 1:
	        printf("Hello from core: %d \n",__CORE__);            
    	    while(1);
            break;

        case 2:
            printf("Hello from core: %d \n",__CORE__);
    	    while(1);
            break;

        case 3:
            printf("Hello from core: %d \n",__CORE__);
    	    while(1);
            break;

        case 4:
            printf("Hello from core: %d \n",__CORE__);
    	    while(1);
            break;
    }

#else
    //This shall never be reached if makefile is setup propperly
    while(1){
        printf("__CORE__ not defined\n");
    }
#endif
    return 0;
}



