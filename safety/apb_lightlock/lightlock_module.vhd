library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
library grlib;
use grlib.amba.all;

package lightlock_module is
    component apb_wrapper_lightlock is
        generic (
            -- apb generics
            pindex : integer := 0;
            pirq   : integer := 0;
            paddr  : integer := 0;
            pmask  : integer := 16#fff#;
            -- Lockstep generics
            lanes_number        : integer := 2;   -- Number of lanes of each core
            register_input      : integer := 0;   -- The inputs (icnts) are registered with as many registers as the value of register_input
            register_output     : integer := 0;   -- If is 1, the output is registered. Can be used to improve timing
            en_cycles_limit     : integer := 500; -- If one core activates lockstep and the other core doesn't activate the lockstep before 500 cycles it rise an interrupt
            min_staggering_init : integer := 20   -- If no min_staggering is configured through the API, this will be take as the default minimum threshold
        );
        port (
            rstn     : in  std_ulogic;
            clk      : in  std_ulogic;
            -- apb signals
            apbi_i   : in  apb_slv_in_type;
            apbo_o   : out apb_slv_out_type;
            -- lockstep signals 
            icnt1_i  : in  std_logic_vector(lanes_number-1 downto 0);    -- Instruction counter from the first core
            icnt2_i  : in  std_logic_vector(lanes_number-1 downto 0);    -- Instruction counter from the second core
            stall1_o : out std_logic;                                    -- Signal to stall the first core
            stall2_o : out std_logic                                     -- Signal to stall the second core
        );
    end component apb_wrapper_lightlock; 

end lightlock_module;
