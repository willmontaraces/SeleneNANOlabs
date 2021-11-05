#ifndef GLOBAL_DEFS
#define GLOBAL_DEFS

#define RES_ITEMS 64
#define CORE_DELAY 20
#include "RootVoter.h"

#endif

extern volatile int * RES_PTR;
extern RootVoterDescriptor RVC0;


void mkernel(int mhartid);


