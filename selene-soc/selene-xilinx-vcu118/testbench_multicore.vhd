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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

library gaisler;
use gaisler.libdcom.all;
use gaisler.jtagtst.all;
use gaisler.sim.all;

library grlib;
use grlib.config_types.all;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.stdlib.tost;

use grlib.stdio.all;
use grlib.devices.all;
use gaisler.ahbtbp.all;
use gaisler.spacewire.all;
use gaisler.canfd.all;

use grlib.testlib.check;
library techmap;
use techmap.gencomp.all;
library work;
use work.debug.all;
use work.config.all;
use work.selene.all;

entity testbench is
  generic(
    fabtech : integer := CFG_FABTECH;
    memtech : integer := CFG_MEMTECH;
    padtech : integer := CFG_PADTECH;
    clktech : integer := CFG_CLKTECH;
    disas   : integer := CFG_DISAS;
    vmode   : boolean := false; -- extra print-outs
    dbguart : integer := CFG_DUART; -- Print UART on console
    USE_MIG_INTERFACE_MODEL : boolean := false 
  -- True       - Use an AHBRAM as main memory located at 16#400#
  -- False      - Use the MIG simulation model
    );
end;

architecture behav of testbench is

  -----------------------------------------------------
  -- Components ---------------------------------------
  -----------------------------------------------------

  component ddr4_wrap
    generic(
      CONFIGURED_DQ_BITS  : natural
      );
    port(
      CK        : in    std_logic_vector(1 downto 0);
      ACT_n     : in    std_logic;
      RAS_n_A16 : in    std_logic;
      CAS_n_A15 : in    std_logic;
      WE_n_A14  : in    std_logic;
      ALERT_n   : out   std_logic;
      PARITY    : in    std_logic;
      RESET_n   : in    std_logic;
      TEN       : in    std_logic;
      CS_n      : in    std_logic;
      CKE       : in    std_logic;
      ODT       : in    std_logic;
      C         : in    std_logic_vector(2 downto 0);
      BG        : in    std_logic_vector(0 downto 0);
      BA        : in    std_logic_vector(1 downto 0);
      ADDR      : in    std_logic_vector(13 downto 0);
      ADDR_17   : in    std_logic;
      DM_n      : in    std_logic_vector(7 downto 0);
      DQ        : inout std_logic_vector(63 downto 0);
      DQS_t     : inout std_logic_vector(7 downto 0);
      DQS_c     : inout std_logic_vector(7 downto 0);
      ZQ        : in    std_logic;
      PWR       : in    std_logic;
      VREF_CA   : in    std_logic;
      VREF_DQ   : in    std_logic
      );  
  end component ddr4_wrap;

  -----------------------------------------------------
  -- Constant -----------------------------------------
  -----------------------------------------------------

  constant promfile  : string := "prom.srec"; -- rom contents
  constant ramfile   : string := "ram.srec"; -- ram contents
  constant simulation : boolean := true;
  constant autonegotiation     : integer := 1; 
  -----------------------------------------------------
  -- Signals ------------------------------------------
  -----------------------------------------------------

  signal clk            : std_logic := '0';
  signal system_rst     : std_ulogic;

  signal gnd            : std_ulogic := '0';
  signal vcc            : std_ulogic := '1';
  signal nc             : std_ulogic := 'Z';

  signal clk250p        : std_ulogic := '0';
  signal clk250n        : std_ulogic := '1';
  signal clk125p        : std_ulogic := '0';
  signal clk125n        : std_ulogic := '1';

  signal txd1           : std_ulogic;
  signal rxd1           : std_ulogic;
  signal ctsn1          : std_ulogic;
  signal rtsn1          : std_ulogic;

  signal iic_scl        : std_ulogic;
  signal iic_sda        : std_ulogic;
  signal iic_mreset     : std_ulogic;

  signal switch         : std_logic_vector(3 downto 0);
  signal uart485_rsde   : std_logic_vector(1 downto 0);  -- RS-485 UART driver enable
  signal uart485_rsre   : std_logic_vector(1 downto 0);  -- RS-485 UART receiver enable
  signal uart485_rstx   : std_logic_vector(1 downto 0);  -- RS-485 UART tx data
  signal uart485_rsrx   : std_logic_vector(1 downto 0);   -- RS-485 UART rx data
  signal led            : std_logic_vector(7 downto 0);
  signal button         : std_logic_vector(4 downto 0);

  signal phy_mii_data   : std_logic;
  signal phy_tx_clk     : std_ulogic;
  signal phy_rx_clk     : std_ulogic;
  signal phy_rx_data    : std_logic_vector(7 downto 0);
  signal phy_dv         : std_ulogic;
  signal phy_rx_er      : std_ulogic;
  signal phy_col        : std_ulogic;
  signal phy_crs        : std_ulogic;
  signal phy_tx_data    : std_logic_vector(7 downto 0);
  signal phy_tx_en      : std_ulogic;
  signal phy_tx_er      : std_ulogic;
  signal phy_mii_clk    : std_ulogic;
  signal phy_rst_n      : std_ulogic;
  signal phy_gtx_clk    : std_ulogic;
  signal phy_mii_int_n  : std_ulogic;

  signal clkethp         : std_ulogic := '0';
  signal clkethn         : std_ulogic := '1';
  signal txp_eth        : std_ulogic;
  signal txn_eth        : std_ulogic;
  signal phy_mdio       : std_logic;
  signal phy_mdc        : std_ulogic;

  signal dsutx          : std_ulogic;
  signal dsurx          : std_ulogic;
  signal dsuctsn        : std_ulogic;
  signal dsurtsn        : std_ulogic;

  signal ddr4_ck        : std_logic_vector(1 downto 0);
  signal ddr4_dq        : std_logic_vector(63 downto 0);
  signal ddr4_dqs_c     : std_logic_vector(7 downto 0);
  signal ddr4_dqs_t     : std_logic_vector(7 downto 0);
  signal ddr4_addr      : std_logic_vector(13 downto 0);
  signal ddr4_ras_n     : std_logic;
  signal ddr4_cas_n     : std_logic;
  signal ddr4_we_n      : std_logic;
  signal ddr4_ba        : std_logic_vector(1 downto 0);
  signal ddr4_bg        : std_logic_vector(0 downto 0);
  signal ddr4_dm_n      : std_logic_vector(7 downto 0);
  signal ddr4_ck_c      : std_logic_vector(0 downto 0);
  signal ddr4_ck_t      : std_logic_vector(0 downto 0);
  signal ddr4_cke       : std_logic_vector(0 downto 0);
  signal ddr4_act_n     : std_logic;
  --signal ddr4_alert_n   : std_logic;
  signal ddr4_odt       : std_logic_vector(0 downto 0);
  signal ddr4_par       : std_logic;
  signal ddr4_ten       : std_logic;
  signal ddr4_cs_n      : std_logic_vector(0 downto 0);
  signal ddr4_reset_n   : std_logic;

  -- Signals to STAR-Dundee mezzanine
  signal spw_dout_p : std_logic_vector(1 to CFG_SPW_PORTS*CFG_SPW_NUM);
  signal spw_dout_n : std_logic_vector(1 to CFG_SPW_PORTS*CFG_SPW_NUM);
  signal spw_sout_p : std_logic_vector(1 to CFG_SPW_PORTS*CFG_SPW_NUM);
  signal spw_sout_n : std_logic_vector(1 to CFG_SPW_PORTS*CFG_SPW_NUM);
  signal spw_din_p  : std_logic_vector(1 to CFG_SPW_PORTS*CFG_SPW_NUM);
  signal spw_din_n  : std_logic_vector(1 to CFG_SPW_PORTS*CFG_SPW_NUM);
  signal spw_sin_p  : std_logic_vector(1 to CFG_SPW_PORTS*CFG_SPW_NUM);
  signal spw_sin_n  : std_logic_vector(1 to CFG_SPW_PORTS*CFG_SPW_NUM);

    -- signal GRCANFD: CAN Interface
  signal can_tx          :   std_logic_vector(1 downto 0);
  signal can_rx          :    std_logic_vector(1 downto 0);
  signal can_stb         :   std_logic_vector(1 downto 0);--connected to gnd by
                                                         --the pad

  -- Testbench Related Signals
  signal dsurst         : std_ulogic;
  signal errorn         : std_logic;

  signal io_atm_ctrl   : ahbtb_ctrl_type;
  signal atm_ctrl      : ahbtb_ctrl_type;



begin

  -----------------------------------------------------
  -- Clocks and Reset ---------------------------------
  ----------------------------------------------------

  clk250p <= not clk250p after 2 ns;
  clk250n <= not clk250n after 2 ns;
  clk125p <= not clk125p after 4 ns; -- clkethp
  clk125n <= not clk125p after 4 ns; -- clkethn
  clkethp <= not clkethp after 0.8 ns; --625MHz
  clkethn <= not clkethn after 0.8 ns;

  system_rst    <= not dsurst;
  
  ddr4_ck       <= clk250n & clk250p;


  -----------------------------------------------------
  -- Misc ---------------------------------------------
  -----------------------------------------------------

  errorn        <= 'H'; -- ERROR pull-up
  switch(2 downto 0) <= (2 => '1', others => '0');
  button <= (others => '0');
  

  -----------------------------------------------------
  -- Top ----------------------------------------------
  -----------------------------------------------------

  cpu : entity work.selene_soc
    generic map(
      fabtech                 => fabtech,
      memtech                 => memtech,
      padtech                 => padtech,
      clktech                 => clktech,
      dbguart                 => dbguart,
      simulation              => simulation,
      autonegotiation         => autonegotiation,
      migmodel                => USE_MIG_INTERFACE_MODEL
      )
    port map(
      reset             => system_rst,
      clk250p           => clk250p,
      clk250n           => clk250n,
      switch            => switch,
      led               => led,
      --gpio              => gpio,
      gtrefclk_p        => clkethp,
      gtrefclk_n        => clkethn,
      txp               => txp_eth,
      txn               => txn_eth,
      rxp               => txp_eth,
      rxn               => txn_eth,
      emdio             => phy_mdio,
      emdc              => phy_mdc,
      eint              => '0',
      erst              => OPEN,
      dsurx             => dsurx,
      dsutx             => dsutx,
      dsuctsn           => dsuctsn,
      dsurtsn           => dsurtsn,
      button            => button,
      -- Spacewire
      spw_dout_p        => spw_dout_p, 
      spw_dout_n        => spw_dout_n, 
      spw_sout_p        => spw_sout_p, 
      spw_sout_n        => spw_sout_n, 
      spw_din_p         => spw_din_p, 
      spw_din_n         => spw_din_n, 
      spw_sin_p         => spw_sin_p, 
      spw_sin_n         => spw_sin_n, 
      -- GRCANFD: CAN Interface
      can_tx            => can_tx,
      can_rx            => can_rx,
      can_stb           => can_stb,--connected to gnd by
                             --the pad
    -- RS-485 interfaces
      uart485_rsde      => uart485_rsde,
      uart485_rsre      => uart485_rsre,
      uart485_rstx      => uart485_rstx,
      uart485_rsrx      => uart485_rsrx,
      -- DDR4
      ddr4_dq           => ddr4_dq,
      ddr4_dqs_c        => ddr4_dqs_c,
      ddr4_dqs_t        => ddr4_dqs_t,
      ddr4_addr         => ddr4_addr,
      ddr4_ras_n        => ddr4_ras_n,
      ddr4_cas_n        => ddr4_cas_n,
      ddr4_we_n         => ddr4_we_n,
      ddr4_ba           => ddr4_ba,
      ddr4_bg           => ddr4_bg,
      ddr4_dm_n         => ddr4_dm_n,
      ddr4_ck_c         => ddr4_ck_c,
      ddr4_ck_t         => ddr4_ck_t,
      ddr4_cke          => ddr4_cke,
      ddr4_act_n        => ddr4_act_n,
      --ddr4_alert_n      => ddr4_alert_n,
      ddr4_odt          => ddr4_odt,
      ddr4_par          => ddr4_par,
      ddr4_ten          => ddr4_ten, 
      ddr4_cs_n         => ddr4_cs_n, 
      ddr4_reset_n      => ddr4_reset_n,
      io_atmi           => io_atm_ctrl.i,
      io_atmo           => io_atm_ctrl.o,
      atmi              => atm_ctrl.i,
      atmo              => atm_ctrl.o
      );

  phy0 : if (CFG_GRETH = 1) generate
    --Simulation model for SGMII PHY MDIO interface 
   phy_mdio <= 'H';
   p0: phy
    generic map (
             address       => 3,
             extended_regs => 1,
             aneg          => 1,
             base100_t4    => 1,
             base100_x_fd  => 1,
             base100_x_hd  => 1,
             fd_10         => 1,
             hd_10         => 1,
             base100_t2_fd => 1,
             base100_t2_hd => 1,
             base1000_x_fd => CFG_GRETH1G,
             base1000_x_hd => CFG_GRETH1G,
             base1000_t_fd => CFG_GRETH1G,
             base1000_t_hd => CFG_GRETH1G,
             rmii          => 0,
             extrxclken    => 1, -- align rx_clk with extrxclk (gmii only)
             gmii100       => 1  -- force 10/100 to (x10/x100 repeating) gmii
    )
    port map(dsurst, phy_mdio, OPEN , OPEN , OPEN ,
             OPEN , OPEN , OPEN , OPEN , "00000000",
             '0', '0', phy_mdc, '0', '0' ); 

  end generate;

  -- Memory model instantiation- MIG IP is being simulated in SoC. Connecting micron DDR4_if interface module.
  gen_mem_model : if (USE_MIG_INTERFACE_MODEL = false) generate
    ddr4mem : if (CFG_MIG_7SERIES = 1) generate
    u1 : ddr4_wrap
      generic map (
      CONFIGURED_DQ_BITS        => 8
      )
    port map (
      ck          => ddr4_ck,
      act_n       => ddr4_act_n,
      ras_n_a16   => ddr4_ras_n,
      cas_n_a15   => ddr4_cas_n,
      we_n_a14    => ddr4_we_n,
      alert_n     => open,
      parity      => ddr4_par,
      reset_n     => ddr4_reset_n,
      ten         => ddr4_ten,
      cs_n        => ddr4_cs_n(0),
      cke         => ddr4_cke(0),
      odt         => ddr4_odt(0),
      c           => "000",
      bg          => ddr4_bg,
      ba          => ddr4_ba,
      addr        => ddr4_addr,
      addr_17     => '0',
      dm_n        => ddr4_dm_n,
      dq          => ddr4_dq,
      dqs_t       => ddr4_dqs_t,
      dqs_c       => ddr4_dqs_c,
      zq          => '0',
      pwr         => '0',
      vref_ca     => '0',
      vref_dq     => '0'
      );
    end generate ddr4mem;
  end generate gen_mem_model;

  -- MIG IP is not being simulated. AXI memory simulation model is being used.
  mig_mem_model : if (USE_MIG_INTERFACE_MODEL = true) generate
    ddr4_dq    <= (others => 'Z');
    ddr4_dqs_c <= (others => 'Z');
    ddr4_dqs_t <= (others => 'Z');
  end generate mig_mem_model;
  -----------------------------------------------------
  -- Process ------------------------------------------
  -----------------------------------------------------

  iuerr : process
  begin
    wait for 5000 ns;
    if to_x01(errorn) = '1' then
      wait on errorn;
    end if;
    assert (to_x01(errorn) = '1')
      report "*** IU in error mode, simulation halted ***"
      severity failure;			-- this should be a failure
  end process;

  dsucom : process
    procedure read_srec(
    fname  : in string := "ram.srec";
    endian : in integer := 1;
    signal tx : out std_logic) is --return mem_type is
    file TCF : text open read_mode is fname;
    --variable mem      : mem_type;
    constant txp      : time := 160 * 1 ns;
    variable L1       : line;   
    variable CH       : character;
    variable ai       : integer := 0;
    variable len      : integer := 0;
    variable rectype  : std_logic_vector(3 downto 0);
    variable recaddr  : std_logic_vector(31 downto 0);
    variable reclen   : std_logic_vector(7 downto 0);
    variable recdata  : std_logic_vector(0 to 16*8-1);
    variable data     : std_logic_vector(31 downto 0);
    variable d        : integer := 1;
    variable wa       : std_logic_vector(31 downto 0);
    begin
      --mem := (others => (others => '0'));

      L1:= new string'("");
      while not endfile(TCF) loop
        readline(TCF,L1);
        if (L1'length /= 0) then  --'
          while (not (L1'length=0)) and (L1(L1'left) = ' ') loop
            std.textio.read(L1,CH);
          end loop;

          if L1'length > 0 then --'
            read(L1, ch);
            if (ch = 'S') or (ch = 's') then
              hread(L1, rectype);
              hread(L1, reclen);
              len := conv_integer(reclen)-1;
              recaddr := (others => '0');
              case rectype is 
                 when "0001" =>
                        hread(L1, recaddr(15 downto 0));
                 when "0010" =>
                        hread(L1, recaddr(23 downto 0));
                 when "0011" =>
                        hread(L1, recaddr);
                 when others => next;
              end case;
              hread(L1, recdata(0 to ((len-4)*8)-1));
              print("A: " & tost(recaddr) & " len: " & tost(len) & " rec: " & tost(recdata));
              --recaddr(31 downto abits+2) := (others => '0');
              ai := conv_integer(recaddr)/4;
              for i in 0 to ((len-4)/4)-1 loop
                if endian = 1 then
                  --mem(ai+i)
                  data      := recdata((i*32 + 24) to (i*32 + 31)) &
                               recdata((i*32 + 16) to (i*32 + 23)) &
                               recdata((i*32 +  8) to (i*32 + 15)) &
                               recdata((i*32 +  0) to (i*32 +  7));
                else
                  --mem(ai+i) 
                  data      := recdata((i*32) to (i*32+31));
                end if;
                print("A: " & tost(recaddr + i*4) & " D: " & tost(data));
                --at_write(recaddr + i*4, data, 32, true , false, 0, d, atmi, atmo);
                
                wa := recaddr + i*4;
                txc(tx, 16#c0#, txp);
                txa(tx, conv_integer(wa(31 downto 24)), conv_integer(wa(23 downto 16)), 
                        conv_integer(wa(15 downto 8)) , conv_integer(wa(7 downto 0)), txp);
                txa(tx, conv_integer(data(31 downto 24)), conv_integer(data(23 downto 16)), 
                        conv_integer(data(15 downto 8)) , conv_integer(data(7 downto 0)), txp);
              end loop;

              if ai = 0 then
                ai := 1;
              end if;
            end if;
          end if;
        end if;
      end loop;
      --return mem;
    end procedure;

    procedure dsucfg(signal dsurx : in std_ulogic; signal dsutx : out std_ulogic) is
      variable w32        : std_logic_vector(31 downto 0);
      variable w32_l      : std_logic_vector(31 downto 0);
      variable w64        : std_logic_vector(63 downto 0);
      variable c8         : std_logic_vector(7 downto 0);
      constant lresp    : boolean := false;

      constant txp : time := 160 * 1 ns;

    begin

      Print("dsucom process starts here");
      dsutx       <= '1';
      dsurst      <= '0';
      switch(3)   <= '0';
      
      if (USE_MIG_INTERFACE_MODEL = false and CFG_MIG_7SERIES = 1) then
        wait for 50 us; -- This is for proper DDR4 behaviour durign init phase not needed durin simulation
      end if;

      wait for 100 us;
      report("Deassert global reset here");
      -- Deassert global reset
      dsurst      <= '1';
      switch(3)   <= '1';

      if (USE_MIG_INTERFACE_MODEL = false and CFG_MIG_7SERIES = 1) then
        wait on led(1) until led(1) = '1';  -- Wait for DDR4 Memory Init ready
      end if;
      report "Start DSU transfer";
      wait for 500 ns;
      txc(dsutx, 16#55#, txp);      -- sync uart
      report "UART synced";
      wait for 10 us;
    end;

    -- AHBUART test
    procedure duart_test(signal dsurx : in std_ulogic; signal dsutx : out std_ulogic) is
      variable w32        : std_logic_vector(31 downto 0);
      variable w32_l      : std_logic_vector(31 downto 0);
      variable w64        : std_logic_vector(63 downto 0);
      variable c8         : std_logic_vector(7 downto 0);
      constant lresp    : boolean := false;

      constant txp : time := 160 * 1 ns;

    begin

        -- Read old value:
        print("[DUART] Reading old value from 0x00000100");
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#00#, 16#00#, 16#01#, 16#00#, txp);
        rxi(dsurx, w32_l, txp, lresp);
        print("[DUART] Value at [0x00000100]: " & tost(w32_l));

        -- Write: 
        print("[DUART] Write 0x00AAAAAA to 0x00000100");
        txc(dsutx, 16#c0#, txp);
        txa(dsutx, 16#00#, 16#00#, 16#01#, 16#00#, txp);
        txa(dsutx, 16#00#, 16#AA#, 16#AA#, 16#AA#, txp);

        -- Read:
        print("[DUART] Read sequence check");
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#00#, 16#00#, 16#01#, 16#00#, txp);
        rxi(dsurx, w32, txp, lresp);
        print("[DUART] read[0x00000100]: " & tost(w32));

        -- Write old value back
        print("[DUART] Writing old value back");
        txc(dsutx, 16#c0#, txp);
        txa(dsutx, 16#00#, 16#00#, 16#01#, 16#00#, txp);
        txa(dsutx,  conv_integer(w32_l(31 downto 24)), conv_integer(w32_l(23 downto 16)), 
                    conv_integer(w32_l(15 downto 8)) , conv_integer(w32_l(7 downto 0)), txp);

        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#00#, 16#00#, 16#01#, 16#00#, txp);
        rxi(dsurx, w32, txp, lresp);
        print("[DUART] Value written back at [0x00000100]: " & tost(w32));

        -- Repeat the same for next address
        -- Read old value:
        print("[DUART] Reading old value from 0x00000108");
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#00#, 16#00#, 16#01#, 16#08#, txp);
        rxi(dsurx, w32_l, txp, lresp);
        print("[DUART] Value at [0x00000108]: " & tost(w32_l));

        -- Write: 
        print("[DUART] Write 0x00BBBBBB to 0x00000108");
        txc(dsutx, 16#c0#, txp);
        txa(dsutx, 16#00#, 16#00#, 16#01#, 16#08#, txp);
        txa(dsutx, 16#00#, 16#BB#, 16#BB#, 16#BB#, txp);

        -- Read:
        print("[DUART] Read sequence check");
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#00#, 16#00#, 16#01#, 16#08#, txp);
        rxi(dsurx, w32, txp, lresp);
        print("[DUART] read[0x00000108]: " & tost(w32));

        -- Write old value back
        print("[DUART] Writing old value back");
        txc(dsutx, 16#c0#, txp);
        txa(dsutx, 16#00#, 16#00#, 16#01#, 16#08#, txp);
        txa(dsutx,  conv_integer(w32_l(31 downto 24)), conv_integer(w32_l(23 downto 16)), 
                    conv_integer(w32_l(15 downto 8)) , conv_integer(w32_l(7 downto 0)), txp);

        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#00#, 16#00#, 16#01#, 16#08#, txp);
        rxi(dsurx, w32, txp, lresp);
        print("[DUART] Value written back at [0x00000108]: " & tost(w32));

      
      print("[DUSRT] End of UART Debug Communication Link Test");
      wait for 50 us;
      
      --wait;
    end;


    procedure spw_link_start(signal dsurx : in std_ulogic; signal dsutx : out std_ulogic) is
      variable w32        : std_logic_vector(31 downto 0);
      variable w64        : std_logic_vector(63 downto 0);
      variable c8         : std_logic_vector(7 downto 0);
      constant lresp    : boolean := false;

      constant txp : time := 160 * 1 ns;

    begin

      Print("SPW link start test");
      report "Start SPW links";
      wait for 10 ns;
 
      -- Write: 
      print("[SPW0] Enable auto and link start");
      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FC#, 16#00#, 16#06#, 16#00#, txp);
      txa(dsutx, 16#00#, 16#00#, 16#00#, 16#06#, txp);
  
      print("[SPW1] Enable auto and link start");
      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FC#, 16#00#, 16#07#, 16#00#, txp);
      txa(dsutx, 16#00#, 16#00#, 16#00#, 16#06#, txp);

      --print("[SPW2] Enable auto and link start");
      --txc(dsutx, 16#c0#, txp);
      --txa(dsutx, 16#80#, 16#00#, 16#08#, 16#00#, txp);
      --txa(dsutx, 16#00#, 16#00#, 16#00#, 16#06#, txp);

      --print("[SPW3] Enable auto and link start");
      --txc(dsutx, 16#c0#, txp);
      --txa(dsutx, 16#80#, 16#00#, 16#09#, 16#00#, txp);
      --txa(dsutx, 16#00#, 16#00#, 16#00#, 16#06#, txp);

      print("[SPW] Complete Write sequence");
  
  
      -- Read:
      print("[SPW] Start Read sequence check");

      txc(dsutx, 16#80#, txp);
      txa(dsutx, 16#FC#, 16#00#, 16#06#, 16#04#, txp);
      rxi(dsurx, w32, txp, lresp);
      print("[SPW0] read[0xFC000604]: " & tost(w32));

      txc(dsutx, 16#80#, txp);
      txa(dsutx, 16#FC#, 16#00#, 16#07#, 16#04#, txp);
      rxi(dsurx, w32, txp, lresp);
      print("[SPW1] read[0xFC000704]: " & tost(w32));

      --txc(dsutx, 16#80#, txp);
      --txa(dsutx, 16#80#, 16#00#, 16#08#, 16#04#, txp);
      --rxi(dsurx, w32, txp, lresp);
      --print("[SPW2] read[0x80000804]: " & tost(w32));

      --txc(dsutx, 16#80#, txp);
      --txa(dsutx, 16#80#, 16#00#, 16#09#, 16#04#, txp);
      --rxi(dsurx, w32, txp, lresp);
      --print("[SPW3] read[0x80000904]: " & tost(w32));

      
      print("[SPW] End of SPW Link start routine!");
      wait for 10 us;
      
      --wait;
    end;

    procedure dm_reg_write (
      signal dsurx : in std_ulogic; 
      signal dsutx : out std_ulogic;
      variable regno : in  std_logic_vector(15 downto 0);
      variable data  : in  std_logic_vector(31 downto 0) ) is

      variable tmp : std_logic_vector(31 downto 0);
      variable cmd : std_logic_vector(31 downto 0);
      -- TB variables
      variable TP       : boolean := true;
      variable Screen   : boolean := false;
      constant txp      : time := 160 * 1 ns;
      constant lresp    : boolean := false;
    begin
      cmd :=x"00" & -- cmdtype
            '0' &
            "011" & -- aarsize
            '0' &   -- aarpostincrement
            '0' &   -- postexec
            '1' &   -- transfer
            '1' &   -- write
            regno;  -- regno

      print("Write:" & tost(cmd) & " " & tost(data));
      -- Write data to Abstract Data 0 buffer
      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#10#, txp);
      txa(dsutx, conv_integer(data(31 downto 24)), conv_integer(data(23 downto 16)),
                 conv_integer(data(15 downto 8)), conv_integer(data(7 downto 0)), txp);  
      -- Write command to Abstract Command
      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#5c#, txp);
      txa(dsutx, conv_integer(cmd(31 downto 24)), conv_integer(cmd(23 downto 16)),
                 conv_integer(cmd(15 downto 8)), conv_integer(cmd(7 downto 0)), txp);  
      --at_write(dm +x"005c", x"003307B1", 32, true , false, 0, d, atmi, atmo);

      -- Wait untill busy bit is cleared, indicating successfull execution of command
      tmp := (others => '1');
      while tmp(12) = '1' loop
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#58#, txp);
        rxi(dsurx, tmp, txp, lresp);
        print("-- Abstract Control and Status is " & tost(tmp));
      end loop;
    end procedure;

    -- IOMMU configuration
    procedure iommu_conf(
      signal dsurx : in std_ulogic; 
      signal dsutx : out std_ulogic ) is
      variable w32        : std_logic_vector(31 downto 0);
      variable r32        : std_logic_vector(31 downto 0);
      constant lresp    : boolean := false;
      constant txp      : time := 160 * 1 ns;

    begin
      print("************* Configuring IOMMU *************");
      --Read out the plug and play area 
      report("Configure IOMMU in passthrough mode ");
      -- Write to control reg
      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FF#, 16#FA#, 16#00#, 16#10#, txp);
      txa(dsutx, 16#00#, 16#00#, 16#00#, 16#00#, txp);
      r32(0) := '1';
      while (r32(0) /= '0') loop
      txc(dsutx, 16#80#, txp);
      txa(dsutx, 16#FF#, 16#FA#, 16#00#, 16#10#, txp);
      rxi(dsurx, r32, txp, lresp);
      end loop;

    end procedure iommu_conf;

    -- MIGs test
    procedure migs_test(signal dsurx : in std_ulogic; signal dsutx : out std_ulogic) is
      variable w32        : std_logic_vector(31 downto 0);
      variable w32_l      : std_logic_vector(31 downto 0);
      constant lresp    : boolean := false;

      constant txp : time := 160 * 1 ns;

    begin

      if (CFG_MIG_7SERIES = 1) then

        print("----------------- [MIG 1] -----------------");

        print("----------------- Beginning of [MIG 1] -----------------");

        -- Read old value:
        print("[MIG 1] Reading old value from 0x00000000");
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#00#, 16#00#, 16#00#, 16#00#, txp);
        rxi(dsurx, w32_l, txp, lresp);
        print("[MIG 1] Value at [0x00000000]: " & tost(w32_l));

        -- Write: 
        print("[MIG 1] Write 0x00AAAAAA to 0x00000000");
        txc(dsutx, 16#c0#, txp);
        txa(dsutx, 16#00#, 16#00#, 16#00#, 16#00#, txp);
        txa(dsutx, 16#00#, 16#AA#, 16#AA#, 16#AA#, txp);

        -- Read:
        print("[MIG 1] Read sequence check");
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#00#, 16#00#, 16#00#, 16#00#, txp);
        rxi(dsurx, w32, txp, lresp);
        print("[MIG 1] read[0x00000000]: " & tost(w32));

        print("----------------- Ending of [MIG 1] -----------------");

        -- Read old value:
        print("[MIG 1] Reading old value from 0x3FFFFFE0");
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#3F#, 16#FF#, 16#FF#, 16#E0#, txp);
        rxi(dsurx, w32_l, txp, lresp);
        print("[MIG 1] Value at [0x3FFFFFE0]: " & tost(w32_l));

        -- Write: 
        print("[MIG 1] Write 0x00BBBBBB to 0x3FFFFFE0");
        txc(dsutx, 16#c0#, txp);
        txa(dsutx, 16#3F#, 16#FF#, 16#FF#, 16#E0#, txp);
        txa(dsutx, 16#00#, 16#BB#, 16#BB#, 16#BB#, txp);

        -- Read:
        print("[MIG 1] Read sequence check");
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#3F#, 16#FF#, 16#FF#, 16#E0#, txp);
        rxi(dsurx, w32, txp, lresp);
        print("[MIG 1] read[0x3FFFFFE0]: " & tost(w32));




        print("----------------- [MIG 2] -----------------");

        print("----------------- Beginning of [MIG 2] -----------------");

        -- Read old value:
        print("[MIG 2] Reading old value from 0x40000000");
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#40#, 16#00#, 16#00#, 16#00#, txp);
        rxi(dsurx, w32_l, txp, lresp);
        print("[MIG 2] Value at [0x40000000]: " & tost(w32_l));

        -- Write: 
        print("[MIG 2] Write 0x00AAAAAA to 0x40000000");
        txc(dsutx, 16#c0#, txp);
        txa(dsutx, 16#40#, 16#00#, 16#00#, 16#00#, txp);
        txa(dsutx, 16#00#, 16#AA#, 16#AA#, 16#AA#, txp);

        -- Read:
        print("[MIG 2] Read sequence check");
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#40#, 16#00#, 16#00#, 16#00#, txp);
        rxi(dsurx, w32, txp, lresp);
        print("[MIG 2] read[0x40000000]: " & tost(w32));

        print("----------------- Ending of [MIG 2] -----------------");

        -- Read old value:
        print("[MIG 2] Reading old value from 0x7FFFFFE0");
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#7F#, 16#FF#, 16#FF#, 16#E0#, txp);
        rxi(dsurx, w32_l, txp, lresp);
        print("[MIG 2] Value at [0x7FFFFFE0]: " & tost(w32_l));

        -- Write: 
        print("[MIG 2] Write 0x00BBBBBB to 0x7FFFFFE0");
        txc(dsutx, 16#c0#, txp);
        txa(dsutx, 16#7F#, 16#FF#, 16#FF#, 16#E0#, txp);
        txa(dsutx, 16#00#, 16#BB#, 16#BB#, 16#BB#, txp);

        -- Read:
        print("[MIG 2] Read sequence check");
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#7F#, 16#FF#, 16#FF#, 16#E0#, txp);
        rxi(dsurx, w32, txp, lresp);
        print("[MIG 2] read[0x7FFFFFE0]: " & tost(w32));
      end if;

    end procedure migs_test;

    procedure riscvtb(signal dsurx : in std_ulogic; signal dsutx : out std_ulogic) is
      variable w32        : std_logic_vector(31 downto 0);

      -- Debug Unit Variables
      variable halted   : std_logic := '0';
      variable active   : std_logic := '0';
      variable resumed  : std_logic := '0';
      variable busy     : std_logic := '1';

      variable status   : std_logic_vector(31 downto 0);

      variable TP       : boolean := true;
      variable Screen   : boolean := false;

      constant txp      : time := 160 * 1 ns;
      constant lresp    : boolean := false;

      variable reg      : std_logic_vector(15 downto 0);

    begin

      report("-- Check AHBROM");
      txc(dsutx, 16#80#, txp);
      txa(dsutx, 16#C0#, 16#00#, 16#40#, 16#00#, txp);
      rxi(dsurx, w32, txp, lresp);
      report("-- AHBROM @ C000_4000: " & tost(w32));
     
      -- Enable TX and RX FIFO in APBUART
      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FC#, 16#00#, 16#10#, 16#08#, txp);
      txa(dsutx, 16#80#, 16#00#, 16#00#, 16#03#, txp);

      print("-- Activate the Debug Module");
      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#40#, txp);
      txa(dsutx, 16#00#, 16#00#, 16#00#, 16#01#, txp);

      print("-- Halt all of the cores");
    
      -- Select all harts in Hart Array Window
      for i in 0 to CFG_NCPU-1 loop
        w32(i) := '1';
      end loop;
      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#54#, txp);
      txa(dsutx, conv_integer(w32(31 downto 24)), conv_integer(w32(23 downto 16)),
                 conv_integer(w32(15 downto 8)) , conv_integer(w32(7 downto 0)), txp);
      --Halting   
      w32 := (others => '0');
      w32(31) := '1';
      w32(0) := '1';
      if CFG_NCPU /= 1 then
        w32(26) := '1';
      end if;
      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#40#, txp);
      txa(dsutx, conv_integer(w32(31 downto 24)), conv_integer(w32(23 downto 16)),
                 conv_integer(w32(15 downto 8)) , conv_integer(w32(7 downto 0)), txp);

      txc(dsutx, 16#80#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#44#, txp);
      rxi(dsurx, w32, txp, lresp);
      print("-- DMSTATUS: " & tost(w32));

      --read_srec("ram.srec", 1, dsutx);

      print("-- Break on ebreak");
      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#5C#, txp);
      txa(dsutx, 16#00#, 16#32#, 16#07#, 16#b0#, txp);
      
      txc(dsutx, 16#80#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#58#, txp);
      rxi(dsurx, w32, txp, lresp);
      print("-- Abstract Control and Status is " & tost(w32));

      busy := w32(12);

      while busy = '1' loop
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#58#, txp);
        rxi(dsurx, w32, txp, lresp);
        print("-- Abstract Control and Status is " & tost(w32));

        busy := w32(12);
      end loop;
      
      txc(dsutx, 16#80#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#10#, txp);
      rxi(dsurx, w32, txp, lresp);
      w32(15) := '1';
      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#10#, txp);
      txa(dsutx, conv_integer(w32(31 downto 24)), conv_integer(w32(23 downto 16)),
                 conv_integer(w32(15 downto 8)) , conv_integer(w32(7 downto 0)), txp);

      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#5C#, txp);
      txa(dsutx, 16#00#, 16#33#, 16#07#, 16#b0#, txp);

      txc(dsutx, 16#80#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#58#, txp);
      rxi(dsurx, w32, txp, lresp);
      print("-- Abstract Control and Status is " & tost(w32));

      busy := w32(12);

      while busy = '1' loop
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#58#, txp);
        rxi(dsurx, w32, txp, lresp);
        print("-- Abstract Control and Status is " & tost(w32));

        busy := w32(12);
      end loop;

      print("-- Write new pc");
      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#10#, txp);
      txa(dsutx, 16#C0#, 16#00#, 16#40#, 16#00#, txp);

      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#5C#, txp);
      txa(dsutx, 16#00#, 16#33#, 16#07#, 16#b1#, txp);
      
      txc(dsutx, 16#80#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#58#, txp);
      rxi(dsurx, w32, txp, lresp);
      print("-- Abstract Control and Status is " & tost(w32));

      busy := w32(12);

      while busy = '1' loop
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#58#, txp);
        rxi(dsurx, w32, txp, lresp);
        print("-- Abstract Control and Status is " & tost(w32));

        busy := w32(12);
      end loop;


      print("-- Write new pc to hart 1");
      w32 := (others => '0');
      w32(0) := '1';
      w32(17 downto 16) := "01";
      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#40#, txp);
      txa(dsutx, conv_integer(w32(31 downto 24)), conv_integer(w32(23 downto 16)),
                 conv_integer(w32(15 downto 8)) , conv_integer(w32(7 downto 0)), txp);
      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#10#, txp);
      txa(dsutx, 16#C0#, 16#00#, 16#40#, 16#00#, txp);

      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#5C#, txp);
      txa(dsutx, 16#00#, 16#33#, 16#07#, 16#b1#, txp);
      
      txc(dsutx, 16#80#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#58#, txp);
      rxi(dsurx, w32, txp, lresp);
      print("-- Abstract Control and Status is " & tost(w32));

      busy := w32(12);

      while busy = '1' loop
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#58#, txp);
        rxi(dsurx, w32, txp, lresp);
        print("-- Abstract Control and Status is " & tost(w32));

        busy := w32(12);
      end loop;


            
      print("-- Write new pc to hart 2");
      w32 := (others => '0');
      w32(0) := '1';
      w32(17 downto 16) := "10";
      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#40#, txp);
      txa(dsutx, conv_integer(w32(31 downto 24)), conv_integer(w32(23 downto 16)),
                 conv_integer(w32(15 downto 8)) , conv_integer(w32(7 downto 0)), txp);
      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#10#, txp);
      txa(dsutx, 16#C0#, 16#00#, 16#40#, 16#00#, txp);

      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#5C#, txp);
      txa(dsutx, 16#00#, 16#33#, 16#07#, 16#b1#, txp);
      
      txc(dsutx, 16#80#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#58#, txp);
      rxi(dsurx, w32, txp, lresp);
      print("-- Abstract Control and Status is " & tost(w32));

      busy := w32(12);

      while busy = '1' loop
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#58#, txp);
        rxi(dsurx, w32, txp, lresp);
        print("-- Abstract Control and Status is " & tost(w32));

        busy := w32(12);
      end loop;            
            
 
      print("-- Write new pc to hart 3");
      w32 := (others => '0');
      w32(0) := '1';
      w32(17 downto 16) := "11";
      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#40#, txp);
      txa(dsutx, conv_integer(w32(31 downto 24)), conv_integer(w32(23 downto 16)),
                 conv_integer(w32(15 downto 8)) , conv_integer(w32(7 downto 0)), txp);
      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#10#, txp);
      txa(dsutx, 16#C0#, 16#00#, 16#40#, 16#00#, txp);

      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#5C#, txp);
      txa(dsutx, 16#00#, 16#33#, 16#07#, 16#b1#, txp);
      
      txc(dsutx, 16#80#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#58#, txp);
      rxi(dsurx, w32, txp, lresp);
      print("-- Abstract Control and Status is " & tost(w32));

      busy := w32(12);

      while busy = '1' loop
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#58#, txp);
        rxi(dsurx, w32, txp, lresp);
        print("-- Abstract Control and Status is " & tost(w32));

        busy := w32(12);
      end loop;               
	  

      print("-- Configure Stack Pointer");
      if (CFG_MIG_7SERIES = 1) then
      -- MIG 1GB Memory at 0x00000000, stack should be at 0x3FFFFFF0
        w32 := conv_std_logic_vector(16#3ffffff0#, 32);
      else
      -- 1MB AHBRAM Memory at 0x00000000 stack should be at 0x000FFFF0
        w32 := conv_std_logic_vector(16#000FFFF0#, 32);
      end if;
      reg := (12 => '1', others => '0'); reg(4 downto 0) := "00010"; --GPR_SP
      -- Writing stack pointer to hart 1 since hart 1 is now selected in debug module control reg now.
      dm_reg_write(dsurx, dsutx, reg, w32); 
      -- Select hart0 and write the stack pointer
      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#40#, txp);
      txa(dsutx, 16#00#, 16#00#, 16#00#, 16#01#, txp);
      dm_reg_write(dsurx, dsutx, reg, w32); 

--      wait for 100 ns;
--      print("-- Trying to access address 0xFC0E0004");
--      txc(dsutx, 16#80#, txp); --read command
--      txa(dsutx, 16#FC#, 16#0E#, 16#00#, 16#04#, txp); --address to read
--      rxi(dsurx, w32, txp, lresp); -- wait for respone and save response
--                                   -- variable w32
--      print("-- READ from 0xFC0E0004: " & tost(w32));
--      
--      print("-- Trying to access address 0xFC0E0008");
--      txc(dsutx, 16#80#, txp); --read command
--      txa(dsutx, 16#FC#, 16#0E#, 16#00#, 16#08#, txp); --address to read
--      rxi(dsurx, w32, txp, lresp); -- wait for respone and save response
--                                   -- variable w32
--      print("-- READ from 0xFC0E0008: " & tost(w32));

      wait for 100 ns;
      print("-- Remove halt for hart 0");
      -- Select only hart 0
      txc(dsutx, 16#c0#, txp); --TX command
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#54#, txp); --address
      txa(dsutx, 16#00#, 16#00#, 16#00#, 16#0F#, txp); --data

      -- Remove halt for hart 0
      txc(dsutx, 16#c0#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#40#, txp);
      txa(dsutx, 16#44#, 16#00#, 16#00#, 16#01#, txp);

      txc(dsutx, 16#80#, txp);
      txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#44#, txp);
      rxi(dsurx, w32, txp, lresp);
      print("-- Debug Module Status is " & tost(w32));

      --resumed := w32(10) and w32(11);
      resumed := w32(10);

      while resumed = '0' loop
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#44#, txp);
        rxi(dsurx, w32, txp, lresp);
        print("-- Debug Module Status is " & tost(w32));

        --resumed := w32(10) and w32(11);
        resumed := w32(10);
      end loop;
      print("-- hart 0 resume status : " & tost(resumed));
      while halted = '0' loop
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#FE#, 16#00#, 16#00#, 16#44#, txp);
        rxi(dsurx, w32, txp, lresp);
        halted := w32(9);
      end loop;
      print("Hart 0 halted after successfull RAM test binary execution.");
    end;

  begin
    dsuctsn <= '0';
    dsucfg(dsutx, dsurx);

    -- Uncomment for AHBUART TEST
    --duart_test(dsutx, dsurx);

    -- Uncomment for GRSPW TEST
    --spw_link_start(dsutx, dsurx);

    -- Uncomment for IOMMU Configuration(Any one of the configuration procedures)

    -- Configuration through debug uart
    --iommu_conf(dsutx, dsurx);

    -- RISCV Test
    riscvtb(dsutx, dsurx);
    --migs_test(dsutx, dsurx);
    wait for 10 ns;
    assert false
    report "Testbench execution completed successfully!"
    severity failure;
  end process;

end;

