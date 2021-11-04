-----------------------------------------------------------------------------
-- MEMORY SYSTEM for SELENE Design
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
use gaisler.misc.all;
use gaisler.l2cache.all;
use gaisler.memctrl.all;
-- pragma translate_off
use gaisler.sim.all;

library unisim;
use unisim.all;
-- pragma translate_on

use work.config.all;
use work.selene.all;

entity mem_sys is
  generic(
    memtech    : integer := CFG_MEMTECH;
    apbstart   : integer := 0;          --first assigned APB index
    ahbsstart  : integer := 1;          --first assigned AHB slave index
    migmodel   : boolean := false;
    simulation : boolean := false
    ); 
  port(
    -- Clock and Reset
    clkinp       : in    std_ulogic;
    clkinn       : in    std_ulogic;
    rstn         : in    std_ulogic;
    rstraw       : in    std_ulogic;
    mig_clkout   : out   std_ulogic;  -- out clock from mig. This will be used as the system clock
    clkin        : in    std_ulogic;  -- input clock from the clock generator if the mig is not generated
    ahbsi        : in    ahb_slv_in_type;
    ahbso        : out   ahb_slv_out_vector_type (1 downto 0);  -- 0- ahbram/ahbram_sim, 1- fake mig
    apbo         : out   apb_slv_out_vector;
    apbi         : in    apb_slv_in_vector;
    aximi        : out   axi_somi_type;
    aximo        : in    axi4_mosi_type;
    -- DDR4 (MIG)
    ddr4_dq      : inout std_logic_vector(63 downto 0);
    ddr4_dqs_c   : inout std_logic_vector(7 downto 0);  -- Data Strobe
    ddr4_dqs_t   : inout std_logic_vector(7 downto 0);  -- Data Strobe
    ddr4_addr    : out   std_logic_vector(13 downto 0);         -- Address
    ddr4_ras_n   : out   std_ulogic;
    ddr4_cas_n   : out   std_ulogic;
    ddr4_we_n    : out   std_ulogic;
    ddr4_ba      : out   std_logic_vector(1 downto 0);  -- Device bank address per group
    ddr4_bg      : out   std_logic_vector(0 downto 0);  -- Device bank group address
    ddr4_dm_n    : inout std_logic_vector(7 downto 0);  -- Data Mask
    ddr4_ck_c    : out   std_logic_vector(0 downto 0);  -- Clock Negative Edge
    ddr4_ck_t    : out   std_logic_vector(0 downto 0);  -- Clock Positive Edge
    ddr4_cke     : out   std_logic_vector(0 downto 0);  -- Clock Enable
    ddr4_act_n   : out   std_ulogic;    -- Command Input
    --ddr4_alert_n: in    std_ulogic;                   -- Alert Output
    ddr4_odt     : out   std_logic_vector(0 downto 0);  -- On-die Termination
    ddr4_par     : out   std_ulogic;    -- Parity for cmd and addr
    ddr4_ten     : out   std_ulogic;    -- Connectivity Test Mode
    ddr4_cs_n    : out   std_logic_vector(0 downto 0);  -- Chip Select
    ddr4_reset_n : out   std_ulogic;    -- Asynchronous Reset
    calib_done   : out   std_ulogic
    );
end;

architecture rtl of mem_sys is

  -----------------------------------------------------
  -- Components ---------------------------------------
  -----------------------------------------------------
  component axi_mig4_7series is
    generic(
      mem_bits : integer := 30
      );
    port(
      calib_done           : out   std_logic;
      sys_clk_p            : in    std_logic;
      sys_clk_n            : in    std_logic;
      ddr4_addr            : out   std_logic_vector(13 downto 0);
      ddr4_we_n            : out   std_logic;
      ddr4_cas_n           : out   std_logic;
      ddr4_ras_n           : out   std_logic;
      ddr4_ba              : out   std_logic_vector(1 downto 0);
      ddr4_cke             : out   std_logic_vector(0 downto 0);
      ddr4_cs_n            : out   std_logic_vector(0 downto 0);
      ddr4_dm_n            : inout std_logic_vector(7 downto 0);
      ddr4_dq              : inout std_logic_vector(63 downto 0);
      ddr4_dqs_c           : inout std_logic_vector(7 downto 0);
      ddr4_dqs_t           : inout std_logic_vector(7 downto 0);
      ddr4_odt             : out   std_logic_vector(0 downto 0);
      ddr4_bg              : out   std_logic_vector(0 downto 0);
      ddr4_reset_n         : out   std_logic;
      ddr4_act_n           : out   std_logic;
      ddr4_ck_c            : out   std_logic_vector(0 downto 0);
      ddr4_ck_t            : out   std_logic_vector(0 downto 0);
      ddr4_ui_clk          : out   std_logic;
      ddr4_ui_clk_sync_rst : out   std_logic;
      rst_n_syn            : in    std_logic;
      rst_n_async          : in    std_logic;
      aximi                : out   axi_somi_type;
      aximo                : in    axi4_mosi_type;
      -- Misc
      ddr4_ui_clkout1      : out   std_logic;
      clk_ref_i            : in    std_logic
      );
  end component;

  -----------------------------------------------------
  -- Constants ----------------------------------------
  -----------------------------------------------------
  constant ramfile : string := "hello_ahbram.srec";  -- ram contents
  constant ramfile_axi : string := "hello.srec";  -- ram contents

  -----------------------------------------------------
  -- Signals ------------------------------------------
  -----------------------------------------------------

  -- Misc
  signal vcc     : std_ulogic;
  signal gnd     : std_ulogic;
  signal migrstn : std_ulogic;
  signal calib   : std_ulogic;
  signal aximo_l : axi_mosi_type;

  -- Clocks and Reset
  signal clkm   : std_ulogic := '0';
  signal clkref : std_ulogic;

  -- Bus indexes
  ----------------
  -- AHB slaves
  constant hsidx_ram_sim : integer := 2;
  constant hsidx_ahbram  : integer := 2;
  constant hsidx_mig     : integer := 3;

  -- memory AHB IO system bus indexes
  -- AHB system with 1 AHBCTRL(TODO), L2C master, one MIG slave(TODOextended to two)
  constant miosid_mig1 : integer := 0;

  -- APB slaves
  --constant pidx_mig1    : integer := apbstart;

  constant USE_MIG_INTERFACE_MODEL : boolean := migmodel;

  constant mig_hconfig : ahb_config_type := (
    0      => ahb_device_reg (VENDOR_GAISLER, GAISLER_MIG_7SERIES, 0, 0, 0),
    4      => ahb_membar(16#000#, '1', '1', 16#C00#),
    others => zero32);

begin

  ----------------------------------------------------------------------
  ---  MISC  -----------------------------------------------------------
  ----------------------------------------------------------------------
  vcc <= '1';
  gnd <= '0';

  migrstn    <= rstn;
  mig_clkout <= clkm;
  calib_done <= calib;

  -- For designs that have PAR connected from the FPGA to a component, SODIMM, or UDIMM,
  -- the PAR output of the FPGA should be driven low using an SSTL12 driver to ensure it
  -- is held low at the memory.
  ddr4_par <= gnd;
  ddr4_ten <= gnd;
  clkref   <= gnd;

  -- No APB interface on memory controller  
  --apbo(pidx_mig1)  <= apb_none;
  memapbo_none : for i in 0 to 15 generate
    apbo(i) <= apb_none;
  end generate memapbo_none;
  -----------------------------------------------------------------------------
  -- DDR4 Memory Controller (MIG) ---------------------------------------------
  -----------------------------------------------------------------------------

  mig_gen : if (CFG_MIG_7SERIES = 1) generate
    
    gen_ddr4c : if USE_MIG_INTERFACE_MODEL = false generate

      ddr4c1 : axi_mig4_7series
        generic map (
          mem_bits => 30
        )
        port map (
          calib_done           => calib,
          sys_clk_p            => clkinp,
          sys_clk_n            => clkinn,
          ddr4_addr            => ddr4_addr,
          ddr4_we_n            => ddr4_we_n,
          ddr4_cas_n           => ddr4_cas_n,
          ddr4_ras_n           => ddr4_ras_n,
          ddr4_ba              => ddr4_ba,
          ddr4_cke             => ddr4_cke,
          ddr4_cs_n            => ddr4_cs_n,
          ddr4_dm_n            => ddr4_dm_n,
          ddr4_dq              => ddr4_dq,
          ddr4_dqs_c           => ddr4_dqs_c,
          ddr4_dqs_t           => ddr4_dqs_t,
          ddr4_odt             => ddr4_odt,
          ddr4_bg              => ddr4_bg,
          ddr4_reset_n         => ddr4_reset_n,
          ddr4_act_n           => ddr4_act_n,
          ddr4_ck_c            => ddr4_ck_c,
          ddr4_ck_t            => ddr4_ck_t,
          ddr4_ui_clk          => open,
          ddr4_ui_clk_sync_rst => open,
          rst_n_syn            => migrstn,
          rst_n_async          => rstraw,
          aximi                => aximi,
          aximo                => aximo,
          -- Misc
          ddr4_ui_clkout1      => clkm,
          clk_ref_i            => clkref
          );

    end generate gen_ddr4c;

    sim_ram_gen : if USE_MIG_INTERFACE_MODEL = true generate
    -- pragma translate_off
      axi_mem : aximem 
        generic map (
          fname   => ramfile_axi,
          axibits => AXIDW,
          rstmode => 0
          )
        port map (
          clk  => clkm,
          rst  => rstn,
          axisi=> aximo_l,
          axiso=> aximi
          );
      aximo_l.aw.id    <= aximo.aw.id;
      aximo_l.aw.addr  <= aximo.aw.addr;
      aximo_l.aw.len   <= aximo.aw.len(3 downto 0);
      aximo_l.aw.size  <= aximo.aw.size;
      aximo_l.aw.burst <= aximo.aw.burst;
      aximo_l.aw.lock  <= '0' & aximo.aw.lock;
      aximo_l.aw.cache <= aximo.aw.cache;
      aximo_l.aw.prot  <= aximo.aw.prot;
      aximo_l.aw.valid <= aximo.aw.valid;
      aximo_l.w.id       <= aximo.aw.id;
      aximo_l.w.data     <= aximo.w.data;
      aximo_l.w.strb     <= aximo.w.strb;
      aximo_l.w.last     <= aximo.w.last;
      aximo_l.w.valid    <= aximo.w.valid;  

      aximo_l.b        <= aximo.b;
      aximo_l.ar.id    <= aximo.ar.id;
      aximo_l.ar.addr  <= aximo.ar.addr;
      aximo_l.ar.len   <= aximo.ar.len(3 downto 0);
      aximo_l.ar.size  <= aximo.ar.size;
      aximo_l.ar.burst <= aximo.ar.burst;
      aximo_l.ar.lock  <= '0' & aximo.ar.lock;
      aximo_l.ar.cache <= aximo.ar.cache;
      aximo_l.ar.prot  <= aximo.ar.prot;
      aximo_l.ar.valid <= aximo.ar.valid;
      aximo_l.r        <= aximo.r;

      clkm <= not clkm after 5.0 ns;

      -- Drive signals when MIG is not instantiated

      -- Tie-Off DDR4 Signals
      ddr4_addr    <= (others => '0');
      ddr4_we_n    <= '0';
      ddr4_cas_n   <= '0';
      ddr4_ras_n   <= '0';
      ddr4_ba      <= (others => '0');
      ddr4_cke     <= (others => '0');
      ddr4_ck_c    <= (others => '0');
      ddr4_ck_t    <= (others => '0');
      ddr4_cs_n    <= (others => '0');
      ddr4_dm_n    <= (others => 'Z');
      ddr4_dq      <= (others => 'Z');
      ddr4_dqs_c   <= (others => 'Z');
      ddr4_dqs_t   <= (others => 'Z');
      ddr4_odt     <= (others => '0');
      ddr4_bg      <= (others => '0');
      ddr4_reset_n <= '1';
      ddr4_act_n   <= '1';
      -- Drive caliberation done signal
      calib        <= '1';

    -- pragma translate_on
    end generate sim_ram_gen;

    ahbso(0) <= ahbs_none; 
    ------------------------------
    ---  Fake MIG PNP ------------
    ------------------------------
    ahbso(1).hindex  <= hsidx_mig;
    ahbso(1).hconfig <= mig_hconfig;
    ahbso(1).hready  <= '1';
    ahbso(1).hresp   <= "00";
    ahbso(1).hirq    <= (others => '0');
    ahbso(1).hrdata  <= (others => '0');
    ahbso(1).hsplit  <= (others => '0');

  end generate mig_gen;

  no_mig_gen : if (CFG_MIG_7SERIES = 0) generate

    -- Simulation 
    sim_ram_gen : if (simulation = true) generate
    -- pragma translate_off
      sim_ram : ahbram_sim
        generic map (
          hindex     => hsidx_ram_sim,
          haddr      => 16#400#,
          hmask      => 16#FFF#,
          tech       => 0,
          kbytes     => 1000,
          pipe       => 0,
          maccsz     => AHBDW,
          endianness => GRLIB_CONFIG_ARRAY(grlib_little_endian),
          fname      => ramfile
          )
        port map(
          rst   => rstn,
          clk   => clkm,
          ahbsi => ahbsi,
          ahbso => ahbso(0)
          );

      clkm <= not clkm after 5.0 ns;
      -- pragma translate_on
    end generate sim_ram_gen;

    -- No Simulation 
    ahbram_gen : if (simulation = false) generate
      ahbram1 : ahbram
        generic map (
          hindex     => hsidx_ahbram,
          haddr      => 16#400#,
          tech       => memtech,
          kbytes     => 16,
          endianness => GRLIB_CONFIG_ARRAY(grlib_little_endian))
        port map (
          rstn,
          clkin,
          ahbsi,
          ahbso(0));
    end generate ahbram_gen;

    -- Drive signals when MIG/mig model is not instantiated
    aximi        <= aximi_none;
    -- Tie-Off DDR4 Signals
    ddr4_addr    <= (others => '0');
    ddr4_we_n    <= '0';
    ddr4_cas_n   <= '0';
    ddr4_ras_n   <= '0';
    ddr4_ba      <= (others => '0');
    ddr4_cke     <= (others => '0');
    ddr4_ck_c    <= (others => '0');
    ddr4_ck_t    <= (others => '0');
    ddr4_cs_n    <= (others => '0');
    ddr4_dm_n    <= (others => 'Z');
    ddr4_dq      <= (others => 'Z');
    ddr4_dqs_c   <= (others => 'Z');
    ddr4_dqs_t   <= (others => 'Z');
    ddr4_odt     <= (others => '0');
    ddr4_bg      <= (others => '0');
    ddr4_reset_n <= '1';
    ddr4_act_n   <= '1';
    -- Drive caliberation done signal
    calib        <= '1';
    -- no_fake_mig_gen :
    ahbso(1) <= ahbs_none;
  end generate no_mig_gen;

end;

