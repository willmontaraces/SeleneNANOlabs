#ifndef GLOBAL_DEFS
#define GLOBAL_DEFS

#define RES_ITEMS 64
#define CORE_DELAY 0

#endif

extern volatile int * RES_PTR;
extern volatile int * REFERENCE_PTR;

void mkernel(int mhartid);


