-----------------------------------------------------------------------------
-- Package:     ahb_pmu
-- File:        pmu_types.vhd
-- Author:      Guillem Cabo, Barcelona Supercomputing Center
-- Description: ahb_pmu types and components
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.config.all;
use grlib.amba.all;
library gaisler;
use gaisler.noelv.all;
library gaisler;
use gaisler.noelv.nv_counter_out_vector;
use gaisler.noelv.nv_counter_out_type;


package pmu_module is

  type ccs_contention_type is record
    r_and_w : std_logic;
    read    : std_logic;
    write   : std_logic;
  end record;

  type ccs_contention_vector_type is array (integer range <>) of ccs_contention_type; 
  
  type ccs_latency_type is record
    total  : std_logic;
    dcmiss : std_logic;
    icmiss : std_logic;
    write  : std_logic;
  end record;

  type ccs_latency_vector_type is array (integer range <>) of ccs_latency_type; 

  type pmu_intr_out_type is record
    intr_overflow_o : std_ulogic;
    intr_quota_o : std_ulogic; 
    intr_MCCU_o : std_logic_vector(3 downto 0);
    intr_RDC_o : std_ulogic; 
  end record;
   -- interface with GRLIB
  component ahb_wrapper

    generic (
        ncpu        : integer range 1 to 16 := 1;
        hindex : integer := 0;
        haddr  : integer := 0;
        hmask  : integer := 16#fff#);
    port (
        rst            : in  std_ulogic;
        clk            : in  std_ulogic;
        pmu_events     : in nv_counter_out_vector(ncpu-1 downto 0); --GRLIB like straucture for events
        ccs_contention : in ccs_contention_vector_type((ncpu-1)-1 downto 0); --we only measure contention over core 0 at the moment and we have a total of 4 cores. 
        ccs_latency    : in ccs_latency_vector_type(ncpu-1 downto 0);
        ahbsi          : in  ahb_slv_in_type;
        ahbso          : out ahb_slv_out_type);
  end component;
  -- Interface of pmu_ahb.sv 
  component pmu_ahb  
    generic (
        haddr  : integer := 0;
        hmask  : integer := 16#fff#;
        N_REGS : integer := 43 ; 
    	PMU_COUNTERS   : integer := 24;
    	N_SOC_EV       : integer := 32;
        REG_WIDTH : integer := CFG_AHBDW
        );
    port (
        rstn_i   : in  std_ulogic;
        clk_i   : in  std_ulogic;
        -- AHB bus slave interface
        hsel_i       : in  std_ulogic;                               -- slave select
        haddr_i      : in  std_logic_vector(31 downto 0);            -- address bus 
        hwrite_i     : in  std_ulogic;                               -- read/write 
        htrans_i     : in  std_logic_vector(1 downto 0);             -- transfer type
        hsize_i      : in  std_logic_vector(2 downto 0);             -- transfer size
        hburst_i     : in  std_logic_vector(2 downto 0);             -- burst type
        hwdata_i     : in  std_logic_vector(CFG_AHBDW-1 downto 0);   -- write data bus
        hprot_i      : in  std_logic_vector(3 downto 0);             -- prtection control
        hreadyi_i    : in  std_ulogic;                               -- transfer done 
--        hmaster_i    : in  std_logic_vector(3 downto 0);             -- current master
        hmastlock_i  : in  std_ulogic;                               -- locked access 
        hreadyo_o    : out std_ulogic;                               -- trasfer done 
        hresp_o      : out std_logic_vector(1 downto 0);             -- response type
        hrdata_o     : out std_logic_vector(CFG_AHBDW-1 downto 0);   -- read data bus
--      ;  hsplit_o     : out std_logic_vector(15 downto 0)          -- split completion
        -- PMU signals
        events_i    : in std_logic_vector(N_SOC_EV-1 downto 0); 
        intr_overflow_o : out std_ulogic;
        intr_quota_o : out std_ulogic; 
        intr_MCCU_o : out std_logic_vector(3 downto 0);
        intr_RDC_o : out std_ulogic 
        );
  end component;
  -- Interface of dummy_ahb.sv 
  component dummy_ahb  
    generic (
        haddr  : integer := 0;
        hmask  : integer := 16#fff#;
        N_REGS : integer := 10 ; 
        REG_WIDTH : integer := CFG_AHBDW
        );
    port (
        rstn_i   : in  std_ulogic;
        clk_i   : in  std_ulogic;
        -- AHB bus slave interface
        hsel_i       : in  std_ulogic;                               -- slave select
        haddr_i      : in  std_logic_vector(31 downto 0);            -- address bus 
        hwrite_i     : in  std_ulogic;                               -- read/write 
        htrans_i     : in  std_logic_vector(1 downto 0);             -- transfer type
        hsize_i      : in  std_logic_vector(2 downto 0);             -- transfer size
        hburst_i     : in  std_logic_vector(2 downto 0);             -- burst type
        hwdata_i     : in  std_logic_vector(CFG_AHBDW-1 downto 0);   -- write data bus
        hprot_i      : in  std_logic_vector(3 downto 0);             -- prtection control
        hreadyi_i    : in  std_ulogic;                               -- transfer done 
--        hmaster_i    : in  std_logic_vector(3 downto 0);             -- current master
        hmastlock_i  : in  std_ulogic;                               -- locked access 
        hreadyo_o    : out std_ulogic;                               -- trasfer done 
        hresp_o      : out std_logic_vector(1 downto 0);             -- response type
        hrdata_o     : out std_logic_vector(CFG_AHBDW-1 downto 0)   -- read data bus
--;        hsplit_o     : out std_logic_vector(15 downto 0)             -- split completion
        );
  end component;

end pmu_module;
