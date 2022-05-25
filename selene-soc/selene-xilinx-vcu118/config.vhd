------------------------------------------------------------------------------
--  This file was developed as part of H2020 SELENE project.
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
-----------------------------------------------------------------------------
-- Demonstration design test bench configuration
-----------------------------------------------------------------------------
library techmap;
use techmap.gencomp.all;
package config is
-- Technology and synthesis options
  constant CFG_FABTECH : integer := virtexup;
  constant CFG_MEMTECH : integer := virtexup;
  constant CFG_PADTECH : integer := virtexup;
  constant CFG_TRANSTECH : integer := TT_XGTP0;
  constant CFG_NOASYNC : integer := 0;
  constant CFG_SCAN : integer := 0;
-- Clock generator
  constant CFG_CLKTECH : integer := virtexup;
  constant CFG_BOARDFRQ : integer := 250000;
  constant CFG_CLKMUL : integer := (4);
  constant CFG_CLKDIV : integer := (10);
  constant CFG_OCLKDIV : integer := 1;
  constant CFG_OCLKBDIV : integer := 0;
  constant CFG_OCLKCDIV : integer := 0;
  constant CFG_PCIDLL : integer := 0;
  constant CFG_PCISYSCLK: integer := 0;
  constant CFG_CLK_NOFB : integer := 0;
-- NOELV processor core
  constant CFG_NOELV : integer := 1;
  constant CFG_NCPU : integer := (6);
  constant CFG_CFG : integer := (0);
  constant CFG_NODBUS : integer := 1;
  constant CFG_DISAS : integer := 0;
  constant CFG_RV_M : integer := 1;
  constant CFG_RV_A : integer := (1);
  constant CFG_FPULEN : integer := 64;
  constant CFG_RV_C : integer := 0;
  constant CFG_RV_S : integer := 1;
  constant CFG_RV_U : integer := 1;
  constant CFG_LATE_BRANCH : integer := 1;
  constant CFG_LATE_ALU : integer := 1;
  constant CFG_BHTEN : integer := 1;
  constant CFG_BHTENTRIES : integer := 128;
  constant CFG_BHTBITS : integer := 5;
  constant CFG_BHTPREDICTOR : integer := (1);
  constant CFG_BTBEN : integer := 1;
  constant CFG_BTBENTRIES : integer := 32;
  constant CFG_BTBWAYS : integer := 2;
  constant CFG_RISCV_MMU : integer := 2;   -- 
  constant CFG_PMP_NO_TOR : integer := 0;  -- Disable PMP TOR
  constant CFG_PMP_ENTRIES : integer := 8; -- Implemented PMP registers
  constant CFG_PMP_G : integer := 1;       -- PMP grain is 2^(pmp_g + 2) bytes
  constant CFG_V8 : integer := 0 + 4*0;
  constant CFG_MAC : integer := 0;
  constant CFG_SVT : integer := 1;
  constant CFG_RSTADDR : integer := 16#00010#;
  constant CFG_LDDEL : integer := (1);
  constant CFG_NWP : integer := (0);
  constant CFG_PWD : integer := 1*2;
  constant CFG_FPU : integer := 0 + 16*0 + 32*0;
  constant CFG_GRFPUSH : integer := 0;
  constant CFG_ICEN : integer := 1;
  constant CFG_ISETS : integer := 4;
  constant CFG_ISETSZ : integer := 4;
  constant CFG_ILINE : integer := 8;
  constant CFG_IREPL : integer := 0;
  constant CFG_ILOCK : integer := 0;
  constant CFG_ILRAMEN : integer := 0;
  constant CFG_ILRAMADDR: integer := 16#8E#;
  constant CFG_ILRAMSZ : integer := 1;
  constant CFG_DCEN : integer := 1;
  constant CFG_DSETS : integer := 4;
  constant CFG_DSETSZ : integer := 4;
  constant CFG_DLINE : integer := 8;
  constant CFG_DREPL : integer := 0;
  constant CFG_DLOCK : integer := 0;
  constant CFG_DSNOOP : integer := 1 + 1 + 4*1;
  constant CFG_DFIXED : integer := 16#0#;
  constant CFG_BWMASK : integer := 16#00FF#;
  constant CFG_CACHEBW : integer := 128;
  constant CFG_DLRAMEN : integer := 0;
  constant CFG_DLRAMADDR: integer := 16#8F#;
  constant CFG_DLRAMSZ : integer := 1;
  constant CFG_MMUEN : integer := 1;
  constant CFG_ITLBNUM : integer := 8;
  constant CFG_DTLBNUM : integer := 8;
  constant CFG_TLB_TYPE : integer := 1 + 0*2;
  constant CFG_TLB_REP : integer := 1;
  constant CFG_DSU : integer := 1;
  constant CFG_ITBSZ : integer := 2 + 64*0;
  constant CFG_ATBSZ : integer := 0;
  constant CFG_AHBPF : integer := 0;
  constant CFG_AHBWP : integer := 0;
  constant CFG_LEON4FT_EN : integer := 0 + 0*8;
  constant CFG_IUFT_EN : integer := 0;
  constant CFG_FPUFT_EN : integer := 0;
  constant CFG_RF_ERRINJ : integer := 0;
  constant CFG_CACHE_FT_EN : integer := 0;
  constant CFG_CACHE_ERRINJ : integer := 0;
  constant CFG_LEON4_NETLIST: integer := 0;
  constant CFG_PCHIGH : integer := 32;
  constant CFG_PCLOW : integer := 0;
  constant CFG_STAT_ENABLE : integer := 0;
  constant CFG_STAT_CNT : integer := 1;
  constant CFG_STAT_NMAX : integer := 0;
  constant CFG_STAT_DSUEN : integer := 0;
  constant CFG_NP_ASI : integer := 0;
  constant CFG_WRPSR : integer := 0;
  constant CFG_REX : integer := 0;
  constant CFG_LEON_MEMTECH : integer := (0*2**17 + 0*2**18 + 0*2**16);
-- L2 Cache
  constant CFG_L2_EN : integer := 0;
  constant CFG_L2_SIZE : integer := 256;
  constant CFG_L2_WAYS : integer := 4;
  constant CFG_L2_HPROT : integer := 0;
  constant CFG_L2_PEN : integer := 0;
  constant CFG_L2_WT : integer := 0;
  constant CFG_L2_RAN : integer := 0;
  constant CFG_L2_SHARE : integer := 0;
  constant CFG_L2_LSZ : integer := 32;
  constant CFG_L2_MAP : integer := 16#00FF#;
  constant CFG_L2_MTRR : integer := (0);
  constant CFG_L2_EDAC : integer := 0;
  constant CFG_L2_AXI : integer := 1;
  -- L2 Cache Lite
  constant CFG_L2CL_EN : integer := 1;
  constant CFG_L2CL_SIZE : integer := 128;
  constant CFG_L2CL_WAYS : integer := 4;
  constant CFG_L2CL_REPL : integer := 0;
  constant CFG_L2CL_LSZ : integer := 32;
  constant CFG_L2CL_MAP : integer := 16#00FF#;
-- AMBA settings
  constant CFG_DEFMST : integer := (0);
  constant CFG_RROBIN : integer := 1;
  constant CFG_SPLIT : integer := 1;
  constant CFG_FPNPEN : integer := 1;
  constant CFG_AHBIO : integer := 16#FFF#;
  constant CFG_APBADDR : integer := 16#800#;
  constant CFG_AHB_MON : integer := 0;
  constant CFG_AHB_MONERR : integer := 0;
  constant CFG_AHB_MONWAR : integer := 0;
  constant CFG_AHB_DTRACE : integer := 0;
-- DSU UART
  constant CFG_AHB_UART : integer := 1;
-- JTAG based DSU interface
  constant CFG_AHB_JTAG : integer := 1;
-- USB DSU
  constant CFG_GRUSB_DCL : integer := 0;
  constant CFG_GRUSB_DCL_UIFACE : integer := 1;
  constant CFG_GRUSB_DCL_DW : integer := 8;
-- Ethernet DSU
  constant CFG_DSU_GRETH : integer := 1 + 0 + 0;
  constant CFG_ETH_BUF : integer := 16;
  constant CFG_ETH_IPM : integer := 16#C0A8#;
  constant CFG_ETH_IPL : integer := 16#0033#;
  constant CFG_ETH_ENM : integer := 16#020000#;
  constant CFG_ETH_ENL : integer := 16#000000#;
-- LEON2 memory controller
  constant CFG_MCTRL_LEON2 : integer := 0;
  constant CFG_MCTRL_RAM8BIT : integer := 0;
  constant CFG_MCTRL_RAM16BIT : integer := 0;
  constant CFG_MCTRL_5CS : integer := 0;
  constant CFG_MCTRL_SDEN : integer := 0;
  constant CFG_MCTRL_SEPBUS : integer := 0;
  constant CFG_MCTRL_INVCLK : integer := 0;
  constant CFG_MCTRL_SD64 : integer := 0;
  constant CFG_MCTRL_PAGE : integer := 0 + 0;
-- Xilinx MIG 7-Series
  constant CFG_MIG_7SERIES : integer := 1;
  constant CFG_MIG_7SERIES_MODEL : integer := 0;
-- Spacewire interface
  constant CFG_SPW_EN : integer := 0;
  constant CFG_SPW_NUM : integer := (2);
  constant CFG_SPW_AHBFIFO : integer := 16;
  constant CFG_SPW_RXFIFO : integer := 16;
  constant CFG_SPW_RMAP : integer := 1;
  constant CFG_SPW_RMAPBUF : integer := 2;
  constant CFG_SPW_RMAPCRC : integer := 1;
  constant CFG_SPW_NETLIST : integer := 0;
  constant CFG_SPW_FT : integer := 0;
  constant CFG_SPW_GRSPW : integer := 2;
  constant CFG_SPW_RXUNAL : integer := 0;
  constant CFG_SPW_DMACHAN : integer := (1);
  constant CFG_SPW_PORTS : integer := (1);
  constant CFG_SPW_INPUT : integer := 3;
  constant CFG_SPW_OUTPUT : integer := 0;
  constant CFG_SPW_RTSAME : integer := 1;
  constant CFG_SPW_LB     : integer := 0;
-- GRCANFD
  constant CFG_GRCANFD1   : integer := 0;
  constant CFG_GRCANFD2   : integer := 0;
-- AHB status register
  constant CFG_AHBSTAT : integer := 1;
  constant CFG_AHBSTATN : integer := (1);
-- AHB ROM
  constant CFG_AHBROMEN : integer := 1;
  constant CFG_AHBROPIP : integer := 0;
  constant CFG_AHBRODDR : integer := 16#000#;
  constant CFG_ROMADDR : integer := 16#100#;
  constant CFG_ROMMASK : integer := 16#E00# + 16#100#;
-- AHB RAM
  constant CFG_AHBRAMEN : integer := 1;
  constant CFG_AHBRSZ : integer := 4;
  constant CFG_AHBRADDR : integer := 16#A00#;
  constant CFG_AHBRPIPE : integer := 0;
-- Gaisler Ethernet core
  constant CFG_GRETH : integer := 1;
  constant CFG_GRETH1G : integer := 0;
  constant CFG_ETH_FIFO : integer := 512;
  constant CFG_GRETH_FMC : integer := 0;
-- UART 1
  constant CFG_UART1_ENABLE : integer := 1;
  constant CFG_UART1_FIFO : integer := 32;
-- UART 2
  constant CFG_UART2_ENABLE : integer := 1;
  constant CFG_UART2_FIFO : integer := 32;
-- LEON3 interrupt controller
  constant CFG_IRQ3_ENABLE : integer := 0;
  constant CFG_IRQ3_NSEC : integer := 0;
-- Modular timer
  constant CFG_GPT_ENABLE : integer := 1;
  constant CFG_GPT_NTIM : integer := (2);
  constant CFG_GPT_SW : integer := (8);
  constant CFG_GPT_TW : integer := (32);
  constant CFG_GPT_IRQ : integer := (8);
  constant CFG_GPT_SEPIRQ : integer := 0;
  constant CFG_GPT_WDOGEN : integer := 0;
  constant CFG_GPT_WDOG : integer := 16#0#;
-- GPIO port
  constant CFG_GRGPIO_ENABLE : integer := 1;
  constant CFG_GRGPIO_IMASK : integer := 16#FFFF#;
  constant CFG_GRGPIO_WIDTH : integer := (16);
-- I2C master
  constant CFG_I2C_ENABLE : integer := 0;
-- DMA Controller
  constant CFG_GRDMAC2    : integer := 1;
  -----------------------------------------------------------------------------
  -- IOMMU
  -----------------------------------------------------------------------------
  constant CFG_IOMMU           : integer := 0;
  constant CFG_IOMMU_FCFS      : integer := 0;
  constant CFG_IOMMU_SPLIT     : integer := 0;
  constant CFG_IOMMU_DYNSPLIT  : integer := 0;
  constant CFG_IOMMU_NUMGRP    : integer := 8;
  constant CFG_IOMMU_STAT      : integer := 1;
  constant CFG_IOMMU_APV       : integer := 0;
  constant CFG_IOMMU_APVCEN    : integer := 0;
  constant CFG_IOMMU_APVCLINES : integer := 32;
  constant CFG_IOMMU_APVCTECH  : integer := CFG_MEMTECH;
  constant CFG_IOMMU_APVCGSETA : integer := 0;
  constant CFG_IOMMU_APVCCADDR : integer := 0;
  constant CFG_IOMMU_APVCCMASK : integer := 16#800#;
  constant CFG_IOMMU_APVCPIPE  : integer := 0;
  constant CFG_IOMMU_IOMMU     : integer := 1;
  constant CFG_IOMMU_TLBNUM    : integer := 32;
  constant CFG_IOMMU_TLBTECH   : integer := CFG_MEMTECH;
  constant CFG_IOMMU_TLBGSETA  : integer := 1;
  constant CFG_IOMMU_TLBPIPE   : integer := 0;
  constant CFG_IOMMU_TMASK     : integer := 16#ff#;
  constant CFG_IOMMU_TBWACCSZ  : integer := 128;
  constant CFG_IOMMU_DPAGESZ   : integer := 1;
  constant CFG_IOMMU_FT        : integer := 0;
  constant CFG_IOMMU_MB        : integer := 0;
  constant CFG_IOMMU_NARB      : integer := 0;
-- If read/write combining is disabled, the bridge between the Processor bus
-- and the I/O slave bus will not be able to handle all accesses from the
-- processors(s).
  constant CFG_AHB2AHB_RWCOMB  : integer := 1;  -- Use read and write combining
-- SPI controller
  constant CFG_SPICTRL_ENABLE : integer := 0;
  constant CFG_SPICTRL_NUM : integer := (1);
  constant CFG_SPICTRL_SLVS : integer := (1);
  constant CFG_SPICTRL_FIFO : integer := (1);
  constant CFG_SPICTRL_SLVREG : integer := 0;
  constant CFG_SPICTRL_ODMODE : integer := 0;
  constant CFG_SPICTRL_AM : integer := 0;
  constant CFG_SPICTRL_ASEL : integer := 0;
  constant CFG_SPICTRL_TWEN : integer := 0;
  constant CFG_SPICTRL_MAXWLEN : integer := (0);
  constant CFG_SPICTRL_SYNCRAM : integer := 0;
  constant CFG_SPICTRL_FT : integer := 0;
  constant CFG_SPICTRL_PROT : integer := 0;
-- GRLIB debugging
  constant CFG_DUART : integer := 1;
-- Version and Revision Register
  constant CFG_GRVERSION_ENABLE : integer := 1;
  constant CFG_GRVERSION_VERSION : integer := 16#0003#;
  constant CFG_GRVERSION_REVISION : integer := 16#0000#;
-- ACCELERATORS configuration
  constant CFG_IN_SIMULATION : boolean := false
  --pragma synthesis_off
                                      or true
  --pragma synthesis_on
  ;
  constant CFG_IN_SYNTHESIS : boolean := not CFG_IN_SIMULATION;
  constant CFG_HLSINF_EN : integer := 0;            -- Enable HLSinf accelerator (only for bitstream)
  constant CFG_HLSINF_VERSION : integer := 10;      -- 10:HLSINF_1_0, 11:HLSINF_1_1, 12:HLSINF_1_2, 13:HLSINF_1_3
  
  constant CFG_AXI_N_ACCELERATORS : integer := 6;
  constant CFG_AXI_N_ACCELERATOR_PORTS : integer := CFG_AXI_N_ACCELERATORS + 5; -- CFG_AXI_N_ACCELERATORS + 3(conv_acc have 4 ports)
-- safeSU
  constant CFG_SAFESU_EN : integer := 1; -- Enable safeSU
  constant CFG_SAFESU_FT : integer := 0; -- Fault tolerance
  constant CFG_SAFESU_NEV : integer := 128; -- Crossbar inputs
  constant CFG_SAFESU_NCNT : integer := 24 ; -- Counters
  constant CFG_SAFESU_VERSION : integer := 0; -- 4 bits for version

-- AXI xbar configuration
--The following line "CFG_AXI_N_INITIATORS" must not contain labels, logic operations or comments due to preprocesor scripts
--the current value "5" corresponds to 1(gpp) + CFG_AXI_N_ACCELERATORS + 3(conv_acc have 4 ports)
  constant CFG_AXI_N_INITIATORS : integer := 7;
  constant CFG_AXI_N_TARGETS : integer := 1;
-- AXI LITE xbar configuration
  constant CFG_AXI_LITE_N_INITIATORS : integer := 1;
  constant CFG_AXI_LITE_N_TARGETS : integer := CFG_AXI_N_ACCELERATORS;
-- RootVoter Cells  
  constant CFG_RVC_VERSION     : integer := 2;
  
  constant RVC_0_ENABLE        : integer := 1;
  constant RVC_0_MAX_DATASETS  : integer := 9;
  constant RVC_0_COUNT_MATCHES : integer := 1;
  constant RVC_0_LIST_MATCHES  : integer := 0;
  constant RVC_0_LIST_FAILURES : integer := 1;  

  constant RVC_1_ENABLE        : integer := 1;
  constant RVC_1_MAX_DATASETS  : integer := 9;
  constant RVC_1_COUNT_MATCHES : integer := 1;
  constant RVC_1_LIST_MATCHES  : integer := 0;
  constant RVC_1_LIST_FAILURES : integer := 1;  

  constant RVC_2_ENABLE        : integer := 1;
  constant RVC_2_MAX_DATASETS  : integer := 9;
  constant RVC_2_COUNT_MATCHES : integer := 1;
  constant RVC_2_LIST_MATCHES  : integer := 0;
  constant RVC_2_LIST_FAILURES : integer := 1;  

  constant RVC_3_ENABLE        : integer := 1;
  constant RVC_3_MAX_DATASETS  : integer := 9;
  constant RVC_3_COUNT_MATCHES : integer := 1;
  constant RVC_3_LIST_MATCHES  : integer := 0;
  constant RVC_3_LIST_FAILURES : integer := 1;  
  
  constant FAULT_INJECTOR_ENABLE : integer := 0;
  constant USE_FFI_CLOCK : integer := 0;
  
  
end;
