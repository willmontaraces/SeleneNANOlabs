#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include "workload.h"
#include "aes_lib.h"
#include "aes_lib.c"

uint8_t in[]  = { 0x6b, 0xc1, 0xbe, 0xe2, 0x2e, 0x40, 0x9f, 0x96, 0xe9, 0x3d, 0x7e, 0x11, 0x73, 0x93, 0x17, 0x2a };
                                                          

void mkernel(int mhartid)
{


	uint8_t key[] = { 0x60, 0x3d, 0xeb, 0x10, 0x15, 0xca, 0x71, 0xbe, 0x2b, 0x73, 0xae, 0xf0, 0x85, 0x7d, 0x77, 0x81,
		      0x1f, 0x35, 0x2c, 0x07, 0x3b, 0x61, 0x08, 0xd7, 0x2d, 0x98, 0x10, 0xa3, 0x09, 0x14, 0xdf, 0xf4 };  
                 
	for(int i=0;i<CORE_DELAY*mhartid;i++){
		__asm("nop");
	}

	uint8_t * testin = (uint8_t*) (RES_PTR + mhartid*RES_ITEMS);

	memcpy(testin, in, sizeof(in));


	struct AES_ctx ctx;
	AES_init_ctx(&ctx, key);
	AES_ECB_encrypt(&ctx, testin);

/*
	printf("AES-256 encrypt result: \n");
	for(int i=0;i<16;i++){
		printf("%02x ", *(testin+i) );
	}
*/

	//stall all harts but hart-0 (main core)
	while(mhartid>0){ };
}



