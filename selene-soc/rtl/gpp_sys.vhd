-----------------------------------------------------------------------------
-- GPP SYSTEM for SELENE Design
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
use gaisler.noelv.all;
use gaisler.l2cache.all;
--use gaisler.noelv_pkg.all;
-- pragma translate_off
use gaisler.sim.all;

library unisim;
use unisim.all;
-- pragma translate_on

-- BSC library is added
-- BSC library is now under safety
library safety;
use safety.pmu_module.all;

use work.config.all;
use work.selene.all;

entity gpp_sys is
  generic(
    fabtech       : integer := CFG_FABTECH;
    memtech       : integer := CFG_MEMTECH;
    disas         : integer := CFG_DISAS;
    ncpu          : integer := CFG_NCPU;
    apbstart_mem  : integer := 0;  --first APB index assigned to mem_sys
    apbstart_gpp  : integer := 0;  --first APB index assigned to this system
    ahbmstart     : integer := 1;  --first assigned AHBM index
    ahbsstart_mem : integer := 1;  --first assigned AHBS index to mem_sys
    ahbsstart_gpp : integer := 1;  --first assigned AHBS index to this system
    migmodel      : boolean := false;
    simulation    : boolean := false;
    ndbgmst       : integer := 0
    );
  port(
    -- Clock and Reset
    rstn          : in  std_ulogic;
    clkin         : in  std_ulogic;
    dsuen         : in  std_ulogic;
    dsubreak      : in  std_ulogic;
    cpu0errn      : out std_logic;
    --UART
    uarti         : in  uart_in_type;
    uarto         : out uart_out_type;
    --Interface with mem_sys
    mem_ahbsi     : out ahb_slv_in_type;
    mem_ahbso     : in  ahb_slv_out_vector_type (1 downto 0);
    mem_apbi      : out apb_slv_in_vector;
    mem_apbo      : in  apb_slv_out_vector;
    --Interface with mem_sys
    mem_aximi     : in  axi_somi_type;
    mem_aximo     : out axi4_mosi_type;
    --Interface with accel
    xbar_l_aximi   : in  axi_somi_type;
    xbar_l_aximo   : out axi_mosi_type;
    acc_interrupt  : in  std_ulogic;
    --Interface with io_sys
    io_dbgmi      : out ahb_mst_in_vector_type(ndbgmst-1 downto 0);
    io_dbgmo      : in  ahb_mst_out_vector_type(ndbgmst-1 downto 0);
    io_ahbmi      : out ahb_mst_in_type;
    io_ahbmo      : in  ahb_mst_out_vector_type(ahbmstart -1 downto 0); --io_ahbmo      : in  ahb_mst_out_vector_type(((CFG_SPW_EN * CFG_SPW_NUM + CFG_GRCANFD1 + CFG_GRCANFD2)*(1-CFG_IOMMU)) downto 0);
    io_ahbsi      : out ahb_slv_in_type;
    io_ahbso      : in  ahb_slv_out_vector_type(0 downto 0);
    io_ahbsov_pnp : out ahb_slv_out_vector;
    io_apbi       : out apb_slv_in_vector_type(0 to apbstart_mem -1);
    io_apbo       : in  apb_slv_out_vector
    );
end;

architecture rtl of gpp_sys is

  -----------------------------------------------------
  -- Constants ----------------------------------------
  -----------------------------------------------------

  -- AHB masters
  constant nextmst                 : integer := ahbmstart;


  -- AHB slaves
  --constant hsidx_iommu : integer := 0;
  constant hsidx_l2c    : integer := 1;
  --constant hsidx_ram_sim : integer := 2;
  --constant hsidx_ahbram : integer := 2;
  --constant hsidx_mig : integer := 3; 
  constant hsidx_accel  : integer := 5;
  constant hsidx_ahbrom : integer := 4;
  constant hsidx_ahbrep : integer := 6;
  constant hsidx_pmu : integer := 6  

-- pragma translate_off
  + 1
-- pragma translate_on
;
  constant nextslv      : integer := hsidx_pmu + 1;

  -- APB slaves
  --constant pidx_ahbuart : integer := 0;
  --constant pidx_greth   : integer := 1;
  --constant pidx_sgmii   : integer := 2;
  --constant pidx_gpio    : integer := 3;
  --constant pidx_ahbstat : integer := 4;
  --constant pidx_spw(0)  : integer := 5;
  --constant pidx_spw(1)  : integer := 6;
  --constant pidx_spw(2)  : integer := 7;
  --constant pidx_spw(3)  : integer := 8;
  constant nextapb : integer := apbstart_gpp;


  -----------------------------------------------------
  -- Signals ------------------------------------------
  -----------------------------------------------------

  -- Misc
  signal vcc        : std_ulogic;
  signal clkm       : std_ulogic;
  signal axi3_aximo : axi3_mosi_type;
  signal axi_aximo : axi_mosi_type;

  -- APB
  signal apbo : apb_slv_out_vector := (others => apb_none);
  signal apbi : apb_slv_in_vector;

  -- AHB
  signal ahbsi : ahb_slv_in_type;
  signal ahbso : ahb_slv_out_vector := (others => ahbs_none);
  signal ahbmi : ahb_mst_in_type;
  signal ahbmo : ahb_mst_out_vector := (others => ahbm_none);
  signal acc_ahbso :  ahb_slv_out_type;

  signal dbgmi : ahb_mst_in_vector_type(ndbgmst-1 downto 0);
  signal dbgmo : ahb_mst_out_vector_type(ndbgmst-1 downto 0);

  -- AHB UART
  signal u1i : uart_in_type;
  signal u1o : uart_out_type;

  ---------------------------------------------------------------------------------------------------------
  -- BSC signals
  ---------------------------------------------------------------------------------------------------------
  -- Signals of the PMU
  signal pmu_events : nv_counter_out_vector(ncpu-1 downto 0);
  signal one_hmaster : std_logic_vector (ncpu-1 downto 0); -- one hot encoded hmaster signal
	
  -- rdc contenttion
  signal ccs_contention : ccs_contention_vector_type((ncpu-1)-1 downto 0); 
  signal cpus_ahbmo : ahb_mst_out_vector_type(ncpu-1 downto 0);

  --rdc latency
  type ccs_latency_state is array (integer range <>) of std_logic_vector(1 downto 0);
  signal latency_state, n_latency_state : ccs_latency_state(ncpu-1 downto 0);

  --type ccs_latency_cause_state is (dcmiss, icsmiss, write);
  --type ccs_latency_cause_state_vector is array (integer range <>) of ccs_latency_cause_state;
  type ccs_latency_cause_state is array (integer range <>) of std_logic_vector(1 downto 0);
  signal latency_cause_state, n_latency_cause_state : ccs_latency_cause_state(ncpu-1 downto 0);
  
  signal ccs_latency : ccs_latency_vector_type(ncpu-1 downto 0);

begin

  ----------------------------------------------------------------------
  ---  Signal assignment -------------------------------------
  ----------------------------------------------------------------------
  vcc  <= '1';
  clkm <= clkin;

  -- DBG master signals.
  io_dbgmi                  <= dbgmi (ndbgmst-1 downto 0);
  dbgmo(ndbgmst-1 downto 0) <= io_dbgmo(ndbgmst-1 downto 0);

  -- AHB master signals.
--  io_ahbmi                     <= ahbmi;
--  ahbmo(ahbmstart downto ncpu - 1) <= io_ahbmo(1 downto 0);

  -- AHB master signals.
  io_ahbmi                     <= ahbmi;
  ahbmo(ahbmstart + ncpu -1 downto ncpu) <= io_ahbmo;

  -- AHB slave signals.
  io_ahbsi  <= ahbsi;
  mem_ahbsi <= ahbsi;

  ahbso(0) <= io_ahbso(0);              -- IOMMU + GRSPFI(TODO)
  --ahbso(1)                -- L2cache/ahb2axi3b
  ahbso(2) <= mem_ahbso(0);             -- ahbram/ahbram_sim
  ahbso(3) <= mem_ahbso(1);             -- MIG
  --ahbso(4)                -- AHBROM
  --ahbso(5)                -- AHBREP

  ahbs_set_none : for i in nextslv to 15 generate
    ahbso(i) <= ahbs_none;
  end generate ahbs_set_none;
  io_ahbsov_pnp <= ahbso;

  -- APB slave signals.
  io_apbi                     <= apbi(0 to apbstart_mem - 1);
  apbo(0 to apbstart_mem - 1) <= io_apbo(0 to apbstart_mem - 1);

  -- dummy. No APB slaves in mem_sys now
  mem_apbi <= apbi;

  apbsetnone : for i in nextapb to 15 generate
    apbo(i) <= apb_none;
  end generate apbsetnone;

  -- UART signals
  u1i   <= uarti;
  uarto <= u1o;

  ----------------------------------------------------------------------
  ---  NOEL-V SUBSYSTEM ------------------------------------------------
  ----------------------------------------------------------------------
  noelv0 : noelvsys
    generic map (
      fabtech  => fabtech,
      memtech  => memtech,
      ncpu     => ncpu,
      nextmst  => nextmst,
      nextslv  => nextslv,
      nextapb  => nextapb,
      ndbgmst  => ndbgmst,
      cached   => 0,
      wbmask   => 16#50FF#,
      busw     => AHBDW,
      cmemconf => 0,
      fpuconf  => 0,
      disas    => disas,
      ahbtrace => 0,
      cfg      => CFG_CFG,
      devid    => 0,
      --version  => CFG_GRVERSION_VERSION,
      --revision => CFG_GRVERSION_REVISION,
      nodbus   => CFG_NODBUS
      )
    port map(
      clk      => clkm,                 -- : in  std_ulogic;
      rstn     => rstn,                 -- : in  std_ulogic;
      -- AHB bus interface for other masters (DMA units)
      ahbmi    => ahbmi,                -- : out ahb_mst_in_type;
      ahbmo    => ahbmo(ncpu+nextmst-1 downto ncpu),  -- : in  ahb_mst_out_vector_type(ncpu+nextmst-1 downto ncpu);
      -- AHB bus interface for slaves (memory controllers, etc)
      ahbsi    => ahbsi,                -- : out ahb_slv_in_type;
      ahbso    => ahbso(nextslv-1 downto 0),  -- : in  ahb_slv_out_vector_type(nextslv-1 downto 0);
      -- AHB master interface for debug links
      dbgmi    => dbgmi,  -- : out ahb_mst_in_vector_type(ndbgmst-1 downto 0);
      dbgmo    => dbgmo,  -- : in  ahb_mst_out_vector_type(ndbgmst-1 downto 0);
      -- APB interface for external APB slaves
      apbi     => apbi,                 -- : out apb_slv_in_vector;
      apbo     => apbo,                 -- : in  apb_slv_out_vector;
      -- Bootstrap signals
      dsuen    => dsuen,                -- : in  std_ulogic;
      dsubreak => dsubreak,             -- : in  std_ulogic;
      cpu0errn => cpu0errn,             -- : out std_ulogic;
      -- UART connection
      uarti    => u1i,                  -- : in  uart_in_type;
      uarto    => u1o,                  -- : out uart_out_type
      -- BSC -------------------------------------------------------      
      -- Perf counter
      cnt       => pmu_events, -- signals for PMU
      -- Bus ahbmo from all cores 
      cpus_ahbmo => cpus_ahbmo
      );

  -----------------------------------------------------------------------------
  -- L2 cache -----------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- L2C generation enabled
  gen_l2 : if CFG_L2_EN /= 0 generate
    l2c0 : l2c_axi_be generic map (
      hslvidx  => hsidx_l2c,
      axiid    => 0,
      cen      => CFG_L2_PEN,
      haddr    => 16#000#,
      hmask    => 16#C00#,
      ioaddr   => 16#FF0#,
      cached   => CFG_L2_MAP,
      repl     => CFG_L2_RAN,
      ways     => CFG_L2_WAYS,
      linesize => CFG_L2_LSZ,
      waysize  => CFG_L2_SIZE,
      memtech  => memtech,
      sbus     => 0,
      mbus     => 0,
      arch     => CFG_L2_SHARE,
      ft       => CFG_L2_EDAC,
      stat     => 2)
    port map (
      rst         => rstn,
      clk         => clkm,
      ahbsi       => ahbsi,
      ahbso       => ahbso(hsidx_l2c),  --ahbso(1)
      aximi       => mem_aximi,
      aximo       => axi_aximo, -- TODO: Need to change L2 backend to AXI4 and then use mem_aximo here
      sto         => open);
  end generate gen_l2;

  -- L2C generation disabled
  nogen_l2c : if CFG_L2_EN = 0 generate

    bridge : ahb2axi4b
      generic map  (
        hindex          => hsidx_l2c,
        aximid          => 0,
        wbuffer_num     => 8,
        rprefetch_num   => 8,
        endianness_mode => 0,
        narrow_acc_mode => 0,
        vendor          => VENDOR_GAISLER,
        device          => GAISLER_AHB2AXI,
        bar0            => ahb2ahb_membar(16#000#, '1', '1', 16#C00#),
        ncpu            => ncpu
        )
      port map (
        rstn  => rstn, -- in  std_logic;
        clk   => clkm, -- in  std_logic;
        ahbsi => ahbsi, -- in  ahb_slv_in_type;
        ahbso => ahbso(hsidx_l2c),-- out ahb_slv_out_type;  ahbso(1) 
        aximi => mem_aximi, -- in  axi_somi_type;
        aximo => mem_aximo ); --out axi4_mosi_type 
  end generate;

  -----------------------------------------------------------------------
  ---  AHB to AXI -------------------------------------------------------
  -----------------------------------------------------------------------
  ahb2axi : ahb2axi_l
  generic map(
    hindex    => hsidx_accel,
    aximid    => 0,
    axisecure => true,
    scantest  => 0,
    vendor    => VENDOR_GAISLER,
    device    => GAISLER_AHB2AXI,
    bar0      => 16#3000ff83#, --2048 addressable directions AHB I/O without prefetch or cache
    bar1      => 0,
    bar2      => 0,
    bar3      => 0
  )
  port map(
    rst   => rstn,
    clk   => clkm,
    ahbsi => ahbsi,
    ahbso => acc_ahbso,
    aximi => xbar_l_aximi,
    aximo => xbar_l_aximo
  );

    ahbso(hsidx_accel).hready                      <= acc_ahbso.hready;
    ahbso(hsidx_accel).hresp                       <= acc_ahbso.hresp ;
    ahbso(hsidx_accel).hrdata                      <= acc_ahbso.hrdata;
    ahbso(hsidx_accel).hsplit                      <= acc_ahbso.hsplit;
    ahbso(hsidx_accel).hirq(13)                    <= acc_interrupt;
    ahbso(hsidx_accel).hirq((NAHBIRQ-1) downto 14) <= acc_ahbso.hirq((NAHBIRQ-1) downto 14);
    ahbso(hsidx_accel).hirq(12 downto 0)           <= acc_ahbso.hirq(12 downto 0);
    ahbso(hsidx_accel).hconfig                     <= acc_ahbso.hconfig;
    ahbso(hsidx_accel).hindex                      <= acc_ahbso.hindex;
    
  -----------------------------------------------------------------------
  ---  AHB ROM ----------------------------------------------------------
  -----------------------------------------------------------------------

  brom : entity work.ahbrom
    generic map (
      hindex => hsidx_ahbrom,
      haddr  => 16#C00#,
      cfg_7series => CFG_MIG_7SERIES,
      pipe   => 0)
    port map (
      rst   => rstn,
      clk   => clkm,
      ahbsi => ahbsi,
      ahbso => ahbso(hsidx_ahbrom));

  -----------------------------------------------------------------------
  ---  AHB REP ----------------------------------------------------------
  ----------------------------------------------------------------------- 

-- pragma translate_off
  test0 : ahbrep
    generic map(
      hindex => hsidx_ahbrep,
      haddr  => 16#900#)
    port map(
      rstn,
      clkm,
      ahbsi,
      ahbso(hsidx_ahbrep));
-- pragma translate_on

  -----------------------------------------------------------------------
  ---  Boot message  ----------------------------------------------------
  -----------------------------------------------------------------------

-- pragma translate_off
  x : report_design
    generic map(
      msg1    => "NOELV/GRLIB VCU118 Demonstration design",
      fabtech => tech_table(fabtech), memtech => tech_table(memtech),
      mdel    => 1
      );
-- pragma translate_on

----------------------------------------------------------------------
---  BSC Instances ---------------------------------------------------
----------------------------------------------------------------------
  -- FINITE-STATE MACHINE
  -- 1.- hbusreq=1 and hgrant -> 2
  -- 2.- htrans=3 or (htrans=0 and hready=0) -> 3 ; htrans=0 and hready ->1 
  -- 3.- hready=1 -> 1
  process(clkm)
  begin
      if rising_edge(clkm) then
          if (rstn = '0') then
              latency_state <= (others => (others => '0'));
              latency_cause_state <= (others => (others => '0'));
          else
              latency_state <= n_latency_state;
              latency_cause_state <= n_latency_cause_state;
          end if;
      end if;
  end process;

  latency: for n in 0 to ncpu-1 generate
      process(cpus_ahbmo, latency_state, ahbmi)
      begin
              n_latency_state(n) <= latency_state(n);
              ccs_latency(n).total <= '0';
              case latency_state(n) is
                  when "00" =>
                      if cpus_ahbmo(n).hbusreq = '1' then
                          if cpus_ahbmo(n).hbusreq = '1' and ahbmi.hgrant(n) = '1' then
                              n_latency_state(n) <= "01";
                          end if;
                          ccs_latency(n).total <= '1';
                      end if;
                  when "01" =>
                      ccs_latency(n).total <= '1';
                      if cpus_ahbmo(n).htrans = "11" or (cpus_ahbmo(n).htrans = "00" and ahbmi.hready = '0') then
                          n_latency_state(n) <= "10";
                      elsif cpus_ahbmo(n).htrans = "00" and ahbmi.hready = '1' then
                          n_latency_state(n) <= "00";
                          ccs_latency(n).total <= '0';
                      end if;
                  when "10" => 
                      if ahbmi.hready = '1' then
                          n_latency_state(n) <= "00";
                      else 
                          ccs_latency(n).total <= '1';
                      end if;
                  when others =>

              end case;
      end process;

      process(cpus_ahbmo, pmu_events, latency_cause_state)
      begin
              n_latency_cause_state(n) <= latency_cause_state(n);
              case latency_cause_state(n) is
                  when "00" => --dcmiss
                      if pmu_events(n).icmiss = '1' then
                          n_latency_cause_state(n) <= "01"; --icmiss
                      elsif cpus_ahbmo(n).hwrite = '1' then
                          n_latency_cause_state(n) <= "10"; --write
                      end if;
                  when "01" => --icmiss
                      if pmu_events(n).dcmiss = '1' then
                          n_latency_cause_state(n) <= "00"; --dcmiss
                      elsif cpus_ahbmo(n).hwrite = '1' then
                          n_latency_cause_state(n) <= "10"; --write
                      end if;
                  when "10" => --write
                      if pmu_events(n).icmiss = '1' then
                          n_latency_cause_state(n) <= "01"; --icmiss
                      elsif pmu_events(n).dcmiss = '1' then
                          n_latency_cause_state(n) <= "00"; --dcmiss
                      end if;
                  when others =>

              end case;
      end process;

      ccs_latency(n).dcmiss <= ccs_latency(n).total and (not n_latency_cause_state(n)(0) and not n_latency_cause_state(n)(1));
      ccs_latency(n).icmiss <= ccs_latency(n).total and n_latency_cause_state(n)(0);
      ccs_latency(n).write  <= ccs_latency(n).total and n_latency_cause_state(n)(1);
  end generate latency;
  -- get ahbsi.hmaster to one-hot. TODO: limited to 4 cores
  process(ahbsi.hmaster) begin
	  if ahbsi.hmaster = "0000" then
		  one_hmaster <= "0001"; 
	  elsif ahbsi.hmaster = "0001" then
		  one_hmaster <= "0010"; 
	  elsif ahbsi.hmaster = "0010" then
		  one_hmaster <= "0100"; 
	  elsif ahbsi.hmaster = "0011" then
		  one_hmaster <= "1000"; 
	  else 
		  one_hmaster <= "0000";
	  end if; 
  end process;


  -- 4 CORES --
 --Core 0 contention due to core 1 access 
  ccs_contention(0).r_and_w <= cpus_ahbmo(0).hbusreq and one_hmaster(1);
  ccs_contention(0).read <= ccs_contention(0).r_and_w and not cpus_ahbmo(0).hwrite;
  ccs_contention(0).write <= ccs_contention(0).r_and_w and cpus_ahbmo(0).hwrite;
 --Core 0 contention due to core 2 
  ccs_contention(1).r_and_w <= cpus_ahbmo(0).hbusreq and one_hmaster(2);
  ccs_contention(1).read <= ccs_contention(0).r_and_w and not cpus_ahbmo(0).hwrite;
  ccs_contention(1).write <= ccs_contention(0).r_and_w and cpus_ahbmo(0).hwrite;
 --Core 0 contention due to core 3 access 
  ccs_contention(2).r_and_w <= cpus_ahbmo(0).hbusreq and one_hmaster(3);
  ccs_contention(2).read <= ccs_contention(0).r_and_w and not cpus_ahbmo(0).hwrite;
  ccs_contention(2).write <= ccs_contention(0).r_and_w and cpus_ahbmo(0).hwrite;

  -----------------------------------------------------------------------
  ---  PMU  -----------------------------------------------
  -----------------------------------------------------------------------

  PMU_inst : ahb_wrapper
  generic map(
    ncpu   => CFG_NCPU,
    hindex => hsidx_pmu,
    haddr  => 16#801#,
    hmask  => 16#FFF#
    )
  port map(
    rst                => rstn,
    clk                => clkm,
    pmu_events         => pmu_events,
    ccs_contention     => ccs_contention,
    ccs_latency        => ccs_latency,
    ahbsi              => ahbsi,
    ahbso              => ahbso(hsidx_pmu));

end;

