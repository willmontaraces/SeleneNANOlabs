#include <pmu_test.h>
#define __UART__
#ifdef __UART__ 
    //Do not use __PMU_LIB_DEBUG__ while benchmarking, printf will be included in the measure.
    //#define __PMU_LIB_DEBUG__
#endif

// ** and mask
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

// ** softreset counters 
void reset_counters (void){
    volatile unsigned int RESET_COUNTERS = 0b0010;   
    masked_or_write(BASE_CFG,RESET_COUNTERS);
    masked_and_write(BASE_CFG,~RESET_COUNTERS);
#ifdef __PMU_LIB_DEBUG__
    printf("Softreset counters\n");
#endif
}

// ** enable counters 
void enable_counters (void){
    volatile unsigned int ENABLE_COUNTERS = 0b0001;   

#ifdef __PMU_LIB_DEBUG__
    printf("Enable counters\n");
#endif
    masked_or_write(BASE_CFG,ENABLE_COUNTERS);
}

// ** disable counters 
void disable_counters (void){
    volatile unsigned int ENABLE_COUNTERS = 0b0001;   
    masked_and_write(BASE_CFG,~ENABLE_COUNTERS);
#ifdef __PMU_LIB_DEBUG__
    printf("Disable counters\n");
#endif
}

// ** softreset overflow 
void reset_overflow (void){
    volatile unsigned int RESET_OVERFLOW = 0b1000;   
    masked_or_write(BASE_CFG,RESET_OVERFLOW);
    masked_and_write(BASE_CFG,~RESET_OVERFLOW);
#ifdef __PMU_LIB_DEBUG__
    printf("Softreset PMU\n");
#endif
}

// ** enable overflow 
void enable_overflow (void){
    volatile unsigned int ENABLE_OVERFLOW = 0b0100;   
    masked_or_write(BASE_CFG,ENABLE_OVERFLOW);
#ifdef __PMU_LIB_DEBUG__
    printf("Enable PMU\n");
#endif
}

// ** disable overflow 
void disable_overflow (void){
    volatile unsigned int ENABLE_OVERFLOW = 0b0100;   
    masked_and_write(BASE_CFG,~ENABLE_OVERFLOW);
#ifdef __PMU_LIB_DEBUG__
    printf("Disable PMU\n");
#endif
}

// ** write one register register_id, value
void write_register (unsigned int entry, unsigned int value){
    volatile unsigned int *p;
    unsigned int i;
#ifdef __PMU_LIB_DEBUG__
    printf("\n *** Register write***\n\n");
#endif
    p=(unsigned int*)(PMU_ADDR+(entry*4));
    *p=value;
#ifdef __PMU_LIB_DEBUG__
    printf("address:%x \n",(PMU_ADDR+(entry)));
    printf("value :%x \n",value);
#endif
#ifdef __PMU_LIB_DEBUG__
    printf("\n *** end register write ***\n\n");
#endif
}

// ** read one register register_id, value 32b
unsigned int read_register(unsigned int entry){
    volatile unsigned int *var;
    volatile unsigned int reader;
    unsigned int i=entry;
    var=(unsigned int*)(PMU_ADDR+(i*4));
    reader=*var;
#ifdef __UART__
    printf("\n *** Register read***\n\n");
    printf("address:%x \n",(PMU_ADDR+(i*4)));
    printf("value :%x \n",reader);
    printf("\n *** end register read ***\n\n");
#endif
    return reader;
}

// ** write in main cfg register (counters, overflow and quota)
void write_main_cfg ( unsigned int value){
    write_register(BASE_CFG,value);
}

// ** write in main MCCU cfg register (MCCU RDC)
void write_MCCU_cfg ( unsigned int value){
    write_register(BASE_MCCU_CFG,value);
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

// ** Read range of registers. Includes first and an last values
void read_register_range (unsigned int entry, unsigned int exit){
    volatile unsigned int *var;
    volatile unsigned int reader;
    unsigned int i;
#ifdef __UART__
    printf("\n *** Register read***\n\n");
#endif
    for(i=entry;i<=exit;i=i+1){
        var=(unsigned int*)(PMU_ADDR+(i*4));
        reader=*var;
#ifdef __UART__
        printf("address:%x \n",(PMU_ADDR+(i*4)));
        printf("value :%x \n",reader);
#endif
    }
#ifdef __UART__
    printf("\n *** end register read ***\n\n");
#endif
}

// ** softreset overflow 
void reset_quota (void){
    volatile unsigned int RESET_QUOTA = 0b10000;   
    masked_or_write(BASE_CFG,RESET_QUOTA);
    masked_and_write(BASE_CFG,~RESET_QUOTA);
#ifdef __PMU_LIB_DEBUG__
    printf("Softreset Quota\n");
#endif
}

// ** softreset MCCU
void reset_MCCU (void){
    volatile unsigned int RESET_MCCU = 0b0010;   
    masked_or_write(BASE_MCCU_CFG,RESET_MCCU);
    masked_and_write(BASE_MCCU_CFG,~RESET_MCCU);
#ifdef __PMU_LIB_DEBUG__
    printf("Softreset MCCU\n");
#endif
}

// ** enable MCCU 
void enable_MCCU (void){
    volatile unsigned int ENABLE_MCCU = 0b0001;   
#ifdef __PMU_LIB_DEBUG__
    printf("Enable MCCU\n");
#endif
    masked_or_write(BASE_MCCU_CFG,ENABLE_MCCU);
}

// ** disable MCCU 
void disable_MCCU (void){
    volatile unsigned int ENABLE_MCCU = 0b0001;   
    masked_and_write(BASE_MCCU_CFG,~ENABLE_MCCU);
#ifdef __PMU_LIB_DEBUG__
    printf("Disable MCCU\n");
#endif
}

// ** softreset RDC
void reset_RDC (void){
    volatile unsigned int RESET_RDC = 0b10000000;   
    masked_or_write(BASE_MCCU_CFG,RESET_RDC);
    masked_and_write(BASE_MCCU_CFG,~RESET_RDC);
#ifdef __PMU_LIB_DEBUG__
    printf("Softreset RDC\n");
#endif
}

// ** enable RDC 
void enable_RDC (void){
    volatile unsigned int ENABLE_RDC = 0b01000000;   
#ifdef __PMU_LIB_DEBUG__
    printf("Enable RDC\n");
#endif
    masked_or_write(BASE_MCCU_CFG,ENABLE_RDC);
}

// ** disable RDC 
void disable_RDC (void){
    volatile unsigned int ENABLE_RDC = 0b01000000;   
    masked_and_write(BASE_MCCU_CFG,~ENABLE_RDC);
#ifdef __PMU_LIB_DEBUG__
    printf("Disable RDC\n");
#endif
}

void read_all_pmu_regs(void){
    read_register_range (BASE_CFG,END_PMU);
}

void zero_all_pmu_regs(void){
    write_register_range (BASE_CFG,END_PMU,0);
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

/********************/
/**** Crossbar *****/
/*******************/

void configure_crossbar(unsigned int output, unsigned int event_index)
{
    unsigned int ev_idx = (event_index & 0x0000001F); // Only 32 posible values

#ifdef __PMU_LIB_DEBUG__
    printf("CROSSBAR_REG0 addr = %p\n", &CROSSBAR_REG0);
    printf("CROSSBAR_REG1 addr = %p\n", &CROSSBAR_REG1);
    printf("CROSSBAR_REG2 addr = %p\n", &CROSSBAR_REG2);
    printf("CROSSBAR_REG3 addr = %p\n", &CROSSBAR_REG0);
#endif

    switch(output)
    {
        case 0:
            CROSSBAR_REG0 &= ( ~(0x0000001F << 0));     // Erease the output field
            CROSSBAR_REG0 |= ev_idx;                    // Write into the output field
            break;
        case 1:
            CROSSBAR_REG0 &= ( ~(0x0000001F << 5));     // Erease the output field
            CROSSBAR_REG0 |= ev_idx << 5;               // Write into the output field
            break;
        case 2:
            CROSSBAR_REG0 &= ( ~(0x0000001F << 10));    // Erease the output field
            CROSSBAR_REG0 |= ev_idx << 10;              // Write into the output field
            break;
        case 3:
            CROSSBAR_REG0 &= ( ~(0x0000001F << 15));   // Erease the output field   
            CROSSBAR_REG0 |= ev_idx << 15;             // Write into the output field
            break;
        case 4:
            CROSSBAR_REG0 &= ( ~(0x0000001F << 20));   // Erease the output field
            CROSSBAR_REG0 |= ev_idx << 20;             // Write into the output field
            break;
        case 5:
            CROSSBAR_REG0 &= ( ~(0x0000001F << 25));   // Erease the output field
            CROSSBAR_REG0 |= ev_idx << 25;             // Write into the output field
            break;
        case 6:
            CROSSBAR_REG0 &= ( ~(0x00000003 << 30));            // Erease the output field
            CROSSBAR_REG1 &= ( (~(0x00000007)));                // Erease the output field
            CROSSBAR_REG0 |= ( (ev_idx & 0x00000003) << 30);    // Write into the output field
            CROSSBAR_REG1 |= ( (ev_idx & 0x0000001C) >> 2);     // Write into the output field
            break;
        case 7:
            CROSSBAR_REG1 &= ( ~(0x0000001F << 3));    // Erease the output field
            CROSSBAR_REG1 |= ev_idx << 3;              // Write into the output field
            break;
        case 8:
            CROSSBAR_REG1 &= ( ~(0x0000001F << 8));    // Erease the output field
            CROSSBAR_REG1 |= ev_idx << 8;              // Write into the output field
            break;
        case 9:
            CROSSBAR_REG1 &= ( ~(0x0000001F << 13));   // Erease the output field
            CROSSBAR_REG1 |= ev_idx << 13;             // Write into the output field
            break;
        case 10:
            CROSSBAR_REG1 &= ( ~(0x0000001F << 18));   // Erease the output field
            CROSSBAR_REG1 |= ev_idx << 18;             // Write into the output field
            break;
        case 11:
            CROSSBAR_REG1 &= ( ~(0x0000001F << 23));   // Erease the output field
            CROSSBAR_REG1 |= ev_idx << 23;             // Write into the output field
            break;
        case 12:
            CROSSBAR_REG1 &= ( ~(0x0000000F << 28));            // Erease the output field
            CROSSBAR_REG2 &= ( (~(0x00000001)));                // Erease the output field
            CROSSBAR_REG1 |= ( (ev_idx & 0x0000000F) << 28);    // Write into the output field
            CROSSBAR_REG2 |= ( (ev_idx & 0x00000010) >> 4);     // Write into the output field
            break;
        case 13:
            CROSSBAR_REG2 &= ( ~(0x0000001F << 1));    // Erease the output field
            CROSSBAR_REG2 |= ev_idx << 1;              // Write into the output field
            break;
        case 14:
            CROSSBAR_REG2 &= ( ~(0x0000001F << 6));    // Erease the output field
            CROSSBAR_REG2 |= ev_idx << 6;              // Write into the output field
            break;
        case 15:
            CROSSBAR_REG2 &= ( ~(0x0000001F << 11));   // Erease the output field
            CROSSBAR_REG2 |= ev_idx << 11;             // Write into the output field
            break;
        case 16:
            CROSSBAR_REG2 &= ( ~(0x0000001F << 16));   // Erease the output field
            CROSSBAR_REG2 |= ev_idx << 16;             // Write into the output field
            break;
        case 17:
            CROSSBAR_REG2 &= ( ~(0x0000001F << 21));   // Erease the output field
            CROSSBAR_REG2 |= ev_idx << 21;             // Write into the output field
            break;
        case 18:
            CROSSBAR_REG2 &= ( ~(0x0000001F << 26));   // Erease the output field
            CROSSBAR_REG2 |= ev_idx << 26;             // Write into the output field
            break;
        case 19:
            CROSSBAR_REG2 &= ( ~(0x00000001 << 31));            // Erease the output field
            CROSSBAR_REG3 &= ( (~(0x0000000F)) );               // Erease the output field
            CROSSBAR_REG2 |= ( (ev_idx & 0x00000001) << 31);    // Write into the output field
            CROSSBAR_REG3 |= ( (ev_idx & 0x0000001E) >> 1);     // Write into the output field
            break;
        case 20:
            CROSSBAR_REG3 &= ( ~(0x0000001F << 4));    // Erease the output field
            CROSSBAR_REG3 |= ev_idx << 4;              // Write into the output field
            break;
        case 21:
            CROSSBAR_REG3 &= ( ~(0x0000001F << 9));    // Erease the output field
            CROSSBAR_REG3 |= ev_idx << 9;              // Write into the output field
            break;
        case 22:
            CROSSBAR_REG3 &= ( ~(0x0000001F << 14));   // Erease the output field
            CROSSBAR_REG3 |= ev_idx << 14;             // Write into the output field
            break;        
        case 23:
            CROSSBAR_REG3 &= ( ~(0x0000001F << 19));   // Erease the output field
            CROSSBAR_REG3 |= ev_idx << 19;             // Write into the output field
            break;
        case 24:
            CROSSBAR_REG3 &= ( ~(0x0000001F << 24));    // Erease the output field
            CROSSBAR_REG3 |= ev_idx << 24;              // Write into the output field
            break;
        default:
            #ifdef __PMU_LIB_DEBUG__
                printf("The output register selected do not exists!\n");
            #endif
            break;
    }
}

void read_crossbar_registers()
{
    // unsigned int *crossbar_reg;
    // crossbar_reg = (unsigned int *)(PMU_ADDR + 0xAC);
    printf("CROSSBAR_REG0 = 0x%08x\n", CROSSBAR_REG0);
    printf("CROSSBAR_REG1 = 0x%08x\n", CROSSBAR_REG1);
    printf("CROSSBAR_REG2 = 0x%08x\n", CROSSBAR_REG2);
    printf("CROSSBAR_REG3 = 0x%08x\n", CROSSBAR_REG3);
}

void register_events(const crossbar_event_t *ev_table)
{
    for (int i = 0; i < N_COUNTERS; ++i)
    {
        #ifdef __PMU_LIB_DEBUG__
            printf("EventTable[%d].output = %d\n", i, ev_table[i].output);
            printf("EventTable[%d].event  = %d\n", i, ev_table[i].event);
        #endif
        configure_crossbar(ev_table[i].output, ev_table[i].event);
    }
}
