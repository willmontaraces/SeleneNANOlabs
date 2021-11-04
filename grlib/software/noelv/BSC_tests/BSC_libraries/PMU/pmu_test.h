#ifndef PMU_HEADER_H
#define PMU_HEADER_H

// ========================
// Includes
// ========================

#include <stdio.h> 
#include <stdint.h> 
#include <pmu_vars.h>

// ========================
// General pourpose functions
// ========================

// ** and mask
void masked_and_write (unsigned int entry, unsigned int mask);
// ** or mask
void masked_or_write (unsigned int entry, unsigned int mask);

//Select test mode
unsigned int select_test_mode (unsigned int mode);

// ** write one register register_id, value
void write_register (unsigned int entry, unsigned int value);

// ** read one register register_id,
unsigned int read_register(unsigned int entry);

// ** write in main cfg register (counters, overflow and quota)
void write_main_cfg ( unsigned int value);

// ** write range of address with same value
void write_register_range (unsigned int entry, unsigned int exit, unsigned int value);

// ** Read range of registers. Includes first and an last values
void read_register_range (unsigned int entry, unsigned int exit);

// ** Read and print the content of all the PMU registers
void read_all_pmu_regs(void);

// ** Set to 0 all PMU registers
void zero_all_pmu_regs(void);

// ========================
// Counters
// ========================

// ** softreset counters 
void reset_counters (void);

// ** enable counters 
void enable_counters (void);

// ** disable counters 
void disable_counters (void);

// ========================
// Overflow
// ========================

// ** softreset overflow 
void reset_overflow (void);

// ** enable overflow 
void enable_overflow (void);

// ** disable overflow 
void disable_overflow (void);

// ========================
// QUOTA
// ========================

// ** softreset overflow 
void reset_quota (void);

// ========================
// MCCU
// ========================
// ** write in main MCCU cfg register (MCCU RDC)
void write_MCCU_cfg ( unsigned int value);

// ** softreset MCCU
void reset_MCCU (void);

// ** enable MCCU 
void enable_MCCU (void);

// ** disable MCCU 
void disable_MCCU (void);

// ========================
// RDC
// ========================
// ** softreset RDC
void reset_RDC (void);

// ** enable RDC 
void enable_RDC (void);

// ** disable RDC 
void disable_RDC (void);

// ========================
// Reports
// ========================
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
struct report_s report_pmu (void);

// ========================
//    Crossbar
// ========================
typedef struct 
{
    unsigned output;
    unsigned event;
    char *description;
} crossbar_event_t;

// ** Configure crossbar outputs with a given event **
void configure_crossbar(unsigned int output, unsigned int event_index);

// ** Read all crossbar registers ** 
void read_crossbar_registers();

// ** Register all events from a crossbar_event_t table
void register_events(const crossbar_event_t *ev_table);

#endif
