-- Technology and synthesis options
  constant CFG_FABTECH 	: integer := CONFIG_SYN_TECH;
  constant CFG_MEMTECH  : integer := CFG_RAM_TECH;
  constant CFG_PADTECH 	: integer := CFG_PAD_TECH;
  constant CFG_TRANSTECH	: integer := CFG_TRANS_TECH;
  constant CFG_NOASYNC 	: integer := CONFIG_SYN_NO_ASYNC;
  constant CFG_SCAN 	: integer := CONFIG_SYN_SCAN;

-- Clock generator
  constant CFG_CLKTECH 	: integer := CFG_CLK_TECH;
  constant CFG_CLKMUL   : integer := CONFIG_CLK_MUL;
  constant CFG_CLKDIV   : integer := CONFIG_CLK_DIV;
  constant CFG_OCLKDIV  : integer := CONFIG_OCLK_DIV;
  constant CFG_OCLKBDIV : integer := CONFIG_OCLKB_DIV;
  constant CFG_OCLKCDIV : integer := CONFIG_OCLKC_DIV;
  constant CFG_PCIDLL   : integer := CONFIG_PCI_CLKDLL;
  constant CFG_PCISYSCLK: integer := CONFIG_PCI_SYSCLK;
  constant CFG_CLK_NOFB : integer := CONFIG_CLK_NOFB;

-- LEON4 processor core
  constant CFG_NOELV  	        : integer := CONFIG_NOELV;
  constant CFG_NCPU 	        : integer := CONFIG_PROC_NUM;
  constant CFG_RV_M             : integer := CONFIG_IU_RV_M;
  constant CFG_RV_A             : integer := CONFIG_IU_RV_A;
  constant CFG_FPULEN           : integer := CFG_IU_FPULEN;
  constant CFG_RV_C             : integer := CONFIG_IU_RV_C;
  constant CFG_RV_S             : integer := CONFIG_IU_RV_S;
  constant CFG_RV_U             : integer := CONFIG_IU_RV_U;
  constant CFG_LATE_BRANCH      : integer := CONFIG_IU_LATE_BRANCH;
  constant CFG_LATE_ALU         : integer := CONFIG_IU_LATE_ALU;
  constant CFG_BHTEN            : integer := CONFIG_BHT_ENABLE;
  constant CFG_BHTENTRIES       : integer := CONFIG_BHT_ENTRIES;
  constant CFG_BHTBITS          : integer := CONFIG_BHT_BITS;
  constant CFG_BHTPREDICTOR     : integer := CONFIG_BHT_PREDICTOR;
  constant CFG_BTBEN            : integer := CONFIG_BTB_ENABLE;
  constant CFG_BTBENTRIES       : integer := CONFIG_BTB_ENTRIES;
  constant CFG_BTBWAYS          : integer := CONFIG_BTB_WAYS;
  constant CFG_MAC  	        : integer := CONFIG_IU_MUL_MAC;
  constant CFG_SVT  	        : integer := CONFIG_IU_SVT;
  constant CFG_RSTADDR 	        : integer := 16#CONFIG_IU_RSTADDR#;
  constant CFG_LDDEL	        : integer := CONFIG_IU_LDELAY;
  constant CFG_NWP  	        : integer := CONFIG_IU_WATCHPOINTS;
  constant CFG_PWD 	        : integer := CONFIG_PWD*2;
  constant CFG_FPU 	        : integer := CONFIG_FPU + 16*CONFIG_FPU_NETLIST + 32*CONFIG_FPU_GRFPU_SHARED;
  constant CFG_GRFPUSH          : integer := CONFIG_FPU_GRFPU_SHARED;
  constant CFG_ICEN  	        : integer := CONFIG_ICACHE_ENABLE;
  constant CFG_ISETS	        : integer := CFG_IU_ISETS;
  constant CFG_ISETSZ	        : integer := CFG_ICACHE_SZ;
  constant CFG_ILINE 	        : integer := CFG_ILINE_SZ;
  constant CFG_IREPL 	        : integer := CFG_ICACHE_ALGORND;
  constant CFG_ILOCK 	        : integer := CONFIG_ICACHE_LOCK;
  constant CFG_ILRAMEN	        : integer := CONFIG_ICACHE_LRAM;
  constant CFG_ILRAMADDR        : integer := 16#CONFIG_ICACHE_LRSTART#;
  constant CFG_ILRAMSZ	        : integer := CFG_ILRAM_SIZE;
  constant CFG_DCEN  	        : integer := CONFIG_DCACHE_ENABLE;
  constant CFG_DSETS	        : integer := CFG_IU_DSETS;
  constant CFG_DSETSZ	        : integer := CFG_DCACHE_SZ;
  constant CFG_DLINE 	        : integer := CFG_DLINE_SZ;
  constant CFG_DREPL 	        : integer := CFG_DCACHE_ALGORND;
  constant CFG_DLOCK 	        : integer := CONFIG_DCACHE_LOCK;
  constant CFG_DSNOOP	        : integer := CONFIG_DCACHE_SNOOP*2 + 4*CONFIG_DCACHE_SNOOP_SEPTAG;
  constant CFG_DFIXED	        : integer := 16#CONFIG_CACHE_FIXED#;
  constant CFG_BWMASK  	        : integer := 16#CONFIG_BWMASK#;
  constant CFG_CACHEBW 	        : integer := OFG_CBUSW;
  constant CFG_DLRAMEN	        : integer := CONFIG_DCACHE_LRAM;
  constant CFG_DLRAMADDR        : integer := 16#CONFIG_DCACHE_LRSTART#;
  constant CFG_DLRAMSZ	        : integer := CFG_DLRAM_SIZE;
  constant CFG_MMUEN            : integer := CONFIG_MMUEN;
  constant CFG_ITLBNUM          : integer := CONFIG_ITLBNUM;
  constant CFG_DTLBNUM          : integer := CONFIG_DTLBNUM;
  constant CFG_TLB_TYPE         : integer := CONFIG_TLB_TYPE + CFG_MMU_FASTWB*2;
  constant CFG_TLB_REP          : integer := CONFIG_TLB_REP;
  constant CFG_MMU_PAGE         : integer := CONFIG_MMU_PAGE;
  constant CFG_DSU   	        : integer := CONFIG_DSU_ENABLE;
  constant CFG_ITBSZ 	        : integer := CFG_DSU_ITB + 64*CONFIG_DSU_ITRACE_2P;
  constant CFG_ATBSZ 	        : integer := CFG_DSU_ATB;
  constant CFG_AHBPF            : integer := CFG_DSU_AHBPF;
  constant CFG_AHBWP            : integer := CFG_DSU_AHBWP;
  constant CFG_LEON4FT_EN       : integer := CONFIG_IUFT_EN + (CONFIG_CACHE_FT_EN)*8;
  constant CFG_IUFT_EN          : integer := CONFIG_IUFT_EN;
  constant CFG_FPUFT_EN         : integer := CONFIG_FPUFT;
  constant CFG_RF_ERRINJ        : integer := CONFIG_RF_ERRINJ;	
  constant CFG_CACHE_FT_EN      : integer := CONFIG_CACHE_FT_EN;
  constant CFG_CACHE_ERRINJ     : integer := CONFIG_CACHE_ERRINJ;	
  constant CFG_LEON4_NETLIST    : integer := CONFIG_LEON4_NETLIST;	
  constant CFG_DISAS            : integer := CONFIG_IU_DISAS + CONFIG_IU_DISAS_NET;
  constant CFG_PCLOW            : integer := CFG_DEBUG_PC32;
  constant CFG_STAT_ENABLE      : integer := CONFIG_STAT_ENABLE;
  constant CFG_STAT_CNT         : integer := CONFIG_STAT_CNT;
  constant CFG_STAT_NMAX        : integer := CONFIG_STAT_NMAX;
  constant CFG_STAT_DSUEN       : integer := CONFIG_STAT_DSUEN;
  constant CFG_NP_ASI           : integer := CONFIG_NP_ASI;
  constant CFG_WRPSR            : integer := CONFIG_WRPSR;
  constant CFG_REX              : integer := CONFIG_REX;
  constant CFG_LEON_MEMTECH     : integer := (CONFIG_IU_RFINF*2**17 + CONFIG_FPU_RFINF*2**18 + CONFIG_MMU_INF*2**16);

-- L2 Cache
  constant CFG_L2_EN    : integer := CONFIG_L2_ENABLE;
  constant CFG_L2_SIZE	: integer := CFG_L2_SZ;
  constant CFG_L2_WAYS	: integer := CFG_L2_ASSO;
  constant CFG_L2_HPROT	: integer := CONFIG_L2_HPROT;
  constant CFG_L2_PEN  	: integer := CONFIG_L2_PEN;
  constant CFG_L2_WT   	: integer := CONFIG_L2_WT;
  constant CFG_L2_RAN  	: integer := CONFIG_L2_RAN;
  constant CFG_L2_SHARE	: integer := CONFIG_L2_SHARE;
  constant CFG_L2_LSZ  	: integer := CFG_L2_LINE;
  constant CFG_L2_MAP  	: integer := 16#CONFIG_L2_MAP#;
  constant CFG_L2_MTRR 	: integer := CONFIG_L2_MTRR;
  constant CFG_L2_EDAC	: integer := CONFIG_L2_EDAC;
  constant CFG_L2_AXI	  : integer := CONFIG_L2_AXI;

-- AMBA settings
  constant CFG_DEFMST  	  : integer := CONFIG_AHB_DEFMST;
  constant CFG_RROBIN  	  : integer := CONFIG_AHB_RROBIN;
  constant CFG_SPLIT   	  : integer := CONFIG_AHB_SPLIT;
  constant CFG_FPNPEN  	  : integer := CONFIG_AHB_FPNPEN;
  constant CFG_AHBIO   	  : integer := 16#CONFIG_AHB_IOADDR#;
  constant CFG_APBADDR 	  : integer := 16#CONFIG_APB_HADDR#;
  constant CFG_AHB_MON 	  : integer := CONFIG_AHB_MON;
  constant CFG_AHB_MONERR : integer := CONFIG_AHB_MONERR;
  constant CFG_AHB_MONWAR : integer := CONFIG_AHB_MONWAR;
  constant CFG_AHB_DTRACE : integer := CONFIG_AHB_DTRACE;

-- DSU UART
  constant CFG_AHB_UART	: integer := CONFIG_DSU_UART;

-- JTAG based DSU interface
  constant CFG_AHB_JTAG	: integer := CONFIG_DSU_JTAG;

-- USB DSU
  constant CFG_GRUSB_DCL        : integer := CONFIG_GRUSB_DCL;
  constant CFG_GRUSB_DCL_UIFACE : integer := CONFIG_GRUSB_DCL_UIFACE;
  constant CFG_GRUSB_DCL_DW     : integer := CONFIG_GRUSB_DCL_DW;

-- Ethernet DSU
  constant CFG_DSU_ETH	: integer := CONFIG_DSU_ETH + CONFIG_DSU_ETH_PROG + CONFIG_DSU_ETH_DIS;
  constant CFG_ETH_BUF 	: integer := CFG_DSU_ETHB;
  constant CFG_ETH_IPM 	: integer := 16#CONFIG_DSU_IPMSB#;
  constant CFG_ETH_IPL 	: integer := 16#CONFIG_DSU_IPLSB#;
  constant CFG_ETH_ENM 	: integer := 16#CONFIG_DSU_ETHMSB#;
  constant CFG_ETH_ENL 	: integer := 16#CONFIG_DSU_ETHLSB#;

-- LEON2 memory controller
  constant CFG_MCTRL_LEON2    : integer := CONFIG_MCTRL_LEON2;
  constant CFG_MCTRL_RAM8BIT  : integer := CONFIG_MCTRL_8BIT;
  constant CFG_MCTRL_RAM16BIT : integer := CONFIG_MCTRL_16BIT;
  constant CFG_MCTRL_5CS      : integer := CONFIG_MCTRL_5CS;
  constant CFG_MCTRL_SDEN     : integer := CONFIG_MCTRL_SDRAM;
  constant CFG_MCTRL_SEPBUS   : integer := CONFIG_MCTRL_SDRAM_SEPBUS;
  constant CFG_MCTRL_INVCLK   : integer := CONFIG_MCTRL_SDRAM_INVCLK;
  constant CFG_MCTRL_SD64     : integer := CONFIG_MCTRL_SDRAM_BUS64;
  constant CFG_MCTRL_PAGE     : integer := CONFIG_MCTRL_PAGE + CONFIG_MCTRL_PROGPAGE;

-- Xilinx MIG 7-Series
  constant CFG_MIG_7SERIES    : integer := CONFIG_MIG_7SERIES;
  constant CFG_MIG_7SERIES_MODEL    : integer := CONFIG_MIG_7SERIES_MODEL;

-- AHB status register
  constant CFG_AHBSTAT 	: integer := CONFIG_AHBSTAT_ENABLE;
  constant CFG_AHBSTATN	: integer := CONFIG_AHBSTAT_NFTSLV;

-- AHB ROM
  constant CFG_AHBROMEN	: integer := CONFIG_AHBROM_ENABLE;
  constant CFG_AHBROPIP	: integer := CONFIG_AHBROM_PIPE;
  constant CFG_AHBRODDR	: integer := 16#CONFIG_AHBROM_START#;
  constant CFG_ROMADDR	: integer := 16#CONFIG_ROM_START#;
  constant CFG_ROMMASK	: integer := 16#E00# + 16#CONFIG_ROM_START#;

-- AHB RAM
  constant CFG_AHBRAMEN	: integer := CONFIG_AHBRAM_ENABLE;
  constant CFG_AHBRSZ	: integer := CFG_AHBRAMSZ;
  constant CFG_AHBRADDR	: integer := 16#CONFIG_AHBRAM_START#;
  constant CFG_AHBRPIPE : integer := CONFIG_AHBRAM_PIPE;

-- Gaisler Ethernet core
  constant CFG_GRETH   	    : integer := CONFIG_GRETH_ENABLE;
  constant CFG_GRETH1G	    : integer := CONFIG_GRETH_GIGA;
  constant CFG_ETH_FIFO     : integer := CFG_GRETH_FIFO;
  constant CFG_GRETH_FMC    : integer := CONFIG_GRETH_FMC_MODE;
#ifdef CONFIG_GRETH_SGMII_PRESENT
  constant CFG_GRETH_SGMII  : integer := CONFIG_GRETH_SGMII_MODE;
#endif
#ifdef CONFIG_LEON3FT_PRESENT
  constant CFG_GRETH_FT     : integer := CONFIG_GRETH_FT;
  constant CFG_GRETH_EDCLFT : integer := CONFIG_GRETH_EDCLFT;
#endif
-- UART 1
  constant CFG_UART1_ENABLE : integer := CONFIG_UART1_ENABLE;
  constant CFG_UART1_FIFO   : integer := CFG_UA1_FIFO;

-- LEON3 interrupt controller
  constant CFG_IRQ3_ENABLE  : integer := CONFIG_IRQ3_ENABLE;
  constant CFG_IRQ3_NSEC    : integer := CONFIG_IRQ3_NSEC;

-- Modular timer
  constant CFG_GPT_ENABLE   : integer := CONFIG_GPT_ENABLE;
  constant CFG_GPT_NTIM     : integer := CONFIG_GPT_NTIM;
  constant CFG_GPT_SW       : integer := CONFIG_GPT_SW;
  constant CFG_GPT_TW       : integer := CONFIG_GPT_TW;
  constant CFG_GPT_IRQ      : integer := CONFIG_GPT_IRQ;
  constant CFG_GPT_SEPIRQ   : integer := CONFIG_GPT_SEPIRQ;
  constant CFG_GPT_WDOGEN   : integer := CONFIG_GPT_WDOGEN;
  constant CFG_GPT_WDOG     : integer := 16#CONFIG_GPT_WDOG#;

-- GPIO port
  constant CFG_GRGPIO_ENABLE : integer := CONFIG_GRGPIO_ENABLE;
  constant CFG_GRGPIO_IMASK  : integer := 16#CONFIG_GRGPIO_IMASK#;
  constant CFG_GRGPIO_WIDTH  : integer := CONFIG_GRGPIO_WIDTH;

-- I2C master
  constant CFG_I2C_ENABLE : integer := CONFIG_I2C_ENABLE;

-- SPI controller
  constant CFG_SPICTRL_ENABLE  : integer := CONFIG_SPICTRL_ENABLE;
  constant CFG_SPICTRL_NUM     : integer := CONFIG_SPICTRL_NUM;
  constant CFG_SPICTRL_SLVS    : integer := CONFIG_SPICTRL_SLVS;
  constant CFG_SPICTRL_FIFO    : integer := CONFIG_SPICTRL_FIFO;
  constant CFG_SPICTRL_SLVREG  : integer := CONFIG_SPICTRL_SLVREG;
  constant CFG_SPICTRL_ODMODE  : integer := CONFIG_SPICTRL_ODMODE;
  constant CFG_SPICTRL_AM      : integer := CONFIG_SPICTRL_AM;
  constant CFG_SPICTRL_ASEL    : integer := CONFIG_SPICTRL_ASEL;
  constant CFG_SPICTRL_TWEN    : integer := CONFIG_SPICTRL_TWEN;
  constant CFG_SPICTRL_MAXWLEN : integer := CONFIG_SPICTRL_MAXWLEN;
  constant CFG_SPICTRL_SYNCRAM : integer := CONFIG_SPICTRL_SYNCRAM;
  constant CFG_SPICTRL_FT      : integer := CONFIG_SPICTRL_FT;
  constant CFG_SPICTRL_PROT    : integer := CONFIG_SPICTRL_PROT;

-- GRLIB debugging
  constant CFG_DUART    : integer := CONFIG_DEBUG_UART;

