----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.09.2022 10:25:24
-- Design Name: 
-- Module Name: cpu_vector_tb - Behavioral
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

entity cpu_vector_tb is
--  Port ( );
end cpu_vector_tb;

architecture Behavioral of cpu_vector_tb is

component cpu_vector is
generic (
        VECTOR_LENGTH : integer := 6
    );
  Port ( 
   clk        : in std_logic;
   rstn       : in std_logic;
   push_in    : in std_logic; -- when 1 pushes CPU_IN into vector
   cpu_in     : in std_logic_vector(VECTOR_LENGTH-1 downto 0); -- ONE HOT encoded vector of CPU to push inside queue
   pop_in      : in std_logic; -- when 1 pops pop_vector_in of vector
   pop_vector_in    : in std_logic_vector(VECTOR_LENGTH-1 downto 0); -- ONE HOT encoded vector of CPU to pop of queue
   cpu_vector_o : out std_logic_vector(VECTOR_LENGTH-1 downto 0)
  );
end component;





    constant VECTOR_LENGTH : integer := 6;

	signal clock      : std_logic  := '0';
	signal reset 	  : std_logic  := '0';
    signal push_in    : std_logic  := '0'; -- when 1 pushes CPU_IN into vector
    signal cpu_in     : std_logic_vector(VECTOR_LENGTH-1 downto 0) := (others => '0'); -- ONE HOT encoded vector of CPU to push inside queue
    signal pop_in      : std_logic := '0'; -- when 1 pops pop_vector_in of vector
    signal pop_vector_in    : std_logic_vector(VECTOR_LENGTH-1 downto 0) := (others => '0'); -- ONE HOT encoded vector of CPU to pop of queue
    signal cpu_vector_o : std_logic_vector(VECTOR_LENGTH-1 downto 0) := (others => '0');
	
begin
    dut : cpu_vector
	generic map(
        VECTOR_LENGTH => VECTOR_LENGTH
	)
	port map(
		rstn		  => reset,
		 clk		  => clock,
		push_in		  => push_in,
		cpu_in		  => cpu_in,
		pop_in	 	  => pop_in,
		pop_vector_in		  => pop_vector_in,
		cpu_vector_o  => cpu_vector_o
	);	


	clock <= not clock after 1 ns;
	reset <= '0';
	
		stimulus :
	process begin
		wait for 2 ns;
		-- VECTOR 000000
		push_in <= '1';
		cpu_in  <= "000001";
        wait for 2 ns;
        -- VECTOR 000001
		push_in <= '0';
		
        wait for 2 ns;
        push_in <= '1';
        cpu_in  <= "000010";
        wait for 2 ns;
        -- VECTOR 000011
		push_in       <= '0';
        pop_in        <= '1';
        pop_vector_in <= "000001";
        wait for 2 ns;
        -- VECTOR 000010
        pop_vector_in <= "000010";
        wait for 2 ns;
        -- VECTOR 000000
        pop_in <= '0';
        
        wait for 2 ns;
        -- VECTOR 0000000
        push_in <= '1';
        cpu_in  <= "100000";
        wait for 2 ns; 
        -- VECTOR 100000
        cpu_in <= "000001";
        pop_in <= '1';
        pop_vector_in <= "100000";
        
        wait for 2 ns;
		-- VECTOR 000001
		cpu_in        <= "000010";
        pop_vector_in <= "000001";
        wait for 2 ns;
        -- VECTOR 000010
		pop_in <= '0';
		push_in <= '0';
		
        wait;
    end process stimulus;


end Behavioral;
