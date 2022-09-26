library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- Needed for shifts
use ieee.std_logic_misc.all;            -- Needed for or_reduce
entity mem_monitor_tb is
end entity mem_monitor_tb;


architecture test of mem_monitor_tb is

    constant AXI_ID_WIDTH : integer  := 4;
    constant num_cores : integer  := 16;
    constant NUM_INITIATORS: integer  := 1;
    constant max_pending_req : integer  := 16;
    

	component mem_monitor is
	generic(
		AXI_ID_WIDTH 	: integer := 4;
		NUM_CORES 		: integer := 16;
		NUM_INITIATORS  : integer := 16; 
		MAX_PENDING_REQ : integer := 32
	);
	port(
		-- Clock and Reset
		clkm         : in    std_ulogic;
		rstn         : in    std_ulogic;
		-- AXI bus signals
		ar_valid : in std_logic;
		ar_id  : in unsigned (AXI_ID_WIDTH-1 downto 0);
		ar_qos  : in unsigned (3 downto 0);
		ar_ready : in std_logic;

		r_valid  : in std_logic;
		r_id  : in unsigned (AXI_ID_WIDTH-1 downto 0);
		r_last  : in std_logic;
		r_ready  : in std_logic;
		  
    aw_valid : in std_logic;
    aw_id : in unsigned (AXI_ID_WIDTH-1 downto 0);
    aw_qos : in unsigned (3 downto 0);
    aw_ready : in std_logic;
    
    b_valid  : in std_logic;
    b_id  : in unsigned (AXI_ID_WIDTH-1 downto 0);
    b_ready  : in std_logic;

		-- AXI monitor pending and serving signals
		read_pending_o : out std_ulogic_vector(NUM_CORES - 1 downto 0);
		read_serving_o : out std_ulogic_vector(NUM_CORES - 1 downto 0);
		write_pending_o : out std_ulogic_vector(NUM_CORES - 1 downto 0);
		write_serving_o : out std_ulogic_vector(NUM_CORES - 1 downto 0)
	);
	end component;

	signal clock 			: std_logic  := '0';
	signal reset 			: std_logic  := '0';
	signal ar_valid 	: std_ulogic := '0';
	signal ar_id  	    : unsigned (AXI_ID_WIDTH-1  downto 0) := (others => '0');
	signal ar_qos  	   : unsigned (3  downto 0) := (others => '0');
	signal ar_ready 	: std_ulogic := '0';
	signal r_valid 	   : std_ulogic := '0';
	signal r_id 		: unsigned(AXI_ID_WIDTH-1  downto 0) := (others => '0');
	signal r_last 	    : std_ulogic := '0';
	signal r_ready 	   : std_ulogic := '0';
	signal read_pending_o  : std_ulogic_vector(NUM_CORES - 1 downto 0);
	signal read_serving_o  : std_ulogic_vector(NUM_CORES - 1 downto 0);
	signal write_pending_o : std_ulogic_vector(NUM_CORES - 1 downto 0);
	signal write_serving_o : std_ulogic_vector(NUM_CORES - 1 downto 0);
	
  signal aw_valid :  std_logic;
  signal aw_id :  unsigned (AXI_ID_WIDTH-1 downto 0);
  signal aw_qos : unsigned (3 downto 0);
  signal aw_ready : std_logic;
  signal b_valid  : std_logic;
  signal b_id  : unsigned (AXI_ID_WIDTH-1 downto 0);
  signal b_ready  : std_logic;
	
	signal ccs_out : std_logic_vector(255 downto 0);
	
	
begin
	clock <= not clock after 1 ns;
	reset <= '0', '1' after 5 ns;

	dut : mem_monitor
	generic map(
        AXI_ID_WIDTH 	=> AXI_ID_WIDTH,
		NUM_CORES 		=> NUM_CORES,
		NUM_INITIATORS  => NUM_INITIATORS, 
		MAX_PENDING_REQ => MAX_PENDING_REQ
	)
	port map(
		rstn				 => reset,
		clkm				 => clock,
		ar_valid			 => ar_valid,
		ar_id				 => ar_id,
		ar_qos				 => ar_qos,
		ar_ready			 => ar_ready,
		r_valid				 => r_valid,
		r_id				 => r_id,
		r_last				 => r_last,
		r_ready				 => r_ready,
		aw_valid		     => aw_valid,
		aw_id				 => aw_id,
		aw_qos				 => aw_qos,
		aw_ready			 => aw_ready,
		b_valid				 => b_valid,
		b_id				 => b_id,
		b_ready				 => b_ready,
		read_pending_o	 => read_pending_o,
		read_serving_o	 => read_serving_o,
		write_pending_o  => write_pending_o,
		write_serving_o  => write_serving_o
	);	
	
	stimulus_read :
	process begin
		-- Wait for the Reset to be released
		wait until (reset = '1');
		for i in 0 to (15-1) loop
            -- Everyone is ready
            ar_ready <= '1';
            r_ready  <= '1';
            wait for 2 ns;
            -- |     | OUT
            -- |    0| IN
            ar_valid <= '1';
            ar_qos   <= "0000";
            wait for 2 ns;
            ar_valid <= '0';
    
            wait for 2 ns;
            -- |     | OUT
            -- |   20| IN
            ar_valid <= '1';
            ar_qos   <= "0010";
            wait for 2 ns;
            ar_valid <= '0';
    
            wait for 2 ns;
            --   |     | OUT
            -- BP|   20| IN
            ar_valid <= '1';
            ar_qos   <= "0001";
            ar_ready <= '0';
            wait for 2 ns;
    
            wait for 2 ns;
            -- |     | OUT
            -- |  120| IN
            ar_valid <= '1';
            ar_ready <= '1';
            ar_qos   <= "0001";
            wait for 2 ns;
            ar_valid <= '0';
            wait for 2 ns;
    
            -- |     | OUT
            -- | 5120| IN
            ar_valid <= '1';
            ar_qos   <= "0101";
            wait for 2 ns;
            ar_valid <= '0';
            wait for 2 ns;
    
            -- |    0| OUT
            -- |  512| IN
            r_valid  <= '1';
            wait for 2 ns;
            r_last   <= '1';
            wait for 2 ns;
            r_last   <= '0';
            r_valid  <= '0';
            wait for 2 ns;
    
            -- 2 exits while 3 enters
            -- |    2| OUT
            -- |  351| IN
            r_valid  <= '1';	
            ar_valid <= '1';
            ar_qos   <= "0011";
            wait for 2 ns;
    
            -- 2 exits last while 4 enters
            -- 2 ar requests back to back
            -- One exits while one enters
    
            -- |    2| OUT
            -- | 4351| IN
            ar_qos   <= "0100";
            r_last   <= '1';
            wait for 2 ns;
            ar_valid <= '0';
            r_valid  <= '0';
            r_last   <= '0';
    
            wait for 2 ns;
            -- EMPTY THE QUEUE AND END
            -- |    1| OUT
            -- |  435| IN
            r_valid <= '1';
            r_last  <= '1';
            wait for 2 ns;
            -- EMPTY THE QUEUE AND END
            -- |    5| OUT
            -- |   43| IN
            wait for 2 ns;
            -- EMPTY THE QUEUE AND END
            -- |    3| OUT
            -- |    4| IN
            wait for 2 ns;
            -- EMPTY THE QUEUE AND END
            -- |    4| OUT
            -- |     | IN
            wait for 2 ns;
            r_valid <= '0';
            r_last  <= '0';
            wait for 2 ns;
            --   |     | OUT
            -- BP|     | IN
            ar_valid <= '1';
            ar_ready <= '0';
            ar_qos   <= "0000";
            wait for 40 ns;
            -- |      | OUT
            -- |     0| IN
            ar_ready <= '1';
            wait for 2 ns;
            -- |    0| OUT
            -- |     | IN
            r_valid <= '1';
            ar_valid <= '0';
            wait for 2 ns;
            -- |    0| OUT
            -- |     | IN
            r_last <= '1';
            wait for 2 ns;
            -- |     | OUT
            -- |     | IN
            r_valid <= '0';
            r_last <= '0';
    
            wait for 10 ns;
       end loop;
        wait;
	end process stimulus_read;
	
	
	stimulus_writes :
	process begin
            aw_ready <= '1';
            aw_valid <= '0';
            aw_qos <= "0000";
            b_ready  <= '1';
            b_valid  <= '0';
		-- Wait for the Reset to be released
		wait until (reset = '1');
		  for i in 0 to (15-1) loop
            -- Everyone is ready
            aw_ready <= '1';
            aw_valid <= '0';
            aw_qos <= "0000";
            b_ready  <= '1';
            b_valid  <= '0';
            wait for 2 ns;
            -- |     | OUT
            -- |    0| IN
            --aw_ready <= '1';
            aw_valid  <= '1';
            aw_qos <= "0000";
            --b_ready <= '1';
            --b_valid <= '1';
            
            wait for 2 ns;
            -- |     | OUT
            -- |   10| IN
            --aw_ready <= '1';
            --aw_valid  <= '1';
            aw_qos <= "0001";
            --b_ready <= '1';
            --b_valid <= '1';
                        
            wait for 2 ns;
            -- |    0| OUT
            -- |   21| IN
            --aw_ready <= '1';
            --aw_valid  <= '1';
            aw_qos <= "0010";
            --b_ready <= '1';
            b_valid <= '1';
            
            wait for 2 ns;
            -- |    0| OUT
            -- |   21| IN
            --aw_ready <= '1';
            aw_valid  <= '0';
            --aw_qos <= "0010";
            --b_ready <= '1';
            b_valid <= '0';
      
            wait for 2 ns;
            --   |     | OUT
            -- BP|   21| IN
            aw_ready <= '0';
            aw_valid <= '1';
            aw_qos <= "0101";
            --b_ready <= '1';
            b_valid <= '0';
            
            wait for 2 ns;
            --   |    1| OUT
            -- BP|    2| IN
            --aw_ready <= '0';
            --aw_valid <= '1';
            --aw_qos <= "0101";
            --b_ready <= '1';
            b_valid <= '1';
            
            wait for 2 ns;
            --   |    2| OUT
            -- BP|     | IN
            --aw_ready <= '0';
            --aw_valid <= '1';
            --aw_qos <= "0101";
            --b_ready <= '1';
            b_valid <= '1';
            
            wait for 2 ns;
            --   |      | OUT
            -- BP|      | IN
            --aw_ready <= '0';
            --aw_valid <= '1';
            --aw_qos <= "0101";
            --b_ready <= '1';
            b_valid <= '0';
            
            wait for 2 ns;
            -- |      | OUT
            -- |     5| IN
            aw_ready <= '1';
            --aw_valid <= '1';
            --aw_qos <= "0101";
            --b_ready <= '1';
            --b_valid <= '0';
            
            wait for 2 ns;
            -- |      | OUT
            -- |     5| IN
            --aw_ready <= '1';
            aw_valid <= '0';
            --aw_qos <= "0101";
            --b_ready <= '1';
            b_valid <= '0';
            
            wait for 2 ns;
            -- |     5| OUT
            -- |      | IN
            --aw_ready <= '1';
            --aw_valid <= '0';
            --aw_qos <= "0101";
            --b_ready <= '1';
            b_valid <= '1';
            
            wait for 2 ns;
            -- |      | OUT
            -- |      | IN
            --aw_ready <= '0';
            --aw_valid <= '0';
            --aw_qos <= "0101";
            --b_ready <= '1';
            b_valid <= '0';
            
            wait for 2 ns;
               end loop;
     wait;
	end process stimulus_writes;

end architecture test;

