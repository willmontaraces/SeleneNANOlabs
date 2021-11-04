//RTL Parameters
#define         REG_WIDTH             32
#define         N_COUNTERS            24
#define         N_CONF_REGS           1
#define         OVERFLOW              1
#define         QUOTA                 1
#define         MCCU                  1
#define         RDC                   1
#define         BASE_CFG              0
#define         END_CFG               0
#define         BASE_COUNTERS         1
#define         END_COUNTERS          24
#define         BASE_OVERFLOW_INTR    25
#define         BASE_OVERFLOW_MASK    25
#define         N_OVERFLOW_MASK_REGS  1
#define         END_OVERFLOW_MASK     25
#define         BASE_OVERFLOW_VECT    26
#define         N_OVERFLOW_VECT_REGS  1
#define         END_OVERFLOW_VECT     26
#define         N_OVERFLOW_REGS       1
#define         END_OVERFLOW_INTR     26
#define         BASE_QUOTA_INTR       27
#define         BASE_QUOTA_MASK       27
#define         N_QUOTA_MASK_REGS     1
#define         END_QUOTA_MASK        27
#define         BASE_QUOTA_LIMIT      28
#define         N_QUOTA_LIMIT_REGS    1
#define         END_QUOTA_LIMIT       28
#define         N_QUOTA_REGS          2
#define         END_QUOTA_INTR        28
#define         MCCU_WEIGHTS_WIDTH    8
#define         MCCU_N_CORES          4
#define         MCCU_N_EVENTS         2
#define         BASE_MCCU_CFG         29
#define         N_MCCU_CFG            1
#define         END_MCCU_CFG          29
#define         BASE_MCCU_LIMITS      30
#define         N_MCCU_LIMITS         4
#define         END_MCCU_LIMITS       33
#define         BASE_MCCU_QUOTA       34
#define         N_MCCU_QUOTA          4
#define         END_MCCU_QUOTA        37
#define         BASE_MCCU_WEIGHTS     38
#define         N_MCCU_WEIGHTS        2
#define         END_MCCU_WEIGHTS      39
#define         N_MCCU_REGS           11
#define         RDC_WEIGHTS_WIDTH     8
#define         RDC_N_CORES           4
#define         RDC_N_EVENTS          2
#define         BASE_RDC_VECT         40
#define         N_RDC_VECT_REGS       1
#define         END_RDC_VECT          40
#define         BASE_RDC_WEIGHTS      38
#define         N_RDC_WEIGHTS         0
#define         END_RDC_WEIGHTS       39
#define         BASE_RDC_WATERMARK    41
#define         N_RDC_WATERMARK       2
#define         END_RDC_WATERMARK     42
#define         BASE_CROSSBAR         43
#define         N_CROSSBAR_REG        4
#define         END_CROSSBAR          46
#define         TOTAL_NREGS           47
#define         END_PMU               (TOTAL_NREGS-1)
// SOC parameters
#define PMU_ADDR (0x80200000U)

//CROSSBAR parameters
#define _REG_TYPE (volatile unsigned int *)

#define CROSSBAR_INPUTS (32U)
#define CROSSBAR_OUTPUTS (24U)

#define _PMUREG          ( _REG_TYPE (PMU_ADDR ) ) // PMU base address
#define _PMU_COUNTERS    ( _REG_TYPE (PMU_ADDR + (4*BASE_CFG)) ) // PMU counter base address
#define _PMU_CROSSBAR    ( _REG_TYPE (PMU_ADDR + (4*BASE_CROSSBAR)) ) // PMU crossbar base address

#define CROSSBAR_REG0    ( _PMU_CROSSBAR[0] )   // Crossbar output register 0
#define CROSSBAR_REG1    ( _PMU_CROSSBAR[1] )   // Crossbar output register 1
#define CROSSBAR_REG2    ( _PMU_CROSSBAR[2] )   // Crossbar output register 2
#define CROSSBAR_REG3    ( _PMU_CROSSBAR[3] )   // Crossbar output register 3

#define CROSSBAR_OUTPUT_0   (0U)
#define CROSSBAR_OUTPUT_1   (1U)
#define CROSSBAR_OUTPUT_2   (2U)
#define CROSSBAR_OUTPUT_3   (3U)
#define CROSSBAR_OUTPUT_4   (4U)
#define CROSSBAR_OUTPUT_5   (5U)
#define CROSSBAR_OUTPUT_6   (6U)
#define CROSSBAR_OUTPUT_7   (7U)
#define CROSSBAR_OUTPUT_8   (8U)
#define CROSSBAR_OUTPUT_9   (9U)
#define CROSSBAR_OUTPUT_10  (10U)
#define CROSSBAR_OUTPUT_11  (11U)
#define CROSSBAR_OUTPUT_12  (12U)
#define CROSSBAR_OUTPUT_13  (13U)
#define CROSSBAR_OUTPUT_14  (14U)
#define CROSSBAR_OUTPUT_15  (15U)
#define CROSSBAR_OUTPUT_16  (16U)
#define CROSSBAR_OUTPUT_17  (17U)
#define CROSSBAR_OUTPUT_18  (18U)
#define CROSSBAR_OUTPUT_19  (19U)
#define CROSSBAR_OUTPUT_20  (20U)
#define CROSSBAR_OUTPUT_21  (21U)
#define CROSSBAR_OUTPUT_22  (22U)
#define CROSSBAR_OUTPUT_23  (23U)
#define CROSSBAR_OUTPUT_24  (24U)

#define EVENT_0   (0U)
#define EVENT_1   (1U)
#define EVENT_2   (2U)
#define EVENT_3   (3U)
#define EVENT_4   (4U)
#define EVENT_5   (5U)
#define EVENT_6   (6U)
#define EVENT_7   (7U)
#define EVENT_8   (8U)
#define EVENT_9   (9U)
#define EVENT_10  (10U)
#define EVENT_11  (11U)
#define EVENT_12  (12U)
#define EVENT_13  (13U)
#define EVENT_14  (14U)
#define EVENT_15  (15U)
#define EVENT_16  (16U)
#define EVENT_17  (17U)
#define EVENT_18  (18U)
#define EVENT_19  (19U)
#define EVENT_20  (20U)
#define EVENT_21  (21U)
#define EVENT_22  (22U)
#define EVENT_23  (23U)
#define EVENT_24  (24U)
#define EVENT_25  (25U)
#define EVENT_26  (26U)
#define EVENT_27  (27U)
#define EVENT_28  (28U)
#define EVENT_29  (29U)
#define EVENT_30  (30U)
#define EVENT_31  (31U)
