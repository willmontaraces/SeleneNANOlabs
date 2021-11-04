//#include "asm.h"
#include <stdio.h>



static inline void ld_l1miss(int * p, volatile int iterations)
{

    //Each line of the cache is 32 bytes
    //Each load loads a different line of the cache
    //Whne the maximum offset of the instruction ld is achieve (63*32),  
    //the variable %1 is increased in 4096 (32 bytes perline * 128 lines), doing it this way a new way is written

   
 int q=p;
 //volatile int iterations_int = iterations;

 __asm__ __volatile__ (".ldl1miss_begin:"    "\n\t"
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
 "addi %2,%2,-1" "\n\t"
 "add %1,%1,%3" "\n\t"
 "bne  %2, zero, .ldl1missloop_begin"  "\n\t"
 "nop"  "\n\t"
 ".ldl1miss_end:"   "\n\t"
 :
 : "r"(0), "r"(q), "r"(iterations), "r"(4096)
 );
}

static inline void ld_l1hit(int * p, volatile int iterations)
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
 "addi %2,%2,-1" "\n\t"
 "bne  %2, zero, .ldl1hitloop_begin"  "\n\t"
 "nop"  "\n\t"
 ".ldl1hit_end:"   "\n\t"
 :
 : "r"(0), "r"(q), "r"(iterations)
 );
}

static inline void st_l1(int * p, volatile int iterations)
{

    //It performs several stores to fill the write-buffer

   
 int * q=p;
 //volatile int iterations_int = iterations;

 __asm__ __volatile__ (".stl1_begin:"    "\n\t"
 ".stl1loop_begin:"  "\n\t"
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
 "addi %2,%2,-1" "\n\t"
 "bne  %2, zero, .stl1loop_begin"  "\n\t"
 "nop"  "\n\t"
 ".stl1_end:"   "\n\t"
 :
 : "r"(0), "r"(q), "r"(iterations)
 );
}


inline void l1miss_ic(int iterations)
{

    //It aligns instructions to (32 bytes line * 256 lines = 4096 bytes)
    //In this way every instruction is load in a differente way in the 
    //same line


 __asm__ __volatile__("      nop"    "\n\t"
"                 .align 12         "       "\n\t"
".loop_begin:"    "\n\t"
"      beq zero, zero, .loop_1" "\n\t"
"      nop"    "\n\t"
"                 .align 12         "       "\n\t"
".loop_1:"    "\n\t"
"      beq zero, zero, .loop_2" "\n\t"
"      nop"    "\n\t"
"                 .align 12         "       "\n\t"
".loop_2:"    "\n\t"
"      beq zero, zero, .loop_3" "\n\t"
"      nop"    "\n\t"
"                 .align 12         "       "\n\t"
".loop_3:"    "\n\t"
"      beq zero, zero, .loop_4" "\n\t"
"      nop"    "\n\t"
"                 .align 12         "       "\n\t"
".loop_4:" "\n\t"
"      beq zero, zero, .loop_5" "\n\t"
"      nop"    "\n\t"
".loop_5:" "\n\t"
" addi %0,%0,-1" "\n\t"
" bne  %0, zero, .loop_begin"  "\n\t"
"      nop"    "\n\t"
 ".loop_end:"   "\n\t"
 :
 : "r"(iterations)
 );
}


//TODO: all the previous tests for L2
