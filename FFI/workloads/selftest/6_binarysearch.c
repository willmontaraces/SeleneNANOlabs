
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "workload.h"

#define DATASIZE 20

typedef struct {
  int  key;
  int  value;
} DATA_t;

DATA_t data[DATASIZE] = { 
		{1,    0x10},
		{3,    0x20},
		{5,    0x300},
		{7,    0x700},
		{8,    0x900},
		{9,    0x250},
		{10,   0x400},
		{11,   0x600},
		{12,   0x800},
		{13,   0x1500},
		{19,   0x1200},
		{21,   0x1200},
		{22,   0x1200},
		{28,   0x1200},
		{34,   0x1200},
		{39,   0x1200},		
		{40,   0x110},
		{52,   0x140},
		{56,   0x133},
		{58,   0x10} };


 int binary_search(DATA_t *din, int search_key, int start, int end)
 {
    //Get the midpoint.
    int mid = start + (end - start)/2; 

    if (start > end)
       return -1;
    else if (din[mid].key == search_key)       
       return mid;
    else if (din[mid].key > search_key)         
       return binary_search(din, search_key, start, mid-1);
    else                                 
       return binary_search(din, search_key, mid+1, end);
 }
 
 

 int search(DATA_t *din, int search_key, int count)
 {
    return binary_search(din, search_key, 0, count-1);
 }


int REFERENCE_RESULT[RES_ITEMS] = {
	0x00000000,
	0x00000001,
	0x00000010,
	0xFFFFFFFF,
	0x00000000,
	0x00000000,
	0x00000003,
	0x00000007,
	0x00000700,
	0x00000006,
	0x0000000A,
	0x00000400,
	0x00000009,
	0x0000000D,
	0x00001500,
	0xFFFFFFFF,
	0x00000000,
	0x00000000,
	0x0000000A,
	0x00000013,
	0x00001200,
	0x0000000C,
	0x00000016,
	0x00001200,
	0xFFFFFFFF,
	0x00000000,
	0x00000000,
	0x0000000D,
	0x0000001C,
	0x00001200,
	0xFFFFFFFF,
	0x00000000,
	0x00000000,
	0x0000000E,
	0x00000022,
	0x00001200,
	0xFFFFFFFF,
	0x00000000,
	0x00000000,
	0x00000010,
	0x00000028,
	0x00000110,
	0xFFFFFFFF,
	0x00000000,
	0x00000000,
	0xFFFFFFFF,
	0x00000000,
	0x00000000,
	0xFFFFFFFF,
	0x00000000,
	0x00000000,
	0x00000011,
	0x00000034,
	0x00000140,
	0xFFFFFFFF,
	0x00000000,
	0x00000000,
	0x00000013,
	0x0000003A,
	0x00000010,
	0x00000000,
	0x00000000,
	0x00000000,
	0x00000000	
};
 
 
 void mkernel(int mhartid)
{
                 
	for(int i=0;i<CORE_DELAY*mhartid;i++){
		__asm("nop");
	}


	
	int * res_ptr;
	for(int i=0;i<DATASIZE;i++){
		int key = i+1+i*2;
		int index = search(&(data[0]), key, DATASIZE); 
		res_ptr = (int*) (RES_PTR + mhartid*RES_ITEMS + i*3);
		*(res_ptr)   = index;
		*(res_ptr+1) = index >=0 ? data[index].key   : 0x0;
		*(res_ptr+2) = index >=0 ? data[index].value : 0x0;					
		//printf("index: %3d, data.key: %3d, data.val: %8x\n", index, data[index].key, data[index].value);
	}

	REFERENCE_PTR = &REFERENCE_RESULT[0];
	//stall all harts but hart-0 (main core)
	while(mhartid>0){ };
}



