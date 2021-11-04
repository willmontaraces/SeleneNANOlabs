void ld_l1miss(int * p, volatile int iterations);
void ld_l1hit(int * p, volatile int iterations);
void st_l1(int * p, volatile int iterations);
void l1miss_ic_1set(int iterations);
void ld_st_l1mix(int * p1, int * p2, volatile int iterations) __attribute__((always_inline));
void ld_l2miss(int * p, volatile int iterations);