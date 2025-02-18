#include <stdint.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <bcc/bcc_param.h>

struct mydata {
        uint32_t val32;
        uint8_t  val8[64];
};

uintptr_t i32;
// int main(void)
// {
//         i32 = (uintptr_t) malloc(sizeof (struct mydata));
//         i32++;
//         /*
//          * NOTE: External function call needed so compiler won't cache i32.
//          */
//         printf("%s: forcing misaligned store...\n", __func__);
//         volatile uint32_t *p32 = (void *) i32;
//         *p32 = 0x12345678;
//         printf("%s: done misaligned store\n\n", __func__);

//         printf("%s: executing illegal instruction...\n", __func__);
//         __asm__ volatile ("unimp");
//         printf("%s: done illegal instruction\n\n", __func__);

//         return 0;
// }

#if __riscv_xlen == 32
#define PRINT_REG "0x%08" PRIxPTR
#elif __riscv_xlen == 64
#define PRINT_REG "0x%016" PRIxPTR
#endif

static void printit(
        uintptr_t mstatus,
        uintptr_t mepc,
        uintptr_t mcause,
        struct bcc_exc_ctx *frame
)
{
        printf("%s: mstatus = " PRINT_REG "\n", __func__, mstatus);
        printf("%s: mepc    = " PRINT_REG "\n", __func__, mepc);
        printf("%s: mcause  = " PRINT_REG "", __func__, mcause);
        if (mcause == 2) {
                printf(" *** illegal instruction *** ");
        } else if (mcause == 6) {
                printf(" *** misaligned store *** ");
        }
        printf("\n");
        printf("%s: frame   = " PRINT_REG "\n", __func__, (uintptr_t) frame);
        for (int i = 0; i < 31; i++) {
                printf("%s:   x[%2d] = " PRINT_REG "\n", __func__, i + 1, frame->x[i]);
        }
}

void __bcc_handle_exception(
        uintptr_t mstatus,
        uintptr_t mepc,
        uintptr_t mcause,
        struct bcc_exc_ctx *frame
)
{
        printf("%s: enter\n", __func__);
        if (1) {
                printit(mstatus, mepc, mcause, frame);
        } else {
                __asm__ volatile ("ebreak");
        }

        /* skip instruction causing exception */
        /* NOTE: may not work for C extension */
        frame->mepc += 4;
        printf("%s: exit\n", __func__);
}

