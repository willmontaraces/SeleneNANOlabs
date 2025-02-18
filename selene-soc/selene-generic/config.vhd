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
  constant CFG_CLKMUL : integer := (4);
  constant CFG_CLKDIV : integer := (20);
  constant CFG_OCLKDIV : integer := 1;
  constant CFG_OCLKBDIV : integer := 0;
  constant CFG_OCLKCDIV : integer := 0;
  constant CFG_PCIDLL : integer := 0;
  constant CFG_PCISYSCLK: integer := 0;
  constant CFG_CLK_NOFB : integer := 0;
-- NOELV processor core
  constant CFG_NOELV : integer := 1;
  constant CFG_NCPU : integer := (1);
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
  constant CFG_DISAS : integer := 1 + 0;
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
  constant CFG_L2_EN : integer := 1;
  constant CFG_L2_SIZE : integer := 64;
  constant CFG_L2_WAYS : integer := 4;
  constant CFG_L2_HPROT : integer := 0;
  constant CFG_L2_PEN : integer := 1;
  constant CFG_L2_WT : integer := 0;
  constant CFG_L2_RAN : integer := 1;
  constant CFG_L2_SHARE : integer := 0;
  constant CFG_L2_LSZ : integer := 32;
  constant CFG_L2_MAP : integer := 16#00F0#;
  constant CFG_L2_MTRR : integer := (0);
  constant CFG_L2_EDAC : integer := 0;
  constant CFG_L2_AXI : integer := 0;
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
  constant CFG_DSU_ETH : integer := 0 + 0 + 0;
  constant CFG_ETH_BUF : integer := 1;
  constant CFG_ETH_IPM : integer := 16#C0A8#;
  constant CFG_ETH_IPL : integer := 16#0033#;
  constant CFG_ETH_ENM : integer := 16#020000#;
  constant CFG_ETH_ENL : integer := 16#000009#;
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
  constant CFG_GRETH : integer := 0;
  constant CFG_GRETH1G : integer := 0;
  constant CFG_ETH_FIFO : integer := 8;
  constant CFG_GRETH_FMC : integer := 0;
-- UART 1
  constant CFG_UART1_ENABLE : integer := 1;
  constant CFG_UART1_FIFO : integer := 32;
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
  constant CFG_GRGPIO_IMASK : integer := 16#FFFE#;
  constant CFG_GRGPIO_WIDTH : integer := (20);
-- I2C master
  constant CFG_I2C_ENABLE : integer := 0;
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
end;
