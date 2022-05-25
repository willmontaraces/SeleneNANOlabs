/* $Id: crc.c,v 1.2 2005/04/04 11:34:58 csg Exp $ */

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
/*  FILE: crc.c                                                          */
/*  SOURCE : Numerical Recipes in C - The Second Edition                 */
/*                                                                       */
/*  DESCRIPTION :                                                        */
/*                                                                       */
/*     A demonstration for CRC (Cyclic Redundancy Check) operation.      */
/*     The CRC is manipulated as two functions, icrc1 and icrc.          */
/*     icrc1 is for one character and icrc uses icrc1 for a string.      */
/*     The input string is stored in array lin[].                        */
/*     icrc is called two times, one for X-Modem string CRC and the      */
/*     other for X-Modem packet CRC.                                     */
/*                                                                       */
/*  REMARK :                                                             */
/*                                                                       */
/*  EXECUTION TIME :                                                     */
/*                                                                       */
/*                                                                       */
/*************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "workload.h"

typedef unsigned char uchar;
#define LOBYTE(x) ((uchar)((x) & 0xFF))
#define HIBYTE(x) ((uchar)((x) >> 8))
#define DSIZE 256

//unsigned char lin[64] = "asdffeagewaHAFEFaeDsFEawFdsFaefaeerdjgp";
unsigned char lin[DSIZE] = "Edge computing is a distributed computing paradigm that brings computation and data storage closer to the location where it is needed to improve response times and save bandwidth. The origins of edge computing lie in content delivery networks";

unsigned short icrc1(unsigned short crc, unsigned char onech)
{
	int i;
	unsigned short ans=(crc^onech << 8);

	for (i=0;i<8;i++) {
		if (ans & 0x8000)
			ans = (ans <<= 1) ^ 4129;
		else
			ans <<= 1;
	}
	return ans;
}

unsigned short icrc(unsigned char * data, unsigned short crc, unsigned long len,
		    short jinit, int jrev)
{
  unsigned short icrc1(unsigned short crc, unsigned char onech);
   unsigned short icrctb[256],init=0;
   uchar rchr[256];
  unsigned short tmp1, tmp2, j,cword=crc;
   uchar it[16]={0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15};

  if (!init) {
    init=1;
    for (j=0;j<=255;j++) {
      icrctb[j]=icrc1(j << 8,(uchar)0);
      rchr[j]=(uchar)(it[j & 0xF] << 4 | it[j >> 4]);
    }
  }
  if (jinit >= 0) cword=((uchar) jinit) | (((uchar) jinit) << 8);
  else if (jrev < 0)
    cword=rchr[HIBYTE(cword)] | rchr[LOBYTE(cword)] << 8;
#ifdef DEBUG
  printf("len = %d\n", len);
#endif
  for (j=1;j<=len;j++) {
    if (jrev < 0) {
      tmp1 = rchr[data[j]]^ HIBYTE(cword);
    }
    else {
      tmp1 = data[j]^ HIBYTE(cword);
    }
    cword = icrctb[tmp1] ^ LOBYTE(cword) << 8;
  }
  if (jrev >= 0) {
    tmp2 = cword;
  }
  else {
    tmp2 = rchr[HIBYTE(cword)] | rchr[LOBYTE(cword)] << 8;
  }
  return (tmp2 );
}


void mkernel(int mhartid)
{
	unsigned short i1,i2;
	unsigned long n=DSIZE-8;

	for(int i=0;i<CORE_DELAY*mhartid;i++){
		__asm("nop");
	}


	unsigned char * data_ptr = (unsigned char*) (RES_PTR + mhartid*RES_ITEMS);
	memcpy(data_ptr, lin, sizeof(lin));
	
	
	data_ptr[n+1]=0;
	i1=icrc(data_ptr, 0,n,(short)0,1);
	data_ptr[n+1]=HIBYTE(i1);
	data_ptr[n+2]=LOBYTE(i1);
	i2=icrc(data_ptr, i1,n+2,(short)0,1);

	printf("i1: %08x, i2: %08x\n", i1, i2);
	
	
	
	//stall all harts but hart-0 (main core)
	while(mhartid>0){ };
}



