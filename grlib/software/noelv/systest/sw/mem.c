#include <stdio.h>
#include <stdlib.h>
#define L2C_CTRL_REG_ADDR 0xff000000


int mem_test(__uint32_t start_addr, __uint32_t end_addr, __uint32_t l2c_en) {
    
    int memory_errors = 0;
    __uint32_t write_const = 0x732F100D;
    __uint32_t volatile * base = (__uint32_t*) start_addr; 
    __uint32_t volatile * L2C_ctrl_reg = L2C_CTRL_REG_ADDR;
    
    printf("STARTING MEMORY TEST\n\n");
    if (l2c_en==1) {
        printf("Enabling L2 Cache\n");
        * L2C_ctrl_reg = 0x80040000;
    } else {
        printf("Disabling L2 Cache\n");
        * L2C_ctrl_reg = 0;
    }
    
    printf("Writing 0x%x to memory range: %p-%p\n",write_const, (__uint32_t*) start_addr, (__uint32_t*) end_addr);
    while (base < (__uint32_t*) end_addr) {
        * base = write_const;
        base++;
    }
    printf("Write finished, checking memory...\n");
    base = (__uint32_t*) start_addr; 
    while (base < (__uint32_t*) end_addr) {
        if (*base != write_const) {
            printf("Memory missmatch at address: %p\n", base);
            memory_errors++;
        } 
        base++;
    }
    
    printf("Memory check finished. Reported errors: %d\n", memory_errors);
    printf(" \n");

    return 1;
    
}