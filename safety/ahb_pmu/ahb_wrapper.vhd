-- -----------------------------------------------
-- Project Name   : De-RISC
-- File           : ahb_wrapper.vhd
-- Organization   : Barcelona Supercomputing Center
-- Author(s)      : Francisco Bas
-- Email(s)       : francisco.basjalon@bsc.es
-- References     :
-- -----------------------------------------------
-- Revision History
--  Revision   | Author        | Commit | Description
--  1.0        | Francisco Bas | 000000 | Contribution
-- -----------------------------------------------

library ieee; 
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.config.all;
use grlib.devices.all;
use grlib.stdlib.all;
library gaisler;
use gaisler.noelv.all;
library gaisler;
use gaisler.noelv.nv_counter_out_vector;
use gaisler.noelv.nv_counter_out_type;
library safety;
use safety.pmu_module.all;


entity ahb_wrapper is
    generic (
        ncpu        : integer range 1 to 16 := 1;
        hindex         : integer := 0;
        haddr          : integer := 0;
        hmask          : integer := 16#fff#);
    port (
        rst         : in  std_ulogic;
        clk         : in  std_ulogic;
        pmu_events  : in  nv_counter_out_vector(ncpu-1 downto 0); --GRLIB like straucture for events
        ccs_contention : in ccs_contention_vector_type((ncpu-1)-1 downto 0);
        ccs_latency : in ccs_latency_vector_type(ncpu-1 downto 0);
        ahbsi       : in  ahb_slv_in_type;   -- slave input
        ahbso       : out ahb_slv_out_type); -- slave output
end;

architecture rtl of ahb_wrapper is
-- Internal signals
signal events_i : std_logic_vector(31 downto 0);  
signal irqvec : std_logic_vector(NAHBIRQ-1 downto 0);  
signal dmiss_hold : std_logic;  
signal pmu_32b_data_o : std_logic_vector(31 downto 0 );


-- PMU
component pmu_ahb
  generic(
    haddr          : integer := 0;
    hmask          : integer := 16#fff#;
    N_REGS	   : integer := 43;
    PMU_COUNTERS   : integer := 24;
    N_SOC_EV       : integer := 32;
    REG_WIDTH      : integer := 32
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
    intr_MCCU_o : out std_logic_vector(3 downto 0);
    intr_RDC_o : out std_ulogic                    
    );
end component;
--filter for chold signal
component filter_chold is
    port(
        clk: in std_logic;
        rstn: in std_logic;
        dmiss: in std_logic;
        chold: in std_logic;
        dmiss_hold: out std_logic);
end component;

constant REVISION : integer := 0;
-- plug&play configuration:
-- VENDOR_BSC and BSC_COUNTER imported from devices.vhd
constant HCONFIG: ahb_config_type := (
	-- TODO: not sure about IRQ and IRQ fields meaning
	0 => ahb_device_reg (VENDOR_CONTRIB,BSC_PMU, 0, REVISION, 1),
	-- no cache, no prefetch
	4 => ahb_membar(haddr, '0', '0', hmask),
	-- only registers
	--5 => ahb_iobar(haddr, hmask),
	others => zero32 );

begin
-- Map signals from  pmu_events to specific events in the pmu. In the future
-- we sould implement a crossbar that can be reconfigured, here or inside the 

--clock and debug signal
events_i(0) <= '1';
events_i(1) <= '0';
-- Core0 full signal set
events_i(2) <= pmu_events(0).icnt(0);
events_i(3) <= pmu_events(0).icnt(1);
events_i(4) <= pmu_events(0).icmiss;
events_i(5) <= pmu_events(0).dcmiss;
events_i(6) <= pmu_events(0).bpmiss;
events_i(7) <= ccs_contention(0).r_and_w;
events_i(8) <= ccs_contention(0).read;
events_i(9) <= ccs_contention(0).write;
events_i(10) <= ccs_latency(0).total;
events_i(11) <= ccs_latency(0).dcmiss;
events_i(12) <= ccs_latency(0).icmiss;
events_i(13) <= ccs_latency(0).write;

-- Core1 reduced signal set
events_i(14) <= pmu_events(1).dcmiss;
events_i(15) <= ccs_contention(1).r_and_w;
events_i(16) <= ccs_contention(1).read;
events_i(17) <= ccs_latency(1).total;
events_i(18) <= ccs_latency(1).dcmiss;
events_i(19) <= ccs_latency(1).write; 
-- Core2 reduced signal set
events_i(20) <= pmu_events(2).dcmiss;
events_i(21) <= ccs_contention(2).r_and_w;
events_i(22) <= ccs_contention(2).read;
events_i(23) <= ccs_latency(2).total;
events_i(24) <= ccs_latency(2).dcmiss;
events_i(25) <= ccs_latency(2).write; 
-- Core3 reduced signal set
events_i(26) <= pmu_events(3).dcmiss;
events_i(27) <= ccs_contention(1).write;
events_i(28) <= ccs_contention(2).write;
events_i(29) <= ccs_latency(3).total;
events_i(30) <= ccs_latency(3).dcmiss;
events_i(31) <= ccs_latency(3).write; 

filter_inst: filter_chold
    port map (
        clk => clk,
        rstn => rst,
        dmiss => pmu_events(0).dcmiss,
        chold => '1',  --TODO: the signal chold is missing, should be added to pmu_events --> pmu_events.chold
        dmiss_hold => dmiss_hold 
    );
--Set unconnected signals to 0
--fill_events_FOR_0: for i in (23) downto 23 generate
--    events_i(i) <= '0';
--end generate fill_events_FOR_0;

-- unused interrupt signals filled with 0
fill_IRQ_FOR_1: for i in (NAHBIRQ-1) downto 13 generate
    irqvec(i) <= '0';
end generate fill_IRQ_FOR_1;
fill_IRQ_FOR_2: for i in 5 downto 0 generate
    irqvec(i) <= '0';
end generate fill_IRQ_FOR_2;

ahbso.hconfig <= hconfig;         -- Plug&play configuration
ahbso.hirq    <= irqvec;          -- Interrupt lines
ahbso.hindex  <= hindex;          -- For test porpuses

-- counter component instantiation
pmu_inst: pmu_ahb
    generic map(    haddr           => haddr,
	            hmask           => hmask,
                    N_REGS          => 47,
                    N_SOC_EV        => 32,
                    PMU_COUNTERS    => 24,
                    REG_WIDTH       => 32
               )
    port map(
        rstn_i  => rst,
        clk_i   => clk,
        -- AHB bus slave interface
        hsel_i      => ahbsi.hsel(hindex),
        haddr_i     => ahbsi.haddr,
        hwrite_i    => ahbsi.hwrite,
        htrans_i    => ahbsi.htrans,
        hsize_i     => ahbsi.hsize,
        hburst_i    => ahbsi.hburst,
        hwdata_i    => ahbsi.hwdata(31 downto 0), --TODO: add bridge (bus 128 bits)
        hprot_i     => ahbsi.hprot,
        hreadyi_i   => ahbsi.hready,
--        hmaster_i   => ahbsi.hmaster,
        hmastlock_i => ahbsi.hmastlock,
        hreadyo_o   => ahbso.hready,
        hresp_o     => ahbso.hresp,
        hrdata_o    => pmu_32b_data_o,
--      ,  hsplit_o    => ahbso.hsplit
        -- PMU signals
        events_i => events_i,
        intr_overflow_o => irqvec(6),
        intr_quota_o => irqvec(12),
        intr_MCCU_o => irqvec(10 downto 7),
        intr_RDC_o => irqvec(11)
    );        
--my slave doesn't support splits
ahbso.hsplit <= (others => '0');

--Replicate response to attach 32b slave to 128b master
--TODO: write logic to attach 32b slave to 128b master
-- https://static.docs.arm.com/ihi0033/bb/IHI0033B_B_amba_5_ahb_protocol_spec.pdf#G9.4951353
-- 6.3.1Implementing a narrow slave on a wide bus
ahbso.hrdata(31 downto 0) <= pmu_32b_data_o;
ahbso.hrdata(63 downto 32) <= pmu_32b_data_o;
ahbso.hrdata(95 downto 64) <= pmu_32b_data_o;
ahbso.hrdata(127 downto 96) <= pmu_32b_data_o;


end;
