#include <pmu_hw.h>
#include <math.h>
#include "util.h"
#define PLIC_BASE 0x84000000
#define __PMU_LIB_DEBUG__

/*
 *   Function    : pmu_counters_enable
 *   Description : It enables the event counters.
 *   Parameters  : None
 *   Return      : None   
 */
void pmu_counters_enable(void) {
    PMUCFG0 |= 0x00000001;
    #ifdef __PMU_LIB_DEBUG__
    printf("Enable counters\n");
    printf("CFG0 = 0x%08x\n", PMUCFG0);
    #endif
}

/*
 *   Function    : pmu_counters_disable
 *   Description : It disables the event counters.
 *   Parameters  : None
 *   Return      : None   
 */
void pmu_counters_disable(void) {
    PMUCFG0 &= 0xFFFFFFFE;
    #ifdef __PMU_LIB_DEBUG__
    printf("Disable counters\n");
    printf("CFG0 = 0x%08x\n", PMUCFG0);
    #endif
}

/*
 *   Function    : pmu_counters_reset
 *   Description : It resets (set to 0) all the event counters.
 *   Parameters  : None
 *   Return      : None   
 */
void pmu_counters_reset(void) {
    PMUCFG0 |= 0x00000002;
    PMUCFG0 &= 0xFFFFFFFD;
    #ifdef __PMU_LIB_DEBUG__
    printf("Softreset counters\n");
    printf("CFG0 = 0x%08x\n", PMUCFG0);
    #endif
}

/*
 *   Function    : pmu_configure_crossbar
 *   Description : It routes the HDL wired signals with the 
 *                 counter modules.
 *   Parameters  : 
 *     - output        : Crossbar output number. See the CROSSBAR_OUTPUT_X 
 *                       defines in pmu_vars.h
 *     - event_index   : Event index of the wired signat in the HDL code. Refer to
 *                       SafePMU User's manual, section 2.2,table 2.1.
 *   Return      : None   
 */
unsigned pmu_configure_crossbar(unsigned int output, unsigned int event_index) {
    if (event_index>CROSSBAR_INPUTS){
        #ifdef __UART__
        printf("Input port %d selected out of range\n", event_index);
        #endif
    return (1);
    } 
    if (output>N_COUNTERS){
        #ifdef __UART__
        printf("Output port %d selected out of range\n", output);
        #endif
    return (1);
    } 

    unsigned int ev_idx = (event_index & CROSSBAR_INPUTS ); //?
    unsigned int fieldw = log2(CROSSBAR_INPUTS);
   
    //Blank Mask. It will reset any configuration field
    unsigned int bmask ; 
    bmask=(1<<fieldw)-1;
    //Get the bit position if all registers where concatenated
    unsigned tmp,reg_idx,field_idx;
    tmp = event_index*fieldw;
    //Get the register index given a register width
    reg_idx = tmp/REG_WIDTH;
    //Get the position of the crossbar configuration field
    field_idx = (int)tmp % REG_WIDTH;
    // check if the configuration field has bits in two different registers
    unsigned fieldw1 = fieldw; // Bits in first register
    unsigned fieldw2 = 0; //Bits in second register
    if ((field_idx+fieldw)>REG_WIDTH) {
        fieldw1 = REG_WIDTH-field_idx;
        fieldw2 = fieldw - fieldw1;
        // Clear previous field
        _PMU_CROSSBAR[reg_idx] &= (~((1<<fieldw1)-1) << field_idx); 
        _PMU_CROSSBAR[reg_idx+1] &= ~((1<<fieldw2)-1); 
        //Set new values
        _PMU_CROSSBAR[reg_idx] |= ev_idx << field_idx; 
        _PMU_CROSSBAR[reg_idx] |= (ev_idx>>fieldw1); 
    } else {
        _PMU_CROSSBAR[reg_idx] &= (~((bmask) << field_idx)); // Erease the output field
        _PMU_CROSSBAR[reg_idx] |= ev_idx << field_idx; // Write into the output field
    };
    return (0);
}

/*
 *   Function    : pmu_register_events
 *   Description : It registers all the event given by the ev_table parameter
 *   Parameters  : 
 *       - ev_table      : Table of register events.
 *       - event_count   : Number of register events.
 *   Return      : None   
 */
void pmu_register_events(const crossbar_event_t * ev_table, unsigned int event_count) {
    for (int i = 0; i < event_count; ++i) {
        pmu_configure_crossbar(ev_table[i].output, ev_table[i].event);
    }
}

/*
 *   Function    : pmu_counters_print
 *   Description : It prompt the register events with their
 *                 descriptions.
 *   Parameters  : 
 *       - table         : Table of register events.
 *       - event_count   : Number of register events.
 *   Return      : None   
 */
void pmu_counters_print(const crossbar_event_t * table, unsigned int event_count) {
    for (int i = 0; i < event_count; ++i) {
        printf("PMU_COUNTER[%d] = %d\t%s\n", i, _PMU_COUNTERS[table[i].output], table[i].description);
    }
}

/* **********************************
          OVERFLOW SUBMODULE
* **********************************/

/* 
 *   Function    : pmu_overflow_enable
 *   Description : Enable the PMU overflow submodule.
 *   Parameters  : None
 *   Return      : None   
 */
void pmu_overflow_enable(void) {
    PMUCFG0 |= 0x00000004;
    #ifdef __PMU_LIB_DEBUG__
    printf("pmu_overflow_enable\n");
    printf("PMUCFG0 = 0x%08x\n");
    #endif
}

/*
 *   Function    : pmu_overflow_disable
 *   Description : Disable the PMU overflow submodule.
 *   Parameters  : None
 *   Return      : None   
 */
void pmu_overflow_disable(void) {
    PMUCFG0 &= 0xFFFFFFFB;
    #ifdef __PMU_LIB_DEBUG__
    printf("pmu_overflow_disable\n");
    printf("PMUCFG0 = 0x%08x\n", PMUCFG0);
    #endif
}

/*
 *   Function    : pmu_overflow_reset
 *   Description : It resets the overflow flags.
 *   Parameters  : None
 *   Return      : None   
 */
void pmu_overflow_reset(void) {
    PMUCFG0 |= 0x00000008;
    PMUCFG0 &= 0xFFFFFFF7;
    #ifdef __PMU_LIB_DEBUG__
    printf("pmu_overflow_reset\n");
    #endif
}

/*
 *   Function    : pmu_overflow_enable_interrupt
 *   Description : It enables the interrupts for overflow submodule.
 *   Parameters  : 
 *       - mask  : Mask for each counter.
 *   Return      : None   
 */
void pmu_overflow_enable_interrupt(unsigned int mask) {
    PMU_OVERLFOW_IE |= mask;
    #ifdef __PMU_LIB_DEBUG__
    printf("pmu_overflow_enable_interrupt\n");
    printf("PMU_OVERLFOW_IE = 0x%08x\n", PMU_OVERLFOW_IE);
    #endif
}

/*
 *   Function    : pmu_overflow_disable_interrupt
 *   Description : It disables the interrupts for overflow submodule.
 *   Parameters  : None
 *   Return      : None   
 */
void pmu_overflow_disable_interrupt(unsigned int mask) {
    PMU_OVERLFOW_IE &= ~mask;
    #ifdef __PMU_LIB_DEBUG__
    printf("pmu_overflow_disable_interrupt\n");
    #endif
}

/*
 *   Function    : pmu_overflow_get_iv
 *   Description : It disables the interrupts for overflow submodule.
 *   Parameters  : 
 *       - mask  : Mask of each counter.
 *   Return      : 
 *       - 1     : One or more of the counters passed by mask has caused an overflow interrupt.
 *       - 0     : None of the counters passed by mask has caused an overflow interrupt.
 */
unsigned int pmu_overflow_get_interrupt(unsigned int mask) {
    #ifdef __PMU_LIB_DEBUG__
    printf("pmu_overflow_get_interrupt\n");
    #endif

    return ((PMU_OVERFLOW_IV & mask) != 0);
}

/*
 *   Function    : pmu_overflow_get_iv
 *   Description : It disables the interrupts for overflow submodule.
 *   Parameters  : None
 *   Return      : It returns the Overflow Interrupt Vector register.
 */
unsigned int pmu_overflow_get_iv(void) {
    #ifdef __PMU_LIB_DEBUG__
    printf("pmu_overflow_get_iv\n");
    #endif
    return (PMU_OVERFLOW_IV);
}

// TODO: Change priority
void pmu_overflow_register_interrupt(void( * isr)(void)) {
    #ifdef __PMU_LIB_DEBUG__
    printf("pmu_overflow_register_interrupt IN\n");
    #endif

    volatile unsigned int * p;

    p = (unsigned int * )(PLIC_BASE + 0x001000 + 4 * PMU_OVERFLOW_INT_INDEX);
    printf("Pending interrupt %d\n", * p);

    // p = (unsigned int *)(PLIC_BASE + 0x200000);
    // printf("Priority threshold for context 0 = %d\n", *p);
    // *p = 0;

    p = (unsigned int * )(PLIC_BASE + 0x200004);
    printf("Claim complete interrupt for context 0 = %d\n", * p);
    * p = PMU_OVERFLOW_INT_INDEX;

    write_csr(mtvec, isr);

    // Stablishes the priority level for a given interrupt index.
    p = (unsigned int * )(PLIC_BASE + 4 * PMU_OVERFLOW_INT_INDEX);
    * p = 7; // Priority

    // Enables the interrupt for index 7 (0x40) on context 0
    p = (unsigned int * )(PLIC_BASE + 0x002000);
    * p = 0x00000040;

    // // configure CLINT
    // write_csr(mstatus, 0x00006008);
    // write_csr(mie, 0xffffffff);

    #ifdef __PMU_LIB_DEBUG__
    printf("pmu_overflow_register_interrupt OUT\n");
    #endif
}

/* **********************************
           MCCU SUBMODULE
* **********************************/

/*
 *   Function    : pmu_mccu_enable
 *   Description : It enables the MCCU submodule.
 *   Parameters  : None.
 *   Return      : None.
 */
void pmu_mccu_enable(void) {
    PMUCFG1 |= 0x00000001;
    #ifdef __PMU_LIB_DEBUG__
    printf("pmu_mccu_enable\n");
    printf("PMUCFG1 = %d\n", PMUCFG1);
    #endif
}

/*
 *   Function    : pmu_mccu_disable
 *   Description : It disable the MCCU submodule.
 *   Parameters  : None.
 *   Return      : None.
 */
void pmu_mccu_disable(void) {
    PMUCFG1 &= 0xFFFFFFFE;
    #ifdef __PMU_LIB_DEBUG__
    printf("pmu_mccu_disable\n");
    printf("PMUCFG1 = %d\n", PMUCFG1);
    #endif
}

/*
 *   Function    : pmu_mccu_reset
 *   Description : It resets the MCCU submodule.
 *   Parameters  : None.
 *   Return      : None.
 */
void pmu_mccu_reset(void) {
    PMUCFG1 |= 0x00000002;
    PMUCFG1 &= 0xFFFFFFFD;
    #ifdef __PMU_LIB_DEBUG__
    printf("pmu_mccu_reset\n");
    printf("PMUCFG1 = %d\n", PMUCFG1);
    #endif
}

/*
 *   Function    : pmu_mccu_set_quota_limit
 *   Description : It sets the quota limits for MCCU submodule
 *   Parameters  : 
 *       - core  :  Target core for quota monitoring. Select core number 1, 2, 3 or 4.
 *       - quota :  32 bits wide quota for selected core.
 *   Return      : Unsigned int. 0 no error.
 */
unsigned pmu_mccu_set_quota_limit(const unsigned int core,
    const unsigned int quota) {
    if(core>MCCU_N_CORES){
        printf("mccu_set_quota: core %d does not exist\n", core);
	return(1);
    }
    //set update bits
    PMUCFG1 |= 1<<(core+2);//Offset are enable en reset bits
    //set target quota
    _PMU_MCCU_QUOTA[core]=quota;
    //release set bits
    PMUCFG1 &= ~(0x3f<<2);//shift 2 bits due to enable and reset mccu
                          // 0xf ->4cores / 0x3f -> 6cores
}

/*
 *   Function    : pmu_mccu_get_quota_remaining
 *   Description : Get the remaining quota for a single core.
 *   Parameters  : 
 *       - core  : Target core for quota monitoring. Select core number 1, 2, 3 or 4.
 *   Return      : The remaining quota for a selected core.
 */
unsigned int pmu_mccu_get_quota_remaining(unsigned int core) {
    char err_msg[] = "ERR on pmu_mccu_get_quota_remaining <core> parameter out of range";
    #ifdef __PMU_LIB_DEBUG__
    printf("pmu_mccu_get_quota_remaining\n");
    #endif
    return (_PMU_MCCU_QUOTA[3 + core]);
}

/*
 *   Function    : pmu_mccu_set_event_weigths
 *   Description : It sets the weigths for a selected input.
 *   Parameters  : 
 *      - input  : A given input from 0 to 7.
 *      - weigth : 8 bits wide for a given input.
 *   
 *   Return      : Unsigned int. 0 no error.
 */
unsigned pmu_mccu_set_event_weigths(const unsigned int input,
    const unsigned int weigth) {
    switch (input) {
    case 0:
    case 1:
    case 2:
    case 3:
        EVENT_WEIGHT_REG0 &= ~(0x000000FF << (input << 3));
        EVENT_WEIGHT_REG0 |= (weigth & 0x000000FF) << (input << 3);
        break;

    case 4:
    case 5:
    case 6:
    case 7:
        EVENT_WEIGHT_REG1 &= ~(0x000000FF << (input << 3));
        EVENT_WEIGHT_REG1 |= (weigth & 0x000000FF) << (input << 3);
        break;

    default:
        printf("mccu_set_event_weigths: input %d does not exist\n", input);
        return (1);
    }

    #ifdef __PMU_LIB_DEBUG__
    printf("pmu_mccu_set_event_weigths\n");
    printf("EVENT_WEIGHT_REG0 = %u\n", EVENT_WEIGHT_REG0);
    printf("EVENT_WEIGHT_REG1 = %u\n", EVENT_WEIGHT_REG1);
    #endif
    return (0);
}

/* **********************************
           RDC SUBMODULE
* **********************************/

/*
 *   Function    : pmu_rdc_enable
 *   Description : It enables the RDC submodule.
 *   Parameters  : None.
 *   Return      : None.
 */
void pmu_rdc_enable(void) {
    PMUCFG1 |= 1<<(2+MCCU_N_CORES);
    #ifdef __PMU_LIB_DEBUG__
    printf("pmu_rdc_enable\n");
    printf("PMUCFG1 = %d\n", PMUCFG1);
    #endif
}

/*
 *   Function    : pmu_rdc_disable
 *   Description : It disables the RDC disable.
 *   Parameters  : None.
 *   Return      : None.
 */
void pmu_rdc_disable(void) {
    PMUCFG1 &= ~(1<<(2+MCCU_N_CORES));
    #ifdef __PMU_LIB_DEBUG__
    printf("pmu_rdc_disable\n");
    printf("PMUCFG1 = %d\n", PMUCFG1);
    #endif
}

/*
 *   Function    : pmu_rdc_reset
 *   Description : It resets the RDC disable.
 *   Parameters  : None.
 *   Return      : None.
 */
void pmu_rdc_reset(void) {
    PMUCFG1 |= 1<<(2+MCCU_N_CORES+1);//2(enable,reset mccu),(ncores) quota updates, 1 (enable RDC)
    PMUCFG1 &= ~(1<<(2+MCCU_N_CORES+1));//2(enable,reset mccu),(ncores) quota updates, 1 (enable RDC)
    #ifdef __PMU_LIB_DEBUG__
    printf("pmu_rdc_reset\n");
    printf("PMUCFG1 = %d\n", PMUCFG1);
    #endif
}

/*
 *   Function    : pmu_rdc_read_watermark
 *   Description : It gets the watermarks for a given input.
 *   Parameters  : 
 *       - input : A given input from 0 to 7.
 *   Return      : It return the watermark for a given input.
 */
unsigned int pmu_rdc_read_watermark(unsigned int input) {
    #ifdef __PMU_LIB_DEBUG__
    printf("pmu_rdc_read_watermark\n");
    printf("PMU_RDC_WATERMARK_REG0 = 0x%08x\n", PMU_RDC_WATERMARK_REG0);
    printf("PMU_RDC_WATERMARK_REG1 = 0x%08x\n", PMU_RDC_WATERMARK_REG1);
    #endif

    char err_msg[] = "ERR on pmu_rdc_read_watermark. <input> parameter out of range";
    
    unsigned int idx, tmp; 
    idx = input/(REG_WIDTH/MCCU_WEIGHTS_WIDTH);
    tmp = (_PMU_RDC_WATERMARKS[idx] & (0x000000FF << (input << 3))) >> (input << 3);
    return (tmp);
}

/*
 *   Function    : pmu_rdc_read_iv
 *   Description : It resets the RDC disable.
 *   Parameters  : None.
 *   Return      : It returns the Interrupt Vector for the RDC.
 */
unsigned int pmu_rdc_read_iv() {
    #ifdef __PMU_LIB_DEBUG__
    printf("pmu_rdc_read_iv\n");
    #endif

    return (PMU_RDC_IV);
}

/*
 *   Function    : pmu_rdc_get_interrupt
 *   Description : Get the interrupt for a given core. It interrupts when the 
 *                 quota get to 0. 
 *   Parameters  : 
 *       - core  : Core to monitor the RDC interrupt.
 *   Return      : 
 *       - 1 : The RDC for the given core has interrupted.
 *       - 0 : The RDC for the given core has not interrupted.
 */
unsigned int pmu_rdc_get_interrupt(unsigned int core) {
    #ifdef __PMU_LIB_DEBUG__
    printf("pmu_rdc_get_interrupt\n");
    printf("PMU_RDC_IV = 0x%04x\n", PMU_RDC_IV);
    #endif

    return ((PMU_RDC_IV & (0x00000001 << core)) != 0);
}

/* 
 *  Legacy Functions
 */
void enable_counters (void){
pmu_counters_enable();
}
void disable_counters (void){
pmu_counters_disable();
}
void reset_counters (void){
pmu_counters_reset();
}
void reset_RDC(void){
pmu_rdc_reset(); 
}

// ** write range of address with same value
void write_register_range (unsigned int entry, unsigned int exit, unsigned int value){
    volatile unsigned int *p;
    unsigned int i;
#ifdef __PMU_LIB_DEBUG__
    printf("\n *** Register write***\n\n");
#endif
    for(i=entry;i<=exit;i=i+1){
        p=(unsigned int*)(PMU_ADDR+(i*4));
        *p=value;
#ifdef __PMU_LIB_DEBUG__
        printf("address:%x \n",(PMU_ADDR+(i*4)));
        printf("value :%x \n",value);
#endif
    }
#ifdef __PMU_LIB_DEBUG__
    printf("\n *** end register write ***\n\n");
#endif
}

void zero_all_pmu_regs(void){
    write_register_range (BASE_CFG,END_PMU,0);
}

void enable_RDC (void){
    pmu_rdc_enable();
}
void disable_RDC (void){
    pmu_rdc_disable();
}

struct report_s report_pmu (void){
    volatile unsigned int *var;
    volatile unsigned int reader;
    struct report_s report;
    unsigned int pmu_addr = PMU_ADDR;

    //Counters
    var=(unsigned int*)(pmu_addr+BASE_COUNTERS*4);
    reader=*var;
#ifdef __UART__
    printf("Counters  *******: %d\n",N_COUNTERS);
    printf("SoC events  *******: %d\n",CROSSBAR_INPUTS);
#endif
#ifdef __UART__
    printf("address:%x ,                 Counter0: %10u\n",var,reader);
#endif
    report.ev0 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter1: %10u\n",var,reader);
#endif
    report.ev1 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter2: %10u\n",var,reader);
#endif
    report.ev2 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter3: %10u\n",var,reader);
#endif
    report.ev3 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter4: %10u\n",var,reader);
#endif
    report.ev4 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter5: %10u\n",var,reader);
#endif
    report.ev5 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter6: %10u\n",var,reader);
#endif
    report.ev6 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter7: %10u\n",var,reader);
#endif
    report.ev7 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter8: %10u\n",var,reader);
#endif
    report.ev8 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter9: %10u\n",var,reader);
#endif
    report.ev9 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter10: %10u\n",var,reader);
#endif
    report.ev10 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter11: %10u\n",var,reader);
#endif
    report.ev11 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter12: %10u\n",var,reader);
#endif
    report.ev12 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter13: %10u\n",var,reader);
#endif
    report.ev13 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter14: %10u\n",var,reader);
#endif
    report.ev14 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter15: %10u\n",var,reader);
#endif
    report.ev15 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter16: %10u\n",var,reader);
#endif
    report.ev16 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter17: %10u\n",var,reader);
#endif
    report.ev17 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter18: %10u\n",var,reader);
#endif
    report.ev18 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter19: %10u\n",var,reader);
#endif
    report.ev19 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter20: %10u\n",var,reader);
#endif
    report.ev20 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter21: %10u\n",var,reader);
#endif
    report.ev21 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter22: %10u\n",var,reader);
#endif
    report.ev22 = reader;
    var=(unsigned int*)(var+4);
    reader=*var;
#ifdef __UART__
    printf("address:%x ,                 Counter23: %10u\n",var,reader);
#endif
    report.ev23 = reader;

    //RDC Watermarks
    var=(unsigned int*)(pmu_addr+BASE_RDC_WATERMARK*4);
    reader=*var;
#ifdef __UART__
    printf("address:%x , watermark_0 : %u\n",var,reader & 0x000000ff);
    printf("address:%x , watermark_1 : %u\n",var+1, (reader & 0x0000ff00) >> 8);
    printf("address:%x , watermark_2 : %u\n",var+2, (reader & 0x00ff0000) >> 16);
    printf("address:%x , watermark_3 : %u\n\n",var+3, (reader & 0xff000000) >> 24);
#endif
    var=(unsigned int*)(pmu_addr+(BASE_RDC_WATERMARK+1)*4);
    reader=*var;
#ifdef __UART__
    printf("address:%x , watermark_4 : %u\n",var,reader & 0x000000ff);
    printf("address:%x , watermark_5 : %u\n",var+1, (reader & 0x0000ff00) >> 8);
    printf("address:%x , watermark_6 : %u\n",var+2, (reader & 0x00ff0000) >> 16);
    printf("address:%x , watermark_7 : %u\n\n",var+3, (reader & 0xff000000) >> 24);
#endif
    return(report);
}

void masked_and_write (unsigned int entry, unsigned int mask){
    volatile unsigned int *p;
    volatile unsigned int current_value;
#ifdef __PMU_LIB_DEBUG__
    printf("\n *** Write AND mask register***\n\n");
#endif
    p=(unsigned int*)(PMU_ADDR+(entry*4));
    //get current value 
    current_value=*p;
    //set reset bit
    *p=current_value & mask;
#ifdef __PMU_LIB_DEBUG__
    printf("address:%x \n",(PMU_ADDR+(entry*4)));
    printf("current value :%x \n",current_value);
    printf("mask:%x \n", mask);
    printf("masked value :%x \n",(current_value & mask));
    printf("\n *** end Write AND mask register ***\n\n");
#endif
}

// ** or mask
void masked_or_write (unsigned int entry, unsigned int mask){
    volatile unsigned int *p;
    volatile unsigned int current_value;
#ifdef __PMU_LIB_DEBUG__
    printf("\n *** Write OR mask register***\n\n");
#endif
    p=(unsigned int*)(PMU_ADDR+(entry*4));
    //get current value 
    current_value=*p;
    //set reset bit
    *p=current_value | mask;
#ifdef __PMU_LIB_DEBUG__
    printf("address:%x \n",(PMU_ADDR+(entry*4)));
    printf("current value :%x \n",current_value);
    printf("mask:%x \n", mask);
    printf("masked value :%x \n",(current_value & mask));
    printf("\n *** end Write OR mask register ***\n\n");
#endif
}

//Select test mode
unsigned int select_test_mode (unsigned int mode){
    volatile unsigned int MASK_MODE;
    volatile unsigned int CLEAR_MODE = 0xf0000000;
    switch (mode)
    {
        case 0:
            //pass through
#ifdef __PMU_LIB_DEBUG__
            printf("No selftests, events are passed through\n");
#endif
            MASK_MODE = 0x000000000;
            break;
        case 1:
            //ALL ones
#ifdef __PMU_LIB_DEBUG__
            printf("Selftests, All events set to 1\n");
#endif
            MASK_MODE = 0x40000000;
            break;
        case 2:
            //ALL zeros
#ifdef __PMU_LIB_DEBUG__
            printf("Selftests, All events set to 0\n");
#endif
            MASK_MODE = 0x80000000;
            break;
        case 3:
            //First singnal 1 all the other 0
#ifdef __PMU_LIB_DEBUG__
            printf("Selftests, First event is 1 all the other are 0\n");
#endif
            MASK_MODE = 0xf0000000;
            break;
        default:
#ifdef __PMU_LIB_DEBUG__
            printf("Invalid mode for selftest\n");
#endif
            MASK_MODE = 0x00000000;
            return 1;
    }
    //clear previous mode
    masked_and_write(BASE_CFG,~CLEAR_MODE);
    masked_or_write(BASE_CFG,MASK_MODE);
    return 0;
}

