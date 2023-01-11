library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library grlib;
use grlib.config.all;
use grlib.amba.all;
library gaisler;
use gaisler.noelv.all;
library safety;
use safety.pmu_module.all;

entity ahb_latency_and_contention is
  generic(
      ncpu : integer := 6;
      nout : integer := 32; --number of outputs to crossbar
      naxi_deep : integer := 16; -- Width of dniff cores vector
      naxi_ccs : integer := 4 -- number of used sources of axi contention 
      );
  port (
      rstn  : in  std_ulogic;
      clk   : in  std_ulogic;
      -- AHB bus signals
      ahbmi         : in ahb_mst_in_type;
      ahbso         : in ahb_slv_out_vector;
      ahbsi         : in ahb_slv_in_type;
      cpus_ahbmo    : in ahb_mst_out_vector_type(ncpu-1 downto 0);
      -- AXI bus signals
      mem_sniff_coreID_read_pending_o : in std_ulogic_vector(naxi_deep - 1 downto 0);
      mem_sniff_coreID_read_serving_o : in std_ulogic_vector(naxi_deep - 1 downto 0);
      mem_sniff_coreID_write_pending_o : in std_ulogic_vector(naxi_deep - 1 downto 0);
      mem_sniff_coreID_write_serving_o : in std_ulogic_vector(naxi_deep - 1 downto 0);
      -- Bug ?  ahbsi_hmaster : in std_logic_vector(ncpu-1 downto 0);
      ahbsi_hmaster : in std_logic_vector(3 downto 0);
      -- PMU events
      pmu_events    : in nv_counter_out_vector(ncpu-1 downto 0);
      dcl2_events   : in std_logic_vector(10 downto 0);
      -- PMU input
      pmu_input : out std_logic_vector(nout-1 downto 0)
      );
end;

architecture rtl of ahb_latency_and_contention is

    constant axi_ccs_victims : integer := ncpu;  -- number of cores suffering contention
    constant DCL2_ACCESS_EVENT : integer := 2;
    constant DCL2_MISS_EVENT   : integer := 1;
    constant DCL2_HIT_EVENT    : integer := 0; 
    constant BASE_BASIC : integer := 0;  
    constant END_BASIC : integer :=(ncpu-1)*7+8;
    constant BASE_CCS_AHB: integer :=END_BASIC+1;
    constant END_CCS_AHB: integer :=BASE_CCS_AHB+(ncpu-1)*(ncpu-1)+(ncpu-2);
    constant BASE_CCS_AXI_W : integer :=END_CCS_AHB+1;
    constant END_CCS_AXI_W : integer :=(axi_ccs_victims*(naxi_ccs-1)) + BASE_CCS_AXI_W -1;
    constant BASE_CCS_AXI_R : integer :=END_CCS_AXI_W+1; 
    constant END_CCS_AXI_R : integer :=(axi_ccs_victims*(naxi_ccs-1)) + BASE_CCS_AXI_R -1;

    -- SIGNALS -----------------------------------------------------------------------------------

    signal cpu_ahb_access : std_logic_vector(ncpu-1 downto 0);
      
    -- Latency signals
    signal latency_state, n_latency_state : ccs_latency_state(ncpu-1 downto 0);

    signal latency_cause_state, n_latency_cause_state : ccs_latency_cause_state(ncpu-1 downto 0);

    -- Latency outputs
    signal ccs_latency : ccs_latency_vector_type(ncpu-1 downto 0);
    -- Contention outputs
    signal ccs_contention : ccs_contention_vector_type((ncpu*(ncpu-1))-1 downto 0);
    signal axi_contention : axi_contention_vector_type((naxi_ccs*(naxi_ccs-1))-1 downto 0);
    
    signal dcache_miss    : std_logic_vector(3 downto 0) := (others => '0');
    
    -- FSM signals
    signal rst : std_logic;
    signal cpu_active_read_req : std_logic_vector(ncpu-1 downto 0);
    signal cpu_active_write_req : std_logic_vector(ncpu-1 downto 0);
    signal cpu_active_req : std_logic_vector(ncpu-1 downto 0);
    signal hsplit_bitwiseor : std_logic; -- will be one if one element of hsplit is one
    signal hsplit_auxvector : std_logic_vector(ncpu-1 downto 0);
    signal bus_empty : std_logic;
    signal bus_empty_aux : std_logic_vector(ncpu-1 downto 0);
    signal requesting_bus : std_logic;
    signal requesting_bus_aux : std_logic_vector(ncpu-1 downto 0);
    signal FIFOpushvectREAD : std_logic_vector(ncpu-1 downto 0);
    signal FIFOpushvectWRITE : std_logic_vector(ncpu-1 downto 0);
    signal FIFOpushvectauxREAD : std_logic_vector(ncpu-1 downto 0);
    signal FIFOpushvectauxWRITE : std_logic_vector(ncpu-1 downto 0);
    signal FIFOpushREAD : std_logic := '0';
    signal FIFOpushWRITE : std_logic := '0';
    signal FIFO_push_unified : std_logic := '0';
    type array_of_vectors is array (0 to 1) of std_logic_vector(ncpu-1 downto 0);
    signal cpu_ahb_access_delayed : array_of_vectors := (others => (others => '0'));
    signal FIFOpullREAD : std_logic := '0';
    signal FIFOpullWRITEvect : std_logic_vector(ncpu-1 downto 0);
    signal FIFOpullWRITE : std_logic := '0';
    signal DataFIFOpullREAD : std_logic_vector(ncpu-1 downto 0);
    signal DataFIFOpullWRITE : std_logic_vector(ncpu-1 downto 0);
    signal Data_FIFO_pull_unified : std_logic_vector(ncpu-1 downto 0);
    signal FIFO_pull_unified : std_logic;
    signal Data_FIFO_push_unified : std_logic_vector(ncpu-1 downto 0);
    signal hmaster_decoded : std_logic_vector(ncpu-1 downto 0);
    signal isCPUrequestingBus : std_logic_vector(ncpu-1 downto 0);

    component FIFO_control_fsm_reads is
        port (
            clk_i : in std_logic;
            rst_i : in std_logic;
            htrans_i : in std_logic_vector(1 downto 0);
            hwrite_i : in std_logic;
            bus_empty_i : in std_logic;
            hsplit_i : in std_logic;
            hmaster_i : in std_logic;
            requesting_bus_i : in std_logic;
            hready_i : in std_logic;
            push_o : out std_logic;
            pop_o : out std_logic
    ); end component;
    
    component FIFO_control_fsm_writes is
    port (
        clk_i : in std_logic;
        rst_i : in std_logic;
        htrans_i : in std_logic_vector(1 downto 0);
        hwrite_i : in std_logic;
        hresp_i  : in std_logic_vector(1 downto 0);
        bus_empty_i : in std_logic;
        hsplit_i : in std_logic;
        hmaster_i : in std_logic;
        requesting_bus_i : in std_logic;
        hready_i : in std_logic;
        push_o : out std_logic;
        pop_o : out std_logic
    ); end component;

    component elementwise_or is
        generic(
            length : integer
        );
        port(
            vector_in : in std_logic_vector(length-1 downto 0);
            data_out  : out std_logic
        );
    end component;

    component multiplePushPullingUnifier is
        Generic(
            DATA_WIDTH : integer := 32
        );
        Port ( clk_in             : in STD_LOGIC;
               push_read_in       : in STD_LOGIC;
               push_data_read_in  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
               push_write_in      : in STD_LOGIC;
               push_data_write_in : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
               push_valid_out     : out STD_LOGIC;
               push_data_out      : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
               pull_read_in       : in STD_LOGIC;
               pull_write_in      : in STD_LOGIC;
               pull_valid_out     : out STD_LOGIC
            );
    end component;

begin
    
    rst <= not rstn;
    ----------------------------------------------------------------------------------------------------------------------
    -- LATENCY CALCULATION -----------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------------------
    --TODO: revise description
  
    -- These two FSM calculates which is the total latency of the last bus transmission and which is the
    -- cause for this latency (write, data cache miss or instruction cache miss)
  
    -- FINITE-STATE MACHINES
    -- There are 2 FSM: The first one is in charge of calculating the total latency while the other
    -- is in charge of deducing if the contention is produced after a data cache miss a instruction
    -- cache miss or a write.

    -- FIRST FSM:
    -- STATE1: "000" --> Waits for a write (to state 001) or a cahce miss (data or instruction) (to state 001)
    -- STATE2: "001" --> Waits for the start of a non-sequential transmission (htrans = "10") 
    -- STATE3: "010" --> As the bus is 128 bits and the cache line 256 bits, the transmission will be a burst of two transmissions
    --                   It waits for the first part of the line to be transfered (hready = '1')
    -- STATE4: "011" --> It waits for the second part of the line to be transfered (second data of the burst) (hready = '1')
    -- STATE5: "100" --> If the hready = '1' and the next transmission is not part of the burst htrans = "11" then the write has finished
  
    -- This FSM  dete
    process(clk)
    begin
        if rising_edge(clk) then
            if (rstn = '0') then
                latency_state <= (others => (others => '0'));
                latency_cause_state <= (others => (others => '0'));
            else
                latency_state <= n_latency_state;
                latency_cause_state <= n_latency_cause_state;
            end if;
        end if;
    end process;
  

     latency: for n in 0 to ncpu-1 generate
        process(cpus_ahbmo, latency_state, ahbmi, pmu_events, ahbsi_hmaster)
        begin
            n_latency_state(n) <= latency_state(n);
            ccs_latency(n).total <= '0';
            case latency_state(n) is
                when "000" =>
                    if (pmu_events(n).dcmiss = '1' or pmu_events(n).icmiss = '1') then
                        if unsigned(ahbsi_hmaster) = n  and cpus_ahbmo(n).htrans = "10" and ahbmi.hready = '1' then 
                            n_latency_state(n) <= "010";
                            ccs_latency(n).total <= '1';
                        else
                            n_latency_state(n) <= "001";
                        end if;
                    elsif cpus_ahbmo(n).hwrite = '1' and unsigned(ahbsi_hmaster) = n  and cpus_ahbmo(n).htrans = "10" and ahbmi.hready = '1' then 
                        n_latency_state(n) <= "100";
                    end if;
                -- for cache misses
                when "001" =>
                    ccs_latency(n).total <= '1';
                    if unsigned(ahbsi_hmaster) = n  and cpus_ahbmo(n).htrans = "10" and ahbmi.hready = '1' then 
                        n_latency_state(n) <= "010";
                        ccs_latency(n).total <= '1';
                    end if;
                when "010" =>
                    ccs_latency(n).total <= '1';
                    if ahbmi.hready = '1' then
                        n_latency_state(n) <= "011";
                    end if;
                when "011" => 
                    ccs_latency(n).total <= '1';
                    if ahbmi.hready = '1'  then
                        n_latency_state(n) <= "000";
                        ccs_latency(n).total <= '0';
                    end if;
                 -- for writes
                 when "100" =>
                    if ahbmi.hready = '1' and cpus_ahbmo(n).htrans /= "11" then
                        n_latency_state(n) <= "000";
                        ccs_latency(n).total <= '0';
                    end if;

                when others =>
  
            end case;
        end process;
       
        -- SECOND FSM:
        -- This second state machines keep in its state (n_latency_cause_satate) which
        -- was the last event (write dcmiss icmiss) and therefore which is the cause of
        -- the latency
        process(cpus_ahbmo, pmu_events, latency_cause_state)
        begin
                n_latency_cause_state(n) <= latency_cause_state(n);
                case latency_cause_state(n) is
                    when "00" => --dcmiss
                        if pmu_events(n).icmiss = '1' then
                            n_latency_cause_state(n) <= "01"; --icmiss
                        elsif cpus_ahbmo(n).hwrite = '1' then
                            n_latency_cause_state(n) <= "10"; --write
                        end if;
                    when "01" => --icmiss
                        if pmu_events(n).dcmiss = '1' then
                            n_latency_cause_state(n) <= "00"; --dcmiss
                        elsif cpus_ahbmo(n).hwrite = '1' then
                            n_latency_cause_state(n) <= "10"; --write
                        end if;
                    when "10" => --write
                        if pmu_events(n).icmiss = '1' then
                            n_latency_cause_state(n) <= "01"; --icmiss
                        elsif pmu_events(n).dcmiss = '1' then
                            n_latency_cause_state(n) <= "00"; --dcmiss
                        end if;
                    when others =>
  
                end case;
        end process;
  
        -- From the total latency and the cause of this latency we calculate the latency of each type 
        ccs_latency(n).dcmiss <= ccs_latency(n).total and (not n_latency_cause_state(n)(0) and not n_latency_cause_state(n)(1));
        ccs_latency(n).icmiss <= ccs_latency(n).total and n_latency_cause_state(n)(0);
        ccs_latency(n).write  <= ccs_latency(n).total and n_latency_cause_state(n)(1);
    end generate latency;
    -------------------------------------------------------------------------------------------------------------------------------


    ----------------------------------------------------------------------------------------------------------------------
    -- CONTENTION CALCULATION -----------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------------------
  
    hsplit_auxvector(0) <= ahbso(1).hsplit(0);
    genHSPLITvector : for i in 1 to ncpu-1 generate
        hsplit_auxvector(i) <= hsplit_auxvector(i-1) or ahbso(1).hsplit(i);
    end generate;
    hsplit_bitwiseor <= hsplit_auxvector(ncpu-1);

    -- bus_empty_or : elementwise_or
    -- generic map(
    --     length => ncpu
    -- )port map(
    --     vector_in => cpu_ahb_access,
    --     data_out  => bus_empty
    -- );

    bus_empty_aux(0) <= cpu_ahb_access(0);
    genBusEmptyVector : for i in 1 to ncpu-1 generate
        bus_empty_aux(i) <= bus_empty_aux(i-1) or cpu_ahb_access(i);
    end generate;
    bus_empty <= not(bus_empty_aux(ncpu-1)); -- not reduction_or(cpu_ahb_access(i));

    requesting_bus_aux(0) <= cpus_ahbmo(0).hbusreq;
    genBusReqVector : for i in 1 to ncpu-1 generate
        requesting_bus_aux(i) <= requesting_bus_aux(i-1) or cpus_ahbmo(i).hbusreq;
    end generate;
    -- If someone is requesting the bus and the arbiter is accepting the bus then transaction happened
    requesting_bus <= requesting_bus_aux(ncpu-1) and ahbsi.hready; 
    
    --------------------------------
    -- Push FSM --------------------
    --------------------------------
    FIFOpushvectauxREAD(0) <= FIFOpushvectREAD(0);
    FIFOpushvectauxWRITE(0) <= FIFOpushvectWRITE(0);
    FIFOpushvectorbitwiseor : for i in 1 to ncpu-1 generate
        FIFOpushvectauxREAD (i) <= FIFOpushvectauxREAD(i-1)  or FIFOpushvectREAD(i);
        FIFOpushvectauxWRITE(i) <= FIFOpushvectauxWRITE(i-1) or FIFOpushvectWRITE(i);
    end generate;
    FIFOpushREAD  <= FIFOpushvectauxREAD(ncpu-1); --FIFOpushREAD = or FIFOpushvectREAD
    FIFOpushWRITE <= FIFOpushvectauxWRITE(ncpu-1); --FIFOpushREAD = or FIFOpushvectREAD


    genFSM: for i in 0 to ncpu-1 generate
        hmaster_decoded(i) <= '1' when unsigned(ahbsi.hmaster) = i else '0';
        isCPUrequestingBus(i) <= cpus_ahbmo(i).hbusreq and ahbsi.hready;

        fifofsm_inst_reads : FIFO_control_fsm_reads
        port map(
            clk_i    => clk,
            rst_i    => rst,
            htrans_i => ahbsi.htrans,
            hwrite_i => ahbsi.hwrite,
            bus_empty_i => bus_empty,
            hsplit_i => ahbso(1).hsplit(i),
            hmaster_i => hmaster_decoded(i),
            requesting_bus_i => isCPUrequestingBus(i),
            hready_i => ahbsi.hready,
            push_o => FIFOpushvectREAD(i),
            pop_o  => open
        );
        fifofsm_inst_writes : FIFO_control_fsm_writes
        port map(
            clk_i    => clk,
            rst_i    => rst,
            htrans_i => ahbsi.htrans,
            hwrite_i => ahbsi.hwrite,
            bus_empty_i => bus_empty,
            hsplit_i => ahbso(1).hsplit(i),
            hresp_i => ahbso(1).hresp,
            hmaster_i => hmaster_decoded(i),
            requesting_bus_i => isCPUrequestingBus(i),
            hready_i => ahbsi.hready,
            push_o => FIFOpushvectWRITE(i),
            pop_o  => FIFOpullWRITEvect(i)
        );
    end generate;
    --BitwiseOr of FIFOpullWrite -> vhdl2008 -> FIFOpullWrite <= or (FIFOpullWRITEvect)
    FIFOpullWRITE <= '0' when unsigned(FIFOpullWRITEvect) = 0 else '1';

    --Data_FIFO_pull_unified <= DataFIFOpullWRITE when FIFOpullWRITE='1' else DataFIFOpullREAD;
     

    --delay Data 1 cycle to that it's on time with control
    process(clk)
    begin
        if rising_edge(clk) then
            cpu_ahb_access_delayed(0) <= cpu_ahb_access;
            cpu_ahb_access_delayed(1) <= cpu_ahb_access_delayed(0);
        end if;
        end process;

    -- POP logic --
    process(clk) begin
    if rising_edge(clk) then
        if ahbsi.htrans = "11" and ahbsi.hready = '1' and ahbsi.hwrite = '0' then
            FIFOpullREAD <= '1';
        else
            FIFOpullREAD <= '0';
        end if;
--        FIFOpullREAD <= '1' when ahbsi.htrans = "11" and ahbsi.hready = '1' and ahbsi.hwrite = '0' else '0';
    end if;
    end process;
    --------------------------------
    -- Initiator tracking module --
    --------------------------------
    isCPUinFIFO_READS : cpu_vector
	generic map(
        VECTOR_LENGTH => ncpu
	)
	port map(
        clk		  => clk,
		rstn		  => rst,
		push_in		  => FIFOpushREAD,
		cpu_in		  => cpu_ahb_access_delayed(0),
		pop_in	 	  => FIFOpullREAD,
		pop_vector_in     => DataFIFOpullREAD,
		cpu_vector_o      => cpu_active_read_req
	);	
    isCPUinFIFO_WRITES : cpu_vector
	generic map(
        VECTOR_LENGTH => ncpu
	)
	port map(
        clk		          => clk,
		rstn		      => rst,
		push_in		      => FIFOpushWRITE,
		cpu_in		      => cpu_ahb_access_delayed(1), --delaying 2 cycles as pushing is also delayed 2 cycles
		pop_in	 	      => FIFOpullWRITE,
		pop_vector_in     => DataFIFOpullWRITE,
		cpu_vector_o      => cpu_active_write_req
	);	
    cpu_active_req <= cpu_active_read_req or cpu_active_write_req;

    unifying_fifo_control : multiplePushPullingUnifier 
    Generic map(
        DATA_WIDTH => ncpu
    )
    Port map( 
        clk_in             => clk,
        push_read_in       => FIFOpushREAD,
        push_data_read_in  => cpu_ahb_access_delayed(0),
        push_write_in      => FIFOpushWRITE,
        push_data_write_in => cpu_ahb_access_delayed(1),
        push_valid_out     => FIFO_push_unified,
        push_data_out      => Data_FIFO_push_unified,
        pull_read_in       => FIFOpullREAD,
        pull_write_in      => FIFOpullWRITE,
        pull_valid_out     => FIFO_pull_unified
    );

    FIFO_unified : module_fifo
    generic map(
        g_WIDTH  	  => ncpu,
        g_DEPTH  	  => ncpu
    )port map(
        rst      	  => rst,
        clk           => clk,

        -- FIFO Write Interface
        wr_en   	  =>  FIFO_push_unified,
        wr_data 	  =>  Data_FIFO_push_unified,
        full    	  =>  open,

        -- FIFO Read Interface
        rd_en    	  =>  FIFO_pull_unified,
        rd_data 	  =>  Data_FIFO_pull_unified,
        empty   	  =>  open
    );

    FIFO_READS :  module_fifo 
    generic map (
        g_WIDTH  	  => ncpu,
        g_DEPTH  	  => ncpu
    )
    port map(
        rst      	  => rst,
        clk           => clk,

        -- FIFO Write Interface
        wr_en   	  =>  FIFOpushREAD,
        wr_data 	  =>  cpu_ahb_access_delayed(0),
        full    	  =>  open,

        -- FIFO Read Interface
        rd_en    	  =>  FIFOpullREAD,
        rd_data 	  =>  DataFIFOpullREAD,
        empty   	  =>  open
    );

    FIFO_WRITES :  module_fifo 
    generic map (
        g_WIDTH  	  => ncpu,
        g_DEPTH  	  => ncpu
    )
    port map(
        rst      	  => rst,
        clk           => clk,

        -- FIFO Write Interface
        wr_en   	  =>  FIFOpushWRITE,
        wr_data 	  =>  cpu_ahb_access_delayed(1),
        full    	  =>  open,

        -- FIFO Read Interface
        rd_en    	  =>  FIFOpullWRITE,
        rd_data 	  =>  dataFIFOpullWRITE,
        empty   	  =>  open
    );



    -- To calculate the contention we should know which core has the control of the bus. This information is provided
    -- by the signal hmaster. 

    contention: for n in 0 to ncpu-1 generate
        --Previously
        --cpu_ahb_access(n) <= '1' when unsigned(ahbsi_hmaster) = n and not(ahbmi.hready = '1' and cpus_ahbmo(n).htrans = "00") else '0';
        --Now changed cpus_ahbmo(n).htrans = "00" for ahbsi.htrans="00" due to split transactions. Apparently there is a fake bus-parking where
        --When core 0 has a split and is blocked waiting for a response it asserts htrans="10" but bus parking requires the default master to 
        --Have htrans="00", thus, even though hmaster is 0 htrans seems to be modified by the arbiter, thus, 
        --We need to look at the htrans of the slave to have the processed output and detect correctly bus parking on split transactions
        cpu_ahb_access(n) <= '1' when unsigned(ahbsi_hmaster) = n and not(ahbmi.hready = '1' and ahbsi.htrans = "00") else '0';
    end generate contention;
    


    -- This generate generates the contention signals that depend on the number of cores. An equivalent example code for 4 cores
    -- is shown below
    -- I -> current core; J -> contender core
    gen1 : for I in 0 to ncpu-1 generate
        gen2 : for J in 0 to ncpu-1 generate
            gen3 : if J < I generate
                --SPLIT or NOSPLIT
                -- A contender(J) causes contention if it is the head of the queue and you are queued OR
                -- A contender(J) causes contention if it has the bus and you are requesting it
                ccs_contention(I*(ncpu-1) + J).write   <= (Data_FIFO_pull_unified(J) and cpu_active_req(I)) or 
                                                          (cpu_ahb_access(J) and cpus_ahbmo(I).hbusreq and      cpus_ahbmo(J).hwrite  and (not cpu_active_req(I)));
                ccs_contention(I*(ncpu-1) + J).read    <= (Data_FIFO_pull_unified(J) and  cpu_active_req(I)) or 
                                                          (cpu_ahb_access(J) and cpus_ahbmo(I).hbusreq and (not cpus_ahbmo(J).hwrite) and (not cpu_active_req(I))) ;
                ccs_contention(I*(ncpu-1) + J).r_and_w <= ccs_contention(I*(ncpu-1) + J).write  OR ccs_contention(I*(ncpu-1) + J).read;
            end generate gen3;
            gen4 : if J > I generate
                --SPLIT or NOSPLIT
                ccs_contention(I*(ncpu-1) + J-1).write   <= (Data_FIFO_pull_unified(J) and cpu_active_req(I)) or --Blame head of FIFO or blame current master on bus
                                                            (cpu_ahb_access(J) and cpus_ahbmo(I).hbusreq and      cpus_ahbmo(J).hwrite  and (not cpu_active_req(I)));
                ccs_contention(I*(ncpu-1) + J-1).read    <= (Data_FIFO_pull_unified(J) and  cpu_active_req(I)) or 
                                                            (cpu_ahb_access(J) and cpus_ahbmo(I).hbusreq and (not cpus_ahbmo(J).hwrite) and (not cpu_active_req(I))) ;
                ccs_contention(I*(ncpu-1) + J-1).r_and_w <= ccs_contention(I*(ncpu-1) + J-1).write OR ccs_contention(I*(ncpu-1) + J-1).read;
            end generate gen4;
        end generate gen2;
    end generate gen1;
    
  

	-- TODO UPDATE WITH AXI EXAMPLE	   
	---------------------------------------------------------------------------
    -- 4 CORES AXI CCS EXAMPLE -------------------------------------------------------- 
    ---------------------------------------------------------------------------
    ----Core 0 contention
    --ccs_contention(0)  <= cpu_ahb_access(1) and ahbmo(0).hbusreq; --over core 0
    --ccs_contention(1)  <= cpu_ahb_access(2) and ahbmo(0).hbusreq; --over core 0
    --ccs_contention(2)  <= cpu_ahb_access(3) and ahbmo(0).hbusreq; --over core 0
    ----Core 1 contention   
    --ccs_contention(3)  <= cpu_ahb_access(0) and ahbmo(1).hbusreq; --over core 1
    --ccs_contention(4)  <= cpu_ahb_access(2) and ahbmo(1).hbusreq; --over core 1
    --ccs_contention(5)  <= cpu_ahb_access(3) and ahbmo(1).hbusreq; --over core 1
    ----Core 2 contention   
    --ccs_contention(6)  <= cpu_ahb_access(0) and ahbmo(2).hbusreq; --over core 2
    --ccs_contention(7)  <= cpu_ahb_access(1) and ahbmo(2).hbusreq; --over core 2
    --ccs_contention(8)  <= cpu_ahb_access(3) and ahbmo(2).hbusreq; --over core 2
    ----Core 3 contention   
    --ccs_contention(9)  <= cpu_ahb_access(0) and ahbmo(3).hbusreq; --over core 3
    --ccs_contention(10) <= cpu_ahb_access(1) and ahbmo(3).hbusreq; --over core 3
    --ccs_contention(11) <= cpu_ahb_access(2) and ahbmo(3).hbusreq; --over core 3
    ----------------------------------------------------------------------------------------------------------------------
    -- CONTENTION CALCULATION (AXI bus)--------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------------------


    gen5 : for k in 0 to axi_ccs_victims-1 generate
        gen6 : for l in 0 to naxi_ccs-1 generate
            gen7 : if l < k generate
       axi_contention(k*(naxi_ccs-1) + l).write   <= mem_sniff_coreID_write_serving_o(l) and mem_sniff_coreID_write_pending_o(k);
       axi_contention(k*(naxi_ccs-1) + l).read    <= mem_sniff_coreID_read_serving_o(l) and mem_sniff_coreID_read_pending_o(k);
            end generate gen7;
            gen8 : if l > k generate
       axi_contention(k*(naxi_ccs-1) + l-1).write   <= mem_sniff_coreID_write_serving_o(l) and mem_sniff_coreID_write_pending_o(k);
       axi_contention(k*(naxi_ccs-1) + l-1).read    <= mem_sniff_coreID_read_serving_o(l) and mem_sniff_coreID_read_pending_o(k);
            end generate gen8;
        end generate gen6;
    end generate gen5;




    ---------------------------------------------------------------------------
    -- 4 CORES AHB CCS EXAMPLE -------------------------------------------------------- 
    ---------------------------------------------------------------------------
    ----Core 0 contention
    --ccs_contention(0)  <= cpu_ahb_access(1) and ahbmo(0).hbusreq; --over core 0
    --ccs_contention(1)  <= cpu_ahb_access(2) and ahbmo(0).hbusreq; --over core 0
    --ccs_contention(2)  <= cpu_ahb_access(3) and ahbmo(0).hbusreq; --over core 0
    ----Core 1 contention   
    --ccs_contention(3)  <= cpu_ahb_access(0) and ahbmo(1).hbusreq; --over core 1
    --ccs_contention(4)  <= cpu_ahb_access(2) and ahbmo(1).hbusreq; --over core 1
    --ccs_contention(5)  <= cpu_ahb_access(3) and ahbmo(1).hbusreq; --over core 1
    ----Core 2 contention   
    --ccs_contention(6)  <= cpu_ahb_access(0) and ahbmo(2).hbusreq; --over core 2
    --ccs_contention(7)  <= cpu_ahb_access(1) and ahbmo(2).hbusreq; --over core 2
    --ccs_contention(8)  <= cpu_ahb_access(3) and ahbmo(2).hbusreq; --over core 2
    ----Core 3 contention   
    --ccs_contention(9)  <= cpu_ahb_access(0) and ahbmo(3).hbusreq; --over core 3
    --ccs_contention(10) <= cpu_ahb_access(1) and ahbmo(3).hbusreq; --over core 3
    --ccs_contention(11) <= cpu_ahb_access(2) and ahbmo(3).hbusreq; --over core 3

    ----------------------------------------------------------------------------------------------------------------------
    -- PMU INPUT GENERATION ----------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------------------
    -- Depending on the number of cores the assigment of the signals to the input PMU vector will be different
    -- Here we give it value to the output of this component which is the input of the PMU. 
    -- This vecotr is a 32 bits std_logic_vector.

    -- This signals are assigned no matter how many cores are defined
    pmu_input(BASE_BASIC) <= '1';
    pmu_input(BASE_BASIC+1) <= '0';

    gen_ne : for I in 0 to ncpu-1 generate -- generate normal events
        pmu_input(BASE_BASIC+I*7+2) <= pmu_events(I).icnt(0);  -- Instruction count pipeline 0
        pmu_input(BASE_BASIC+I*7+3) <= pmu_events(I).icnt(1);  -- Instruction count pipeline 1
        pmu_input(BASE_BASIC+I*7+4) <= pmu_events(I).icmiss;   -- Instruction cache miss
        pmu_input(BASE_BASIC+I*7+5) <= pmu_events(I).itlbmiss;   --Instruction TLB miss
        pmu_input(BASE_BASIC+I*7+6) <= pmu_events(I).dcmiss;   -- Data chache L1 miss
        pmu_input(BASE_BASIC+I*7+7) <= pmu_events(I).dtlbmiss;   -- Data TLB miss 
        pmu_input(BASE_BASIC+I*7+8) <= pmu_events(I).bpmiss;   -- Branch predictor miss
    end generate gen_ne;

    gen_ccse : for n in 0 to ncpu-1 generate -- generate ccs events
        gen4 : for I in 0 to ncpu-2 generate -- iterate over ccs signals
        -- Last signal assigned by gen_ne -> ((ncpu-1)*7+8)
        -- (ncpu-1) -> number of ccs signals for each core. 
         pmu_input(n*(ncpu-1)+I+BASE_CCS_AHB) <= ccs_contention(n*(ncpu-1)+I).r_and_w; 
         -- read and write contention can be measured individually with
         -- ccs_contention(n - 1).write; ccs_contention(n-1).read; 
        end generate gen4;
    end generate gen_ccse;

    gen_axi_write_e : for n in 0 to axi_ccs_victims-1 generate -- generate axi events
	gen9 : for I in 0 to naxi_ccs -2 generate -- iterate over axi signals
         pmu_input(n*(naxi_ccs -1)+ I + BASE_CCS_AXI_W) <= axi_contention(n*(naxi_ccs -1)+I).write; 
         end generate gen9;
    end generate gen_axi_write_e;


    gen_axi_read_e : for n in 0 to axi_ccs_victims-1 generate -- generate axi events
	gen10 : for I in 0 to naxi_ccs -2 generate -- iterate over axi signals
         pmu_input(n*(naxi_ccs -1)+I+ BASE_CCS_AXI_R) <= axi_contention(n*(naxi_ccs -1)+I).read; 
         end generate gen10;
    end generate gen_axi_read_e;


   --Fill unused signals on event vector
    gen_fill : for n in (END_CCS_AXI_R+1) to (nout-1)  generate -- generate ccs events
         pmu_input(n) <= '0'; 
    end generate gen_fill;

-- TODO: review and update on python script, update comment

-- |-------|----------------------------|----------|-----------|---------------------------------------------------------------------------------------------------------|
-- | Index |  Name                      |   Type   |   Source  |    Description                                                                                          |  
-- |-------|----------------------------|----------|-----------|---------------------------------------------------------------------------------------------------------|
-- |  0    |  ?1?                       |   Debug  |   Local   |    Constant HIGH signal, used for debug purposes or clock cycles                                        |  
-- |  1    |  ?0?                       |   Debug  |   Local   |    Constant LOW signal, used for debug purposes                                                         |  
-- |  2    |  pmu_events(0).icnt(0)     |   Pulse  |   Core 0  |    Instruction count pipeline 0                                                                         |  
-- |  3    |  pmu_events(0).icnt(1)     |   Pulse  |   Core 0  |    Instruction count pipeline 1                                                                         |  
-- |  4    |  pmu_events(0).icmiss      |   Pulse  |   Core 0  |    Instruction cache miss                                                                               |  
-- |  5    |  pmu_events(0).bpmiss      |   Pulse  |   Core 0  |    Branch Perdictor miss                                                                                |  
-- |  6    |  pmu_events(0).dcmiss      |   Pulse  |   Core 0  |    Data cache L1 miss                                                                                   |  
-- |  7    |  ccs_contention(0).read    |   CCS    |   AHB     |    Contention caused to core 0 due to core 1 AHB read accesses                                          |  
-- |  8    |  ccs_contention(0).write   |   CCS    |   AHB     |    Contention caused to core 0 due to core 1 AHB write accesses                                         |  
-- |  9    |  ccs_latency(0).icmiss     |   CCS    |   AHB     |    Latency experienced by core 0 between a instruction cache miss and the reception of the data         |  
-- |  10   |  ccs_latency(0).dcmiss     |   CCS    |   AHB     |    Latency experienced by core 0 between a data cache miss and the reception of the data                |  
-- |  11   |  ccs_latency(0).write      |   CCS    |   AHB     |    Latency experienced by core 0 between the start of a write and its termination                       |  
-- |  12   |  pmu_events(1).dcmiss      |   Pulse  |   Core 1  |    Data cache L1 miss                                                                                   |  
-- |  13   |  ccs_contention(1).read    |   CCS    |   AHB     |    Contention caused to core 0 due to core 2 AHB read accesses                                          |  
-- |  14   |  ccs_contention(1).write   |   CCS    |   AHB     |    Contention caused to core 0 due to core 2 AHB write accesses                                         |  
-- |  15   |  ccs_latency(1).icmiss     |   CCS    |   AHB     |    Latency experienced by core 1 between a instruction cache miss and the reception of the data         |  
-- |  16   |  ccs_latency(1).dcmiss     |   CCS    |   AHB     |    Latency experienced by core 1 between a data cache miss and the reception of the data                |  
-- |  17   |  ccs_latency(1).write      |   CCS    |   AHB     |    Latency experienced by core 1 between the start of a write and its termination                       |  
-- |  18   |  pmu_events(2).dcmiss      |   Pulse  |   Core 2  |    Data cache L1 miss                                                                                   |  
-- |  19   |  ccs_contention(2).read    |   CCS    |   AHB     |    Contention caused to core 0 due to core 3 AHB read accesses                                          |  
-- |  20   |  ccs_contention(2).write   |   CCS    |   AHB     |    Contention caused to core 0 due to core 3 AHB write accesses                                         |  
-- |  21   |  ccs_latency(2).icmiss     |   CCS    |   AHB     |    Latency experienced by core 2 between a instruction cache miss and the reception of the data         |  
-- |  22   |  ccs_latency(2).dcmiss     |   CCS    |   AHB     |    Latency experienced by core 2 between a data cache miss and the reception of the data                |  
-- |  23   |  ccs_latency(2).write      |   CCS    |   AHB     |    Latency experienced by core 2 between the start of a write and its termination                       |  
-- |  24   |  pmu_events(3).dcmiss      |   Pulse  |   Core 3  |    Data cache L1 miss                                                                                   |
-- |  25   |  ccs_contention(3).read    |   CCS    |   AHB     |    Contention caused to core 1 due to core 0 AHB read accesses                                          |
-- |  26   |  ccs_contention(3).write   |   CCS    |   AHB     |    Contention caused to core 1 due to core 0 AHB write accesses                                         |
-- |  27   |  ccs_latency(3).icmiss     |   CCS    |   AHB     |    Latency experienced by core 3 between a instruction cache miss and the reception of the data         |  
-- |  28   |  ccs_latency(3).dcmiss     |   CCS    |   AHB     |    Latency experienced by core 3 between a data cache miss and the reception of the data                |  
-- |  29   |  ccs_latency(3).write      |   CCS    |   AHB     |    Latency experienced by core 3 between the start of a write and its termination                       |      
-- |  30   |                            |          |           |    Empty                                                                                                |
-- |  31   |                            |          |           |    Empty                                                                                                |
-- |       |                            |          |           |                                                                                                         |
-- |---------------------------------------------------------------------------------------------------------------------------------------------------------------------|
                                     
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity elementwise_or is
    generic(
        length : integer := 6
    );
    port(
        vector_in : in std_logic_vector(length-1 downto 0);
        data_out  : out std_logic
    );
end entity elementwise_or;
architecture behavioural of elementwise_or is
signal vector_aux : std_logic_vector(length-1 downto 0);
begin
    vector_aux(0) <= vector_in(0);
    genOr: for i in 1 to length-1 generate
        vector_aux(i) <= vector_aux(i-1) or vector_aux(i);
    end generate;
    data_out <= vector_aux(length-1);
end;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_control_fsm_reads is
port (
    clk_i : in std_logic;
    rst_i : in std_logic;
    htrans_i : in std_logic_vector(1 downto 0);
    hwrite_i : in std_logic;
    bus_empty_i : in std_logic;
    hsplit_i : in std_logic;
    hmaster_i : in std_logic;
    requesting_bus_i : in std_logic;
    hready_i : in std_logic;
    push_o : out std_logic;
    pop_o : out std_logic
);
end;
architecture rtl of FIFO_control_fsm_reads is 
    type t_PushFSM_state is (idle, push, retry);
    signal PushFSM_state : t_PushFSM_state := idle;
    signal PUSHFSM_next  : t_PushFSM_state := idle;
begin
    process(clk_i, rst_i)
    begin
        if(rst_i = '1') then
            PushFSM_state <= idle;
        elsif(rising_edge(clk_i)) then
            PushFSM_state <= PushFSM_next;
        else
            null;
        end if;
    end process;

    process(PushFSM_state, htrans_i, hready_i, hwrite_i, bus_empty_i, hsplit_i, requesting_bus_i, hmaster_i)
    begin
        PushFSM_next <= PushFSM_state;       
        case PushFSM_state is
            when idle =>
                push_o <= '0';
                -- transition to push
                if htrans_i = "10" and requesting_bus_i = '1' and hmaster_i='1'
                    and hwrite_i ='0' and bus_empty_i = '0' and hsplit_i = '0' then
                    PushFSM_next <= push;
                -- transition to retry
                elsif hsplit_i = '1' then
                    PushFSM_next <= retry;
                -- transition to myself
                else
                    PushFSM_next <= idle;
                end if;
            when push =>
                push_o <= '1';
                -- transition to myself
                if htrans_i = "10" and requesting_bus_i = '1' and hwrite_i = '0' and 
                    bus_empty_i = '0' and hsplit_i = '0' and hmaster_i='1' then
                    PushFSM_next <= push;
                -- transition to retry
                elsif hsplit_i = '1' then
                    PushFSM_next <= retry;
                -- transtion to idle
                else 
                    PushFSM_next <= idle;
                end if;
            when retry =>
                push_o <= '0';
                --transition to idle
                if htrans_i = "10" and hready_i = '1'--and requesting_bus = '1' 
		            and bus_empty_i = '0' and hsplit_i = '0' and hmaster_i = '1' then
                    PushFSM_next <= idle;
                -- transition to myself
                else
                    PushFSM_next <= retry;
                end if;
        end case;
    end process;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_control_fsm_writes is
    port (
        clk_i : in std_logic;
        rst_i : in std_logic;
        htrans_i : in std_logic_vector(1 downto 0);
        hwrite_i : in std_logic;
        hresp_i  : in std_logic_vector(1 downto 0);
        bus_empty_i : in std_logic;
        hsplit_i : in std_logic;
        hmaster_i : in std_logic;
        requesting_bus_i : in std_logic;
        hready_i : in std_logic;
        push_o : out std_logic;
        pop_o : out std_logic
    );
    end;
    architecture rtl of FIFO_control_fsm_writes is 
        type t_PushFSM_state is (idle, push, retry);
        signal PushFSM_state : t_PushFSM_state := idle;
        signal PUSHFSM_next  : t_PushFSM_state := idle;
        signal hmasterDelayed : std_logic_vector(1 downto 0) := "00";
        signal hwriteDelayed : std_logic_vector(1 downto 0) := "00";
    begin
        process(clk_i) begin
            if(rising_edge(clk_i)) then
                hmasterDelayed(0) <= hmaster_i;
                hwriteDelayed(0)  <= hwrite_i;
                hmasterDelayed(1) <= hmasterDelayed(0);
                hwriteDelayed(1)  <= hwriteDelayed(0);
            end if;
        end process;

        process(clk_i, rst_i)
        begin
            if(rst_i = '1') then
                PushFSM_state <= idle;
            elsif(rising_edge(clk_i)) then
                PushFSM_state <= PushFSM_next;
            else
                null;
            end if;
        end process;
    
        process(PushFSM_state, htrans_i, hwriteDelayed(1), bus_empty_i, hready_i, hsplit_i, requesting_bus_i, hmaster_i,hresp_i, hmasterDelayed(1))
        begin
            PushFSM_next <= PushFSM_state;       
            case PushFSM_state is
                when idle =>
                    push_o <= '0';
                    -- transition to push
                    --if htrans_i = "10" and requesting_bus_i = '1' and hmaster_i='1'
                    --    and hwrite_i ='0' and bus_empty_i = '0' and hsplit_i = '0' then
                    if hmasterDelayed(1) = '1' and hwriteDelayed(1) = '1' and hready_i = '1' and hresp_i = "11" then 
                        PushFSM_next <= push;
                    -- transition to retry
                    elsif hsplit_i = '1' then
                        PushFSM_next <= retry;
                    -- transition to myself
                    else
                        PushFSM_next <= idle;
                    end if;
                when push =>
                    push_o <= '1';
                    -- transition to retry
                    if hsplit_i = '1' then
                        PushFSM_next <= retry;
                    -- transtion to idle
                    else 
                        PushFSM_next <= idle;
                    end if;
                when retry =>
                    push_o <= '0';
                    --transition to idle
                    if htrans_i = "10" and hready_i = '1'--and requesting_bus = '1' 
                        and bus_empty_i = '0' and hsplit_i = '0' and hmaster_i = '1' then
                        PushFSM_next <= idle;
                    -- transition to myself
                    else
                        PushFSM_next <= retry;
                    end if;
            end case;
        end process;
        pop_o <= '1' when PushFSM_state = retry and htrans_i = "10" and hready_i = '1' and hwrite_i = '1'
                          and bus_empty_i = '0' and hsplit_i = '0' and hmaster_i = '1' 
                 else '0';
end;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- This module handles multiple pushing and pulling on the same cycle.
-- Limitations: Between each multiple pushing/popping there needs to be one bubble
entity multiplePushPullingUnifier is
    Generic(
        DATA_WIDTH : integer := 32
    );
    Port ( clk_in             : in STD_LOGIC;
           push_read_in       : in STD_LOGIC;
           push_data_read_in  : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
           push_write_in      : in STD_LOGIC;
           push_data_write_in : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
           push_valid_out     : out STD_LOGIC;
           push_data_out      : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
           pull_read_in       : in STD_LOGIC;
           pull_write_in      : in STD_LOGIC;
           pull_valid_out     : out STD_LOGIC
        );
end multiplePushPullingUnifier;

architecture Behavioral of multiplePushPullingUnifier is
    signal push_valid_buffer : STD_LOGIC;
    signal push_data_buffer : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    
    signal pull_valid_buffer : STD_LOGIC;
begin

--Get rid of buffered data else serve current transactions
push_valid_out <= '1' when push_valid_buffer = '1' else push_read_in or push_write_in;
pull_valid_out <= '1' when pull_valid_buffer = '1' else pull_read_in or pull_write_in;

--If buffered data, get rid of it, else give priority to writes as reads will be buffered, else serve reads.
push_data_out <= push_data_buffer when push_valid_buffer = '1' else 
                 push_data_write_in when push_write_in = '1' else 
                 push_data_read_in; 


-- When multiple pushing, buffer read transaction and serve it the next cycle
process(clk_in) is
begin
    if rising_edge(clk_in) then
        if( (push_read_in = '1') and (push_write_in = '1')) then
            push_valid_buffer <= push_read_in;
            push_data_buffer <= push_data_read_in;
        else
            push_valid_buffer <= '0';
        end if;
    end if;
end process;

process(clk_in) is
begin
    if rising_edge(clk_in) then
        if( (pull_read_in = '1') and (pull_write_in = '1')) then
            pull_valid_buffer <= pull_read_in;
        else
            pull_valid_buffer <= '0';
        end if;
    end if;
end process;

-- synthesis translate_off
p_assert: process(clk_in) is
begin
    if rising_edge(clk_in) then
        if pull_valid_buffer = '1' and pull_read_in = '1' and pull_write_in = '1' then
            report "Back-to-back multiple pulling is not supported" severity failure;
        end if;
        if push_valid_buffer = '1' and push_read_in = '1' and push_write_in = '1' then
            report "Back-to-back multiple pushing is not supported" severity failure;
        end if;
        if pull_valid_buffer = '1' and (pull_read_in = '1' or pull_write_in = '1') then
            report "Pulling after multiple pulling without two bubbles is not supported, module needs to be rewriten to support this case" severity failure;
        end if;
        if push_valid_buffer = '1' and (push_read_in = '1' or push_write_in = '1') then
            report "Pushing after multiple pulling without two bubbles is not supported, module needs to be rewriten to support this case" severity failure;
        end if;
    end if;
end process;
-- synthesis translate_on


end Behavioral;

