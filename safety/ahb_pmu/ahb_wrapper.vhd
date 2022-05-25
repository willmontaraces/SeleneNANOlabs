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
        ncpu           : integer range 1 to 16 := 1;
        hindex         : integer := 0;
        nev            : integer := 32;
        ft             : integer := 0;
        ncounters      : integer := 24;
        haddr          : integer := 0;
        hmask          : integer := 16#fff#);
    port (
        rst           : in  std_ulogic;
        clk           : in  std_ulogic;
        events_vector : in  std_logic_vector(nev-1 downto 0);
        ahbsi         : in  ahb_slv_in_type;   -- slave input
        ahbso         : out ahb_slv_out_type;
        hq_mccu       : out std_logic_vector(ncpu-1 downto 0) := (others => '0') 
    ); -- slave output
end;

architecture rtl of ahb_wrapper is
-- Internal signals
signal events_i : std_logic_vector(nev-1 downto 0);  
signal irqvec : std_logic_vector(NAHBIRQ-1 downto 0);  
signal dmiss_hold : std_logic;  
signal pmu_32b_data_o : std_logic_vector(31 downto 0 );
signal intr_MCCU : std_logic_vector(ncpu-1 downto 0);
signal hardware_quota_active : std_logic;

constant REVISION : integer := 0;
-- plug&play configuration:
-- VENDOR_CONTRIB and BSC_COUNTER imported from devices.vhd
constant HCONFIG: ahb_config_type := (
	-- TODO: not sure about IRQ and IRQ fields
	0 => ahb_device_reg (VENDOR_CONTRIB,BSC_PMU, 0, REVISION, 1),
	-- no cache, no prefetch
	4 => ahb_membar(haddr, '0', '0', hmask),
	-- only registers
	--5 => ahb_iobar(haddr, hmask),
	others => zero32 );

begin
-- Map signals from  pmu_events to specific events in the pmu.

    -- The std_logic_vector from the input is passed to the module beneath "pmu_ahb"
    events_map : for n in 0 to (nev-1) generate
        events_i(n) <= events_vector(n);
    end generate events_map;

-- unused interrupt signals filled with 0

fill_IRQ_FOR_1: for i in (NAHBIRQ-1) downto 13 generate
    irqvec(i) <= '0';
end generate fill_IRQ_FOR_1;
fill_IRQ_FOR_2: for i in (8-ncpu) downto 0 generate
    irqvec(i) <= '0';
end generate fill_IRQ_FOR_2;

ahbso.hconfig <= hconfig;         -- Plug&play configuration
ahbso.hirq    <= irqvec;          -- Interrupt lines
ahbso.hindex  <= hindex;          -- For test porpuses
-- TODO: move register calculation to pmu_ahb.sv instead
-- TODO: add all the cases for CPUs up to 6
-- TODO: make it change with the remaining parameters (N_SOC_EV,PMU_COUNTERS,etc..)
-- change the number of registers based on current configurations
gen_pmu6 : if (ncpu = 6) generate
begin
-- counter component instantiation
pmu_inst: pmu_ahb
    generic map(    haddr           => haddr,
	                hmask           => hmask,
                    N_SOC_EV        => nev,
                    MCCU_N_CORES    => ncpu,
                    N_COUNTERS      => ncounters,
                    REG_WIDTH       => 32,
                    MCCU_WEIGHTS_WIDTH => 8,
                    N_CONF_REGS     =>1,
                    MCCU_N_EVENTS   =>2,  
                    FT          =>ft) 
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
        intr_overflow_o => irqvec(10),
        intr_quota_o => irqvec(12),
        intr_MCCU_o => intr_MCCU,
        intr_RDC_o => irqvec(11),
        en_hwquota_o => hardware_quota_active
    );        
end generate;

gen_pmu : if (ncpu = 4) generate
begin
-- counter component instantiation
pmu_inst: pmu_ahb
    generic map(    haddr           => haddr,
    	            hmask           => hmask,
                    N_SOC_EV        => nev,
                    REG_WIDTH       => 32,
                    MCCU_N_CORES    => ncpu,
                    N_COUNTERS      => ncounters,
                    MCCU_WEIGHTS_WIDTH => 8,
                    N_CONF_REGS     =>1,
                    MCCU_N_EVENTS   =>2,  
                    FT          => ft 
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
        intr_overflow_o => irqvec(10),
        intr_quota_o => irqvec(12),
        intr_MCCU_o => intr_MCCU,
        intr_RDC_o => irqvec(11),
        en_hwquota_o => hardware_quota_active
    );        
end generate;

--Routes interrupts to plic if hardware quota is not active (IE: default)
irqvec(9 downto (10-ncpu)) <= intr_MCCU when hardware_quota_active = '0'
                                        else (others => '0');
--When hardware quota is active routes PMU interrupt signals directly to AHBCTRL
HQ_MCCU <= intr_MCCU when hardware_quota_active = '1'
                     else (others => '0');

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
