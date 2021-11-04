-----------------------------------------------------------------------------
-- Description:	AHB rom. 0/1-waitstate read
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
use grlib.config.all;
use grlib.config_types.all;

entity ahbrom is
  generic (
    hindex : integer := 0;
    haddr  : integer := 0;
    hmask  : integer := 16#fff#;
    pipe   : integer := 0;
    tech   : integer := 0;
    cfg_7series : integer := 0;
    kbytes : integer := 1);
  port (
    rst   : in  std_ulogic;
    clk   : in  std_ulogic;
    ahbsi : in  ahb_slv_in_type;
    ahbso : out ahb_slv_out_type
  );
end;

architecture rtl of ahbrom is
constant abits : integer := 17;
constant bytes : integer := 560;

constant ENDIAN : boolean := (GRLIB_CONFIG_ARRAY(grlib_little_endian) /= 0);

constant hconfig : ahb_config_type := (
  0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_AHBROM, 0, 0, 0),
  4 => ahb_membar(haddr, '1', '1', hmask), others => zero32);

signal romdata      : std_logic_vector(127 downto 0);
signal addr         : std_logic_vector(abits-1 downto 2);
signal hsel, hready : std_ulogic;
signal hsize        : std_logic_vector(2 downto 0);

begin

  ahbso.hresp   <= "00";
  ahbso.hsplit  <= (others => '0');
  ahbso.hirq    <= (others => '0');
  ahbso.hconfig <= hconfig;
  ahbso.hindex  <= hindex;

  reg : process (clk)
  begin
    if rising_edge(clk) then
      addr <= ahbsi.haddr(abits-1 downto 2);
      if ENDIAN then
        addr(3 downto 2) <= not ahbsi.haddr(3 downto 2);
      end if;
      hsize <= ahbsi.hsize;
    end if;
  end process;

  p0 : if pipe = 0 generate
    ahbso.hrdata <= ahbselectdata(romdata, addr(4 downto 2), hsize);
    ahbso.hready <= '1';
  end generate;

  p1 : if pipe = 1 generate
    reg2 : process (clk)
    begin
      if rising_edge(clk) then
        hsel         <= ahbsi.hsel(hindex) and ahbsi.htrans(1);
        hready       <= ahbsi.hready;
        ahbso.hready <= (not rst) or (hsel and hready) or
          (ahbsi.hsel(hindex) and not ahbsi.htrans(1) and ahbsi.hready);
        ahbso.hrdata <= ahbselectdata(romdata, addr(4 downto 2), ahbsi.hsize);
      end if;
    end process;
  end generate;

  comb : process (addr)
  begin
    if ENDIAN then
      case conv_integer(addr(abits-1 downto 4)) is
        -- 128-bits words
        -- text.hang
        when 16#00000# => romdata <= X"10500073FFC5859300004597F1402573";
        when 16#00001# => romdata <= X"FF1FF06F000000130000001300000013";
        -- Padding
        when 16#00002# => romdata <= X"00000013000000130000001300000013";
        when 16#00003# => romdata <= X"00000013000000130000001300000013";
        -- text.start
        when 16#00400# => 
          if cfg_7series = 1 then
            romdata <= X"FF85859300008597F140257300000437";
          else
            romdata <= X"FF85859300008597F140257340000437";
          end if;
        when 16#00401# => romdata <= X"0000001310500073000400670000100F";
        -- Padding
        when 16#00402# => romdata <= X"00000013000000130000001300000013";
        when 16#00403# => romdata <= X"00000013000000130000001300000013";
        when others    => romdata <= (others => '-');
      end case;
    else
      case conv_integer(addr(abits-1 downto 4)) is
        -- 128-bits words
        -- text.hang
        when 16#00000# => romdata <= X"00004597F140257310500073FFC58593";
        when 16#00001# => romdata <= X"0000001300000013FF1FF06F00000013";
        -- Padding
        when 16#00002# => romdata <= X"00000013000000130000001300000013";
        when 16#00003# => romdata <= X"00000013000000130000001300000013";
        -- text.start
        when 16#00400# => 
          if cfg_7series = 1 then
            romdata <= X"F140257300000437FF85859300008597";
          else
            romdata <= X"F140257340000437FF85859300008597";
          end if;
        when 16#00401# => romdata <= X"000400670000100F0000001310500073";
        -- Padding
        when 16#00402# => romdata <= X"00000013000000130000001300000013";
        when 16#00403# => romdata <= X"00000013000000130000001300000013";
        when others    => romdata <= (others => '-');
      end case;
    end if;
  end process;
  -- pragma translate_off
  bootmsg : report_version
  generic map ("ahbrom" & tost(hindex) &
  ": 128-bit AHB ROM Module,  " & tost(bytes/4) & " words, " & tost(abits-2) & " address bits");
  -- pragma translate_on
  end;

