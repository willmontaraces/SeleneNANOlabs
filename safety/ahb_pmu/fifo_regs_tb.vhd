library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity fifo_tb is
end fifo_tb;

architecture Behavioral of fifo_tb is


constant clock_period : time := 10 ns;

component module_fifo is
generic (
    g_WIDTH : natural := 6;
    g_DEPTH : integer := 6
    );
  port (
    rst      : in std_logic;
    clk      : in std_logic;
 
    -- FIFO Write Interface
    wr_en    : in  std_logic;
    wr_data  : in  std_logic_vector(g_WIDTH-1 downto 0);
    full     : out std_logic;
 
    -- FIFO Read Interface
    rd_en    : in  std_logic;
    rd_data  : out std_logic_vector(g_WIDTH-1 downto 0);
    empty    : out std_logic
    );
end component;

-- Generics
constant g_WIDTH : natural := 6;
constant g_DEPTH : natural := 6;

-- component signals
signal clk : std_logic := '0';
signal rst : std_logic := '0';
signal wr_en : std_logic := '0';
signal wr_data : std_logic_vector(g_WIDTH - 1 downto 0) := (others => '0');
signal rd_en : std_logic := '0';
signal rd_data : std_logic_vector(g_WIDTH - 1 downto 0);
signal empty : std_logic;
signal full : std_logic;

begin

DUT : module_fifo
    generic map (
      g_WIDTH => g_WIDTH,
      g_DEPTH => g_DEPTH
    )
    port map (
      clk => clk,
      rst => rst,
      wr_en => wr_en,
      wr_data => wr_data,
      rd_en => rd_en,
      rd_data => rd_data,
      empty => empty,
      full => full
    );
    
 
    clk <= not clk after clock_period / 2;
    rst <= '0';
    PROC_SEQUENCER : process
    begin
      wait until rising_edge(clk);
      -- Pushing in the FIFO until it's full
      -- Start writing
      wr_en <= '1';
      wr_data <= std_logic_vector(unsigned(wr_data) + 1);
      wait until rising_edge(clk);
      wr_data <= std_logic_vector(unsigned(wr_data) + 1);
      wait until rising_edge(clk);
      wr_data <= std_logic_vector(unsigned(wr_data) + 1);
      wait until rising_edge(clk);
      wr_data <= std_logic_vector(unsigned(wr_data) + 1);
      wait until rising_edge(clk);
      wr_data <= std_logic_vector(unsigned(wr_data) + 1);
      wait until rising_edge(clk);
      wr_data <= std_logic_vector(unsigned(wr_data) + 1);
      wait until rising_edge(clk);
      
      -- Stop writing
      wr_en <= '0';

      -- Popping from the FIFO until it's empty
      -- Start reading
      wait until rising_edge(clk);
      rd_en <= '1';
      -- Stop wreading
      wait until empty = '1';
      rd_en <= '0';
      
      -- Pushing and popping at the same time      
      -- Start writing
      wait until rising_edge(clk);
      wr_en <= '1';
      wr_data <= std_logic_vector(unsigned(wr_data) + 1);
      wait until rising_edge(clk);
      wr_data <= std_logic_vector(unsigned(wr_data) + 1);
      wait until rising_edge(clk);
      rd_en <= '1';
      
      while wr_data <= "001111" loop
        wr_data <= std_logic_vector(unsigned(wr_data) + 1);
        wait until rising_edge(clk);
      end loop;   
         
      wait until rising_edge(clk);
      wait until rising_edge(clk);
      -- Stop writing
      wr_en <= '0';
      -- Stop wreading
      wait until rising_edge(clk);
      wait until rising_edge(clk);  
      rd_en <= '0';
      
    end process;

end Behavioral;
