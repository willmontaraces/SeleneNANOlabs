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
-- SELENE-generic Demonstration Design
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library grlib, techmap;
use grlib.amba.all;
use grlib.devices.all;
use grlib.stdlib.all;
use grlib.config.all;
use grlib.config_types.all;
use techmap.gencomp.all;
use techmap.allclkgen.all;

library gaisler;
use gaisler.noelv.all;
use gaisler.uart.all;
use gaisler.misc.all;
--use gaisler.spi.all;
use gaisler.net.all;
use gaisler.jtag.all;
--use gaisler.i2c.all;
use gaisler.subsys.all;
use gaisler.axi.all;
use gaisler.plic.all;
use gaisler.riscv.all;
use gaisler.l2cache.all;
--use gaisler.noelv_pkg.all;

-- pragma translate_off
use gaisler.sim.all;
use grlib.at_pkg.all;
use grlib.at_ahb_slv_pkg.all;

library unisim;
use unisim.all;
-- pragma translate_on

use work.config.all;

entity selene_soc is
  generic(
    fabtech    : integer := CFG_FABTECH;
    memtech    : integer := CFG_MEMTECH;
    padtech    : integer := CFG_PADTECH;
    clktech    : integer := CFG_CLKTECH;
    disas      : integer := CFG_DISAS;
    dbguart    : integer := CFG_DUART;  -- Print UART on console
    migmodel   : boolean := false;
    simulation : boolean := false
    ); 
  port(
    -- Clock and Reset
    reset        : in    std_ulogic;
    clk250p      : in    std_ulogic;    -- 250 MHz clock
    clk250n      : in    std_ulogic;    -- 250 MHz clock
    -- Switches
    switch       : in    std_logic_vector(3 downto 0);
    -- Active high LEDs
    led          : out   std_logic_vector(7 downto 0);
    -- GPIOs
    gpio         : inout std_logic_vector(15 downto 0);
    -- UART
    dsurx        : in    std_ulogic;
    dsutx        : out   std_ulogic;
    dsuctsn      : in    std_ulogic;
    dsurtsn      : out   std_ulogic;
    -- Push Buttons (Active High) 
    -- This does not include FPGA prog(SW4), CPU reset pushbutton(SW5)
    button       : in    std_logic_vector(4 downto 0);
    -- DDR4 (MIG)
    ddr4_dq      : inout std_logic_vector(71 downto 0);
    ddr4_dqs_c   : inout std_logic_vector(8 downto 0);  -- Data Strobe
    ddr4_dqs_t   : inout std_logic_vector(8 downto 0);  -- Data Strobe
    ddr4_addr    : out   std_logic_vector(13 downto 0);  -- Address
    ddr4_ras_n   : out   std_ulogic;
    ddr4_cas_n   : out   std_ulogic;
    ddr4_we_n    : out   std_ulogic;
    ddr4_ba      : out   std_logic_vector(1 downto 0);  -- Device bank address per group
    ddr4_bg      : out   std_logic_vector(0 downto 0);  -- Device bank group address
    ddr4_dm_n    : inout std_logic_vector(8 downto 0);  -- Data Mask
    ddr4_ck_c    : out   std_logic_vector(0 downto 0);  -- Clock Negative Edge
    ddr4_ck_t    : out   std_logic_vector(0 downto 0);  -- Clock Positive Edge
    ddr4_cke     : out   std_logic_vector(0 downto 0);  -- Clock Enable
    ddr4_act_n   : out   std_ulogic;    -- Command Input
    --ddr4_alert_n: in    std_ulogic;                   -- Alert Output
    ddr4_odt     : out   std_logic_vector(0 downto 0);  -- On-die Termination
    ddr4_par     : out   std_ulogic;    -- Parity for cmd and addr
    ddr4_ten     : out   std_ulogic;    -- Connectivity Test Mode
    ddr4_cs_n    : out   std_logic_vector(0 downto 0);  -- Chip Select
    ddr4_reset_n : out   std_ulogic     -- Asynchronous Reset
-- pragma translate_off
;
    atmi         : in    at_ahb_mst_in_type;
    atmo         : out   at_ahb_mst_out_type
-- pragma translate_on
    );
end;

architecture rtl of selene_soc is

  constant BOARD_FREQ : integer := 250000;  -- input frequency in KHz
  -----------------------------------------------------
  -- Signals ------------------------------------------
  -----------------------------------------------------
  -- JTAG
  signal tck          : std_logic;
  signal tms          : std_logic;
  signal tdi          : std_logic;
  signal trst         : std_logic;
  signal tdo          : std_logic;
begin

  -----------------------------------------------------
  -- Top ----------------------------------------------
  -----------------------------------------------------
  cpu : entity work.pads
    generic map (
      fabtech    => fabtech,
      clktech    => clktech,
      memtech    => memtech,
      padtech    => padtech,
      disas      => disas,
      board_freq => BOARD_FREQ,
      migmodel   => migmodel,
      simulation => simulation
      )
    port map (
      -- Clock and Reset
      reset        => reset,
      clkinp       => clk250p,
      clkinn       => clk250n,
      -- Switches 
      switch       => switch,
      -- LEDs
      led          => led,
      -- GPIOs
      gpio         => gpio,
      --UART
      uart_rx      => dsurx,
      uart_tx      => dsutx,
      uart_ctsn    => dsuctsn,
      uart_rtsn    => dsurtsn,
      --JTAG
      tck          => tck,
      tms          => tms,
      tdi          => tdi,
      tdo          => tdo,
      trst         => trst,
      -- Push Buttons (Active High) 
      -- North, south, east, west and center buttons
      button       => button,
      -- DDR4 (MIG)
      ddr4_dq      => ddr4_dq,
      ddr4_dqs_c   => ddr4_dqs_c,
      ddr4_dqs_t   => ddr4_dqs_t,
      ddr4_addr    => ddr4_addr,
      ddr4_ras_n   => ddr4_ras_n,
      ddr4_cas_n   => ddr4_cas_n,
      ddr4_we_n    => ddr4_we_n,
      ddr4_ba      => ddr4_ba,
      ddr4_bg      => ddr4_bg,
      ddr4_dm_n    => ddr4_dm_n,
      ddr4_ck_c    => ddr4_ck_c,
      ddr4_ck_t    => ddr4_ck_t,
      ddr4_cke     => ddr4_cke,
      ddr4_act_n   => ddr4_act_n,
      --ddr4_alert_n
      ddr4_odt     => ddr4_odt,
      ddr4_par     => ddr4_par,
      ddr4_ten     => ddr4_ten,
      ddr4_cs_n    => ddr4_cs_n,
      ddr4_reset_n => ddr4_reset_n
      --FOR TESTING
      -- pragma translate_off
,
      dbg_atmi     => atmi,
      dbg_atmo     => atmo
      -- pragma translate_on
      );
end;

