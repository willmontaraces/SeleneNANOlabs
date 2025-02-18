-----------------------------------------------------------------------------
-- SELENE core system
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
use gaisler.net.all; -- Modification for sgmii fix
use gaisler.jtag.all;
--use gaisler.i2c.all;
use gaisler.subsys.all;
use gaisler.axi.all;
use gaisler.plic.all;
use gaisler.noelv.all;
use gaisler.l2cache.all;
use gaisler.spacewire.all;
use gaisler.canfd.all;
-- pragma translate_off
use gaisler.sim.all;
use gaisler.ahbtbp.all;
-- pragma translate_on

library interconnect;
use interconnect.libnoc.all;
use interconnect.libaxirom.all;
library accelerators;
use accelerators.dot_prod_pkg.all;
library safety; 
use safety.librv.all;


use work.selene.all;
use work.config.all;

entity selene_core is
  generic(
    fabtech         : integer := CFG_FABTECH;
    memtech         : integer := CFG_MEMTECH;
    padtech         : integer := CFG_PADTECH;
    clktech         : integer := CFG_CLKTECH;
    cpufreq         : integer := 100000;
    disas           : integer := CFG_DISAS;
    board_freq      : integer := 250000;
    migmodel        : boolean := false;
    autonegotiation : integer := 1;
    simulation      : boolean := false
    ); 
  port(
    -- Clock and Reset
    rst          : in    std_ulogic;
    clkinp       : in    std_ulogic;
    clkinn       : in    std_ulogic;
    lclk         : in    std_ulogic;
    cpu0errn     : out   std_logic;
    dsuen        : in    std_logic;
    lock         : out   std_logic;
    rstn_out     : out   std_ulogic;
    dsubreak     : in    std_logic;
    -- AHBUART
    dui          : in    uart_in_type;
    duo          : out   uart_out_type;
    -- APBUART
    u1i          : in    uart_in_type;
    u1o          : out   uart_out_type;
    -- GPIO
    gpio_i       : in    gpio_in_type;
    gpio_o       : out   gpio_out_type;
    -- Ethernet
    sgmiii       : in    eth_sgmii_in_type;
    sgmiio       : out   eth_sgmii_out_type;
    --AHBJTAG
    tck          : in    std_ulogic;
    tms          : in    std_ulogic;
    tdi          : in    std_ulogic;
    tdo          : out   std_ulogic;
    trst         : in    std_ulogic;
    -- Spacewire
    spwo         : out   grspw_out_type_vector(0 to CFG_SPW_NUM - 1);
    dtmp         : in    std_logic_vector(0 to CFG_SPW_PORTS * CFG_SPW_NUM - 1);
    stmp         : in    std_logic_vector(0 to CFG_SPW_PORTS * CFG_SPW_NUM - 1);
    --CAN signals
    cani1, cani2 : in  canfd_in_type;
    cano1, cano2 : out canfd_out_type;
  -- RS-485 APBUART
    uart485_i    : in uart_in_vector_type(1 downto 0);
    uart485_o    : out uart_out_vector_type(1 downto 0);
    -- DDR4 (MIG)
    ddr4_dq      : inout std_logic_vector(63 downto 0);
    ddr4_dqs_c   : inout std_logic_vector(7 downto 0);  -- Data Strobe
    ddr4_dqs_t   : inout std_logic_vector(7 downto 0);  -- Data Strobe
    ddr4_addr    : out   std_logic_vector(13 downto 0);  -- Address
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
    ddr4_reset_n : out   std_ulogic     -- Asynchronous Reset

  --FOR TESTING
    -- pragma translate_off
    ;
    io_atmi       : in  ahbtbm_ctrl_in_type;
    io_atmo       : out ahbtbm_ctrl_out_type;
    dbg_atmi      : in  ahbtbm_ctrl_in_type;
    dbg_atmo      : out ahbtbm_ctrl_out_type
  -- pragma translate_on
    );
end;

architecture rtl of selene_core is

  -----------------------------------------------------
  -- Components----------------------------------------
  -----------------------------------------------------

  component FFICTR is
  port (
    clk_in : in STD_LOGIC;
    reset : in STD_LOGIC;
    CLK_O_0 : out STD_LOGIC;
    RST_O_0 : out STD_LOGIC;
    GPIO_EXT : in STD_LOGIC_VECTOR ( 31 downto 0 )    
  );
  end component FFICTR;

  -----------------------------------------------------
  -- Constants ----------------------------------------
  -----------------------------------------------------
  -- System AHB master indexes ----
  constant ahbmstart_io  : integer := CFG_NCPU;  -- GRETH
  constant ahbmstart_gpp : integer := CFG_IOMMU + (((CFG_SPW_NUM * CFG_SPW_EN) + (CFG_GRCANFD1 + CFG_GRCANFD2) + 1 + CFG_GRDMAC2 )*(1-CFG_IOMMU));  -- GRETH + SPW cores if no IOMMU; if IOMMU is enabled,then it will be only IOMMU

  -- System debug bus indexes ----  
  constant ndbgmst : integer := 3       -- AHBUART + AHBJTAG + EDCL
-- pragma translate_off
  + 1                                   --AT_AHB_MST
-- pragma translate_on
;

  --System AHB slave indexes
  --constant ahbsstart_io    : integer := 0; --io_sys : IOMMU+grspfi(TODO)
  constant ahbsstart_io  : integer := 0;                 --io_sys : IOMMU
  --constant ahbsstart_mem   : integer := ahbsstart_io + 2;  --mem_sys : ahbram/L2c,mig,spimctrl(TODO),FTMCTRL(TODO)
  constant ahbsstart_mem : integer := ahbsstart_io + 1;  --mem_sys : ahbram/L2c,mig
  --constant ahbsstart_gpp   : integer := ahbsstart_mem + 4; --gpp_sys : ahbrom, ahbrep
  constant ahbsstart_gpp : integer := ahbsstart_mem + 2;  --gpp_sys : ahbrom, ahbrep 

  --System APB slave indexes
  constant apbstart_io  : integer := 0;  --AHBUART+GRETH+SGMII+GPIO+GRVERSION+AHBSTAT+(CFG_SPW_NUM * CFG_SPW_EN)
  constant apbstart_mem : integer := apbstart_io + 6 + (CFG_SPW_NUM * CFG_SPW_EN) + (CFG_GRCANFD1 + CFG_GRCANFD2) + CFG_UART2_ENABLE*2 + CFG_GRDMAC2;  --No APB slaves in mem_sys now
  constant apbstart_gpp : integer := apbstart_mem;
  
  -----------------------------------------------------
  -- Signals ------------------------------------------
  -----------------------------------------------------

  -- Clocks and Reset
  signal clkm       : std_ulogic := '0';
  signal mig_clkout : std_ulogic;
  signal gen_clk    : std_ulogic;
  signal rstn       : std_ulogic;
  signal rstraw     : std_ulogic;
  signal clk_lock   : std_ulogic;

  signal ddr_calib_done : std_ulogic;
  signal sgmiirst       : std_ulogic;
  signal mem_ahbsi      : ahb_slv_in_type;
  signal mem_ahbso      : ahb_slv_out_vector_type(1 downto 0);
  signal mem_apbi       : apb_slv_in_vector;
  signal mem_apbo       : apb_slv_out_vector;
  signal mem_aximi      : axi_somi_type;
  signal mem_aximo      : axi4_mosi_type;

  signal io_dbgmi      : ahb_mst_in_vector_type(ndbgmst-1 downto 0);
  signal io_dbgmo      : ahb_mst_out_vector_type(ndbgmst-1 downto 0);
  signal io_ahbmi      : ahb_mst_in_type;
  signal io_ahbmo      : ahb_mst_out_vector_type(((CFG_SPW_EN * CFG_SPW_NUM + CFG_GRCANFD1 + CFG_GRCANFD2 + CFG_GRDMAC2)* (1-CFG_IOMMU)) downto 0);
  signal io_ahbsi      : ahb_slv_in_type;
  signal io_ahbso      : ahb_slv_out_vector_type(0 downto 0);
  signal io_ahbsov_pnp : ahb_slv_out_vector;
  signal io_apbi       : apb_slv_in_vector_type(apbstart_mem -1 downto 0);
  signal io_apbo       : apb_slv_out_vector;
  signal cgi           : clkgen_in_type;
  signal cgo           : clkgen_out_type;
  
   -- Intra-module-crossbar
  signal gpp_aximi : axi_somi_type;
  signal gpp_aximo : axi4_mosi_type;

  -- AXI interconnection with accelerator (pass by crossbar)
  signal xbar_l_aximi : axi_somi_vector_type (0 to 0);
  signal xbar_l_aximo : axi_mosi_vector_type (0 to 0);
  signal accel_l_aximi : axi_somi_vector_type(0 to CFG_AXI_LITE_N_TARGETS-1);
  signal accel_l_aximo : axi_mosi_vector_type(0 to CFG_AXI_LITE_N_TARGETS-1);

  --Interconnection network--
    
  signal target_aximi     : axi_somi_vector_type(0 to CFG_AXI_N_TARGETS-1);
  signal target_aximo     : axi4_mosi_vector_type(0 to CFG_AXI_N_TARGETS-1); 
  signal initiator_aximi  : axi_somi_vector_type(0 to CFG_AXI_N_INITIATORS-1);
  signal initiator_aximo  : axi4_mosi_vector_type(0 to CFG_AXI_N_INITIATORS-1);
  signal acc_interrupt    : std_ulogic ;
  signal rv_interrupt     : std_ulogic_vector(3 downto 0);
  signal acc_control_aximi : axi_somi_type;
  signal acc_control_aximo : axi_mosi_type;   
  signal acc_mem_aximo     : axi4_mosi_vector_type(0 to CFG_AXI_N_ACCELERATOR_PORTS-1);
  signal acc_mem_aximi     : axi_somi_vector_type(0 to CFG_AXI_N_ACCELERATOR_PORTS-1);
  signal acc_mem_aximo_wide : axi4wide_mosi_vector_type(0 to CFG_AXI_N_ACCELERATOR_PORTS-1);
  signal acc_mem_aximi_wide : axiwide_somi_vector_type(0 to CFG_AXI_N_ACCELERATOR_PORTS-1);
  signal acc_sw_reset_n      : std_ulogic;
  signal acc_rst_n : std_ulogic;

    signal ffi_clk : STD_LOGIC;
    signal ffi_rst : STD_LOGIC;
    signal ffi_gpio_in : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal rstboardn      : std_ulogic;

  --mem_monitor wires from mem_sys to gpp--
  signal mem_sniff_coreID_read_pending_int : std_ulogic_vector(MEM_SNIFF_CORES_VECTOR_DEEP - 1 downto 0);
  signal mem_sniff_coreID_read_serving_int : std_ulogic_vector(MEM_SNIFF_CORES_VECTOR_DEEP - 1 downto 0);
  signal mem_sniff_coreID_write_pending_int : std_ulogic_vector(MEM_SNIFF_CORES_VECTOR_DEEP - 1 downto 0);
  signal mem_sniff_coreID_write_serving_int : std_ulogic_vector(MEM_SNIFF_CORES_VECTOR_DEEP - 1 downto 0);

    
    --| XXXX XXXX    XXXX XX      X        X         X
    --| ---------    -------    ------   ------    ------
    --| 32 bits      20 bits    4 bits   4 bits    4 bits
    --| ---------    -------    ------   ------    ------
    --| Base         Device     Device   Device    Device
    --| Address      Features     ID     Version   Type
    --
    --| Device Types:
    --      0x0 - None (empty slot)
    --      0xA - RootVoter
    --      0xB - HSL accelerator     
    --      0xC - SafeSU 
    --      0xD - SafeDE 
    function format_HWInfo(
            Enabled : integer;
            BaseAddress: std_logic_vector;
            Features: std_logic_vector;
            ID: integer;
            Version: integer;
            DeviceType: integer 
        ) return std_logic_vector is        
            
            variable result: std_logic_vector(63 downto 0) := X"0000000000000000";
        begin
        
        if(Enabled > 0) then
            result :=   BaseAddress & 
                        Features & 
                        std_logic_vector(to_unsigned(ID, 4)) &
                        std_logic_vector(to_unsigned(Version, 4)) &
                        std_logic_vector(to_unsigned(DeviceType, 4));
        end if;
        return result;
    end format_HWInfo;


    function format_RVC_Features(
            Enabled : integer;
            MAX_DATASETS : integer;
            LIST_FAILURES: integer;
            LIST_MATCHES: integer;
            COUNT_MATCHES: integer 
        ) return std_logic_vector is        
            
            variable result: std_logic_vector(19 downto 0) := X"00000";
        begin
        
        if(Enabled > 0) then
            result :=   X"000" & 
                        std_logic_vector(to_unsigned(COUNT_MATCHES, 1)) &            
                        std_logic_vector(to_unsigned(LIST_MATCHES,  1)) &
                        std_logic_vector(to_unsigned(LIST_FAILURES, 1)) &
                        std_logic_vector(to_unsigned(MAX_DATASETS,  5));
        end if;
        return result;
    end format_RVC_Features;
    
    function format_safeSU_Features(
            Enabled : integer;
            Crossbar_in: integer; 
            Counters: integer 
        ) return std_logic_vector is        
            
            variable result: std_logic_vector(19 downto 0) := X"00000";
        begin
        
        if(Enabled > 0) then
            result :=   B"000" & 
                        std_logic_vector(to_unsigned(Crossbar_in, 9)) &            
                        std_logic_vector(to_unsigned(Counters,  8)); 
        end if;
        return result;
    end format_safeSU_Features;
    
  
begin

  ----------------------------------------------------------------------
  ---  Reset and Clock generation  -------------------------------------
  ----------------------------------------------------------------------

  cgi.pllctrl <= "00";
  cgi.pllrst  <= rstraw;
  sgmiirst    <= not rstraw;

  ----------------------------------------------------------------------
  ---  Clock  ----------------------------------------------------------
  ----------------------------------------------------------------------

  -- If MIG is enabled, clkm is generated from MIG. clkgen module generates
  -- clkm otherwise
  clk_gen : if (CFG_MIG_7SERIES = 0 and simulation = false) generate
    clkgen0 : clkgen                    -- clock generator
      generic map (clktech, CFG_CLKMUL, CFG_CLKDIV, CFG_MCTRL_SDEN,
                   CFG_CLK_NOFB, 0, 0, 0, board_freq)
      port map (lclk, lclk, gen_clk, open, open, open, open, cgi, cgo, open, open, open);
      
      clkm <= ffi_clk when USE_FFI_CLOCK = 1 else gen_clk;  
  end generate;
  
  
  def_clk_gen : if (CFG_MIG_7SERIES = 1) generate
    clkm    <= mig_clkout;
    gen_clk <= mig_clkout;
  end generate;
  
  
  clk_lock <= cgo.clklock when (CFG_MIG_7SERIES = 0 and simulation = false) else ddr_calib_done;
  lock     <= clk_lock;
  ----------------------------------------------------------------------
  ---  Reset  ----------------------------------------------------------
  ----------------------------------------------------------------------    

  rst0 : rstgen                         -- reset generator
    generic map (acthigh => 1, syncin => 0)
    port map (rst, clkm, clk_lock, rstboardn, rstraw);

  rstn <= not ffi_rst when (USE_FFI_CLOCK = 1 and FAULT_INJECTOR_ENABLE = 1) else
        rstboardn;
  
  rstn_out <= rstn;
  acc_rst_n <= (rstn and acc_sw_reset_n);

  ----------------------------------------------------------------------
  ---  Fault Injector --------------------------------------------------
  ----------------------------------------------------------------------  

FFI_GEN: if (FAULT_INJECTOR_ENABLE = 1) generate
    FFICORE: component FFICTR
         port map (
            clk_in => gen_clk,
            reset => rst,
            CLK_O_0 => ffi_clk,
            RST_O_0 => ffi_rst,
            GPIO_EXT(31 downto 0) => ffi_gpio_in
        );
        
end generate;




  
  ----------------------------------------------------------------------
  --- SYSTEMS CONNECTIONS ----------------------------------------------
  ----------------------------------------------------------------------
  gpp0 : entity work.gpp_sys
    generic map (
      fabtech       => fabtech,
      memtech       => memtech,
      disas         => disas,
      ncpu          => CFG_NCPU,
      apbstart_mem  => apbstart_mem,
      apbstart_gpp  => apbstart_gpp,  --first APB index assigned to this system
      ahbmstart     => ahbmstart_gpp,   --first assigned AHBM index
      ahbsstart_mem => ahbsstart_mem,   --first assigned AHBS index to mem_sys
      ahbsstart_gpp => ahbsstart_gpp,   --first assigned AHBS index this system
      ndbgmst       => ndbgmst
      ) 
    port map (
      -- Clock and Reset
      rstn          => rstn,
      clkin         => clkm,
      dsuen         => dsuen,
      dsubreak      => dsubreak,
      cpu0errn      => cpu0errn,
      --UART
      uarti         => u1i,
      uarto         => u1o,
      --Interface with mem_sys
      mem_ahbsi     => mem_ahbsi,
      mem_ahbso     => mem_ahbso,
      mem_apbi      => mem_apbi,
      mem_apbo      => mem_apbo,
      mem_aximi     => gpp_aximi,
      mem_aximo     => gpp_aximo,
      mem_sniff_coreID_read_pending_o  => mem_sniff_coreID_read_pending_int,
      mem_sniff_coreID_read_serving_o  => mem_sniff_coreID_read_serving_int,
      mem_sniff_coreID_write_pending_o => mem_sniff_coreID_write_pending_int,
      mem_sniff_coreID_write_serving_o => mem_sniff_coreID_write_serving_int,
      --Interface with xbar lite
      xbar_l_aximi  => xbar_l_aximi(0),
      xbar_l_aximo  => xbar_l_aximo(0),
      acc_interrupt => acc_interrupt,

      --Interface with io_sys
      io_dbgmi      => io_dbgmi,
      io_dbgmo      => io_dbgmo,
      io_ahbmi      => io_ahbmi,
      io_ahbmo      => io_ahbmo,
      io_ahbsi      => io_ahbsi,
      io_ahbso      => io_ahbso,
      io_ahbsov_pnp => io_ahbsov_pnp,
      io_apbi       => io_apbi,
      io_apbo       => io_apbo
      );

  mem0 : entity work.mem_sys
    generic map (
      memtech    => memtech,
      apbstart   => apbstart_mem,
      ahbsstart  => ahbsstart_mem,
      migmodel   => migmodel,
      simulation => simulation
      )
    port map (
    -- Clock and Reset
      clkinp       => clkinp,
      clkinn       => clkinn,
      rstn         => rstn,
      rstraw       => rstraw,
      mig_clkout   => mig_clkout,
      clkin        => clkm,
      ahbsi        => mem_ahbsi,
      ahbso        => mem_ahbso,
      apbo         => mem_apbo,
      apbi         => mem_apbi,
      aximi        => mem_aximi,
      aximo        => mem_aximo,
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
      --ddr4_alert_n ,
      ddr4_odt     => ddr4_odt,
      ddr4_par     => ddr4_par,
      ddr4_ten     => ddr4_ten,
      ddr4_cs_n    => ddr4_cs_n,
      ddr4_reset_n => ddr4_reset_n,
      calib_done   => ddr_calib_done,
      --mem_sniff signals
      mem_sniff_coreID_read_pending_o  => mem_sniff_coreID_read_pending_int,
      mem_sniff_coreID_read_serving_o  => mem_sniff_coreID_read_serving_int,
      mem_sniff_coreID_write_pending_o => mem_sniff_coreID_write_pending_int,
      mem_sniff_coreID_write_serving_o => mem_sniff_coreID_write_serving_int
    );

  io0 : entity work.io_sys
    generic map (
      fabtech         => fabtech,
      cpufreq         => cpufreq,
      ahbmstart       => ahbmstart_io,
      ahbsstart       => ahbsstart_io,
      apbstart        => apbstart_io,
      autonegotiation => autonegotiation,
      ndbgmst         => ndbgmst
      )
    port map(
      -- Clock and Reset
      clkm       => clkm,
      rstn       => rstn,
      --AHB masters 
      ahbmi      => io_ahbmi,
      ahbmo      => io_ahbmo,
      -- AHB slave vector
      ahbsi      => io_ahbsi,
      ahbso      => io_ahbso,
      ahbsov_pnp => io_ahbsov_pnp,
      --Debug masters
      dbgmi      => io_dbgmi,
      dbgmo      => io_dbgmo,
      -- APB slaves
      apbi       => io_apbi,
      apbo       => io_apbo,
      --JTAG
      tck        => tck,
      tms        => tms,
      tdi        => tdi,
      tdo        => tdo,
      trst       => trst,
      -- Spacewire
      spwo       => spwo,
      dtmp       => dtmp,
      stmp       => stmp,
      --CAN signals
      cani1      => cani1,
      cani2      => cani2,
      cano1      => cano1,
      cano2      => cano2,
      -- RS-485 APBUART
      uart485_i  => uart485_i,
      uart485_o  => uart485_o,
      -- Ethernet
      sgmiii     => sgmiii,
      sgmiio     => sgmiio,
      sgmiirst   => sgmiirst,
      -- GPIO 
      gpio_i     => gpio_i,
      gpio_o     => gpio_o,
      -- AHB UART
      uarti      => dui,
      uarto      => duo
  -- pragma translate_off
      ,
      io_atmi    => io_atmi,
      io_atmo    => io_atmo,
      atmi       => dbg_atmi,
      atmo       => dbg_atmo
  -- pragma translate_on
      );

     --AXI interconnect--
    axi_noc_instance : axi_noc
      generic map(
        NoInitiators => CFG_AXI_N_INITIATORS,
        NoTargets    => CFG_AXI_N_TARGETS,
        ncpu         => CFG_NCPU  
      )
      port map (
        clk                 => clkm,
        rst                 => rstn,
        axi_from_target     => target_aximi,    
        axi_to_target       => target_aximo,
        axi_from_initiator  => initiator_aximo, 
        axi_to_initiator    => initiator_aximi
    );

   --AXI LITE interconnect--
    axi_lite_noc_instance : axi_lite_noc
      generic map(
        NoInitiators => CFG_AXI_LITE_N_INITIATORS,
        NoTargets    => CFG_AXI_LITE_N_TARGETS
      )
      port map (
        clk                 => clkm,
        rst                 => rstn,
        axi_from_target     => accel_l_aximi,    
        axi_to_target       => accel_l_aximo,
        axi_from_initiator  => xbar_l_aximo, 
        axi_to_initiator    => xbar_l_aximi
    );  

    ----------------------------------------------------------------------
    --- VITIS HLS ACCEL INSTANCE -----------------------------------------
    ----------------------------------------------------------------------
    axi_acc_instance0 : dot_prod_krnl 
    port map (
      clk              => clkm,
      rst_n            => acc_rst_n,
      axi_control_in   => accel_l_aximo(--NUMBER--),
      axi_control_out  => accel_l_aximi(--NUMBER--),
      axi_to_mem_1     => acc_mem_aximo_wide(0),
      axi_from_mem_1   => acc_mem_aximi_wide(0),
      axi_to_mem_2     => acc_mem_aximo_wide(1),
      axi_from_mem_2   => acc_mem_aximi_wide(1),
      interrupt        => acc_interrupt
    );

    width_converter_conv_mem0: axi_dw_wrapper 
    generic map(
      AxiMaxReads =>    32,     
      AxiSlvPortDataWidth => 32,
      AxiMstPortDataWidth => AXIDW
    )
    port map (
      clk               => clkm, 
      rst               => rstn, 
      axi_component_in  => acc_mem_aximo_wide(0),
      axi_component_out => acc_mem_aximi_wide(0),
      axi_from_noc      => acc_mem_aximi(0),
      axi_to_noc        => acc_mem_aximo(0)
    );
    width_converter_conv_mem1: axi_dw_wrapper 
    generic map(
      AxiMaxReads =>    32,     
      AxiSlvPortDataWidth => 32,
      AxiMstPortDataWidth => AXIDW
    )
    port map (
      clk               => clkm, 
      rst               => rstn, 
      axi_component_in  => acc_mem_aximo_wide(1),
      axi_component_out => acc_mem_aximi_wide(1),
      axi_from_noc      => acc_mem_aximi(1),
      axi_to_noc        => acc_mem_aximo(1)
    );
    acc_mem_aximi(--NUMBER--)      <= initiator_aximi(--NUMBER--); 
    initiator_aximo(--NUMBER--) <= acc_mem_aximo(--NUMBER--);

    acc_mem_aximi(--NUMBER--)      <= initiator_aximi(--NUMBER--); 
    initiator_aximo(--NUMBER--) <= acc_mem_aximo(--NUMBER--);

    ----------------------------------------------------------------------
    --- END OF ACCEL INSTANCE -- -----------------------------------------
    ----------------------------------------------------------------------


    RVC_0_GEN: if(RVC_0_ENABLE = 1) generate
        rootvoter_0 : rv_wrapper
        generic map (
          RVC_ID              => 1,
          MAX_DATASETS        => RVC_0_MAX_DATASETS,
          COUNT_MATCHES       => RVC_0_COUNT_MATCHES,
          LIST_MATCHES        => RVC_0_LIST_MATCHES,
          LIST_FAILURES       => RVC_0_LIST_FAILURES
        )
        port map (
          clk       => clkm,
          rst_n     => rstn, 
          axi_in    => accel_l_aximo(0), 
          axi_out   => accel_l_aximi(0), 
          interrupt => rv_interrupt(0) -- not used yet
        );  
    end generate;


    RVC_1_GEN: if(RVC_1_ENABLE = 1) generate	
        rootvoter_1 : rv_wrapper
        generic map (
          RVC_ID              => 2,
          MAX_DATASETS        => RVC_1_MAX_DATASETS,
          COUNT_MATCHES       => RVC_1_COUNT_MATCHES,
          LIST_MATCHES        => RVC_1_LIST_MATCHES,
          LIST_FAILURES       => RVC_1_LIST_FAILURES
        )    
        port map (
          clk       => clkm,
          rst_n     => rstn, 
          axi_in    => accel_l_aximo(1), 
          axi_out   => accel_l_aximi(1), 
          interrupt => rv_interrupt(1) -- not used yet
        );  
	end generate;
    
    
    RVC_2_GEN: if(RVC_2_ENABLE = 1) generate	
        rootvoter_2 : rv_wrapper
        generic map (
          RVC_ID              => 3,
          MAX_DATASETS        => RVC_2_MAX_DATASETS,
          COUNT_MATCHES       => RVC_2_COUNT_MATCHES,
          LIST_MATCHES        => RVC_2_LIST_MATCHES,
          LIST_FAILURES       => RVC_2_LIST_FAILURES
        )    
        port map (
          clk       => clkm,
          rst_n     => rstn, 
          axi_in    => accel_l_aximo(2), 
          axi_out   => accel_l_aximi(2), 
          interrupt => rv_interrupt(2) -- not used yet
        );  
    end generate;


    RVC_3_GEN: if(RVC_3_ENABLE = 1) generate
        rootvoter_3 : rv_wrapper
        generic map (
          RVC_ID              => 4,
          MAX_DATASETS        => RVC_3_MAX_DATASETS,
          COUNT_MATCHES       => RVC_3_COUNT_MATCHES,
          LIST_MATCHES        => RVC_3_LIST_MATCHES,
          LIST_FAILURES       => RVC_3_LIST_FAILURES
        )    
        port map (
          clk       => clkm,
          rst_n     => rstn, 
          axi_in    => accel_l_aximo(3), 
          axi_out   => accel_l_aximi(3), 
          interrupt => rv_interrupt(3) -- not used yet
        );  	
    end generate;


    target_aximi(0)    <= mem_aximi; 
    mem_aximo          <= target_aximo(0); 

    gpp_aximi          <= initiator_aximi(0);
    initiator_aximo(0) <= gpp_aximo; 
     

    --HWInf descriptors for SELENE-specific modules
    --AxiRom is present in the design if sync word (0xFFFC0000) equals 0xAACC5577
    --Each descriptor comprises one 64 bit word starting from 0xFFFC0008
    AxiRom_0 : AxiRom_wrapper
    generic map (
      REG_DATA_WIDTH      => 64,
      REGNUM              => 16,
      INIT                => (
        x"0000000000000000" &
        x"0000000000000000" &
        x"0000000000000000" &
        x"0000000000000000" &
        x"0000000000000000" &
        x"0000000000000000" &
        x"0000000000000000" &
        x"0000000000000000" &
        
        -- Template for appenging HWInfo descriptors for new cores
        -- format_HWInfo(
                    -- CORE_ENABLE_FLAG (1/0 - core is present/absent in this SoC),
                    -- CORE_BASE_ADDRESS (std_logic_vector: 32 bits: X"00000000"),
                    -- CORE_FEATURES (std_logic_vector: 20 bits: core-specific, optional (may be kept uninitialized X"00000"),
                    -- CORE_ID (integer: 4 bits),
                    -- CORE_VERSION (integer: 4 bits),
                    -- CORE_DEVICE_TYPE (integer: 4 bits)
        -- )
       
        --HWInfo for SafeDE 
        format_HWInfo(CFG_SAFEDE_EN,X"FC000500", 
                        X"00000",
                        16#6#, CFG_SAFEDE_VERSION,16#4#)& 

        --HWInfo for SafeSU 
        format_HWInfo(CFG_SAFESU_EN,X"80100000", 
                        format_safeSU_Features(CFG_SAFESU_EN, CFG_SAFESU_NEV,CFG_SAFESU_NCNT),
                        16#5#, CFG_SAFESU_VERSION,16#3#)& 

        --HWInfo for RootVoter 3        
        format_HWInfo(RVC_3_ENABLE, X"FFFC0500", 
                        format_RVC_Features(RVC_3_ENABLE,  RVC_3_MAX_DATASETS, RVC_3_LIST_FAILURES, RVC_3_LIST_MATCHES, RVC_3_COUNT_MATCHES ), 
                        16#4#,  CFG_RVC_VERSION,    16#2#) &

        --HWInfo for RootVoter 2                        
        format_HWInfo(RVC_2_ENABLE, X"FFFC0400", 
                        format_RVC_Features(RVC_2_ENABLE,  RVC_2_MAX_DATASETS, RVC_2_LIST_FAILURES, RVC_2_LIST_MATCHES, RVC_2_COUNT_MATCHES ), 
                        16#3#,  CFG_RVC_VERSION,    16#2#) &
                        
        --HWInfo for RootVoter 1                        
        format_HWInfo(RVC_1_ENABLE, X"FFFC0300", 
                        format_RVC_Features(RVC_1_ENABLE,  RVC_1_MAX_DATASETS, RVC_1_LIST_FAILURES, RVC_1_LIST_MATCHES, RVC_1_COUNT_MATCHES ), 
                        16#2#,  CFG_RVC_VERSION,    16#2#) &
                        
        --HWInfo for RootVoter 0
        format_HWInfo(RVC_0_ENABLE, X"FFFC0200", 
                        format_RVC_Features(RVC_0_ENABLE,  RVC_0_MAX_DATASETS, RVC_0_LIST_FAILURES, RVC_0_LIST_MATCHES, RVC_0_COUNT_MATCHES ), 
                        16#1#,  CFG_RVC_VERSION,    16#2#) &
                        
        --HWInfo for HLSinf accelerator
        format_HWInfo(CFG_HLSINF_EN, X"FFFC0000", 
                        X"00000", 
                        16#0#,  CFG_HLSINF_VERSION, 16#1#) &
      
        --SYNC Word to detect AxiRom
        X"00000000AACC5577" 
                              )
    )
    port map (
      clk       => clkm,
      rst_n     => rstn, 
      axi_in    => accel_l_aximo(4), 
      axi_out   => accel_l_aximi(4), 
      acc_sw_reset_n => acc_sw_reset_n
    ); 

    
     
end;

