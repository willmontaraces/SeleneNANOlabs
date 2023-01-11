----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.09.2022 09:47:28
-- Design Name: 
-- Module Name: cpu_vector - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


-- IF PUSH_I THEN WE LATCH CPU_IN INSIDE OUR LIST
-- IF pop_in  THEN WE REMOVE pop_vector_in OF OUR LIST
entity cpu_vector is
generic (
        VECTOR_LENGTH : integer := 6
    );
  Port ( 
   clk          : in std_logic;
   rstn         : in std_logic;
   push_in      : in std_logic; -- when 1 pushes CPU_IN into vector
   cpu_in       : in std_logic_vector(VECTOR_LENGTH-1 downto 0); -- ONE HOT encoded vector of CPU to push inside queue
   pop_in        : in std_logic; -- when 1 pops pop_vector_in of vector
   pop_vector_in      : in std_logic_vector(VECTOR_LENGTH-1 downto 0); -- ONE HOT encoded vector of CPU to pop of queue
   cpu_vector_o : out std_logic_vector(VECTOR_LENGTH-1 downto 0)
  );
end cpu_vector;


architecture Behavioral of cpu_vector is

signal vector : STD_LOGIC_VECTOR(VECTOR_LENGTH-1 downto 0) := (others=> '0');

begin

process(clk, rstn) 
begin
    if rstn = '1' then
        vector <= (others => '0');
    elsif rising_edge(clk) then
        if push_in = '1' and pop_in = '1' then
            vector <= (vector and (not pop_vector_in)) or cpu_in;
        elsif push_in = '1' then
            -- VECTOR => 000100
            -- CPU_IN => 000001
            -- RESULT => 000101
            vector <= vector or cpu_in;
        elsif pop_in = '1' then
            -- VECTOR  => 000101
            -- pop_vector_in => 000001
            -- NOT CPU => 111110
            -- RESULT  => 000100
            vector <= vector and (not pop_vector_in);
        end if;
    end if;
end process;

cpu_vector_o <= vector;

end Behavioral;
