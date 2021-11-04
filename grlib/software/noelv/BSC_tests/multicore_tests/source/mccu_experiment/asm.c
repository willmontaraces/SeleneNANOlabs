#include "asm.h"
#include <stdio.h>



void ld_l1miss(int * p, volatile int iterations)
{

    //Each line of the cache is 32 bytes
    //Each load loads a different line of the cache
    //Whne the maximum offset of the instruction ld is achieve (63*32),  
    //the variable %1 is increased in 4096 (32 bits perline * 256 lines), doing it this way a new way is written

   
 int *q;
 int reg;
  int block_set = 10;   // 640/64 = 10 (all sets/half way)
 //volatile int iterations_int = iterations;

 __asm__ __volatile__ (".ldl1miss_begin:"    "\n\t"
 "add %5,%1, 0" "\n\t" 
 ".ldl1missloop_begin:"  "\n\t"
 "ld %0, 0*32(%1) " "\n\t"
 "ld %0, 1*32(%1) " "\n\t"
 "ld %0, 2*32(%1) " "\n\t"
 "ld %0, 3*32(%1) " "\n\t"
 "ld %0, 4*32(%1) " "\n\t"
 "ld %0, 5*32(%1) " "\n\t"
 "ld %0, 6*32(%1) " "\n\t"
 "ld %0, 7*32(%1) " "\n\t"
 "ld %0, 8*32(%1) " "\n\t"
 "ld %0, 9*32(%1) " "\n\t"
 "ld %0, 10*32(%1) " "\n\t"
 "ld %0, 11*32(%1) " "\n\t"
 "ld %0, 12*32(%1) " "\n\t"
 "ld %0, 13*32(%1) " "\n\t"
 "ld %0, 14*32(%1) " "\n\t"
 "ld %0, 15*32(%1) " "\n\t"
 "ld %0, 16*32(%1) " "\n\t"
 "ld %0, 17*32(%1) " "\n\t"
 "ld %0, 18*32(%1) " "\n\t"
 "ld %0, 19*32(%1) " "\n\t"
 "ld %0, 20*32(%1) " "\n\t"
 "ld %0, 21*32(%1) " "\n\t"
 "ld %0, 22*32(%1) " "\n\t"
 "ld %0, 23*32(%1) " "\n\t"
 "ld %0, 24*32(%1) " "\n\t"
 "ld %0, 25*32(%1) " "\n\t"
 "ld %0, 26*32(%1) " "\n\t"
 "ld %0, 27*32(%1) " "\n\t"
 "ld %0, 28*32(%1) " "\n\t"
 "ld %0, 29*32(%1) " "\n\t"
 "ld %0, 30*32(%1) " "\n\t"
 "ld %0, 31*32(%1) " "\n\t"
 "ld %0, 32*32(%1) " "\n\t"
 "ld %0, 33*32(%1) " "\n\t"
 "ld %0, 34*32(%1) " "\n\t"
 "ld %0, 35*32(%1) " "\n\t"
 "ld %0, 36*32(%1) " "\n\t"
 "ld %0, 37*32(%1) " "\n\t"
 "ld %0, 38*32(%1) " "\n\t"
 "ld %0, 39*32(%1) " "\n\t"
 "ld %0, 40*32(%1) " "\n\t"
 "ld %0, 41*32(%1) " "\n\t"
 "ld %0, 42*32(%1) " "\n\t"
 "ld %0, 43*32(%1) " "\n\t"
 "ld %0, 44*32(%1) " "\n\t"
 "ld %0, 45*32(%1) " "\n\t"
 "ld %0, 46*32(%1) " "\n\t"
 "ld %0, 47*32(%1) " "\n\t"
 "ld %0, 48*32(%1) " "\n\t"
 "ld %0, 49*32(%1) " "\n\t"
 "ld %0, 50*32(%1) " "\n\t"
 "ld %0, 51*32(%1) " "\n\t"
 "ld %0, 52*32(%1) " "\n\t"
 "ld %0, 53*32(%1) " "\n\t"
 "ld %0, 54*32(%1) " "\n\t"
 "ld %0, 55*32(%1) " "\n\t"
 "ld %0, 56*32(%1) " "\n\t"
 "ld %0, 57*32(%1) " "\n\t"
 "ld %0, 58*32(%1) " "\n\t"
 "ld %0, 59*32(%1) " "\n\t"
 "ld %0, 60*32(%1) " "\n\t"
 "ld %0, 61*32(%1) " "\n\t"
 "ld %0, 62*32(%1) " "\n\t"
 "ld %0, 63*32(%1) " "\n\t"
 "add %1,%1, %2" "\n\t"
 "addi %4,%4, -1" "\n\t"
 "bne  %4, zero, .ldl1missloop_begin"  "\n\t"
 "addi %4,%4, 10" "\n\t"
 "add %1,%5, 0" "\n\t" 
 "addi %3,%3, -1" "\n\t"
 "bne  %3, zero, .ldl1missloop_begin"  "\n\t"
 "nop"  "\n\t"
 ".ldl1miss_end:"   "\n\t"
 ://%0        %1      %2          %3               %4              %5
 : "r"(reg), "r"(p), "r"(64*32), "r"(iterations), "r"(block_set), "r"(q)
 );
}

void ld_l1hit(int * p, volatile int iterations)
{

    //It just loads the same postition again and again

   
 int * q=p;
 //volatile int iterations_int = iterations;

 __asm__ __volatile__ (".ldl1hit_begin:"    "\n\t"
 ".ldl1hitloop_begin:"  "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t" 
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "ld %0, (%1) " "\n\t"
 "addi %2,%2,-1" "\n\t"
 "bne  %2, zero, .ldl1hitloop_begin"  "\n\t"
 "nop"  "\n\t"
 ".ldl1hit_end:"   "\n\t"
 :
 : "r"(0), "r"(q), "r"(iterations)
 );
}

void st_l1(int * p, volatile int iterations)
{
    //sd reg_origin, reg_dest
    //It performs several stores to fill the write-buffer

   
 int *q;
 int reg = 0xcafecafe;
  int block_set = 10;   // 640/64 = 10 (all sets/half way)
 //volatile int iterations_int = iterations;

__asm__ __volatile__ (".sdl1_begin:"    "\n\t"
 "add %5,%1, 0" "\n\t" 
 ".sdl1loop_begin:"  "\n\t"
 "sd %0, 0*32(%1) " "\n\t"
 "sd %0, 1*32(%1) " "\n\t"
 "sd %0, 2*32(%1) " "\n\t"
 "sd %0, 3*32(%1) " "\n\t"
 "sd %0, 4*32(%1) " "\n\t"
 "sd %0, 5*32(%1) " "\n\t"
 "sd %0, 6*32(%1) " "\n\t"
 "sd %0, 7*32(%1) " "\n\t"
 "sd %0, 8*32(%1) " "\n\t"
 "sd %0, 9*32(%1) " "\n\t"
 "sd %0, 10*32(%1) " "\n\t"
 "sd %0, 11*32(%1) " "\n\t"
 "sd %0, 12*32(%1) " "\n\t"
 "sd %0, 13*32(%1) " "\n\t"
 "sd %0, 14*32(%1) " "\n\t"
 "sd %0, 15*32(%1) " "\n\t"
 "sd %0, 16*32(%1) " "\n\t"
 "sd %0, 17*32(%1) " "\n\t"
 "sd %0, 18*32(%1) " "\n\t"
 "sd %0, 19*32(%1) " "\n\t"
 "sd %0, 20*32(%1) " "\n\t"
 "sd %0, 21*32(%1) " "\n\t"
 "sd %0, 22*32(%1) " "\n\t"
 "sd %0, 23*32(%1) " "\n\t"
 "sd %0, 24*32(%1) " "\n\t"
 "sd %0, 25*32(%1) " "\n\t"
 "sd %0, 26*32(%1) " "\n\t"
 "sd %0, 27*32(%1) " "\n\t"
 "sd %0, 28*32(%1) " "\n\t"
 "sd %0, 29*32(%1) " "\n\t"
 "sd %0, 30*32(%1) " "\n\t"
 "sd %0, 31*32(%1) " "\n\t"
 "sd %0, 32*32(%1) " "\n\t"
 "sd %0, 33*32(%1) " "\n\t"
 "sd %0, 34*32(%1) " "\n\t"
 "sd %0, 35*32(%1) " "\n\t"
 "sd %0, 36*32(%1) " "\n\t"
 "sd %0, 37*32(%1) " "\n\t"
 "sd %0, 38*32(%1) " "\n\t"
 "sd %0, 39*32(%1) " "\n\t"
 "sd %0, 40*32(%1) " "\n\t"
 "sd %0, 41*32(%1) " "\n\t"
 "sd %0, 42*32(%1) " "\n\t"
 "sd %0, 43*32(%1) " "\n\t"
 "sd %0, 44*32(%1) " "\n\t"
 "sd %0, 45*32(%1) " "\n\t"
 "sd %0, 46*32(%1) " "\n\t"
 "sd %0, 47*32(%1) " "\n\t"
 "sd %0, 48*32(%1) " "\n\t"
 "sd %0, 49*32(%1) " "\n\t"
 "sd %0, 50*32(%1) " "\n\t"
 "sd %0, 51*32(%1) " "\n\t"
 "sd %0, 52*32(%1) " "\n\t"
 "sd %0, 53*32(%1) " "\n\t"
 "sd %0, 54*32(%1) " "\n\t"
 "sd %0, 55*32(%1) " "\n\t"
 "sd %0, 56*32(%1) " "\n\t"
 "sd %0, 57*32(%1) " "\n\t"
 "sd %0, 58*32(%1) " "\n\t"
 "sd %0, 59*32(%1) " "\n\t"
 "sd %0, 60*32(%1) " "\n\t"
 "sd %0, 61*32(%1) " "\n\t"
 "sd %0, 62*32(%1) " "\n\t"
 "sd %0, 63*32(%1) " "\n\t"
 "add %1,%1, %2" "\n\t"
 "addi %4,%4, -1" "\n\t"
 "bne  %4, zero, .sdl1loop_begin"  "\n\t"
 "addi %4,%4, 10" "\n\t"
 "add %1,%5, 0" "\n\t" 
 "addi %3,%3, -1" "\n\t"
 "bne  %3, zero, .sdl1loop_begin"  "\n\t"
 "nop"  "\n\t"
 ".sdl1_end:"   "\n\t"
 ://%0        %1      %2          %3               %4              %5
 : "r"(reg), "r"(p), "r"(64*32), "r"(iterations), "r"(block_set), "r"(q)
 );
}


void l1miss_ic_1set(int iterations)
{

    //"align 12" adds 2^12=4096 of nops, then will be placed the next instruction
    //in the same set, but in the next way, the disassembly of this ill be like:
    //x40003000 <.loop_begin>
    //x40004000 <.loop1>
    //x40005000 <.loop2>
    //x40006000 <.loop3>
    //x40007000 <.loop4>
    //x40008000 <.loop5>
    //It aligns instructions to (32 bytes line * 256 lines = 4096 bytes)
    //In this way every instruction is load in a differente way in the 
    //same line


 __asm__ __volatile__(
 ".loop_begin:"    "\n\t"
 "beq zero, zero, .loop_1" "\n\t"
 ".align 12"  "\n\t"
 ".loop_1:"    "\n\t"
 "beq zero, zero, .loop_2" "\n\t"
 ".align 12"  "\n\t"
 ".loop_2:"    "\n\t"
 "beq zero, zero, .loop_3" "\n\t"
 ".align 12"  "\n\t"
 ".loop_3:"    "\n\t"
 "beq zero, zero, .loop_4" "\n\t"
 ".align 12"  "\n\t"
 ".loop_4:" "\n\t"
 "beq zero, zero, .loop_5" "\n\t"
 ".align 12"  "\n\t"
 ".loop_5:" "\n\t"
 "addi %0,%0,-1" "\n\t"
 "bne  %0, zero, .loop_begin"  "\n\t"
 "nop" "\n\t"
 ".loop_end:"   "\n\t"
 :
 : "r"(iterations)
 );
}

void ld_st_l1mix(int * p1, int * p2, volatile int iterations)
{

    //This is a mix of load and store to count the istructions,
    //this is the fusion between the "ld_l1miss" and "st_l1" functions
   
 int *q1;
 int *q2;
 int reg;
  int block_set = 20;   // 640/64 = 10 (all sets/half way)
 //volatile int iterations_int = iterations;

 __asm__ __volatile__ (".ld_st_l1mix_begin:"    "\n\t"
 "add %6,%1, 0" "\n\t" 
 "add %7,%2, 0" "\n\t" 
 ".ld_st_l1mixloop_begin:"  "\n\t"
 "ld %0, 0*32(%1) " "\n\t"
 "sd %0, 0*32(%2) " "\n\t"
 "ld %0, 1*32(%1) " "\n\t"
 "sd %0, 1*32(%2) " "\n\t"
 "ld %0, 2*32(%1) " "\n\t"
 "sd %0, 2*32(%2) " "\n\t"
 "ld %0, 3*32(%1) " "\n\t"
 "sd %0, 3*32(%2) " "\n\t"
 "ld %0, 4*32(%1) " "\n\t"
 "sd %0, 4*32(%2) " "\n\t"
 "ld %0, 5*32(%1) " "\n\t"
 "sd %0, 5*32(%2) " "\n\t"
 "ld %0, 6*32(%1) " "\n\t"
 "sd %0, 6*32(%2) " "\n\t"
 "ld %0, 7*32(%1) " "\n\t"
 "sd %0, 7*32(%2) " "\n\t"
 "ld %0, 8*32(%1) " "\n\t"
 "sd %0, 8*32(%2) " "\n\t"
 "ld %0, 9*32(%1) " "\n\t"
 "sd %0, 9*32(%2) " "\n\t"
 "ld %0, 10*32(%1) " "\n\t"
 "sd %0, 10*32(%2) " "\n\t"
 "ld %0, 11*32(%1) " "\n\t"
 "sd %0, 11*32(%2) " "\n\t"
 "ld %0, 12*32(%1) " "\n\t"
 "sd %0, 12*32(%2) " "\n\t"
 "ld %0, 13*32(%1) " "\n\t"
 "sd %0, 13*32(%2) " "\n\t"
 "ld %0, 14*32(%1) " "\n\t"
 "sd %0, 14*32(%2) " "\n\t"
 "ld %0, 15*32(%1) " "\n\t"
 "sd %0, 15*32(%2) " "\n\t"
 "ld %0, 16*32(%1) " "\n\t"
 "sd %0, 16*32(%2) " "\n\t"
 "ld %0, 17*32(%1) " "\n\t"
 "sd %0, 17*32(%2) " "\n\t"
 "ld %0, 18*32(%1) " "\n\t"
 "sd %0, 18*32(%2) " "\n\t"
 "ld %0, 19*32(%1) " "\n\t"
 "sd %0, 19*32(%2) " "\n\t"
 "ld %0, 20*32(%1) " "\n\t"
 "sd %0, 20*32(%2) " "\n\t"
 "ld %0, 21*32(%1) " "\n\t"
 "sd %0, 21*32(%2) " "\n\t"
 "ld %0, 22*32(%1) " "\n\t"
 "sd %0, 22*32(%2) " "\n\t"
 "ld %0, 23*32(%1) " "\n\t"
 "sd %0, 23*32(%2) " "\n\t"
 "ld %0, 24*32(%1) " "\n\t"
 "sd %0, 24*32(%2) " "\n\t"
 "ld %0, 25*32(%1) " "\n\t"
 "sd %0, 25*32(%2) " "\n\t"
 "ld %0, 26*32(%1) " "\n\t"
 "sd %0, 26*32(%2) " "\n\t"
 "ld %0, 27*32(%1) " "\n\t"
 "sd %0, 27*32(%2) " "\n\t"
 "ld %0, 28*32(%1) " "\n\t"
 "sd %0, 28*32(%2) " "\n\t"
 "ld %0, 29*32(%1) " "\n\t"
 "sd %0, 29*32(%2) " "\n\t"
 "ld %0, 30*32(%1) " "\n\t"
 "sd %0, 30*32(%2) " "\n\t"
 "ld %0, 31*32(%1) " "\n\t"
 "sd %0, 31*32(%2) " "\n\t"
 "add %1,%1, %3" "\n\t"
 "add %2,%2, %3" "\n\t"
 "addi %5,%5, -1" "\n\t"
 "bne  %5, zero, .ld_st_l1mixloop_begin"  "\n\t"
 "addi %5,%5, 20" "\n\t"
 "add %1,%6, 0" "\n\t" 
 "add %2,%7, 0" "\n\t" 
 "addi %4,%4, -1" "\n\t"
 "bne  %4, zero, .ld_st_l1mixloop_begin"  "\n\t"
 "nop"  "\n\t"
 ".ld_st_l1mix_end:"   "\n\t"
 ://%0        %1      %2          %3               %4              %5         %6       %7
 : "r"(reg), "r"(p1), "r"(p2), "r"(32*32), "r"(iterations), "r"(block_set), "r"(q1), "r"(q2)
 );
}


//TODO: all the previous tests for L2
