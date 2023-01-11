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

package pmu_module is
    --TODO I can't get CFG_NCPU from  work.config
    --HACK
    constant PMU_NCPU : integer := 6;

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

  type axi_contention_type is record
    read    : std_logic;
    write   : std_logic;
  end record;
  type axi_contention_vector_type is array (integer range <>) of axi_contention_type;

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
        ft     : integer := 0;
        ncounters  : integer := 24;
        haddr  : integer := 0;
        hmask  : integer := 16#fff#);
    port (
        rst            : in  std_ulogic;
        clk            : in  std_ulogic;
        events_vector  : in  std_logic_vector(nev-1 downto 0);
        ahbsi          : in  ahb_slv_in_type;
        ahbso          : out ahb_slv_out_type;
        --Hardware quota exhausted signals, all zeroes if hardware quota is disabled
        HQ_MCCU        : out std_logic_vector(ncpu-1 downto 0) := (others => '0') 
      );
  end component;
  -- Interface of pmu_ahb.sv 
  component pmu_ahb
    generic(
      haddr          : integer := 0;
      hmask          : integer := 16#fff#;
      N_SOC_EV       : integer := 31;
      MCCU_N_CORES   : integer := PMU_NCPU;
      REG_WIDTH      : integer := 32;
      --Updated parameters
      N_COUNTERS  : integer := 24;
      MCCU_WEIGHTS_WIDTH : integer := 8;
      N_CONF_REGS : integer :=1;
      MCCU_N_EVENTS : integer := 2;  
      FT  : integer := 0   
    );
    port(
      clk_i  : in std_logic;
      rstn_i : in std_logic;
      -- AHB bus slave interface
      hsel_i       : in  std_ulogic;                               -- slave select
      haddr_i      : in  std_logic_vector(31 downto 0);            -- address bus (byte)
      hwrite_i     : in  std_ulogic;                               -- read/write
      htrans_i     : in  std_logic_vector(1 downto 0);             -- transfer type
      hsize_i      : in  std_logic_vector(2 downto 0);             -- transfer size
      hburst_i     : in  std_logic_vector(2 downto 0);             -- burst type
      hwdata_i     : in  std_logic_vector(31 downto 0);   -- write data bus
      hprot_i      : in  std_logic_vector(3 downto 0);             -- prtection control
      hreadyi_i    : in  std_ulogic;                               -- transfer done
  --    hmaster_i    : in  std_logic_vector(3 downto 0);             -- current master
      hmastlock_i  : in  std_ulogic;                               -- locked access
      hreadyo_o    : out std_ulogic;                               -- trasfer done
      hresp_o      : out std_logic_vector(1 downto 0);             -- response type
      hrdata_o     : out std_logic_vector(31 downto 0);   -- read data bus
  --  ;  hsplit_o     : out std_logic_vector(15 downto 0)             -- split completion
      -- PMU signals
      events_i    : in std_logic_vector(N_SOC_EV-1 downto 0); 
      intr_overflow_o : out std_ulogic;
      intr_quota_o : out std_ulogic; 
      intr_MCCU_o : out std_logic_vector(MCCU_N_CORES-1 downto 0);
      intr_RDC_o : out std_ulogic;
      en_hwquota_o : out std_logic
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
        nout : integer := 32; --number of outputs to crossbar
        naxi_deep : integer := 16; -- Width of dniff cores vector
        naxi_ccs : integer := 4 -- number of masters for axi ccs signals 
        );
    port (
        rstn  : in  std_ulogic;
        clk   : in  std_ulogic;
        -- AHB bus signals
        ahbmi         : in ahb_mst_in_type;
        ahbso         : in ahb_slv_out_vector;
        ahbsi         : in ahb_slv_in_type;
        cpus_ahbmo    : in ahb_mst_out_vector_type(ncpu-1 downto 0);
        ahbsi_hmaster : in std_logic_vector(3 downto 0);
        -- mem_sniff signals
        mem_sniff_coreID_read_pending_o : in std_ulogic_vector(naxi_deep - 1 downto 0);
        mem_sniff_coreID_read_serving_o : in std_ulogic_vector(naxi_deep - 1 downto 0);
        mem_sniff_coreID_write_pending_o : in std_ulogic_vector(naxi_deep - 1 downto 0);
        mem_sniff_coreID_write_serving_o : in std_ulogic_vector(naxi_deep - 1 downto 0);
        -- PMU events
        pmu_events : in nv_counter_out_vector(ncpu-1 downto 0);
        dcl2_events   : in std_logic_vector(10 downto 0);
        -- PMU input
        pmu_input : out std_logic_vector(nout-1 downto 0)
        );
  end component;

  component cpu_vector is
    generic (
          VECTOR_LENGTH : integer := 6
      );
    Port ( 
     clk        : in std_logic;
     rstn       : in std_logic;
     push_in    : in std_logic; -- when 1 pushes CPU_IN into vector
     cpu_in     : in std_logic_vector(VECTOR_LENGTH-1 downto 0); -- ONE HOT encoded vector of CPU to push inside queue
     pop_in      : in std_logic; -- when 1 pops pop_vector_in of vector
     pop_vector_in    : in std_logic_vector(VECTOR_LENGTH-1 downto 0); -- ONE HOT encoded vector of CPU to pop of queue
     cpu_vector_o : out std_logic_vector(VECTOR_LENGTH-1 downto 0)
    );
  end component;      
   
  component module_fifo is
    generic (
    g_WIDTH : natural := 6;
    g_DEPTH : integer := 6
    );
  port (
    rst      : in std_logic;
    clk      : in std_logic;

    -- FIFO Write Interface
    wr_en    : in  std_logic;
    wr_data  : in  std_logic_vector(g_WIDTH-1 downto 0);
    full     : out std_logic;

    -- FIFO Read Interface
    rd_en    : in  std_logic;
    rd_data  : out std_logic_vector(g_WIDTH-1 downto 0);
    empty    : out std_logic
    );
  end component ;

end pmu_module;
