#include <stdio.h>
#include <stdlib.h>
#include "kernel.h"




void mkernel(int mhartid)
{
	//introduce core-specific delay to simulate staggered execution
	for(int i=0;i<5*mhartid;i++){ __asm("nop"); }
	
	//load dataset to the voter
	RVC_load_dataset(&RVC0, mhartid-1, 0xf1f2f3f4cafebabe);	

	//stall all harts but hart-0 (main core)
	while(mhartid>0){ };
}



