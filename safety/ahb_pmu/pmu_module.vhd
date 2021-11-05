-----------------------------------------------------------------------------
-- Package:     ahb_pmu
-- File:        pmu_types.vhd
-- Author:      Guillem Cabo, Barcelona Supercomputing Center
-- Description: ahb_pmu types and components
------------------------------------------------------------------------------
 library ieee;
 use ieee.std_logic_1164.all;
 library grlib;
 use grlib.config_types.all;
 use grlib.config.all;
 use grlib.amba.all;
 library gaisler;
 use gaisler.noelv.all;
 use gaisler.noelv.nv_counter_out_vector;
 use gaisler.noelv.nv_counter_out_type;
-- library work;
-- use work.config.all;
-- use work.selene.all;

package pmu_module is
    --TODO I can't get CFG_NCPU from  work.config
    --HACK
    constant PMU_NCPU : integer := 6;
    constant CB_NSIG : integer := 128; -- crossbar input signals

  -- TYPE DEFINITION ---------------------------------------------------------------------------
   
  -- This type is used to calculate the contention of the different cores. The contention can 
  -- be due to a write or a read. r_and_write will include both.
  -- These signals are ccs signals and will be asserted during the contentions.
  type ccs_contention_type is record
    r_and_w : std_logic;
    read    : std_logic;
    write   : std_logic;
  end record;
  type ccs_contention_vector_type is array (integer range <>) of ccs_contention_type;

  -- This type is used to measure the time from a dcmiss, icmiss or the start of a write request
  -- until the end of these transmissions.
  -- These signals are ccs signals and will be asserted from the petition until the end
  -- of the transmission of the data.
  type ccs_latency_type is record
    total  : std_logic;
    dcmiss : std_logic;
    icmiss : std_logic;
    write  : std_logic;
  end record;
  type ccs_latency_vector_type is array (integer range <>) of ccs_latency_type;
  type ccs_latency_state is array (integer range <>) of std_logic_vector(2 downto 0);
  type ccs_latency_cause_state is array (integer range <>) of std_logic_vector(1 downto 0);

  type pmu_intr_out_type is record
    intr_overflow_o : std_ulogic;
    intr_quota_o : std_ulogic; 
    intr_MCCU_o : std_logic_vector(PMU_NCPU-1 downto 0);
    intr_RDC_o : std_ulogic; 
  end record;
   -- interface with GRLIB
  component ahb_wrapper

    generic (
        ncpu        : integer range 1 to 6 := 1;
        hindex : integer := 0;
        nev    : integer := 31;
        haddr  : integer := 0;
        hmask  : integer := 16#fff#);
    port (
        rst            : in  std_ulogic;
        clk            : in  std_ulogic;
        events_vector  : in  std_logic_vector(CB_NSIG-1 downto 0);
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
        MCCU_N_CORES : integer := 4;
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

  component ahb_latency_and_contention
    generic(
        ncpu : integer := 4;
        nout : integer := 32 --number of outputs to crossbar
        );
    port (
        rstn  : in  std_ulogic;
        clk   : in  std_ulogic;
        -- AHB bus signals
        ahbmi         : in ahb_mst_in_type;
        cpus_ahbmo    : in ahb_mst_out_vector_type(ncpu-1 downto 0);
        ahbsi_hmaster : in std_logic_vector(3 downto 0);
        -- PMU events
        pmu_events : in nv_counter_out_vector(ncpu-1 downto 0);
        dcl2_events   : in std_logic_vector(10 downto 0);
        -- PMU input
        pmu_input : out std_logic_vector(nout-1 downto 0)
        );
  end component;

      
        
        


end pmu_module;
