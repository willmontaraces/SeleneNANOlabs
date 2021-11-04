library IEEE;
use IEEE.std_logic_1164.all;

entity filter_chold is
port(
clk: in std_logic;
rstn: in std_logic;
dmiss: in std_logic;
chold: in std_logic;
dmiss_hold: out std_logic);
end filter_chold;

architecture rtl of filter_chold is
signal hold: std_logic;
begin

process(dmiss, chold, hold) is
begin
dmiss_hold <= (dmiss and chold) or (chold and hold);
end process;

process(clk) is
begin
   if rising_edge(clk) then
    if(rstn <= '0') then
        hold <= '0';
    elsif (dmiss='1') then
        hold <= '1';
    elsif (chold='0') then
        hold <= '0';
    else
        hold <= hold;
    end if;
end if;

end process;
end rtl;

