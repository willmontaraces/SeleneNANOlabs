/*************************************************************************/
/*                                                                       */
/*   SNU-RT Benchmark Suite for Worst Case Timing Analysis               */
/*   =====================================================               */
/*                              Collected and Modified by S.-S. Lim      */
/*                                           sslim@archi.snu.ac.kr       */
/*                                         Real-Time Research Group      */
/*                                        Seoul National University      */
/*                                                                       */
/*                                                                       */
/*        < Features > - restrictions for our experimental environment   */
/*                                                                       */
/*          1. Completely structured.                                    */
/*               - There are no unconditional jumps.                     */
/*               - There are no exit from loop bodies.                   */
/*                 (There are no 'break' or 'return' in loop bodies)     */
/*          2. No 'switch' statements.                                   */
/*          3. No 'do..while' statements.                                */
/*          4. Expressions are restricted.                               */
/*               - There are no multiple expressions joined by 'or',     */
/*                'and' operations.                                      */
/*          5. No library calls.                                         */
/*               - All the functions needed are implemented in the       */
/*                 source file.                                          */
/*                                                                       */
/*                                                                       */
/*************************************************************************/
/*                                                                       */
/*  FILE: qsort-exam.c                                                   */
/*  SOURCE : Numerical Recipes in C - The Second Edition                 */
/*                                                                       */
/*  DESCRIPTION :                                                        */
/*                                                                       */
/*     Non-recursive version of quick sort algorithm.                    */
/*     This example sorts 20 floating point numbers, arr[].              */
/*                                                                       */
/*  REMARK :                                                             */
/*                                                                       */
/*  EXECUTION TIME :                                                     */
/*                                                                       */
/*                                                                       */
/*************************************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "workload.h"


float data[20] = {
  5, 4, 10.3, 1.1, 5.7, 100, 231, 111, 49.5, 99,
  10, 150, 222.22, 101, 77, 44, 35, 20.54, 99.99, 88.88
};

int cmpfunc (const void * a, const void * b)
{
  if (*(float*)a > *(float*)b)
    return 1;
  else if (*(float*)a < *(float*)b)
    return -1;
  else
    return 0;  
}



void mkernel(int mhartid)
{

	for(int i=0;i<CORE_DELAY*mhartid;i++){
		__asm("nop");
	}
	
	
	float * data_ptr = (float*) (RES_PTR + mhartid*RES_ITEMS);
	memcpy(data_ptr, data, sizeof(data));
		
	qsort(data_ptr, 20, sizeof(float), cmpfunc);

/*
	for(int i=0;i<20;i++) printf("%f ", data_ptr[i]);
	printf("\n");
*/

	//stall all harts but hart-0 (main core)
	while(mhartid>0){ };
}



