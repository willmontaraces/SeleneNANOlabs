-----------------------------------------------------------------------------
-- IO SYSTEM for SELENE Design
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
--use gaisler.noelv.all;
use gaisler.uart.all;
use gaisler.misc.all;
--use gaisler.spi.all;
use gaisler.net.all;
use gaisler.jtag.all;
--use gaisler.i2c.all;
use gaisler.subsys.all;
use gaisler.axi.all;
use gaisler.iommu.all;
use gaisler.plic.all;
use gaisler.noelv.all;
use gaisler.l2cache.all;
use gaisler.spacewire.all;
use gaisler.canfd.all;
--use gaisler.noelv_pkg.all;
-- pragma translate_off
use gaisler.sim.all;
use gaisler.ahbtbp.all;

library unisim;
use unisim.all;
-- pragma translate_on

use work.config.all;
use work.selene.all;


entity io_sys is
  generic(
    fabtech         : integer := CFG_FABTECH;
    memtech         : integer := CFG_MEMTECH;
    cpufreq         : integer := 100000;
    ahbmstart       : integer := 0;     --first assigned AHBM index
    ahbsstart       : integer := 0;     --first assigned AHBS index
    apbstart        : integer := 0;
    autonegotiation : integer := 1;
    ndbgmst         : integer := 0;
    dbguart         : integer := CFG_DUART    -- Print UART on console
    ); 
  port(
    -- Clock and Reset
    clkm       : in  std_ulogic;
    rstn       : in  std_ulogic;
    --DEBUG BUS
    dbgmi      : in  ahb_mst_in_vector_type (ndbgmst-1 downto 0);
    dbgmo      : out ahb_mst_out_vector_type(ndbgmst-1 downto 0);
    --AMBA SYSTEM BUS
    ahbmi      : in  ahb_mst_in_type;
    ahbmo      : out ahb_mst_out_vector_type(((CFG_SPW_EN * CFG_SPW_NUM + CFG_GRCANFD1 + CFG_GRCANFD2) *(1-CFG_IOMMU)) downto 0);
    ahbsi      : in  ahb_slv_in_type;
    ahbso      : out ahb_slv_out_vector_type(0 downto 0);
    ahbsov_pnp : in  ahb_slv_out_vector;
    --APB BUS
    apbi       : in  apb_slv_in_vector_type(5 + (CFG_SPW_NUM * CFG_SPW_EN) + CFG_GRCANFD1 + CFG_GRCANFD2 + CFG_UART2_ENABLE*2 downto 0);
    apbo       : out apb_slv_out_vector;
    --AHBJTAG
    tck        : in  std_ulogic;
    tms        : in  std_ulogic;
    tdi        : in  std_ulogic;
    tdo        : out std_ulogic;
    trst       : in  std_ulogic;
    -- Spacewire
    spwo       : out grspw_out_type_vector(0 to CFG_SPW_NUM - 1);
    dtmp       : in  std_logic_vector(0 to CFG_SPW_PORTS * CFG_SPW_NUM - 1);
    stmp       : in  std_logic_vector(0 to CFG_SPW_PORTS * CFG_SPW_NUM - 1);
    --CAN signals
    cani1, cani2 : in  canfd_in_type;
    cano1, cano2 : out canfd_out_type;
    -- RS-485 APBUART
    uart485_i  : in uart_in_vector_type(1 downto 0);
    uart485_o  : out uart_out_vector_type(1 downto 0);
    -- Ethernet
    sgmiii     : in  eth_sgmii_in_type;
    sgmiio     : out eth_sgmii_out_type;
    sgmiirst   : in  std_ulogic;
    -- GPIO 
    gpio_i     : in  gpio_in_type;
    gpio_o     : out gpio_out_type;
    -- AHB UART
    uarti      : in  uart_in_type;
    uarto      : out uart_out_type
-- pragma translate_off
    ;
    io_atmi : in  ahbtbm_ctrl_in_type;
    io_atmo : out ahbtbm_ctrl_out_type;
    atmi      : in  ahbtbm_ctrl_in_type;
    atmo      : out ahbtbm_ctrl_out_type
-- pragma translate_on
    );
end;

architecture rtl of io_sys is

  -----------------------------------------------------
  -- Components ---------------------------------------
  -----------------------------------------------------
  component sgmii_vcu118
    generic(
      pindex          : integer := 0;
      paddr           : integer := 0;
      pmask           : integer := 16#fff#;
      abits           : integer := 8;
      autonegotiation : integer := 1;
      pirq            : integer := 0;
      debugmem        : integer := 0;
      tech            : integer := 0;
      simulation      : integer := 0
      );
    port(
      sgmiii   : in  eth_sgmii_in_type;
      sgmiio   : out eth_sgmii_out_type;
      gmiii    : out eth_in_type;
      gmiio    : in  eth_out_type;
      reset    : in  std_logic;
      clkout0o : out std_logic;
      clkout1o : out std_logic;
      clkout2o : out std_logic;
      apb_clk  : in  std_logic;
      apb_rstn : in  std_logic;
      apbi     : in  apb_slv_in_type;
      apbo     : out apb_slv_out_type
      );
  end component;

  -----------------------------------------------------
  --- Types -------------------------------------------
  -----------------------------------------------------
  --RS-485 UARTs
  type int_array is array (integer range <>) of integer;

  -----------------------------------------------------
  -- Constants ---------------------------------------
  -----------------------------------------------------

  -- Bus indexes
  -- AHB master indexes
  constant hmidx_iommu : integer := ahbmstart;
  constant hmidx_greth : integer := ahbmstart*(1-CFG_IOMMU);
  constant hmidx_spw   : integer := hmidx_greth + 1*CFG_SPW_EN;
  -- spw0     := hmidx_greth + 1;
  -- spw1     := hmidx_greth + 2;
  constant hmidx_canfd1           : integer := hmidx_greth + (CFG_SPW_NUM * CFG_SPW_EN) + CFG_GRCANFD1;
  -- hmidx_canfd2           : integer := hmidx_canfd1 + CFG_GRCANFD2;
  constant hmidx_free  : integer := hmidx_greth + (CFG_SPW_NUM * CFG_SPW_EN) + (CFG_GRCANFD1 + CFG_GRCANFD2) + 1;

  -- Number of AHB masters on master I/O bus
  constant IO_NAHBM : integer := hmidx_free 
  -- pragma translate_off
  + 1                                   --at_ahb_mst
  -- pragma translate_on
;

  -- Debug masters
  constant hdidx_ahbuart : integer := 0;
  constant hdidx_ahbjtag : integer := 1;
  constant hdidx_edcl    : integer := 2;
  constant hdidx_at_mst  : integer := 3;

  -- AHB slaves
  constant hsidx_iommu : integer := ahbsstart;
  --constant hsidx_spwrouter  : integer := hsidx_iommu     + 1;
  --constant hsidx_spfi       : integer := hsidx_spwrouter + 1;
  --constant hsidx_free       : integer := hsidx_spfi      + 1;  

  -- Slave on the IO AHB bus
  constant iosidx_iommu : integer := 0;

  -- APB slaves
  constant pidx_ahbuart : integer := 0;
  constant pidx_greth   : integer := 1;
  constant pidx_sgmii   : integer := 2;
  constant pidx_gpio    : integer := 3;
  constant pidx_version : integer := 4; 
  constant pidx_ahbstat : integer := 5;
  constant pidx_spw     : integer := 6;
  -- pidx_spw0     := pidx_ahbstat + 1;
  -- pidx_spw1     := pidx_ahbstat + 2;
  constant pidx_canfd1  : integer := (CFG_SPW_NUM * CFG_SPW_EN) + pidx_spw;
  -- pidx_canfd2  : integer := pidx_canfd1 + 1;
  constant pidx_apbuart485_0    : integer := pidx_canfd1 + (CFG_GRCANFD1 + CFG_GRCANFD2);
  -- pidx_apbuart485_1    : integer :=  pidx_apbuart485_0 + 1;  
  constant pidx_total   : integer := pidx_apbuart485_0 + 2*CFG_UART2_ENABLE;

  --IOMMU
  -- System burst length in 32-bit words
  constant BURSTLEN     : integer := 8;
  -- Bus ids used in bridges
  constant PROC_BUS_ID  : integer := 0;
  constant MSTIO_BUS_ID : integer := 0;  -- Not used, don't care
  constant REVISION : integer := 256 + 1;

  --RS-485 UARTs
  constant uart485_from_to_FDIR      : integer := 32;
  constant uart485_from_to_reserved  : integer := 8;
  constant uart485_fifo_sizes        : int_array(2 - 1 downto 0) := (uart485_from_to_reserved, uart485_from_to_FDIR);


  -----------------------------------------------------
  -- Signals ------------------------------------------
  -----------------------------------------------------

  -- Misc
  signal vcc   : std_ulogic;
  signal gnd   : std_ulogic;
  signal stati : ahbstat_in_type;

  -- AHB UART
  signal dui : uart_in_type;
  signal duo : uart_out_type;

  -- Ethernet
  signal gmiii       : eth_in_type;
  signal gmiio       : eth_out_type;
  signal clkout2o    : std_ulogic;
  signal greth_ahbmi : ahb_mst_in_type;
  signal greth_ahbmo : ahb_mst_out_type;
  signal greth_dbgmi : ahb_mst_in_type;
  signal greth_dbgmo : ahb_mst_out_type;
  signal spw_ahbmi   : ahb_mst_in_type;
  signal spw_ahbmo   : ahb_mst_out_vector_type(CFG_SPW_NUM-1 downto 0);

  -- SpaceWire
  signal spwi        : grspw_in_type_vector(0 to CFG_SPW_NUM - 1);
  signal spw_rxclk0  : std_logic_vector(0 to CFG_SPW_NUM - 1);
  signal spw_rxclk1  : std_logic_vector(0 to CFG_SPW_NUM - 1);
  signal spw_rxclkiv : std_logic_vector(0 to CFG_SPW_PORTS * CFG_SPW_NUM - 1);
  signal spw_rxclkin : std_ulogic;
  signal spw_txclk   : std_ulogic;

  -- CAN
  signal ahbmi_can1         : ahb_mst_in_vector_type(0 downto 0); --(1 downto 0);   -- sepbus enabled
  signal ahbmo_can1         : ahb_mst_out_vector_type(0 downto 0); --(1 downto 0);  -- sepbus enabled
  signal ahbmi_can2         : ahb_mst_in_vector_type(0 downto 0);
  signal ahbmo_can2         : ahb_mst_out_vector_type(0 downto 0);
  --signal can_bus0, can_bus1 : std_ulogic;

  --IO AHB
  signal io_ahbsi : ahb_slv_in_type;
  signal io_ahbso : ahb_slv_out_vector := (others => ahbs_none);
  signal io_ahbmi : ahb_mst_in_type;
  signal io_ahbmo : ahb_mst_out_vector := (others => ahbm_none);

  --IOMMU
  signal nolock   : ahb2ahb_ctrl_type;
  signal noifctrl : ahb2ahb_ifctrl_type;

  -- GPIOs
  signal gpioi : gpio_in_type;
  signal gpioo : gpio_out_type;

begin

  ----------------------------------------------------------------------
  ---  MISC  -----------------------------------------------------------
  ----------------------------------------------------------------------

  vcc <= '1';
  gnd <= '0';

  ----------------------------------------------------------------------
  ---  GRIOMMU  --------------------------------------------------------
  ----------------------------------------------------------------------
  --IOMMU generation enabled
  iommu : if CFG_IOMMU = 1 generate
    iommus : griommu
      generic map (
        memtech    => memtech,
        iohsindex  => iosidx_iommu,
        syshmindex => hmidx_iommu,
        syshsindex => hsidx_iommu,
        syshaddr   => 16#A00#,
        syshmask   => 16#FFE#,
        syshirq    => 31,
        dir        => 1,
        ffact      => 1,                --No scaling
        slv        => 0,
        pfen       => 1,
        wburst     => BURSTLEN,
        iburst     => 8,
        rburst     => BURSTLEN,
        irqsync    => 0,
        bar0       => ahb2ahb_membar(16#000#, '0', '0', 16#800#), -- AHB area
        bar1       => ahb2ahb_membar(16#800#, '0', '0', 16#800#),
        bar2       => 0,
        bar3       => 0,
        sbus       => MSTIO_BUS_ID,
        mbus       => PROC_BUS_ID,
        --ioarea     => 16#FFE#,
        ioarea     => 0,
        ibrsten    => 0,
        lckdac     => 0,
        slvmaccsz  => 32 + 96*CFG_AHB2AHB_RWCOMB,
        mstmaccsz  => 32 + 96*CFG_AHB2AHB_RWCOMB,
        rdcomb     => 2*CFG_AHB2AHB_RWCOMB,
        wrcomb     => 2*CFG_AHB2AHB_RWCOMB,
        combmask   => 16#7FFF#,  -- No acc. combining on 0xf0000000 and up
        allbrst    => 0,
        ifctrlen   => 0,
        fcfs       => IO_NAHBM*CFG_IOMMU_FCFS,
        fcfsmtech  => 0,
        scantest   => 0,                --scantest
        split      => CFG_IOMMU_SPLIT,
        dynsplit   => CFG_IOMMU_DYNSPLIT,
        nummst     => IO_NAHBM,
        numgrp     => CFG_IOMMU_NUMGRP,
        stat       => CFG_IOMMU_STAT,
        apv        => CFG_IOMMU_APV,
        apvc_en    => CFG_IOMMU_APVCEN,
        apvc_ways  => 1,                -- Only valid value
        apvc_lines => CFG_IOMMU_APVCLINES,
        apvc_tech  => CFG_IOMMU_APVCTECH,
        apvc_gseta => CFG_IOMMU_APVCGSETA,
        apvc_caddr => CFG_IOMMU_APVCCADDR,
        apvc_cmask => CFG_IOMMU_APVCCMASK,
        apvc_pipe  => CFG_IOMMU_APVCPIPE,
        iommu      => CFG_IOMMU_IOMMU,
        iommutype  => 0,
        tlb_num    => CFG_IOMMU_TLBNUM,
        tlb_type   => 0,
        tlb_tech   => CFG_IOMMU_TLBTECH,
        tlb_gseta  => CFG_IOMMU_TLBGSETA,
        tlb_pipe   => CFG_IOMMU_TLBPIPE,
        tmask      => CFG_IOMMU_TMASK,
        tbw_accsz  => CFG_IOMMU_TBWACCSZ,
        dpagesz    => CFG_IOMMU_DPAGESZ,
        ft         => CFG_IOMMU_FT,
        narb       => CFG_IOMMU_NARB)
      port map (
        rstn       => rstn,
        hclksys    => clkm,
        hclkio     => clkm,
        io_ahbsi   => io_ahbsi,
        io_ahbso   => io_ahbso(iosidx_iommu),
        io_ahbpnp  => io_ahbmo(IO_NAHBM-1 downto 0),
        sys_ahbmi  => ahbmi,
        sys_ahbmo  => ahbmo(0),
        sys_ahbpnp => ahbsov_pnp,
        sys_ahbsi  => ahbsi,
        sys_ahbso  => ahbso(0),
        lcki       => nolock,
        lcko       => open,
        stato      => open,
        ifctrl     => noifctrl);

    --AHBCTRL for ahb I/O bus. IOAREA is disabled, no pnp
    --Only one slave -> GRIOMMU
    ioahb0 : ahbctrl                    -- AHB arbiter/multiplexer
      generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                   rrobin  => CFG_RROBIN, ioaddr => 0,iomask => 0,cfgaddr => 0, cfgmask => 0, fpnpen => 0,
                   ioen    => 0, nahbm => IO_NAHBM, nahbs => 1)
      port map (rstn, clkm, io_ahbmi, io_ahbmo, io_ahbsi, io_ahbso);

    -----------------------------------------------------------------------
    ---  AT AHB MST -------------------------------------------------------
    -----------------------------------------------------------------------

    -- pragma translate_off
    iodma0 : ahbtbm
      generic map(
      hindex => hmidx_free,
      venid  => 1,
      devid   => 0)
      port map(
      rst   => rstn,
      clk   => clkm,
        -- Direct Memory Access Interface
      ctrli => io_atmi,
      ctrlo  => io_atmo,
        -- AMBA AHB Master Interface
      ahbmi  => io_ahbmi,
      ahbmo  => io_ahbmo(hmidx_free)
      );
    -- pragma translate_on

    noiomst : for i in IO_NAHBM + 1 to 15 generate
      io_ahbmo(i) <= ahbm_none;
    end generate;

     noioslv : for i in 1 to 15 generate
      io_ahbso(i) <= ahbs_none;
    end generate;

    -- Ethernet signal mapping the IO AHB system
    greth_ahbmi           <= io_ahbmi;
    io_ahbmo(hmidx_greth) <= greth_ahbmo;

    -- SPW signal mapping the IO AHB system
    spw_ahbmi <= io_ahbmi;
    spw_ahbm_gen : if CFG_SPW_EN /= 0 generate
      spw_ahbm : for i in 0 to (CFG_SPW_NUM - 1) generate
        io_ahbmo(i+1) <= spw_ahbmo(i);
      end generate spw_ahbm;
    end generate spw_ahbm_gen;

    -- GRCANFD signal mapping the IO AHB system
    ahbmi_can1(0)                   <= io_ahbmi;
    ahbmi_can2(0)                   <= io_ahbmi;

    canfd1_ahbm_gen : if CFG_GRCANFD1 /= 0 generate
      io_ahbmo(hmidx_canfd1)          <= ahbmo_can1(0);
    end generate canfd1_ahbm_gen;

    canfd2_ahbm_gen : if CFG_GRCANFD2 /= 0 generate
      io_ahbmo(hmidx_canfd1 + 1)          <= ahbmo_can2(0);
    end generate canfd2_ahbm_gen;

  end generate iommu;

  --IOMMU generation Disabled
  noiommu : if CFG_IOMMU = 0 generate
    -- GRETH
    greth_ahbmi <= ahbmi;
    ahbmo(0)    <= greth_ahbmo;
    -- SPW
    spw_ahbmi   <= ahbmi;
    spw_ahbm_gen : if CFG_SPW_EN /= 0 generate
      spw_ahbm : for i in 0 to (CFG_SPW_NUM - 1) generate
        ahbmo(i+1) <= spw_ahbmo(i);
      end generate spw_ahbm;
    end generate spw_ahbm_gen;
    -- AHB slave out signal
    ahbso(0) <= ahbs_none;

    -- GRCANFD 
    ahbmi_can1(0)                   <= ahbmi;
    ahbmi_can2(0)                   <= ahbmi;

    canfd1_ahbm_gen : if CFG_GRCANFD1 /= 0 generate
      ahbmo(CFG_SPW_EN * CFG_SPW_NUM + CFG_GRCANFD1)          <= ahbmo_can1(0);
    end generate canfd1_ahbm_gen;

    canfd2_ahbm_gen : if CFG_GRCANFD2 /= 0 generate
      ahbmo(CFG_SPW_EN * CFG_SPW_NUM + CFG_GRCANFD1 + CFG_GRCANFD2)          <= ahbmo_can2(0);
    end generate canfd2_ahbm_gen;

    -- No IO AHB signals
    noiomst : for i in 0 to 15 generate
      io_ahbmo(i) <= ahbm_none;
    end generate;
    -- pragma translate_off
    io_atmo <= ctrlo_nodrive;
    -- pragma translate_on
  end generate noiommu;
  -----------------------------------------------------------------------------
  -- Debug UART ---------------------------------------------------------------
  -----------------------------------------------------------------------------

  dcomgen : if CFG_AHB_UART = 1 generate
    dui   <= uarti;
    uarto <= duo;
    dcom0 : ahbuart
      generic map(
        hindex => hdidx_ahbuart,
        pindex => pidx_ahbuart,
        paddr  => 3)
      port map(
        rstn,
        clkm,
        dui,
        duo,
        apbi(pidx_ahbuart),
        apbo(pidx_ahbuart),
        dbgmi(hdidx_ahbuart),
        dbgmo(hdidx_ahbuart));
    --dui.extclk <= '0';
  end generate;

  nouah : if CFG_AHB_UART = 0 generate
    dbgmo(hdidx_ahbuart) <= ahbm_none;
    apbo(pidx_ahbuart)   <= apb_none;
    duo.txd              <= '0';
    duo.rtsn             <= '0';
    dui.extclk           <= '0';
  end generate;

  -----------------------------------------------------------------------------
  -- JTAG debug link ----------------------------------------------------------
  -----------------------------------------------------------------------------

  ahbjtaggen0 : if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag
      generic map(tech => fabtech, hindex => hdidx_ahbjtag)
      port map(rstn, clkm, tck, tms, tdi, tdo, dbgmi(hdidx_ahbjtag), dbgmo(hdidx_ahbjtag),
               open, open, open, open, open, open, open, gnd);
  end generate;
  nojtag : if CFG_AHB_JTAG = 0 generate
    dbgmo(hdidx_ahbjtag) <= ahbm_none;
  end generate;

  -----------------------------------------------------------------------
  ---  Ethernet core   --------------------------------------------------
  -----------------------------------------------------------------------
  -- Ethernet generation enabled
  eth0 : if CFG_GRETH = 1 generate
  -- Reset address of the PHY on VCU118 board is 0x3
      e0 : grethm_mb
        generic map (
          hindex       => hmidx_greth,
          ehindex      => hdidx_edcl,
          pindex       => pidx_greth,
          paddr        => 16#840#,
          pmask        => 16#FFF#,
          pirq         => 5,
          memtech      => memtech,
          mdcscaler    => cpufreq / 1000,
          rmii         => 0,
          enable_mdio  => 1,
          fifosize     => CFG_ETH_FIFO,
          nsync        => 2,
          edcl         => CFG_DSU_GRETH,
          edclbufsz    => CFG_ETH_BUF,
          phyrstadr    => 3,
          macaddrh     => CFG_ETH_ENM,
          macaddrl     => CFG_ETH_ENL,
          enable_mdint => 1,
          ipaddrh      => CFG_ETH_IPM,
          ipaddrl      => CFG_ETH_IPL,
          giga         => CFG_GRETH1G,
          ramdebug     => 0,
          gmiimode     => 1,
          edclsepahb   => 1
        )
        port map (
          rst    => rstn,
          clk    => clkm,
          ahbmi  => greth_ahbmi,
          ahbmo  => greth_ahbmo,
          ahbmi2 => greth_dbgmi,
          ahbmo2 => greth_dbgmo,
          apbi   => apbi(pidx_greth),
          apbo   => apbo(pidx_greth),
          ethi   => gmiii,
          etho   => gmiio
        );
  -- Reset driven to the SGMII IP is active high
    sgmii0 : sgmii_vcu118
      generic map (
        pindex          => pidx_sgmii,
        paddr           => 16#010#,
        pmask           => 16#ff0#,
        abits           => 8,
        autonegotiation => autonegotiation,
        pirq            => 11,
        debugmem        => 1,
        tech            => fabtech
      )
      port map (
        sgmiii   => sgmiii,
        sgmiio   => sgmiio,
        gmiii    => gmiii,
        gmiio    => gmiio,
        reset    => sgmiirst,
        clkout0o => open,
        clkout1o => open,
        clkout2o => clkout2o,
        apb_clk  => clkm,
        apb_rstn => rstn,
        apbi     => apbi(pidx_sgmii),
        apbo     => open
      );

  end generate eth0;

  -- Ethernet generation disabled
  no_eth0 : if (CFG_GRETH = 0) generate
    greth_dbgmo      <= ahbm_none;
    greth_ahbmo      <= ahbm_none;
    apbo(pidx_greth) <= apb_none;
  end generate no_eth0;

  -- Generate EDCL based on CFG_DSU_GRETH
  edcl0 : if (CFG_DSU_GRETH = 1) generate
    greth_dbgmi       <= dbgmi(hdidx_edcl);
    dbgmo(hdidx_edcl) <= greth_dbgmo;
  end generate edcl0;

  noecdl0 : if (CFG_DSU_GRETH = 0) generate
    dbgmo(hdidx_edcl) <= ahbm_none;
  end generate noecdl0;

  -- APB slave out for sgmii is none.
  apbo(pidx_sgmii) <= apb_none;
  -----------------------------------------------------------------------
  ---  SpaceWire --------------------------------------------------------
  -----------------------------------------------------------------------
  -- CFG_SPW_NUM defines the number of SpaceWire cores.
  -- CFG_SPW_PORTS defines the number of SpaceWire ports per Spacewire core. This can be 1(Nominal) or 2(Redundant). Any one of these will be active at a time. 

  -- rxclkin and nrxclki are unused
  spw_rxclkin <= '0';
  -- SpaceWire Transmitter clock should be clocked at 100 MHz
  spw_txclk   <= clkm;

  -- Enabled SPW generation
  spw : if CFG_SPW_EN /= 0 generate

    spwloop : for i in 0 to CFG_SPW_NUM - 1 generate

      -- For self-clock implementations we reuse the strobe input, otherwise we
      -- sample with the txclk
      spw_rxclkiv(i) <= stmp(i) when CFG_SPW_INPUT /= 3 else spw_txclk;

      -- GRSPW2 PHY
      spw2_input : if CFG_SPW_GRSPW = 2 generate
        spw_phy0 : grspw2_phy
          generic map (
            scantest     => 0,
            tech         => fabtech,
            input_type   => CFG_SPW_INPUT,
            rxclkbuftype => 1
          )
          port map (
            rstn      => rstn,
            rxclki    => spw_rxclkiv(i),                -- Receiver Clock Input
            rxclkin   => spw_rxclkin,
            nrxclki   => spw_rxclkin,
            di        => dtmp(i),       -- SpaceWire Data Input (from Pads)
            si        => stmp(i),       -- SpaceWire Strobe Input (from Pads)
            do        => spwi(i).d(1 downto 0),         -- Recovered Data
            dov       => spwi(i).dv(1 downto 0),        -- Data Valid
            dconnect  => spwi(i).dconnect(1 downto 0),  -- Disconnect
            dconnect2 => spwi(i).dconnect2(1 downto 0),
            dconnect3 => spwi(i).dconnect3(1 downto 0),
            rxclko    => spw_rxclk0(i)  -- Receiver Clock Output
          );

        spwi(i).nd <= (others => '0');  -- Only used in GRSPW
      end generate spw2_input;

      -- Single Port PHY
      singleportphy : if CFG_SPW_PORTS = 1 generate

        spwi(i).d(3 downto 2)         <= "00";  -- For second port
        spwi(i).dv(3 downto 2)        <= "00";  -- For second port
        spwi(i).dconnect(3 downto 2)  <= "00";  -- For second port
        spwi(i).dconnect2(3 downto 2) <= "00";  -- For second port
        spwi(i).dconnect3(3 downto 2) <= "00";  -- For second port
        spwi(i).s(1 downto 0)         <= "00";  -- Only used in PHY

      end generate singleportphy;

      -- Dual Port PHY
      dualportphy : if CFG_SPW_PORTS = 2 generate
        spw_rxclkiv(i * 2 + 1) <= stmp(i * 2 + 1) when CFG_SPW_INPUT /= 3 else spw_txclk;

        spw_phy0 : grspw2_phy
          generic map (
            scantest     => 0,
            tech         => fabtech,
            input_type   => CFG_SPW_INPUT,
            rxclkbuftype => 1
          )
          port map (
            rstn      => rstn,
            rxclki    => spw_rxclkiv(i * 2 + 1),
            rxclkin   => spw_rxclkin,
            nrxclki   => spw_rxclkin,
            di        => dtmp(i * 2 + 1),
            si        => stmp(i * 2 + 1),
            do        => spwi(i).d(3 downto 2),
            dov       => spwi(i).dv(3 downto 2),
            dconnect  => spwi(i).dconnect(3 downto 2),
            dconnect2 => spwi(i).dconnect2(3 downto 2),
            dconnect3 => spwi(i).dconnect3(3 downto 2),
            rxclko    => spw_rxclk1(i)
          );

      end generate dualportphy;

      -- GRSPW Codec
      sw0 : grspwm
        generic map (
          tech           => fabtech,
          hindex         => hmidx_spw + i,
          pindex         => pidx_spw + i,
          paddr          => (6 + i),
          pirq           => (6 + i),
          sysfreq        => cpufreq,
          nsync          => 1,
          rmap           => CFG_SPW_RMAP,
          rmapcrc        => CFG_SPW_RMAPCRC,
          fifosize1      => CFG_SPW_AHBFIFO,
          fifosize2      => CFG_SPW_RXFIFO,
          rxclkbuftype   => 1,
          memtech        => memtech,
          rmapbufs       => CFG_SPW_RMAPBUF,
          ft             => CFG_SPW_FT,
          ports          => CFG_SPW_PORTS,
          dmachan        => CFG_SPW_DMACHAN,
          netlist        => CFG_SPW_NETLIST,
          spwcore        => CFG_SPW_GRSPW,
          input_type     => CFG_SPW_INPUT,
          output_type    => CFG_SPW_OUTPUT,
          rxtx_sameclk   => CFG_SPW_RTSAME,
          rxunaligned    => CFG_SPW_RXUNAL,
          internalrstgen => 1
        )
        port map (
          rst        => rstn,
          clk        => clkm,
          rxasyncrst => gnd,
          rxsyncrst0 => gnd,
          rxclk0     => spw_rxclk0(i),  -- Receiver Clock for Port 0
          rxsyncrst1 => gnd,
          rxclk1     => spw_rxclk1(i),  -- Receiver Clock for Port 1
          txsyncrst  => gnd,
          txclk      => spw_txclk,      -- Transmitter default run-state clock
          txclkn     => spw_txclk,  -- Transmitter inverted default run-state clock
          ahbmi      => spw_ahbmi,
          ahbmo      => spw_ahbmo(i),
          apbi       => apbi(pidx_spw + i),
          apbo       => apbo(pidx_spw + i),
          swni       => spwi(i),        -- SpaceWire Input
          swno       => spwo(i)         -- SpaceWire Output
        );

      spwi(i).tickin       <= '0'; spwi(i).rmapen <= '0';
      spwi(i).clkdiv10     <= conv_std_logic_vector(cpufreq / 10000 - 1, 8);
      spwi(i).dcrstval     <= (others => '0');
      spwi(i).timerrstval  <= (others => '0');
      spwi(i).pnpusn       <= (others => '0');
      spwi(i).pnpuprodid   <= (others => '0');
      spwi(i).pnpuvendid   <= (others => '0');
      spwi(i).pnpen        <= '0';
      spwi(i).irqtxdefault <= (others => '0');
      spwi(i).intcreload   <= (others => '0');
      spwi(i).intiareload  <= (others => '0');
      spwi(i).intpreload   <= (others => '0');
      spwi(i).rmapnodeaddr <= (others => '0');
      spwi(i).timein       <= (others => '0');
      spwi(i).tickinraw    <= '0';

    end generate spwloop;

  end generate spw;

  -- SPW generation disabled
  no_spw : if CFG_SPW_EN = 0 generate
    spw_apb : for i in 0 to (CFG_SPW_NUM - 1) generate
      spw_ahbmo(i)       <= ahbm_none;
    end generate spw_apb;
    spwo <= (others => grspw_out_none);
  end generate no_spw;
  
  
  ----------------------------------------------------------------------
  ---  GRCANFD  --------------------------------------------------------
  ----------------------------------------------------------------------
  -----------------------------------------------------------------------

  --can_bus0 <= cano1.tx(0) and cano2.tx(0);
  --can_bus1 <= cano1.tx(1) and cano2.tx(1);
  
  gengrcanfd1: if CFG_GRCANFD1 = 1  generate
    --cani1.rx(0) <= can_bus0;
    --cani1.rx(1) <= can_bus1;
    
    canfd1 : grcanfd_ahb
      generic map(
        tech            => memtech,
        hindex	        => hmidx_canfd1,
        pindex	        => pidx_canfd1,
        paddr 	        => 16#C00#,
        pmask	        => 16#FFC#,
        pirq            => pidx_canfd1,
        singleirq       => 1,
        txbufsize       => 2,
        rxbufsize       => 2,
        canopen         => 0,
        sepbus          => 0,
        hindexcopen     => 0 
        )
      port map(
        clk    	        => clkm,
        rstn 	        => rstn,
        ahbmi           => ahbmi_can1,
        ahbmo           => ahbmo_can1, --hindex parameter, the AHB master index
        apbi	        => apbi(pidx_canfd1), --pindex parameter, the APB slave index
        apbo	        => apbo(pidx_canfd1), --idem
        cani	        => cani1,
        cano 	        => cano1,
        cfg	            => GRCANFD_CFG_NULL 
        );
  end generate;

  nogrcangen1 : if CFG_GRCANFD1 = 0 generate
    cano1 <= (tx => "11", en => "00");
  end generate; 

  gengrcanfd2: if CFG_GRCANFD2 = 1  generate

    --cani2.rx(0) <= can_bus0;
    --cani2.rx(1) <= can_bus1;
    
    canfd2 : grcanfd_ahb
      generic map(
        tech            => memtech,
        hindex	        => hmidx_canfd1 + 1,
        pindex	        => pidx_canfd1 + 1,
        paddr 	        => 16#D00#,
        pmask	        => 16#FFC#,
        pirq            => pidx_canfd1 + 1,
        singleirq       => 1,
        txbufsize       => 2,
        rxbufsize       => 2,
        canopen         => 0,
        sepbus          => 0,
        hindexcopen     => 0
        )
      port map(
        clk    	        => clkm,
        rstn 	        => rstn,
        ahbmi           => ahbmi_can2,
        ahbmo           => ahbmo_can2, 
        apbi	        => apbi(pidx_canfd1 + 1), --pindex parameter, the APB slave index
        apbo	        => apbo(pidx_canfd1 + 1), --idem
        cani	        => cani2,
        cano 	        => cano2,
        cfg	            => GRCANFD_CFG_NULL
        );  
  end generate;
  
  nogrcangen2 : if CFG_GRCANFD2 = 0 generate
    cano2 <= (tx => "11", en => "00");
  end generate; 

----------------------------------------------------------------------
---  RS-485 UARTs  ---------------------------------------------------
----------------------------------------------------------------------
  rs485_en : if (CFG_UART2_ENABLE /= 0) generate

      rs485_apbuart0 : apbuart generic map (pindex   => pidx_apbuart485_0,
                                           paddr    => 16#E00#,
                                           pmask    => 16#FFF#,
                                           console  => dbguart,
                                           pirq     => pidx_apbuart485_0,
                                           parity   => 1,
                                           flow     => 0,
                                           fifosize => 1, --uart485_fifo_sizes(0),
                                           abits    => 8,
                                           sbits    => 12)
                              port map (rst   => rstn,
                                        clk   => clkm,
                                        apbi  => apbi(pidx_apbuart485_0),
                                        apbo  => apbo(pidx_apbuart485_0),
                                        uarti => uart485_i(0),
                                        uarto => uart485_o(0));

      rs485_apbuart1 : apbuart generic map (pindex   => (pidx_apbuart485_0 + 1),
                                           paddr    => 16#F00#,
                                           pmask    => 16#FFF#,
                                           console  => dbguart,
                                           pirq     => (pidx_apbuart485_0 + 1),
                                           parity   => 1,
                                           flow     => 0,
                                           fifosize => 1, --uart485_fifo_sizes(1),
                                           abits    => 8,
                                           sbits    => 12)
                              port map (rst   => rstn,
                                        clk   => clkm,
                                        apbi  => apbi(pidx_apbuart485_0 + 1),
                                        apbo  => apbo(pidx_apbuart485_0 + 1),
                                        uarti => uart485_i(1),
                                        uarto => uart485_o(1));

  end generate;

  -----------------------------------------------------------------------
  ---  AT AHB MST -------------------------------------------------------
  -----------------------------------------------------------------------

-- pragma translate_off
  dma0 : ahbtbm
    generic map(
    hindex => hdidx_at_mst,
    venid  => 1,
    devid   => 0)
    port map(
    rst   => rstn,
    clk   => clkm,
      -- Direct Memory Access Interface
    ctrli=> atmi,
    ctrlo   => atmo,
      -- AMBA AHB Master Interface
    ahbmi  => dbgmi(hdidx_at_mst),
    ahbmo => dbgmo(hdidx_at_mst)
    );

-- pragma translate_on

  -----------------------------------------------------------------------
  ---  GPIO units -------------------------------------------------------
  -----------------------------------------------------------------------  
  gpio_gen : if CFG_GRGPIO_ENABLE /= 0 generate
    
    gpioi  <= gpio_i;
    gpio_o <= gpioo;

    gpio : grgpio
      generic map(
        pindex => pidx_gpio,
        paddr  => 16#830#,
        imask  => CFG_GRGPIO_IMASK,
        nbits  => CFG_GRGPIO_WIDTH)
      port map(
        rst   => rstn,
        clk   => clkm,
        apbi  => apbi(pidx_gpio),
        apbo  => apbo(pidx_gpio),
        gpioi => gpioi,
        gpioo => gpioo);   
  end generate;

  no_gpio : if CFG_GRGPIO_ENABLE = 0 generate
   gpio_o.dout     <= (others => '0');
   gpio_o.oen      <= (others => '0');
   gpio_o.val      <= (others => '0');
   gpio_o.sig_out  <= (others => '0');
   apbo(pidx_gpio) <= apb_none;
  end generate no_gpio;

  -- Version
  grver0 : grversion
    generic map(
      pindex      => pidx_version,
      paddr       => 16#810#,
      pmask       => 16#FFF#,
      versionnr   => CFG_CFG,
      revisionnr  => REVISION)
    port map(
      rstn  => rstn,
      clk   => clkm,
      apbi  => apbi(pidx_version),
      apbo  => apbo(pidx_version));

  -----------------------------------------------------------------------
  ---  AHB Status Register ----------------------------------------------
  ----------------------------------------------------------------------- 

  ahbs : if CFG_AHBSTAT = 1 generate
    stati <= ahbstat_in_none;
    ahbstat0 : ahbstat
      generic map(pindex => pidx_ahbstat,
                  paddr  => 16#820#,
                  pirq   => 4,
                  nftslv => CFG_AHBSTATN)
      port map(
        rstn,
        clkm,
        ahbmi,
        ahbsi,
        stati,
        apbi(pidx_ahbstat),
        apbo(pidx_ahbstat));
  end generate;
  no_ahbs : if CFG_AHBSTAT /= 1 generate
    apbo(pidx_ahbstat) <= apb_none;
  end generate no_ahbs;

  noapb : for i in pidx_total to 15 generate
    apbo(i) <= apb_none;
  end generate noapb;

end;

