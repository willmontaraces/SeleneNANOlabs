//#include <bcc/bcc.h>
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include "exception.c"

#define read_csr_safe(reg) ({ long __tmp = 0; \
    __asm__ volatile ("csrr %0, " #reg : "+r"(__tmp)); \
    __tmp; })

int main()
{
    int start, end;
    int cpu_time_used;

    start = read_csr_safe(cycle);
    printf("Hello\n");

    end = read_csr_safe(cycle);
    cpu_time_used = end-start;
    
    printf("Time taken: %d cycles\n", cpu_time_used);

    return 0;
}
