#ifndef PMU_HEADER_H
#define PMU_HEADER_H

// ========================
// Includes
// ========================

#include <stdio.h>

#include <stdlib.h>

#include <stdint.h>

#include <pmu_vars.h>
 // ========================
// Defines
// ========================

//base addres for PMU on SoC
#define PMU_ADDR (0x80100000)
#define PLIC_BASE 0xf8000000U

// ========================
// General pourpose functions
// ========================

// ** and mask
void masked_and_write(unsigned int entry, unsigned int mask);
// ** or mask
void masked_or_write(unsigned int entry, unsigned int mask);

//Select test mode
unsigned int select_test_mode(unsigned int mode);

// ** write one register register_id, value
void write_register(unsigned int entry, unsigned int value);

// ** read one register register_id,
unsigned int read_register(unsigned int entry);

// ** write in main cfg register (counters, overflow and quota)
void write_main_cfg(unsigned int value);

// ** write range of address with same value
void write_register_range(unsigned int entry, unsigned int exit, unsigned int value);

// ** Read range of registers. Includes first and an last values
void read_register_range(unsigned int entry, unsigned int exit);

// ** Read and print the content of all the PMU registers
void read_all_pmu_regs(void);

// ** Set to 0 all PMU registers
void zero_all_pmu_regs(void);

// ========================
// Counters
// ========================

// ========================
// Overflow
// ========================

// ** softreset overflow 
void reset_overflow(void);

// ** enable overflow 
void enable_overflow(void);

// ** disable overflow 
void disable_overflow(void);

//Write all 1 to the overflow mask Write all 1 to the overflow mask 
//Pass condition: Register shall be set to max value
void test_overflow_1(void);

//Configure the PMU in a way that will trigger an interrupt
//Given that all the input events are set to 1
//Pass condition: Each bit assigned to a counter in the interruption vector
//shall be set to 1, overflow interruption shall be 1
void test_overflow_2(void);

// ========================
// QUOTA
// ========================

// ** softreset overflow 
void reset_quota(void);

//Disable counters, set counters to 1, set mask enable for all counters, wait
//as many cycles as counters pass: Interruption shall trigger
void test_quota_1(void);

//Disable counters, set counters to max_value , set mask disabled for  all
//counters, wait as many cycles as counters pass: Interruption shall not
//trigger
void test_quota_2(void);

//Quota test 1 and reset the unit.
//pass: Interruption shall trigger and be disabled after softreset. Mask will
//be updated from the wrapper registers once the softreset is set to 0 again and
//interruption may rettrigger
void test_quota_3(void);

// ========================
// MCCU
// ========================

// ** write in main MCCU cfg register (MCCU RDC)
void write_MCCU_cfg(unsigned int value);

// ** softreset MCCU
void reset_MCCU(void);

// ** enable MCCU 
void enable_MCCU(void);

// ** disable MCCU 
void disable_MCCU(void);

//Disable MCCU, write quota limits and toogle quota update bit on MCCU_CFG reg
//pass:Internal registers of MCCU shall be exactly the configured values after
//two cycles
void test_MCCU_1(unsigned int value);

//Disable MCCU, set weights for each eventi
//pass: weights shall be internally registered after two cycles
void test_MCCU_2(unsigned int value);

//Disable MCCU, set limits, set weights, and enable MCCU. When available quota
//reach 0 the interrupts risen pass: all interrupts must rise. This will happen
//up to 2 cycles before the wrapper registers are updated
void test_MCCU_3(void);

//Disable MCCU, set limits, and DONT enable MCCU. 
//pass: non of the interrupts must rise. Available quota shall not decerease 
void test_MCCU_4(void);

// ========================
// RDC
// ========================

// ** softreset RDC
void reset_RDC(void);

// ** enable RDC 
void enable_RDC(void);

// ** disable RDC 
void disable_RDC(void);

//Set weights to low value and count pulse length in testmode 1
//pass:Since all the events are high the interupt shall rise
void test_RDC_1(void);

//Set weights to low value and count pulse length in testmode 2
//pass:Since all the events are low the interupt shall not rise
void test_RDC_2(void);

// ** Read range of registers. Includes first and an last values
void read_mem_range(unsigned int entry, unsigned int exit);

// ** Return structure of pmu report
struct report_s {
    unsigned int ev0;
    unsigned int ev1;
    unsigned int ev2;
    unsigned int ev3;
    unsigned int ev4;
    unsigned int ev5;
    unsigned int ev6;
    unsigned int ev7;
    unsigned int ev8;
    unsigned int ev9;
    unsigned int ev10;
    unsigned int ev11;
    unsigned int ev12;
    unsigned int ev13;
    unsigned int ev14;
    unsigned int ev15;
    unsigned int ev16;
    unsigned int ev17;
    unsigned int ev18;
    unsigned int ev19;
    unsigned int ev20;
    unsigned int ev21;
    unsigned int ev22;
    unsigned int ev23;
};

// ** Read PMU counters and print in a formated way
struct report_s report_pmu(void);

// ========================
//    Crossbar
// ========================

typedef struct {
    unsigned int output;
    unsigned int event;
    char * description;
}
crossbar_event_t;

// ** Configure crossbar outputs with a given event **
unsigned  pmu_configure_crossbar(unsigned int output, unsigned int event_index);

// ** Read all crossbar registers ** 
void read_crossbar_registers();

// ** Register all events from a crossbar_event_t table
void pmu_register_events(const crossbar_event_t * ev_table, unsigned int event_count);

#define EV_CNT_HIGH(EVENT_0) // Constant HIGH signal
#define EV_CNT_LOW(EVENT_1) // Constant LOW signal
#define EV_ICNT0_P0(EVENT_2) // Core 0. Instruction count pipeline 0 
#define EV_ICNT0_P1(EVENT_3) // Core 0. Instruction count pipeline 1  
#define EV_PMU_ICMISS0(EVENT_4) // Core 0. Instruction cache miss
#define EV_PMU_BPMISS0(EVENT_5) // Core 0. Branch Predictor miss
#define EV_PMU_DCMISS0(EVENT_6) // Core 0. Data cache L1 miss
#define EV_PMU_DCHIT0(EVENT_7) // Core 0. Data cache L1 hit
#define EV_PMU_DCMISS1(EVENT_8) // Core 1. Data cache L1 miss
#define EV_PMU_DCMISS2(EVENT_9) // Core 2. Data cache L1 miss
#define EV_PMU_DCMISS3(EVENT_10) // Core 3. Data cache L1 miss
#define EV_L2_MISS(EVENT_11) // Cache L2 miss
#define EV_L2_ACCESS(EVENT_12) // Cache L2 access
#define EV_CSSCONT_RD_C1VC0(EVENT_13) // Contention of core 1 over core 0 on read access
#define EV_CSSCONT_WR_C1VC0(EVENT_14) // Contention of core 1 over core 0 on write access 
#define EV_CCSCONT_RD_C2VC0(EVENT_15) // Contention of core 2 over core 0 on read access
#define EV_CSSCONT_WR_C2VC0(EVENT_16) // Contention of core 2 over core 0 on write access 
#define EV_CSSCONT_RD_C3VC0(EVENT_17) // Contention of core 3 over core 0 on read access
#define EV_CSSCONT_WR_C3VC0(EVENT_18) // Contention of core 3 over core 0 on write access 

#define EV_CCSLATC0_ICMISS(EVENT_19) // Latency experienced by core 0 between a instruction cache miss and the reception of the data
#define EV_CCSLATC0_DCMISS(EVENT_20) // Latency experienced by core 0 between a data cache miss and the reception of the data
#define EV_CCSLATC0_WR(EVENT_21) // Latency experienced by core 0 between the start of a write and its termination  
#define EV_CCSLATC1_ICMISS(EVENT_22) // Latency experienced by core 1 between a instruction cache miss and the reception of the data
#define EV_CCSLATC1_DCMISS(EVENT_23) // Latency experienced by core 1 between a data cache miss and the reception of the data
#define EV_CCSLATC1_WR(EVENT_24) // Latency experienced by core 1 between the start of a write and its termination  
#define EV_CCSLATC2_ICMISS(EVENT_25) // Latency experienced by core 2 between a instruction cache miss and the reception of the data
#define EV_CCSLATC2_DCMISS(EVENT_26) // Latency experienced by core 2 between a data cache miss and the reception of the data
#define EV_CCSLATC2_WR(EVENT_27) // Latency experienced by core 2 between the start of a write and its termination  

#define EV_CCSLATC3_ICMISS(EVENT_28) // Latency experienced by core 3 between a instruction cache miss and the reception of the data
#define EV_CCSLATC3_DCMISS(EVENT_29) // Latency experienced by core 3 between a data cache miss and the reception of the data
#define EV_CCSLATC3_WR(EVENT_30) // Latency experienced by core 3 between the start of a write and its termination  

// #define EV_CSSCONT_RD_C0VC1     ()   // Contention of core 0 over core 1 on read access
// #define EV_CSSCONT_WR_C0VC1     ()   // Contention of core 0 over core 1 on write access

#define PMU_ERROR_MSG_FORMAT "\033[0;31m"
#define PMU_DEFAULT_MSG_FORMAT "\033[0m"

void pmu_enable();
void pmu_disable();
void pmu_reset();
void reset_rdc();
void enable_rdc();
void disable_rdc();
void print_watermarks_regs();
void mccu_set_quota(const unsigned int core,
    const unsigned int quota);
void mccu_set_event_weigths(const unsigned int input,
    const unsigned int weigth);

/* **********************************
        COUNTERS SUBMODULE
* **********************************/

void pmu_counters_reset(void);
void pmu_counters_enable(void);
void pmu_counters_disable(void);
void pmu_counters_print(const crossbar_event_t * table, unsigned int event_count);
void pmu_counters_fill_default_descriptions(crossbar_event_t* table, unsigned int event_count);

/* **********************************
          OVERFLOW SUBMODULE
* **********************************/

void pmu_overflow_enable(void);
void pmu_overflow_disable(void);
void pmu_overflow_reset(void);
void pmu_overflow_enable_interrupt(unsigned int mask);
void pmu_overflow_disable_interrupt(unsigned int mask);
void pmu_overflow_register_interrupt(void( * isr)(void));
unsigned int pmu_overflow_get_interrupt(unsigned int mask);
unsigned int pmu_overflow_get_iv(void);

/* **********************************
           MCCU SUBMODULE
* **********************************/

void pmu_mccu_enable(void);
void pmu_mccu_disable(void);
void pmu_mccu_reset(void);
void pmu_mccu_enable_HQ(void);
void pmu_mccu_disable_HQ(void);

unsigned pmu_mccu_set_quota_limit(const unsigned int core,
    const unsigned int quota);
unsigned int pmu_mccu_get_quota_remaining(unsigned int core);
unsigned pmu_mccu_set_event_weigths(const unsigned int input,
    const unsigned int weigth);

/* **********************************
           RDC SUBMODULE
* **********************************/

void pmu_rdc_enable(void);
void pmu_rdc_disable(void);
void pmu_rdc_reset(void);
unsigned int pmu_rdc_read_watermark(unsigned int input);
unsigned int pmu_rdc_read_iv();
unsigned int pmu_rdc_get_interrupt(unsigned int core);

#define PMU_DEFAULT_EVENT_COUNT (25u)
static
const crossbar_event_t pmu_default_event_table[] = {

    {
        CROSSBAR_OUTPUT_0,
        EVENT_0,
        "Constant High"
    },
    {
        CROSSBAR_OUTPUT_1,
        EVENT_1,
        "Constant Low"
    },
    {
        CROSSBAR_OUTPUT_2,
        EVENT_2,
        "Instruction count pipeline 0"
    },
    {
        CROSSBAR_OUTPUT_3,
        EVENT_3,
        "Instruction count pipeline 1"
    },
    {
        CROSSBAR_OUTPUT_4,
        EVENT_4,
        "Instruction cache miss on core 0"
    },
    {
        CROSSBAR_OUTPUT_5,
        EVENT_5,
        "Data cache miss on core 0"
    },
    {
        CROSSBAR_OUTPUT_6,
        EVENT_6,
        "Branch predictor miss on core 0"
    },
    {
        CROSSBAR_OUTPUT_7,
        EVENT_7,
        "Contention of core 1 over core 0 on ramdom access"
    },
    {
        CROSSBAR_OUTPUT_8,
        EVENT_8,
        "Contention of core 1 over core 0 on read access"
    },
    {
        CROSSBAR_OUTPUT_9,
        EVENT_9,
        "Contention of core 1 over core 1 on write acccess"
    },
    {
        CROSSBAR_OUTPUT_10,
        EVENT_10,
        "Total latency on core 0"
    },
    {
        CROSSBAR_OUTPUT_11,
        EVENT_11,
        "Latency caused by a data cache miss on core 0"
    },
    {
        CROSSBAR_OUTPUT_12,
        EVENT_12,
        "Latency caused by a instruction cache miss on core 0"
    },
    {
        CROSSBAR_OUTPUT_13,
        EVENT_13,
        "Latency caused by a write transaction on core 0"
    },
    {
        CROSSBAR_OUTPUT_14,
        EVENT_14,
        "Data cache miss on core 1"
    },
    {
        CROSSBAR_OUTPUT_15,
        EVENT_15,
        "Contention of core 0 over core 1 on ramdom access"
    },
    {
        CROSSBAR_OUTPUT_16,
        EVENT_16,
        "Contention of core 0 over core 1 on write access"
    },
    {
        CROSSBAR_OUTPUT_17,
        EVENT_17,
        "Total latency on core 1"
    },
    {
        CROSSBAR_OUTPUT_18,
        EVENT_18,
        "Latency caused by a data cache miss on core 1"
    },
    {
        CROSSBAR_OUTPUT_19,
        EVENT_19,
        "Latency caused by a write transaction on core 1"
    },
    {
        CROSSBAR_OUTPUT_20,
        EVENT_20,
        "Data cache miss on core 2"
    },
    {
        CROSSBAR_OUTPUT_21,
        EVENT_21,
        "Contention of core 0 over core 2 on ramdom access"
    },
    {
        CROSSBAR_OUTPUT_22,
        EVENT_22,
        "Contention of core 0 over core 2 on write access"
    },
    {
        CROSSBAR_OUTPUT_23,
        EVENT_23,
        "Total latency on core 2"
    },
    {
        CROSSBAR_OUTPUT_24,
        EVENT_24,
        "Latency caused by a data cache miss on core 2"
    }
};

static const char* counterDescriptions[] = {
" 0 - Debug - local -  Constant HIGH, used for debug purposes or clock cycles ",
" 1 - Debug - local -  Constant LOW, used for debug purposes ",
" 2 - Pulse - Core 0 -  Instruction count pipeline 0 ",
" 3 - Pulse - Core 0 -  Instruction count pipeline 1 ",
" 4 - Pulse - Core 0 -  Instruction cache miss ",
" 5 - Pulse - Core 0 -  Instruction TLB miss ",
" 6 - Pulse - Core 0 -  Data chache L1 miss ",
" 7 - Pulse - Core 0 -  Data TLB miss ",
" 8 - Pulse - Core 0 -  Branch predictor miss ",
" 9 - Pulse - Core 1 -  Instruction count pipeline 0 ",
" 10 - Pulse - Core 1 -  Instruction count pipeline 1 ",
" 11 - Pulse - Core 1 -  Instruction cache miss ",
" 12 - Pulse - Core 1 -  Instruction TLB miss ",
" 13 - Pulse - Core 1 -  Data chache L1 miss ",
" 14 - Pulse - Core 1 -  Data TLB miss ",
" 15 - Pulse - Core 1 -  Branch predictor miss ",
" 16 - Pulse - Core 2 -  Instruction count pipeline 0 ",
" 17 - Pulse - Core 2 -  Instruction count pipeline 1 ",
" 18 - Pulse - Core 2 -  Instruction cache miss ",
" 19 - Pulse - Core 2 -  Instruction TLB miss ",
" 20 - Pulse - Core 2 -  Data chache L1 miss ",
" 21 - Pulse - Core 2 -  Data TLB miss ",
" 22 - Pulse - Core 2 -  Branch predictor miss ",
" 23 - Pulse - Core 3 -  Instruction count pipeline 0 ",
" 24 - Pulse - Core 3 -  Instruction count pipeline 1 ",
" 25 - Pulse - Core 3 -  Instruction cache miss ",
" 26 - Pulse - Core 3 -  Instruction TLB miss ",
" 27 - Pulse - Core 3 -  Data chache L1 miss ",
" 28 - Pulse - Core 3 -  Data TLB miss ",
" 29 - Pulse - Core 3 -  Branch predictor miss ",
" 30 - Pulse - Core 4 -  Instruction count pipeline 0 ",
" 31 - Pulse - Core 4 -  Instruction count pipeline 1 ",
" 32 - Pulse - Core 4 -  Instruction cache miss ",
" 33 - Pulse - Core 4 -  Instruction TLB miss ",
" 34 - Pulse - Core 4 -  Data chache L1 miss ",
" 35 - Pulse - Core 4 -  Data TLB miss ",
" 36 - Pulse - Core 4 -  Branch predictor miss ",
" 37 - Pulse - Core 5 -  Instruction count pipeline 0 ",
" 38 - Pulse - Core 5 -  Instruction count pipeline 1 ",
" 39 - Pulse - Core 5 -  Instruction cache miss ",
" 40 - Pulse - Core 5 -  Instruction TLB miss ",
" 41 - Pulse - Core 5 -  Data chache L1 miss ",
" 42 - Pulse - Core 5 -  Data TLB miss ",
" 43 - Pulse - Core 5 -  Branch predictor miss ",
" 44 - CCS AHB -  -  -  Agressor C1 Victim C0",
" 45 - CCS AHB -  -  -  Agressor C2 Victim C0",
" 46 - CCS AHB -  -  -  Agressor C3 Victim C0",
" 47 - CCS AHB -  -  -  Agressor C4 Victim C0",
" 48 - CCS AHB -  -  -  Agressor C5 Victim C0",
" 49 - CCS AHB -  -  -  Agressor C0 Victim C1",
" 50 - CCS AHB -  -  -  Agressor C2 Victim C1",
" 51 - CCS AHB -  -  -  Agressor C3 Victim C1",
" 52 - CCS AHB -  -  -  Agressor C4 Victim C1",
" 53 - CCS AHB -  -  -  Agressor C5 Victim C1",
" 54 - CCS AHB -  -  -  Agressor C0 Victim C2",
" 55 - CCS AHB -  -  -  Agressor C1 Victim C2",
" 56 - CCS AHB -  -  -  Agressor C3 Victim C2",
" 57 - CCS AHB -  -  -  Agressor C4 Victim C2",
" 58 - CCS AHB -  -  -  Agressor C5 Victim C2",
" 59 - CCS AHB -  -  -  Agressor C0 Victim C3",
" 60 - CCS AHB -  -  -  Agressor C1 Victim C3",
" 61 - CCS AHB -  -  -  Agressor C2 Victim C3",
" 62 - CCS AHB -  -  -  Agressor C4 Victim C3",
" 63 - CCS AHB -  -  -  Agressor C5 Victim C3",
" 64 - CCS AHB -  -  -  Agressor C0 Victim C4",
" 65 - CCS AHB -  -  -  Agressor C1 Victim C4",
" 66 - CCS AHB -  -  -  Agressor C2 Victim C4",
" 67 - CCS AHB -  -  -  Agressor C3 Victim C4",
" 68 - CCS AHB -  -  -  Agressor C5 Victim C4",
" 69 - CCS AHB -  -  -  Agressor C0 Victim C5",
" 70 - CCS AHB -  -  -  Agressor C1 Victim C5",
" 71 - CCS AHB -  -  -  Agressor C2 Victim C5",
" 72 - CCS AHB -  -  -  Agressor C3 Victim C5",
" 73 - CCS AHB -  -  -  Agressor C4 Victim C5",
" 74 - CCS AXI - Write -  Agressor MQ1 Victim MQ0",
" 75 - CCS AXI - Write -  Agressor MQ2 Victim MQ0",
" 76 - CCS AXI - Write -  Agressor MQ3 Victim MQ0",
" 77 - CCS AXI - Write -  Agressor MQ4 Victim MQ0",
" 78 - CCS AXI - Write -  Agressor MQ5 Victim MQ0",
" 79 - CCS AXI - Write -  Agressor MQ6 Victim MQ0",
" 80 - CCS AXI - Write -  Agressor MQ7 Victim MQ0",
" 81 - CCS AXI - Write -  Agressor MQ8 Victim MQ0",
" 82 - CCS AXI - Write -  Agressor MQ9 Victim MQ0",
" 83 - CCS AXI - Write -  Agressor MQ10 Victim MQ0",
" 84 - CCS AXI - Write -  Agressor MQ11 Victim MQ0",
" 85 - CCS AXI - Write -  Agressor MQ12 Victim MQ0",
" 86 - CCS AXI - Write -  Agressor MQ13 Victim MQ0",
" 87 - CCS AXI - Write -  Agressor MQ14 Victim MQ0",
" 88 - CCS AXI - Write -  Agressor MQ0 Victim MQ1",
" 89 - CCS AXI - Write -  Agressor MQ2 Victim MQ1",
" 90 - CCS AXI - Write -  Agressor MQ3 Victim MQ1",
" 91 - CCS AXI - Write -  Agressor MQ4 Victim MQ1",
" 92 - CCS AXI - Write -  Agressor MQ5 Victim MQ1",
" 93 - CCS AXI - Write -  Agressor MQ6 Victim MQ1",
" 94 - CCS AXI - Write -  Agressor MQ7 Victim MQ1",
" 95 - CCS AXI - Write -  Agressor MQ8 Victim MQ1",
" 96 - CCS AXI - Write -  Agressor MQ9 Victim MQ1",
" 97 - CCS AXI - Write -  Agressor MQ10 Victim MQ1",
" 98 - CCS AXI - Write -  Agressor MQ11 Victim MQ1",
" 99 - CCS AXI - Write -  Agressor MQ12 Victim MQ1",
" 100 - CCS AXI - Write -  Agressor MQ13 Victim MQ1",
" 101 - CCS AXI - Write -  Agressor MQ14 Victim MQ1",
" 102 - CCS AXI - Write -  Agressor MQ0 Victim MQ2",
" 103 - CCS AXI - Write -  Agressor MQ1 Victim MQ2",
" 104 - CCS AXI - Write -  Agressor MQ3 Victim MQ2",
" 105 - CCS AXI - Write -  Agressor MQ4 Victim MQ2",
" 106 - CCS AXI - Write -  Agressor MQ5 Victim MQ2",
" 107 - CCS AXI - Write -  Agressor MQ6 Victim MQ2",
" 108 - CCS AXI - Write -  Agressor MQ7 Victim MQ2",
" 109 - CCS AXI - Write -  Agressor MQ8 Victim MQ2",
" 110 - CCS AXI - Write -  Agressor MQ9 Victim MQ2",
" 111 - CCS AXI - Write -  Agressor MQ10 Victim MQ2",
" 112 - CCS AXI - Write -  Agressor MQ11 Victim MQ2",
" 113 - CCS AXI - Write -  Agressor MQ12 Victim MQ2",
" 114 - CCS AXI - Write -  Agressor MQ13 Victim MQ2",
" 115 - CCS AXI - Write -  Agressor MQ14 Victim MQ2",
" 116 - CCS AXI - Write -  Agressor MQ0 Victim MQ3",
" 117 - CCS AXI - Write -  Agressor MQ1 Victim MQ3",
" 118 - CCS AXI - Write -  Agressor MQ2 Victim MQ3",
" 119 - CCS AXI - Write -  Agressor MQ4 Victim MQ3",
" 120 - CCS AXI - Write -  Agressor MQ5 Victim MQ3",
" 121 - CCS AXI - Write -  Agressor MQ6 Victim MQ3",
" 122 - CCS AXI - Write -  Agressor MQ7 Victim MQ3",
" 123 - CCS AXI - Write -  Agressor MQ8 Victim MQ3",
" 124 - CCS AXI - Write -  Agressor MQ9 Victim MQ3",
" 125 - CCS AXI - Write -  Agressor MQ10 Victim MQ3",
" 126 - CCS AXI - Write -  Agressor MQ11 Victim MQ3",
" 127 - CCS AXI - Write -  Agressor MQ12 Victim MQ3",
" 128 - CCS AXI - Write -  Agressor MQ13 Victim MQ3",
" 129 - CCS AXI - Write -  Agressor MQ14 Victim MQ3",
" 130 - CCS AXI - Write -  Agressor MQ0 Victim MQ4",
" 131 - CCS AXI - Write -  Agressor MQ1 Victim MQ4",
" 132 - CCS AXI - Write -  Agressor MQ2 Victim MQ4",
" 133 - CCS AXI - Write -  Agressor MQ3 Victim MQ4",
" 134 - CCS AXI - Write -  Agressor MQ5 Victim MQ4",
" 135 - CCS AXI - Write -  Agressor MQ6 Victim MQ4",
" 136 - CCS AXI - Write -  Agressor MQ7 Victim MQ4",
" 137 - CCS AXI - Write -  Agressor MQ8 Victim MQ4",
" 138 - CCS AXI - Write -  Agressor MQ9 Victim MQ4",
" 139 - CCS AXI - Write -  Agressor MQ10 Victim MQ4",
" 140 - CCS AXI - Write -  Agressor MQ11 Victim MQ4",
" 141 - CCS AXI - Write -  Agressor MQ12 Victim MQ4",
" 142 - CCS AXI - Write -  Agressor MQ13 Victim MQ4",
" 143 - CCS AXI - Write -  Agressor MQ14 Victim MQ4",
" 144 - CCS AXI - Write -  Agressor MQ0 Victim MQ5",
" 145 - CCS AXI - Write -  Agressor MQ1 Victim MQ5",
" 146 - CCS AXI - Write -  Agressor MQ2 Victim MQ5",
" 147 - CCS AXI - Write -  Agressor MQ3 Victim MQ5",
" 148 - CCS AXI - Write -  Agressor MQ4 Victim MQ5",
" 149 - CCS AXI - Write -  Agressor MQ6 Victim MQ5",
" 150 - CCS AXI - Write -  Agressor MQ7 Victim MQ5",
" 151 - CCS AXI - Write -  Agressor MQ8 Victim MQ5",
" 152 - CCS AXI - Write -  Agressor MQ9 Victim MQ5",
" 153 - CCS AXI - Write -  Agressor MQ10 Victim MQ5",
" 154 - CCS AXI - Write -  Agressor MQ11 Victim MQ5",
" 155 - CCS AXI - Write -  Agressor MQ12 Victim MQ5",
" 156 - CCS AXI - Write -  Agressor MQ13 Victim MQ5",
" 157 - CCS AXI - Write -  Agressor MQ14 Victim MQ5",
" 158 - CCS AXI - Read -  Agressor MQ1 Victim MQ0",
" 159 - CCS AXI - Read -  Agressor MQ2 Victim MQ0",
" 160 - CCS AXI - Read -  Agressor MQ3 Victim MQ0",
" 161 - CCS AXI - Read -  Agressor MQ4 Victim MQ0",
" 162 - CCS AXI - Read -  Agressor MQ5 Victim MQ0",
" 163 - CCS AXI - Read -  Agressor MQ6 Victim MQ0",
" 164 - CCS AXI - Read -  Agressor MQ7 Victim MQ0",
" 165 - CCS AXI - Read -  Agressor MQ8 Victim MQ0",
" 166 - CCS AXI - Read -  Agressor MQ9 Victim MQ0",
" 167 - CCS AXI - Read -  Agressor MQ10 Victim MQ0",
" 168 - CCS AXI - Read -  Agressor MQ11 Victim MQ0",
" 169 - CCS AXI - Read -  Agressor MQ12 Victim MQ0",
" 170 - CCS AXI - Read -  Agressor MQ13 Victim MQ0",
" 171 - CCS AXI - Read -  Agressor MQ14 Victim MQ0",
" 172 - CCS AXI - Read -  Agressor MQ0 Victim MQ1",
" 173 - CCS AXI - Read -  Agressor MQ2 Victim MQ1",
" 174 - CCS AXI - Read -  Agressor MQ3 Victim MQ1",
" 175 - CCS AXI - Read -  Agressor MQ4 Victim MQ1",
" 176 - CCS AXI - Read -  Agressor MQ5 Victim MQ1",
" 177 - CCS AXI - Read -  Agressor MQ6 Victim MQ1",
" 178 - CCS AXI - Read -  Agressor MQ7 Victim MQ1",
" 179 - CCS AXI - Read -  Agressor MQ8 Victim MQ1",
" 180 - CCS AXI - Read -  Agressor MQ9 Victim MQ1",
" 181 - CCS AXI - Read -  Agressor MQ10 Victim MQ1",
" 182 - CCS AXI - Read -  Agressor MQ11 Victim MQ1",
" 183 - CCS AXI - Read -  Agressor MQ12 Victim MQ1",
" 184 - CCS AXI - Read -  Agressor MQ13 Victim MQ1",
" 185 - CCS AXI - Read -  Agressor MQ14 Victim MQ1",
" 186 - CCS AXI - Read -  Agressor MQ0 Victim MQ2",
" 187 - CCS AXI - Read -  Agressor MQ1 Victim MQ2",
" 188 - CCS AXI - Read -  Agressor MQ3 Victim MQ2",
" 189 - CCS AXI - Read -  Agressor MQ4 Victim MQ2",
" 190 - CCS AXI - Read -  Agressor MQ5 Victim MQ2",
" 191 - CCS AXI - Read -  Agressor MQ6 Victim MQ2",
" 192 - CCS AXI - Read -  Agressor MQ7 Victim MQ2",
" 193 - CCS AXI - Read -  Agressor MQ8 Victim MQ2",
" 194 - CCS AXI - Read -  Agressor MQ9 Victim MQ2",
" 195 - CCS AXI - Read -  Agressor MQ10 Victim MQ2",
" 196 - CCS AXI - Read -  Agressor MQ11 Victim MQ2",
" 197 - CCS AXI - Read -  Agressor MQ12 Victim MQ2",
" 198 - CCS AXI - Read -  Agressor MQ13 Victim MQ2",
" 199 - CCS AXI - Read -  Agressor MQ14 Victim MQ2",
" 200 - CCS AXI - Read -  Agressor MQ0 Victim MQ3",
" 201 - CCS AXI - Read -  Agressor MQ1 Victim MQ3",
" 202 - CCS AXI - Read -  Agressor MQ2 Victim MQ3",
" 203 - CCS AXI - Read -  Agressor MQ4 Victim MQ3",
" 204 - CCS AXI - Read -  Agressor MQ5 Victim MQ3",
" 205 - CCS AXI - Read -  Agressor MQ6 Victim MQ3",
" 206 - CCS AXI - Read -  Agressor MQ7 Victim MQ3",
" 207 - CCS AXI - Read -  Agressor MQ8 Victim MQ3",
" 208 - CCS AXI - Read -  Agressor MQ9 Victim MQ3",
" 209 - CCS AXI - Read -  Agressor MQ10 Victim MQ3",
" 210 - CCS AXI - Read -  Agressor MQ11 Victim MQ3",
" 211 - CCS AXI - Read -  Agressor MQ12 Victim MQ3",
" 212 - CCS AXI - Read -  Agressor MQ13 Victim MQ3",
" 213 - CCS AXI - Read -  Agressor MQ14 Victim MQ3",
" 214 - CCS AXI - Read -  Agressor MQ0 Victim MQ4",
" 215 - CCS AXI - Read -  Agressor MQ1 Victim MQ4",
" 216 - CCS AXI - Read -  Agressor MQ2 Victim MQ4",
" 217 - CCS AXI - Read -  Agressor MQ3 Victim MQ4",
" 218 - CCS AXI - Read -  Agressor MQ5 Victim MQ4",
" 219 - CCS AXI - Read -  Agressor MQ6 Victim MQ4",
" 220 - CCS AXI - Read -  Agressor MQ7 Victim MQ4",
" 221 - CCS AXI - Read -  Agressor MQ8 Victim MQ4",
" 222 - CCS AXI - Read -  Agressor MQ9 Victim MQ4",
" 223 - CCS AXI - Read -  Agressor MQ10 Victim MQ4",
" 224 - CCS AXI - Read -  Agressor MQ11 Victim MQ4",
" 225 - CCS AXI - Read -  Agressor MQ12 Victim MQ4",
" 226 - CCS AXI - Read -  Agressor MQ13 Victim MQ4",
" 227 - CCS AXI - Read -  Agressor MQ14 Victim MQ4",
" 228 - CCS AXI - Read -  Agressor MQ0 Victim MQ5",
" 229 - CCS AXI - Read -  Agressor MQ1 Victim MQ5",
" 230 - CCS AXI - Read -  Agressor MQ2 Victim MQ5",
" 231 - CCS AXI - Read -  Agressor MQ3 Victim MQ5",
" 232 - CCS AXI - Read -  Agressor MQ4 Victim MQ5",
" 233 - CCS AXI - Read -  Agressor MQ6 Victim MQ5",
" 234 - CCS AXI - Read -  Agressor MQ7 Victim MQ5",
" 235 - CCS AXI - Read -  Agressor MQ8 Victim MQ5",
" 236 - CCS AXI - Read -  Agressor MQ9 Victim MQ5",
" 237 - CCS AXI - Read -  Agressor MQ10 Victim MQ5",
" 238 - CCS AXI - Read -  Agressor MQ11 Victim MQ5",
" 239 - CCS AXI - Read -  Agressor MQ12 Victim MQ5",
" 240 - CCS AXI - Read -  Agressor MQ13 Victim MQ5",
" 241 - CCS AXI - Read -  Agressor MQ14 Victim MQ5",
" 242 - - - - -   Filler signal, constant 0 ",
" 243 - - - - -   Filler signal, constant 0 ",
" 244 - - - - -   Filler signal, constant 0 ",
" 245 - - - - -   Filler signal, constant 0 ",
" 246 - - - - -   Filler signal, constant 0 ",
" 247 - - - - -   Filler signal, constant 0 ",
" 248 - - - - -   Filler signal, constant 0 ",
" 249 - - - - -   Filler signal, constant 0 ",
" 250 - - - - -   Filler signal, constant 0 ",
" 251 - - - - -   Filler signal, constant 0 ",
" 252 - - - - -   Filler signal, constant 0 ",
" 253 - - - - -   Filler signal, constant 0 ",
" 254 - - - - -   Filler signal, constant 0 ",
" 255 - - - - -   Filler signal, constant 0 "
    };

/* **********************************
//Legacy function calls
* **********************************/
void enable_counters (void);
void disable_counters (void);
void reset_counters (void);

#endif
