-----------------------------------------------------------------------------
-- Package file for SELENE SoC
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- pragma translate_off
use std.textio.all;
-- pragma translate_on
library grlib;
use grlib.config_types.all;
use grlib.config.all;
use grlib.stdlib.all;
use grlib.amba.all;

package selene is
  -- AXI none signals
  constant axi_aw_mosi_none : axi_aw_mosi_type := ((others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), '0');
  constant axi4_aw_mosi_none : axi4_aw_mosi_type := ((others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), '0', (others => '0'), (others => '0'), '0', (others => '0'));

  constant axi_aw_somi_none : axi_aw_somi_type := (ready => '0');

  constant axi_w_mosi_none : axi_w_mosi_type := (
     (others => '0'), (others => '0'), (others => '0'), '0', '0');
  constant axi4_w_mosi_none : axi4_w_mosi_type := (
     (others => '0'), (others => '0'), '0', '0');

  constant axi_w_somi_none : axi_w_somi_type := (ready => '0');

  constant axi_b_mosi_none : axi_b_mosi_type := (ready => '0');

  constant axi_b_somi_none : axi_b_somi_type := ((others => '0'), (others => '0'), '0');

  constant axi_ar_mosi_none : axi_ar_mosi_type := ((others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), '0');
  constant axi4_ar_mosi_none : axi4_ar_mosi_type := ((others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), '0', (others => '0'), (others => '0'), '0', (others => '0'));

  constant axi_ar_somi_none : axi_ar_somi_type := (ready => '0');

  constant axi_r_mosi_none : axi_r_mosi_type := (ready => '0');

  constant axi_r_somi_none : axi_r_somi_type := (
    (others => '0'), (others => '0'), (others => '0'), '0', '0');

  constant aximo_none : axi_mosi_type := (axi_aw_mosi_none, axi_w_mosi_none, axi_b_mosi_none, axi_ar_mosi_none, axi_r_mosi_none);
  constant axi4mo_none : axi4_mosi_type := (axi4_aw_mosi_none, axi4_w_mosi_none, axi_b_mosi_none, axi4_ar_mosi_none, axi_r_mosi_none);

  constant aximi_none : axi_somi_type := (axi_aw_somi_none,
    axi_w_somi_none, axi_b_somi_none, axi_ar_somi_none, axi_r_somi_none);

end package selene;

