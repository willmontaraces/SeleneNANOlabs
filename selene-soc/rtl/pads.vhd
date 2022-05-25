-----------------------------------------------------------------------------
-- SELENE SOC PADS instantiation
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
use gaisler.canfd.all;
use gaisler.subsys.all;
use gaisler.axi.all;
use gaisler.plic.all;
use gaisler.noelv.all;
use gaisler.l2cache.all;
use gaisler.spacewire.all;
--use gaisler.nandpkg.all;
use gaisler.memctrl.all;
--use gaisler.spacefibre.all;


-- pragma translate_off
use gaisler.sim.all;
use gaisler.ahbtbp.all;
-- pragma translate_on

use work.config.all;
use work.selene.all;

entity pads is
  generic(
    fabtech         : integer := CFG_FABTECH;
    clktech         : integer := CFG_CLKTECH;
    memtech         : integer := CFG_MEMTECH;
    padtech         : integer := CFG_PADTECH;
    disas           : integer := CFG_DISAS;
    board_freq      : integer := CFG_BOARDFRQ;          --250000
    migmodel        : boolean := false;
    autonegotiation : integer := 1;
    simulation      : boolean := false
    ); 
  port(
    -- Clock and Reset
    reset        : in    std_ulogic;    -- board reset
    clkinp       : in    std_ulogic;    -- Clock p from the board
    clkinn       : in    std_ulogic;    -- Clock n from the board
    -- Switches
    switch       : in    std_logic_vector(3 downto 0);
    -- LEDs
    led          : out   std_logic_vector(7 downto 0);
    -- GPIOs
--    gpio         : inout std_logic_vector(15 downto 0);
    -- Ethernet
    gtrefclk_n   : in    std_logic;
    gtrefclk_p   : in    std_logic;
    txp          : out   std_logic;
    txn          : out   std_logic;
    rxp          : in    std_logic;
    rxn          : in    std_logic;
    emdio        : inout std_logic;
    emdc         : out   std_ulogic;
    eint         : in    std_ulogic;
    erst         : out   std_ulogic;
    --UART
    uart_rx      : in    std_ulogic;
    uart_tx      : out   std_ulogic;
    uart_ctsn    : in    std_ulogic;
    uart_rtsn    : out   std_ulogic;
    --JTAG
    tck          : in    std_ulogic;
    tms          : in    std_ulogic;
    tdi          : in    std_ulogic;
    tdo          : out   std_ulogic;
    trst         : in    std_ulogic;
    -- Push Buttons (Active High) 
    -- North, south, east, west and center buttons
    button       : in    std_logic_vector(4 downto 0);
    -- SpaceWire, signals to Star-Dundee FMC-SPW/SpFi Board
    spw_dout_p   : out   std_logic_vector(1 to CFG_SPW_PORTS*CFG_SPW_NUM);
    spw_dout_n   : out   std_logic_vector(1 to CFG_SPW_PORTS*CFG_SPW_NUM);
    spw_sout_p   : out   std_logic_vector(1 to CFG_SPW_PORTS*CFG_SPW_NUM);
    spw_sout_n   : out   std_logic_vector(1 to CFG_SPW_PORTS*CFG_SPW_NUM);
    spw_din_p    : in    std_logic_vector(1 to CFG_SPW_PORTS*CFG_SPW_NUM);
    spw_din_n    : in    std_logic_vector(1 to CFG_SPW_PORTS*CFG_SPW_NUM);
    spw_sin_p    : in    std_logic_vector(1 to CFG_SPW_PORTS*CFG_SPW_NUM);
    spw_sin_n    : in    std_logic_vector(1 to CFG_SPW_PORTS*CFG_SPW_NUM);
      --CAN signals
    can_tx          : out   std_logic_vector(1 downto 0);
    can_rx          : in    std_logic_vector(1 downto 0);
    can_stb         : out   std_logic_vector(1 downto 0);--connected to gnd by
                                                         --the pad
    -- RS-485 interfaces
    uart485_rsde         : out std_logic_vector(1 downto 0);  -- RS-485 UART driver enable
    uart485_rsre         : out std_logic_vector(1 downto 0);  -- RS-485 UART receiver enable
    uart485_rstx         : out std_logic_vector(1 downto 0);  -- RS-485 UART tx data
    uart485_rsrx         : in std_logic_vector(1 downto 0);   -- RS-485 UART rx data
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

architecture rtl of pads is
  -----------------------------------------------------
  -- Componants ---------------------------------------
  -----------------------------------------------------
  component IBUFDS
    generic (
      DQS_BIAS   : string := "FALSE";
      IOSTANDARD : string := "DEFAULT"
      );
    port (
      O  : out std_ulogic;
      I  : in  std_ulogic;
      IB : in  std_ulogic
    );
  end component;

  -----------------------------------------------------
  -- Constants ----------------------------------------
  -----------------------------------------------------
  constant CPU_FREQ : integer := board_freq * CFG_CLKMUL / CFG_CLKDIV;  -- cpu frequency in KHz(100000)

  -----------------------------------------------------
  -- Signals ------------------------------------------
  -----------------------------------------------------

  signal vcc, gnd                            : std_ulogic;
  signal dsu_en, dsubreak, dsu_sel, cpu0errn : std_ulogic;
  signal rstn, lock                          : std_ulogic;
  signal lbtn                                : std_logic_vector(3 downto 0);
  signal lsw                                 : std_logic_vector(2 downto 0);

  signal lclk : std_ulogic;
  signal rst  : std_ulogic;

  -- APB UART
  signal u1i : uart_in_type;
  signal u1o : uart_out_type;

  -- AHB UART
  signal dui : uart_in_type;
  signal duo : uart_out_type;

  signal dsurx_int   : std_ulogic;
  signal dsutx_int   : std_ulogic;
  signal dsuctsn_int : std_ulogic;
  signal dsurtsn_int : std_ulogic;

  -- GPIOs
  signal gpioi : gpio_in_type;
  signal gpioo : gpio_out_type;

  -- Ethernet
  signal sgmiii   : eth_sgmii_in_type;
  signal sgmiio   : eth_sgmii_out_type;
  signal sgmiirst : std_ulogic;

  -- SpaceWire
  signal spwo : grspw_out_type_vector(0 to CFG_SPW_NUM - 1);
  signal dtmp : std_logic_vector(0 to CFG_SPW_PORTS * CFG_SPW_NUM - 1);
  signal stmp : std_logic_vector(0 to CFG_SPW_PORTS * CFG_SPW_NUM - 1);

    --CAN signals
  signal cani1, cani2 : canfd_in_type;
  signal cano1, cano2 : canfd_out_type;

  -- RS-485 APBUART
  signal uart485_i : uart_in_vector_type(1 downto 0);
  signal uart485_o : uart_out_vector_type(1 downto 0);
  signal uart485_rsre_n   : std_logic_vector(1 downto 0); 

begin


  vcc <= '1';
  gnd <= '0';
  ----------------------------------------------------------------------
  ---Clock PAD ---------------------------------------------------------
  ----------------------------------------------------------------------
  clk_check : if (CFG_MIG_7SERIES = 0) generate    
      clk_vup : if fabtech = virtexup generate
        clk_pad : clkpad_ds
          generic map (tech => padtech, level => sstl12_dci, voltage => x12v)
          port map (clkinp, clkinn, lclk);
      end generate clk_vup;
  end generate clk_check;
  ----------------------------------------------------------------------
  ---RESET PAD ---------------------------------------------------------
  ----------------------------------------------------------------------

  reset_pad : inpad
    generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (reset, rst);

  ----------------------------------------------------------------------
  ---BUTTON PADs ------------------------------------------------------
  ----------------------------------------------------------------------
  -- Button 0 to 3(SW6, SW7, SW17) are not used at present
  button_pads : for i in 0 to 3 generate
    btn_pad : inpad
      generic map (tech => padtech, level => cmos, voltage => x18v)
      port map (button(i), lbtn(i));
  end generate;
  -- SW10 - GPIO_SW_N
  dsubre_pad : inpad
    generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (button(4), dsubreak);

  ----------------------------------------------------------------------
  ---switch PADs ------------------------------------------------------
  ----------------------------------------------------------------------
  -- DIP switch 0 to 2 are not used at present
  switch_pads : for i in 0 to 2 generate
    sw_pad : inpad
      generic map (tech => padtech, level => cmos, voltage => x12v)
      port map (switch(i), lsw(i));
  end generate;
  -- Route debug AHB UART output to APB UART(Console UART) based on dsu_sel signal(from switch 3) value.
  sw3_pad : inpad
    generic map (tech => padtech, level => cmos, voltage => x12v)
    port map (switch(3), dsu_sel);
  -- Can map dsu_en to a switch if needed
  dsu_en <= '1';

  ----------------------------------------------------------------------
  --- LED PADs ---------------------------------------------------------
  ----------------------------------------------------------------------

  led0_pad : outpad generic map (tech => padtech, level => cmos, voltage => x12v)
    port map (led(0), rstn);
  led1_pad : outpad generic map (tech => padtech, level => cmos, voltage => x12v)
    port map (led(1), lock);
  led2_pad : outpad generic map (tech => padtech, level => cmos, voltage => x12v)
    port map (led(2), dsu_en);
  led3_pad : outpad generic map (tech => padtech, level => cmos, voltage => x12v)
    port map (led(3), dsu_sel);
  led4_pad : outpad generic map (tech => padtech, level => cmos, voltage => x12v)
    port map (led(4), dsubreak);
  led5_pad : outpad generic map (tech => padtech, level => cmos, voltage => x12v)
    port map (led(5), cpu0errn);
  led_pads : for i in 6 to 7 generate
    led_pad : outpad generic map (tech => padtech, level => cmos, voltage => x12v)
      port map (led(i), gnd);
  end generate;


  ----------------------------------------------------------------------
  --- UART MUXING & PADs -----------------------------------------------
  ----------------------------------------------------------------------
  dsutx_int   <= duo.txd     when dsu_sel = '1' else u1o.txd;
  dui.rxd     <= dsurx_int   when dsu_sel = '1' else '1';
  dsurtsn_int <= duo.rtsn    when dsu_sel = '1' else u1o.rtsn;
  dui.ctsn    <= dsuctsn_int when dsu_sel = '1' else '1';
  u1i.rxd     <= dsurx_int   when dsu_sel = '0' else '1';
  u1i.ctsn    <= dsuctsn_int when dsu_sel = '0' else '1';
  dsurx_pad : inpad
    generic map (level => cmos, voltage => x18v, tech => padtech)
    port map (uart_rx, dsurx_int);
  dsutx_pad : outpad
    generic map (level => cmos, voltage => x18v, tech => padtech)
    port map (uart_tx, dsutx_int);
  dsuctsn_pad : inpad
    generic map (level => cmos, voltage => x18v, tech => padtech)
    port map (uart_ctsn, dsuctsn_int);
  dsurtsn_pad : outpad
    generic map (level => cmos, voltage => x18v, tech => padtech)
    port map (uart_rtsn, dsurtsn_int);

  ----------------------------------------------------------------------
  --- GPIO PADs --------------------------------------------------------
  ----------------------------------------------------------------------
--  pio_pads : for i in 0 to 15 generate
--    gpio_pad : iopad generic map (tech => padtech, level => cmos, voltage => x12v, strength => 8)
--      port map (gpio(i), gpioo.dout(i), gpioo.oen(i), gpioi.din(i));
--  end generate;
  -- Tie-off alternative output enable signals
--  gpioi.sig_en <= (others => '0');
--  gpioi.sig_in <= (others => '0');

  ----------------------------------------------------------------------
  --- Ethernet PADs ----------------------------------------------------
  ----------------------------------------------------------------------
  eth_pad_gen : if CFG_GRETH = 1 generate
    emdio_pad : iopad generic map (tech => padtech, level => cmos, voltage => x18v)
      port map (emdio, sgmiio.mdio_o, sgmiio.mdio_oe, sgmiii.mdio_i);

    emdc_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
      port map (emdc, sgmiio.mdc);

    eint_pad : inpad generic map (tech => padtech, level => cmos, voltage => x18v)
      port map (eint, sgmiii.mdint);

    erst_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
      port map (erst, sgmiio.reset);
    sgmiii.clkp <= gtrefclk_p;
    sgmiii.clkn <= gtrefclk_n;
    txp         <= sgmiio.txp;
    txn         <= sgmiio.txn;
    sgmiii.rxp  <= rxp;
    sgmiii.rxn  <= rxn;

  end generate eth_pad_gen;

  no_eth_pad : if CFG_GRETH = 0 generate
    tx_outpad : outpad_ds
      generic map (padtech, hstl_i_18, x18v)
      port map (txp, txn, gnd, gnd);

    emdio_pad : iopad generic map (tech => padtech, level => cmos, voltage => x18v)
      port map (emdio, gnd, gnd, open);

    emdc_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
      port map (emdc, gnd);

    erst_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
      port map (erst, gnd);
  end generate no_eth_pad;

  ----------------------------------------------------------------------
  --- SpaceWire PADs ---------------------------------------------------
  ----------------------------------------------------------------------
  spw_pad : if CFG_SPW_EN /= 0 generate

    spw_nolb : if CFG_SPW_LB = 0 generate

      spw_pad_loop : for i in 0 to CFG_SPW_NUM - 1 generate
        -- SpaceWire Pads
        spw_txd_pad : outpad_ds generic map (padtech, lvds, x18v)
          port map (spw_dout_p(i * CFG_SPW_PORTS + 1),
                    spw_dout_n(i * CFG_SPW_PORTS + 1),
                    spwo(i).d(0), gnd);

        spw_txs_pad : outpad_ds generic map (padtech, lvds, x18v)
          port map (spw_sout_p(i * CFG_SPW_PORTS + 1),
                    spw_sout_n(i * CFG_SPW_PORTS + 1),
                    spwo(i).s(0), gnd);

        spwsampling : if CFG_SPW_INPUT = 3 generate
          -- SpaceWire inputs are sampling, propagate receive data and strobe
          spw_rxd_pad : inpad_ds generic map (padtech, lvds, x18v)
            port map (spw_din_p(i*CFG_SPW_PORTS+1),
                      spw_din_n(i*CFG_SPW_PORTS+1),
                      dtmp(i*CFG_SPW_PORTS));
          spw_rxs_pad : inpad_ds generic map (padtech, lvds, x18v)
            port map (spw_sin_p(i*CFG_SPW_PORTS+1),
                      spw_sin_n(i*CFG_SPW_PORTS+1),
                      stmp(i*CFG_SPW_PORTS));
        end generate spwsampling;

        dualport : if CFG_SPW_PORTS = 2 generate
  
          spwr_txd_pad : outpad_ds generic map (padtech, lvds, x18v)
            port map (spw_dout_p(i * CFG_SPW_PORTS + 2),
                      spw_dout_n(i * CFG_SPW_PORTS + 2),
                      spwo(i).d(1), gnd);

          spwr_txs_pad : outpad_ds generic map (padtech, lvds, x18v)
            port map (spw_sout_p(i * CFG_SPW_PORTS + 2),
                      spw_sout_n(i * CFG_SPW_PORTS + 2),
                      spwo(i).s(1), gnd);

          spwrsampling : if CFG_SPW_INPUT = 3 generate

            -- SpaceWire inputs are sampling, propate receive data and strobe
            spwr_rxd_pad : IBUFDS generic map (DQS_BIAS => "FALSE", IOSTANDARD => "LVDS")
              port map (
                o  => dtmp(i * CFG_SPW_PORTS + 1),
                i  => spw_din_p(i * CFG_SPW_PORTS + 2),
                ib => spw_din_n(i * CFG_SPW_PORTS + 2)
              );

            spwr_rxs_pad : IBUFDS generic map (DQS_BIAS => "FALSE", IOSTANDARD => "LVDS")
              port map (
                o  => stmp(i * CFG_SPW_PORTS + 1),
                i  => spw_sin_p(i * CFG_SPW_PORTS + 2),
                ib => spw_sin_n(i * CFG_SPW_PORTS + 2)
              );

          end generate spwrsampling;

        end generate dualport;

      end generate spw_pad_loop;

    end generate spw_nolb;
    -- loopback
    spw_lb : if CFG_SPW_LB = 1 generate
      dtmp(0) <= spwo(1).d(0);
      stmp(0) <= spwo(1).s(0);
      dtmp(1) <= spwo(0).d(0);
      stmp(1) <= spwo(0).s(0);
      dtmp(2) <= spwo(3).d(0);
      stmp(2) <= spwo(3).s(0);
      dtmp(3) <= spwo(2).d(0);
      stmp(3) <= spwo(2).s(0);
    end generate spw_lb;

  end generate spw_pad;

  no_spw_pad : if (CFG_SPW_EN = 0 or CFG_SPW_LB = 1) generate

    spw_pad_loop : for i in 0 to CFG_SPW_NUM - 1 generate
      -- SpaceWire Pads
      spw_txd_pad : outpad_ds generic map (padtech, lvds, x18v)
        port map (spw_dout_p(i * CFG_SPW_PORTS + 1),
                  spw_dout_n(i * CFG_SPW_PORTS + 1),
                  gnd, gnd);

      spw_txs_pad : outpad_ds generic map (padtech, lvds, x18v)
        port map (spw_sout_p(i * CFG_SPW_PORTS + 1),
                  spw_sout_n(i * CFG_SPW_PORTS + 1),
                  gnd, gnd);

      dualport : if CFG_SPW_PORTS = 2 generate
 
        spwr_txd_pad : outpad_ds generic map (padtech, lvds, x18v)
          port map (spw_dout_p(i * CFG_SPW_PORTS + 2),
                    spw_dout_n(i * CFG_SPW_PORTS + 2),
                    gnd, gnd);

        spwr_txs_pad : outpad_ds generic map (padtech, lvds, x18v)
          port map (spw_sout_p(i * CFG_SPW_PORTS + 2),
                    spw_sout_n(i * CFG_SPW_PORTS + 2),
                    gnd, gnd);

      end generate dualport;
    end generate spw_pad_loop;

  end generate no_spw_pad;


  ----------------------------------------------------------------------
  --- GRCANFD ----------------------------------------------------------
  ----------------------------------------------------------------------
  
  grcanfd1_pad: if CFG_GRCANFD1 = 1  generate

    cantx0_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
       port map (can_tx(0), cano1.tx(0));
    canrx0_pad : inpad  generic map (tech => padtech, level => cmos, voltage => x18v)
       port map (can_rx(0), cani1.rx(0));
    canstb0_pad : outpad  generic map (tech => padtech, level => cmos, voltage => x18v)
       port map (can_stb(0), gnd);

  end generate grcanfd1_pad;
  
  grcanfd2_pad: if CFG_GRCANFD2 = 1  generate
  
    cantx1_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
       port map (can_tx(1), cano2.tx(0));
    canrx1_pad : inpad  generic map (tech => padtech, level => cmos, voltage => x18v)
       port map (can_rx(1), cani2.rx(0));
    canstb1_pad : outpad  generic map (tech => padtech, level => cmos, voltage => x18v)
       port map (can_stb(1), gnd);

  end generate grcanfd2_pad;


----------------------------------------------------------------------
---  RS-485 UARTs  ---------------------------------------------------
----------------------------------------------------------------------
  rs485_en : if (CFG_UART2_ENABLE /= 0) generate
    rs485_apbuart_loop : for i in 1 downto 0 generate

      uart485_i(i).extclk <= '0';
      -- RS-485 UART driver enable
      uart485_rsde_pad : outpad generic map (tech    => padtech,
                                             level   => cmos,
                                             voltage => x18v)
                                port map (pad => uart485_rsde(i),
                                          i   => uart485_o(i).txen);

      -- RS-485 UART receiver enable
      uart485_rsre_n(i) <= not uart485_o(i).rxen; -- RS-485 UART receiver enable is active low

      uart485_rsre_pad : outpad generic map (tech    => padtech,
                                             level   => cmos,
                                             voltage => x18v)
                                port map (pad => uart485_rsre(i),
                                          i   => uart485_rsre_n(i));

      uart485_rxd2_pad : inpad generic map (tech    => padtech,
                                            level   => cmos,
                                            voltage => x18v)
                               port map (pad => uart485_rsrx(i),
                                         o   => uart485_i(i).rxd);

      uart485_txd2_pad : outpad generic map (tech    => padtech,
                                             level   => cmos,
                                             voltage => x18v)
                                port map (pad => uart485_rstx(i),
                                          i   => uart485_o(i).txd);
    end generate;
  end generate;




  ----------------------------------------------------------------------
  --- Core instantiation -----------------------------------------------
  ----------------------------------------------------------------------

  core0 : entity work.selene_core
    generic map (
      fabtech         => fabtech,
      memtech         => memtech,
      padtech         => padtech,
      clktech         => clktech,
      cpufreq         => CPU_FREQ,
      disas           => CFG_DISAS,
      board_freq      => board_freq,
      migmodel        => migmodel,
      autonegotiation => autonegotiation,
      simulation      => simulation
      ) 
    port map (
      -- Clock and Reset
      rst          => rst,
      clkinp       => clkinp,
      clkinn       => clkinn,
      lclk         => lclk,
      cpu0errn     => cpu0errn,
      dsuen        => dsu_en,
      lock         => lock,
      rstn_out     => rstn,
      dsubreak     => dsubreak,
      -- AHBUART
      dui          => dui,
      duo          => duo,
      -- APBUART
      u1i          => u1i,
      u1o          => u1o,
      -- GPIO
--      gpio_i       => gpioi,
      gpio_i.din  => (others => '0'),
      gpio_i.sig_in => (others => '0'),
      gpio_i.sig_en => (others => '0'),
      gpio_o       => open, --gpioo,
      -- Ethernet
      sgmiii       => sgmiii,
      sgmiio       => sgmiio,
      --AHBJTAG
      tck          => tck,
      tms          => tms,
      tdi          => tdi,
      tdo          => tdo,
      trst         => trst,
      -- Spacewire
      spwo         => spwo,
      dtmp         => dtmp,
      stmp         => stmp,
      --CAN signals
      cani1      => cani1,
      cani2      => cani2,
      cano1      => cano1,
      cano2      => cano2,
      -- RS-485 APBUART
      uart485_i      => uart485_i,
      uart485_o      => uart485_o,
      -- DDR4 (MIGs)
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
      --ddr4_alert_n: in    std_ulogic;                   -- Alert Output
      ddr4_odt     => ddr4_odt,
      ddr4_par     => ddr4_par,
      ddr4_ten     => ddr4_ten,
      ddr4_cs_n    => ddr4_cs_n,
      ddr4_reset_n => ddr4_reset_n
      --FOR TESTING
      -- pragma translate_off
      ,
      io_atmi      => io_atmi,
      io_atmo      => io_atmo,
      dbg_atmi     => dbg_atmi,
      dbg_atmo     => dbg_atmo
     -- pragma translate_on
      );
end;

