library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

 
entity module_fifo is
  generic(
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
end module_fifo;
 
architecture rtl of module_fifo is


  type FIFO_type is array (0 to g_DEPTH - 1) of std_logic_vector(wr_data'range);
  signal FIFO : FIFO_type := (others => (others => '0'));
  
  subtype index_type is integer range FIFO_type'range;
  signal head : index_type;
  signal tail : index_type;
 
  signal fill_count : integer range 0 to g_DEPTH := 0;
  signal i_full     : std_logic;
  signal i_empty    : std_logic;
   
  -- Increment and wrap
  procedure incr(signal index : inout index_type) is
  begin
      if index = index_type'high then
         index <= index_type'low;
      else
         index <= index + 1;
      end if;
  end procedure;

begin

  PROC : process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        head <= 0;
        tail <= 0;
        fill_count <= 0;
      else

        -- Update the head pointer in write
        if wr_en = '1' and i_full = '0' then
          incr(head);
        end if;

        -- Update the tail pointer on read and pulse valid
        if rd_en = '1' and i_empty = '0' then
          incr(tail);
        end if;
        
        -- Update the fill count
        if wr_en = '1' and rd_en = '0' then
           fill_count <= fill_count + 1;
        elsif wr_en = '0' and rd_en = '1' then
           fill_count <= fill_count - 1;
        end if;
        
         -- Write in the FIFO
        if wr_en = '1' then
          FIFO(head) <= wr_data;
        end if;
        
      end if;
    end if;
  end process;
  
  rd_data <= FIFO(tail);   

  -- Set the flags
   i_empty <= '1' when fill_count = 0 else '0';
   i_full  <= '1' when fill_count = g_WIDTH else '0';
   
  -- Copy internal signals to output
   empty <=i_empty;
   full <= i_full;      
   
     -- ASSERTION LOGIC - Not synthesized
  -- synthesis translate_off
 
  p_ASSERT : process (clk) is
  begin
    if rising_edge(clk) then
      if wr_en = '1' and i_full = '1' then
        report "ASSERT FAILURE - MODULE_REGISTER_FIFO: FIFO IS FULL AND BEING WRITTEN " severity failure;
      end if;
 
      if rd_en = '1' and i_empty = '1' then
        report "ASSERT FAILURE - MODULE_REGISTER_FIFO: FIFO IS EMPTY AND BEING READ " severity failure;
      end if;
    end if;
  end process p_ASSERT;
 
  -- synthesis translate_on
   
   
end;


