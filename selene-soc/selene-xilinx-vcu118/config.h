/*
 * Automatically generated C config: don't edit
 */
#define AUTOCONF_INCLUDED
#define CONFIG_HAS_SHARED_GRFPU 1
/*
 * Synthesis      
 */
#undef  CONFIG_SYN_INFERRED
#undef  CONFIG_SYN_AXCEL
#undef  CONFIG_SYN_AXDSP
#undef  CONFIG_SYN_FUSION
#undef  CONFIG_SYN_PROASIC
#undef  CONFIG_SYN_PROASICPLUS
#undef  CONFIG_SYN_PROASIC3
#undef  CONFIG_SYN_PROASIC3E
#undef  CONFIG_SYN_PROASIC3L
#undef  CONFIG_SYN_IGLOO
#undef  CONFIG_SYN_IGLOO2
#undef  CONFIG_SYN_SF2
#undef  CONFIG_SYN_RTG4
#undef  CONFIG_SYN_POLARFIRE
#undef  CONFIG_SYN_UT025CRH
#undef  CONFIG_SYN_UT130HBD
#undef  CONFIG_SYN_UT90NHBD
#undef  CONFIG_SYN_CYCLONEIII
#undef  CONFIG_SYN_STRATIX
#undef  CONFIG_SYN_STRATIXII
#undef  CONFIG_SYN_STRATIXIII
#undef  CONFIG_SYN_STRATIXIV
#undef  CONFIG_SYN_STRATIXV
#undef  CONFIG_SYN_ALTERA
#undef  CONFIG_SYN_ATC18
#undef  CONFIG_SYN_ATC18RHA
#undef  CONFIG_SYN_CUSTOM1
#undef  CONFIG_SYN_DARE
#undef  CONFIG_SYN_CMOS9SF
#undef  CONFIG_SYN_BRAVEMED
#undef  CONFIG_SYN_ECLIPSE
#undef  CONFIG_SYN_RH_LIB18T
#undef  CONFIG_SYN_RHUMC
#undef  CONFIG_SYN_RHS65
#undef  CONFIG_SYN_SAED32
#undef  CONFIG_SYN_SMIC13
#undef  CONFIG_SYN_TM65GPLUS
#undef  CONFIG_SYN_TSMC90
#undef  CONFIG_SYN_UMC
#undef  CONFIG_SYN_ARTIX7
#undef  CONFIG_SYN_KINTEX7
#define CONFIG_SYN_VIRTEXUP 1
#undef  CONFIG_SYN_SPARTAN3
#undef  CONFIG_SYN_SPARTAN3E
#undef  CONFIG_SYN_SPARTAN6
#undef  CONFIG_SYN_VIRTEX2
#undef  CONFIG_SYN_VIRTEX4
#undef  CONFIG_SYN_VIRTEX5
#undef  CONFIG_SYN_VIRTEX6
#undef  CONFIG_SYN_VIRTEX7
#undef  CONFIG_SYN_ZYNQ7000
#undef  CONFIG_SYN_INFER_RAM
#undef  CONFIG_SYN_INFER_PADS
#undef  CONFIG_SYN_NO_ASYNC
#undef  CONFIG_SYN_SCAN
/*
 * Clock generation
 */
#undef  CONFIG_CLK_INFERRED
#undef  CONFIG_CLK_HCLKBUF
#undef  CONFIG_CLK_UT130HBD
#undef  CONFIG_CLK_ALTDLL
#undef  CONFIG_CLK_BRAVEMED
#undef  CONFIG_CLK_PRO3PLL
#undef  CONFIG_CLK_PRO3EPLL
#undef  CONFIG_CLK_PRO3LPLL
#undef  CONFIG_CLK_FUSPLL
#undef  CONFIG_CLK_LIB18T
#undef  CONFIG_CLK_RHUMC
#undef  CONFIG_CLK_DARE
#undef  CONFIG_CLK_SAED32
#undef  CONFIG_CLK_EASIC45
#undef  CONFIG_CLK_RHS65
#define CONFIG_CLK_CLKPLLE2 1
#undef  CONFIG_CLK_CLKDLL
#undef  CONFIG_CLK_DCM
#define CONFIG_CLK_MUL (4)
#define CONFIG_CLK_DIV (10)
#undef  CONFIG_PCI_SYSCLK
/*
 * Processor            
 */
#define CONFIG_NOELV 1
#define CONFIG_PROC_NUM (6)
#undef  CONFIG_NOELV_MIN
#undef  CONFIG_NOELV_GP
#undef  CONFIG_NOELV_HP
#define CONFIG_NOELV_CUSTOM 1
/*
 * Integer unit                                           
 */
#define CONFIG_IU_SVT 1
#define CONFIG_PWD 1
#define CONFIG_IU_RSTADDR 00014
/*
 * Extension Set
 */
#define CONFIG_IU_RV_M 1
#define CONFIG_IU_RV_A 1
#define CONFIG_IU_RV_FPU 1
#undef  CONFIG_IU_RV_F
#define CONFIG_IU_RV_D 1
#undef  CONFIG_IU_RV_Q
#undef  CONFIG_IU_RV_C
#define CONFIG_IU_RV_S 1
#define CONFIG_IU_RV_U 1
#define CONFIG_IU_LATE_BRANCH 1
#define CONFIG_IU_LATE_ALU 1
/*
 * Branch History Table
 */
#undef  CONFIG_BHT_ENABLE
#define CONFIG_BHT_ENTRIES (128)
#define CONFIG_BHT_BITS (5)
/*
 * Branch History Target
 */
/*
 * Floating-point unit
 */
#undef  CONFIG_FPU_ENABLE
/*
 * Cache system
 */
#define CONFIG_CACHE_FIXED 0
#define CONFIG_BWMASK 00FF
#undef  CONFIG_CACHE_64BIT
#define CONFIG_CACHE_128BIT 1
/*
 * Debug Support Unit        
 */
#define CONFIG_DSU_ENABLE 1
#define CONFIG_DSU_ITRACE 1
#undef  CONFIG_DSU_ITRACESZ1
#define CONFIG_DSU_ITRACESZ2 1
#undef  CONFIG_DSU_ITRACESZ4
#undef  CONFIG_DSU_ITRACESZ8
#undef  CONFIG_DSU_ITRACESZ16
#undef  CONFIG_DSU_ITRACE_2P
#undef  CONFIG_DSU_ATRACE
#undef  CONFIG_STAT_ENABLE
/*
 * Fault-tolerance  
 */
#define CONFIG_IUFT_NONE 1
#undef  CONFIG_IUFT_TECHSPEC
#undef  CONFIG_IUFT_TMR
#define CONFIG_CACHE_FT_NONE 1
#undef  CONFIG_CACHE_FT_EN
#undef  CONFIG_CACHE_FT_TECH
#undef  CONFIG_LEON4_NETLIST
/*
 * VHDL debug settings       
 */
#define CONFIG_IU_DISAS 1
#undef  CONFIG_IU_DISAS_NET
#define CONFIG_DEBUG_PC32 1
/*
 * L2 Cache
 */
#define CONFIG_L2_ENABLE 1
#undef  CONFIG_L2_ASSO1
#undef  CONFIG_L2_ASSO2
#undef  CONFIG_L2_ASSO3
#define CONFIG_L2_ASSO4 1
#undef  CONFIG_L2_SZ1
#undef  CONFIG_L2_SZ2
#undef  CONFIG_L2_SZ4
#undef  CONFIG_L2_SZ8
#undef  CONFIG_L2_SZ16
#undef  CONFIG_L2_SZ32
#define CONFIG_L2_SZ64 1
#undef  CONFIG_L2_SZ128
#undef  CONFIG_L2_SZ256
#undef  CONFIG_L2_SZ512
#define CONFIG_L2_LINE32 1
#undef  CONFIG_L2_LINE64
#undef  CONFIG_L2_HPROT
#define CONFIG_L2_PEN 1
#undef  CONFIG_L2_WT
#define CONFIG_L2_RAN 1
#undef  CONFIG_L2_SHARE
#define CONFIG_L2_MAP 00F0
#define CONFIG_L2_MTRR (0)
#define CONFIG_L2_EDAC_NONE 1
#undef  CONFIG_L2_EDAC_YES
#undef  CONFIG_L2_EDAC_TECHSPEC
#undef  CONFIG_L2_AXI
/*
 * AMBA configuration
 */
#define CONFIG_AHB_DEFMST (0)
#define CONFIG_AHB_RROBIN 1
#define CONFIG_AHB_SPLIT 1
#define CONFIG_AHB_FPNPEN 1
#define CONFIG_AHB_IOADDR FFF
#define CONFIG_APB_HADDR 800
#undef  CONFIG_AHB_MON
#undef  CONFIG_AHB_DTRACE
/*
 * Debug Link           
 */
#define CONFIG_DSU_UART 1
#define CONFIG_DSU_JTAG 1
#undef  CONFIG_GRUSB_DCL
/*
 * Peripherals             
 */
/*
 * Memory controller             
 */
/*
 * Leon2 memory controller        
 */
#undef  CONFIG_MCTRL_LEON2
/*
 * MIG 7-Series memory controller   
 */
#define CONFIG_MIG_7SERIES 1
#define CONFIG_MIG_7SERIES_MODEL 1
#undef  CONFIG_AHBSTAT_ENABLE
/*
 * Peripherals             
 */
/*
 * On-chip RAM/ROM                 
 */
#define CONFIG_AHBROM_ENABLE 1
#define CONFIG_AHBROM_START 000
#undef  CONFIG_AHBROM_PIPE
#define CONFIG_AHBRAM_ENABLE 1
#undef  CONFIG_AHBRAM_SZ1
#undef  CONFIG_AHBRAM_SZ2
#define CONFIG_AHBRAM_SZ4 1
#undef  CONFIG_AHBRAM_SZ8
#undef  CONFIG_AHBRAM_SZ16
#undef  CONFIG_AHBRAM_SZ32
#undef  CONFIG_AHBRAM_SZ64
#undef  CONFIG_AHBRAM_SZ128
#undef  CONFIG_AHBRAM_SZ256
#undef  CONFIG_AHBRAM_SZ512
#undef  CONFIG_AHBRAM_SZ1024
#undef  CONFIG_AHBRAM_SZ2048
#undef  CONFIG_AHBRAM_SZ4096
#define CONFIG_AHBRAM_START A00
#undef  CONFIG_AHBRAM_PIPE
/*
 * Ethernet             
 */
#undef  CONFIG_GRETH_ENABLE
/*
 * UARTs, timers and irq control         
 */
#define CONFIG_UART1_ENABLE 1
#undef  CONFIG_UA1_FIFO1
#undef  CONFIG_UA1_FIFO2
#undef  CONFIG_UA1_FIFO4
#undef  CONFIG_UA1_FIFO8
#undef  CONFIG_UA1_FIFO16
#define CONFIG_UA1_FIFO32 1
#undef  CONFIG_IRQ3_ENABLE
#define CONFIG_GPT_ENABLE 1
#define CONFIG_GPT_NTIM (2)
#define CONFIG_GPT_SW (8)
#define CONFIG_GPT_TW (32)
#define CONFIG_GPT_IRQ (8)
#undef  CONFIG_GPT_SEPIRQ
#undef  CONFIG_GPT_WDOGEN
#define CONFIG_GRGPIO_ENABLE 1
#define CONFIG_GRGPIO_WIDTH (8)
#define CONFIG_GRGPIO_IMASK 0000
#define CONFIG_I2C_ENABLE 1
/*
 * SPI
 */
/*
 * SPI controller(s) 
 */
#undef  CONFIG_SPICTRL_ENABLE
/*
 * VHDL Debugging        
 */
#define CONFIG_DEBUG_UART 1
