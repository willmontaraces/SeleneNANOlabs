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

begin
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
  
    -- To calculate the contention we should know which core has the control of the bus. This information is provided
    -- by the signal hmaster.
    contention: for n in 0 to ncpu-1 generate
    --cpu_ahb_access(n) <= '1' when unsigned(ahbsi_hmaster) = n else '0';
        cpu_ahb_access(n) <= '1' when unsigned(ahbsi_hmaster) = n and not(ahbmi.hready = '1' and cpus_ahbmo(n).htrans = "00") else '0';
    end generate contention;

    -- This generate generates the contention signals that depend on the number of cores. An equivalent example code for 4 cores
    -- is shown below
    
    gen1 : for I in 0 to ncpu-1 generate
        gen2 : for J in 0 to ncpu-1 generate
            gen3 : if J < I generate
                ccs_contention(I*(ncpu-1) + J).r_and_w <= cpu_ahb_access(J) and cpus_ahbmo(I).hbusreq;
                ccs_contention(I*(ncpu-1) + J).write   <= cpu_ahb_access(J) and cpus_ahbmo(I).hbusreq and cpus_ahbmo(J).hwrite;
                ccs_contention(I*(ncpu-1) + J).read    <= cpu_ahb_access(J) and cpus_ahbmo(I).hbusreq and (not (cpus_ahbmo(J).hwrite));
            end generate gen3;
            gen4 : if J > I generate
                ccs_contention(I*(ncpu-1) + J-1).r_and_w <= cpu_ahb_access(J) and cpus_ahbmo(I).hbusreq;
                ccs_contention(I*(ncpu-1) + J-1).write   <= cpu_ahb_access(J) and cpus_ahbmo(I).hbusreq and cpus_ahbmo(J).hwrite;
                ccs_contention(I*(ncpu-1) + J-1).read    <= cpu_ahb_access(J) and cpus_ahbmo(I).hbusreq and (not (cpus_ahbmo(J).hwrite));
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
-- |  0    |  ’1’                       |   Debug  |   Local   |    Constant HIGH signal, used for debug purposes or clock cycles                                        |  
-- |  1    |  ’0’                       |   Debug  |   Local   |    Constant LOW signal, used for debug purposes                                                         |  
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
