library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library grlib;
use grlib.amba.all;
use grlib.devices.all;
library safety;
use safety.lightlock_pkg.all;


entity apb_wrapper_lightlock is
    generic (
        -- apb generics
        pindex : integer := 0;
        pirq   : integer := 0;
        paddr  : integer := 0;
        pmask  : integer := 16#fff#;
        -- Lockstep generics
        lanes_number        : integer := 2;   -- Number of lanes of each core
        register_input      : integer := 0;   -- The inputs (icnts) are registered with as many registers as the value of register_input
        register_output     : integer := 0;   -- If it is 1, the output is registered. Can be used to improve timing
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
end;

architecture rtl of apb_wrapper_lightlock is

    -- apb wrapper signals
    constant REVISION  : integer := 0;

    constant PCONFIG : apb_config_type := (
    0 => ahb_device_reg (VENDOR_CONTRIB, BSC_PMU, 0, REVISION, 1),
    1 => apb_iobar(paddr, pmask));

    -- interruption vector
    --signal apbirq : std_logic_vector(NAHBIRQ-1 downto 0);

begin
    
    apb_lightlock_inst : apb_lightlock
    generic map(
        lanes_number        => lanes_number,
        register_input      => register_input,
        register_output     => register_output,
        en_cycles_limit     => en_cycles_limit,
        min_staggering_init => min_staggering_init
        )
    port map(
        rstn          => rstn, 
        clk           => clk, 
        -- apb signals
        apbi_psel_i     => apbi_i.psel(pindex),     
        apbi_paddr_i    => apbi_i.paddr,    
        apbi_penable_i  => apbi_i.penable,  
        apbi_pwrite_i   => apbi_i.pwrite,   
        apbi_pwdata_i   => apbi_i.pwdata,   
        apbo_prdata_o   => apbo_o.prdata,   
        -- lockstep signals
        icnt1_i         => icnt1_i,
        icnt2_i         => icnt2_i,        
        stall1_o        => stall1_o,       
        stall2_o        => stall2_o,       
        error_o         => open --apbirq(pirq)
    );

    --fill_IRQ_high: for i in (NAHBIRQ-1) downto pirq+1 generate
    --    apbirq(i) <= '0';
    --end generate fill_IRQ_high;
    --fill_IRQ_low: for i in pirq-1 downto 0 generate
    --    apbirq(i) <= '0';
    --end generate fill_IRQ_low;

    --apbo_o.pirq    <= apbirq;
    apbo_o.pindex  <= pindex;
    apbo_o.pconfig <= PCONFIG;
    
end;
