#include <stdio.h>
#include <lockstep.h>
#define __UART__
#define __UART__SENSITIVE__
//#__LOCKSTEP_DEBUG__

//base addres for PMU on SoC
#define LOCKSTEP_ADDR 0x80000600


// ** and mask
void lockstep_masked_and_write (unsigned int entry, unsigned int mask) {
    volatile unsigned int *p; 
    volatile unsigned int current_value; 
#ifdef __LOCKSTEP_DEBUG__
    printf("\n *** Write AND mask register***\n\n");
#endif
    p=(unsigned int*)(LOCKSTEP_ADDR+(entry*4));
    //get current value 
    current_value=*p;
    //set register
    *p=current_value & mask;
#ifdef __LOCKSTEP_DEBUG__
    printf("address:%x \n",(LOCKSTEP_ADDR+(entry*4)));
    printf("current value :%x \n",current_value);
    printf("mask:%x \n", mask);
    printf("masked value :%x \n",(current_value & mask));
    printf("\n *** end Write AND mask register ***\n\n");
#endif
}

// ** or mask
void lockstep_masked_or_write (unsigned int entry, unsigned int mask) {
    volatile unsigned int *p; 
    volatile unsigned int current_value; 
#ifdef __LOCKSTEP_DEBUG__
    printf("\n *** Write OR mask register***\n\n");
#endif
    p=(unsigned int*)(LOCKSTEP_ADDR+(entry*4));
    //get current value 
    current_value=*p;
    //set register
    *p=current_value | mask;
#ifdef __LOCKSTEP_DEBUG__
    printf("address:%x \n",(LOCKSTEP_ADDR+(entry*4)));
    printf("current value :%x \n",current_value);
    printf("mask:%x \n", mask);
    printf("masked value :%x \n",(current_value & mask));
    printf("\n *** end Write OR mask register ***\n\n");
#endif
}

// write
void write (unsigned int entry, unsigned int value) {
    volatile unsigned int *p; 
    volatile unsigned int current_value; 
#ifdef __LOCKSTEP_DEBUG__
    printf("\n *** Write register***\n\n");
#endif
    p=(unsigned int*)(LOCKSTEP_ADDR+(entry*4));
    *p=value;
#ifdef __LOCKSTEP_DEBUG__
    printf("address:%x \n",(LOCKSTEP_ADDR+(entry*4)));
    printf("current value :%x \n",current_value);
    printf("new value :%x \n",(current_value & mask));
    printf("\n *** end Write register ***\n\n");
#endif
}

// read
unsigned int read (unsigned int entry) {
    volatile unsigned int *p; 
    volatile unsigned int value; 
#ifdef __LOCKSTEP_DEBUG__
    printf("\n *** Write register***\n\n");
#endif
    p=(unsigned int*)(LOCKSTEP_ADDR+(entry*4));
    value=*p;
#ifdef __LOCKSTEP_DEBUG__
    printf("address:%x \n",(LOCKSTEP_ADDR+(entry*4)));
    printf("current value :%x \n",current_value);
    printf("new value :%x \n",(current_value & mask));
    printf("\n *** end Write register ***\n\n");
#endif
    return value;
}


//It activates the locksep configuration. Slack has to be define before
void start_lockstep(void) {
    lockstep_masked_or_write(LOCKSTEP_CONFIG, 0x1);
#ifdef __UART__
    printf("\nLockstep mode is now activated\n");
#endif
}

//It sets maximum y minimum slack and activates lockstep configuration
void activate_lockstep(int min_slack, int max_slack) {
    unsigned int reg;
    if (min_slack >= max_slack) {
#ifdef __UART__
        printf("\nERROR: minimum slack is equal o bigger than maximum slack. Lockstep will remain off\n");
#endif
    } else if (max_slack > 32767) { 
#ifdef __UART__ 
        printf("\nERROR: maximum slack is too big. Biggest possible value is 32767. Lockstep will remain off.\n"); 
#endif
    } else {  
#ifdef __UART__SENSITIVE__
        printf("\nLockstep mode is now activated\n");
#endif
        reg = max_slack << 16 | min_slack << 1 | 1;
        write(LOCKSTEP_CONFIG, reg);
    }
}

//It sets minimum and maximum slack wihtout stoping or starting lockstep configuration
void configure_lockstep(int min_slack, int max_slack) {
    unsigned int reg;
    if (min_slack >= max_slack) {
#ifdef __UART__
        printf("\nERROR: minimum slack is equal o bigger than maximum slack. Lockstep will remain off\n");
#endif
    } else if (max_slack > 32767) {
#ifdef __UART__
        printf("\nERROR: maximum slack is too big. Biggest possible value is 32767. Lockstep will remain off\n");
#endif
    } else { 
#ifndef __UART__SENSITIVE__
        printf("\nLockstep mode is now activated\n");
#endif
        reg = max_slack << 16 | min_slack << 1 & 0xfffe;
        write(LOCKSTEP_CONFIG, reg);
    }
}

//It stops lockstep configuration
void stop_lockstep(void) {
    lockstep_masked_and_write(LOCKSTEP_CONFIG, 0xfffffffe);
#ifndef __UART__SENSITIVE__
    printf("\nLockstep mode has been stoped\n");
#endif
}

void reset_lockstep_counters(void) {
    lockstep_masked_or_write(LOCKSTEP_CONFIG, 0x80000000);
}

void print_results(void) {
    printf("\n\n--------------- STARTING LOCKSTEP REPORT: ------------------ \n\n");

    printf("              Cycles lockstep has been active: %u\n", read(DATA_REGS_START));
    printf("              Instructions executed by core 1: %u\n", read(DATA_REGS_START+1));
    printf("              Instructions executed by core 2: %u\n", read(DATA_REGS_START+2));
    printf(" Times that one of the cores has been stalled: %u\n\n", read(DATA_REGS_START+3));
    printf("Cycles that one of the cores has been stalled: %u\n\n", read(DATA_REGS_START+4));
    
    printf("\n\n--------------- END OF LOCKSTEP REPORT ------------------ \n\n");

}


