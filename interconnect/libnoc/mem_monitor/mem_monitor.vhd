-----------------------------------------------------------------------------
-- MEMORY SYSTEM for SELENE Design
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- Needed for shifts
use ieee.std_logic_misc.all;            -- Needed for or_reduce
--use ieee.std_logic_arith.all;


entity mem_monitor is
  generic(
    AXI_ID_WIDTH : integer := 4;
    NUM_CORES : integer := 16;
    NUM_INITIATORS : integer := 16; 
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
end;

architecture rtl of mem_monitor is

  type fifo_slot is record
    pending: std_logic;
    qos : unsigned (3 downto 0);
  end record;

  type fifo_type is array (natural range <>) of fifo_slot;

  type mem_sniff_iniciator_type is record 
    full    : std_logic; 
    numpending      : integer range 0 to MAX_PENDING_REQ;   -- numpending
    read_ptr      : integer range 0 to MAX_PENDING_REQ;
    write_ptr      : integer range 0 to MAX_PENDING_REQ;
    request : fifo_type (MAX_PENDING_REQ downto 0);                   -- qos
  end record;

  type mem_sniff_core_type is record 
    pending    : std_logic;                                         
    serving    : std_logic;                                     
  end record;

  type mem_sniff_iniciator_vector_type is array (natural range <>) of mem_sniff_iniciator_type;
  type mem_sniff_core_vector_type is array (natural range <>) of mem_sniff_core_type;

  -----------------------------------------------------
  -- Signals ------------------------------------------
  -----------------------------------------------------

  -- Mem sniff
  signal mem_sniff_read : mem_sniff_iniciator_vector_type(NUM_INITIATORS - 1 downto 0);
  signal mem_sniff_write : mem_sniff_iniciator_vector_type(NUM_INITIATORS - 1 downto 0);
  signal mem_sniff_coreID_read : mem_sniff_core_vector_type(NUM_CORES - 1 downto 0);
  signal mem_sniff_coreID_write : mem_sniff_core_vector_type(NUM_CORES - 1 downto 0);
  signal numpending_reads : integer range 0 to MAX_PENDING_REQ;
  signal numpending_writes : integer range 0 to MAX_PENDING_REQ;
  signal mem_sniff_coreID_read_serving : std_ulogic_vector (NUM_CORES - 1 downto 0);
  signal mem_sniff_coreID_write_serving : std_ulogic_vector (NUM_CORES - 1 downto 0);
  signal mem_sniff_coreID_read_pending : std_ulogic_vector (NUM_CORES - 1 downto 0);
  signal mem_sniff_coreID_write_pending : std_ulogic_vector (NUM_CORES - 1 downto 0);
  signal unsigned_one : unsigned (NUM_CORES - 1 downto 0) := (0 => '0', others => '1');

  signal read_pending_pre_o : std_ulogic_vector (NUM_CORES - 1 downto 0);
  signal read_serving_pre_o : std_ulogic_vector (NUM_CORES - 1 downto 0);
  signal write_pending_pre_o : std_ulogic_vector (NUM_CORES - 1 downto 0);
  signal write_serving_pre_o : std_ulogic_vector (NUM_CORES - 1 downto 0);
  
  signal mem_sniff_coreID_read_serving_all  : std_ulogic_vector (NUM_CORES - 1 downto 0);
  signal mem_sniff_coreID_read_serving_or : std_ulogic;
  signal mem_sniff_coreID_write_serving_all  : std_ulogic_vector (NUM_CORES - 1 downto 0);
  signal mem_sniff_coreID_write_serving_or : std_ulogic;

  signal mem_sniff_coreID_read_backpresure : std_ulogic_vector (NUM_CORES - 1 downto 0);
  signal mem_sniff_coreID_write_backpresure : std_ulogic_vector (NUM_CORES - 1 downto 0);

  signal read_pending_cross_backpresure : std_ulogic_vector (NUM_CORES - 1 downto 0);
  signal read_serving_cross_backpresure : std_ulogic_vector (NUM_CORES - 1 downto 0);
  signal write_pending_cross_backpresure : std_ulogic_vector (NUM_CORES - 1 downto 0);
  signal write_serving_cross_backpresure : std_ulogic_vector (NUM_CORES - 1 downto 0);

  signal read_serving : std_ulogic_vector (NUM_CORES - 1 downto 0);
  signal write_serving : std_ulogic_vector (NUM_CORES - 1 downto 0);

begin

  --Mem sniff
  mem_sniff_coreID_read_serving_or <= or_reduce(mem_sniff_coreID_read_serving_all);
  mem_sniff_coreID_write_serving_or <= or_reduce(mem_sniff_coreID_write_serving_all);

  mem_sniff_coreID_signals : for i in 0 to NUM_CORES-1 generate
    mem_sniff_coreID_read_pending(i)   <= mem_sniff_coreID_read(i).pending;
    mem_sniff_coreID_read_serving_all(i) <= mem_sniff_coreID_read(i).serving;
    mem_sniff_coreID_write_pending(i)  <= mem_sniff_coreID_write(i).pending;
    mem_sniff_coreID_write_serving_all(i) <= mem_sniff_coreID_write(i).serving;

    --mem_sniff_coreID_read_serving(i)     <= '1' when ((r_valid = '1' and r_ready = '1')   and (i = to_integer(mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr).qos))   and (mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr).pending = '1') and (mem_sniff_coreID_read_serving_or = '0'))   else mem_sniff_coreID_read(i).serving; --registered working
    --mem_sniff_coreID_write_serving(i)    <= '1' when ((b_valid = '1' and b_ready = '1')   and (i = to_integer(mem_sniff_write(to_integer(b_id)).request(mem_sniff_write(to_integer(b_id)).read_ptr).qos)) and (mem_sniff_write(to_integer(b_id)).request(mem_sniff_write(to_integer(b_id)).read_ptr).pending = '1') and (mem_sniff_coreID_write_serving_or = '0')) else mem_sniff_coreID_write(i).serving;
    mem_sniff_coreID_read_serving(i)     <=  mem_sniff_coreID_read(i).serving; --registered working
    mem_sniff_coreID_write_serving(i)    <=  mem_sniff_coreID_write(i).serving;

    mem_sniff_coreID_read_backpresure(i) <= '1' when ((ar_valid = '1' and ar_ready = '0') and (i = to_integer(ar_qos))) else '0';
    mem_sniff_coreID_write_backpresure(i) <= '1' when ((aw_valid = '1' and aw_ready = '0') and (i = to_integer(aw_qos))) else '0';

    read_pending_cross_backpresure(i) <= '1' when ((ar_valid = '1' and ar_ready = '0') and (mem_sniff_read(to_integer(ar_id)).numpending = 0) and (i = to_integer(ar_qos))) else '0';
    read_serving_cross_backpresure(i) <= (write_serving_pre_o(i) or mem_sniff_coreID_write_serving(i)) when ((ar_valid = '1' and ar_ready = '0') and (mem_sniff_read(to_integer(ar_id)).numpending = 0)) else '0';
    --read_serving_cross_backpresure(i) <=  '0';
    write_pending_cross_backpresure(i) <= '1' when ((aw_valid = '1' and aw_ready = '0') and (mem_sniff_write(to_integer(aw_id)).numpending = 0)) and (i = to_integer(aw_qos)) else '0';
    write_serving_cross_backpresure(i) <= (read_serving_pre_o(i) or mem_sniff_coreID_read_serving(i)) when ((aw_valid = '1' and aw_ready = '0') and (mem_sniff_write(to_integer(aw_id)).numpending = 0)) else '0';
    --write_serving_cross_backpresure(i) <=  '0';

    read_pending_pre_o(i)  <= '0' when (i = to_integer(mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr).qos)) else mem_sniff_coreID_read(i).pending;
    read_pending_o(i)  <= read_pending_pre_o(i) or mem_sniff_coreID_read_backpresure(i) or read_pending_cross_backpresure(i);
    read_serving_pre_o(i)  <= mem_sniff_coreID_read_pending(i) when (i = to_integer(mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr).qos)) else '0';
    read_serving(i)  <= read_serving_pre_o(i) or mem_sniff_coreID_read_serving(i) or read_serving_cross_backpresure(i);
    read_serving_o(i) <= read_serving(i);

    write_pending_pre_o(i)  <= '0' when (i = to_integer(mem_sniff_write(to_integer(b_id)).request(mem_sniff_write(to_integer(b_id)).read_ptr).qos)) else mem_sniff_coreID_write(i).pending;
    write_pending_o(i) <= write_pending_pre_o(i) or mem_sniff_coreID_write_backpresure(i) or write_pending_cross_backpresure(i);
    write_serving_pre_o(i)  <= mem_sniff_coreID_write_pending(i) when (i = to_integer(mem_sniff_write(to_integer(b_id)).request(mem_sniff_write(to_integer(b_id)).read_ptr).qos)) else '0';
    write_serving(i)  <= write_serving_pre_o(i) or mem_sniff_coreID_write_serving(i) or write_serving_cross_backpresure(i);
    write_serving_o(i) <= write_serving(i);
  end generate mem_sniff_coreID_signals;

  --write_pending_o <= (others => '0');
  --write_serving_o <= (others => '0');


  ----------------------------------------------------------------------
  ---  MEM SNIFF  ------------------------------------------------------
  ----------------------------------------------------------------------

  --process(clkm) --Pending and serving read requests per core id
  --  begin

  --     if (rstn = '1') then
  --        for i in 0 to (NUM_INITIATORS-1) loop
  --          mem_sniff_coreID_read_serving_reg(i) <= '0';
  --     elsif rising_edge(clkm) then
  --        mem_sniff_coreID_read_serving_reg(i)     <= ((r_valid = '1' and r_ready = '1') and (i = to_integer(mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr).qos))   and (mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr).pending = '1') and (mem_sniff_coreID_read_serving_or = '0'));
          
  --     end if; --clk
  --  end process;

  process(clkm)
    begin
       if rstn = '0' then
          numpending_reads <= 0;
          for i in 0 to (NUM_INITIATORS-1) loop
            mem_sniff_read(i).full <= '0';
            mem_sniff_read(i).write_ptr <= 0;
            mem_sniff_read(i).read_ptr <= 0;
            mem_sniff_read(i).numpending <= 0;
          end loop;
       elsif rising_edge(clkm) then
        if (ar_valid = '1' and ar_ready = '1') then
        --Req in
          if (r_valid = '1' and r_last = '1' and r_ready = '1') then
          --Req out
            if (to_integer(ar_id) = to_integer(r_id)) then
            --Req in and out for the same fifo
              if ((mem_sniff_read(to_integer(ar_id)).write_ptr + 1) = MAX_PENDING_REQ) then
                mem_sniff_read(to_integer(ar_id)).write_ptr <= 0;
              else
                mem_sniff_read(to_integer(ar_id)).write_ptr <= mem_sniff_read(to_integer(ar_id)).write_ptr + 1;
              end if;
              if ((mem_sniff_read(to_integer(r_id)).read_ptr + 1) = MAX_PENDING_REQ) then
                mem_sniff_read(to_integer(r_id)).read_ptr <= 0;
              else
                mem_sniff_read(to_integer(r_id)).read_ptr <= mem_sniff_read(to_integer(r_id)).read_ptr + 1;
              end if;
              mem_sniff_read(to_integer(ar_id)).request(mem_sniff_read(to_integer(ar_id)).write_ptr).pending <= '1';
              mem_sniff_read(to_integer(ar_id)).request(mem_sniff_read(to_integer(ar_id)).write_ptr).qos <= ar_qos;
              if(mem_sniff_read(to_integer(ar_id)).full = '0') then
              --Req in and out for the same fifo and not full
                mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr).pending <= '0';
                mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr).qos <= (others => '-');
              end if;--end full
            else
            --Req in and out not for the same fifo
              assert (mem_sniff_read(to_integer(ar_id)).full = '0') report "Test: mem_sniff_read fifo is full!!!, Too much read request for this axi id bus. \n Case: Req in and out not for the same fifo." severity failure;
              if ((mem_sniff_read(to_integer(ar_id)).write_ptr + 1) = MAX_PENDING_REQ) then
                mem_sniff_read(to_integer(ar_id)).write_ptr <= 0;
              else
                mem_sniff_read(to_integer(ar_id)).write_ptr <= mem_sniff_read(to_integer(ar_id)).write_ptr + 1;
              end if;
              mem_sniff_read(to_integer(ar_id)).request(mem_sniff_read(to_integer(ar_id)).write_ptr).pending <= '1';
              mem_sniff_read(to_integer(ar_id)).request(mem_sniff_read(to_integer(ar_id)).write_ptr).qos <= ar_qos;
              mem_sniff_read(to_integer(ar_id)).numpending <= mem_sniff_read(to_integer(ar_id)).numpending + 1;
              if ((mem_sniff_read(to_integer(ar_id)).numpending + 1) = MAX_PENDING_REQ) then
                mem_sniff_read(to_integer(ar_id)).full <= '1';
              end if; --end full
              if ((mem_sniff_read(to_integer(r_id)).read_ptr + 1) = MAX_PENDING_REQ) then
                mem_sniff_read(to_integer(r_id)).read_ptr <= 0;
              else
                mem_sniff_read(to_integer(r_id)).read_ptr <= mem_sniff_read(to_integer(r_id)).read_ptr + 1;
              end if;
              mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr).pending <= '0';
              mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr).qos <= (others => '-');
              mem_sniff_read(to_integer(r_id)).numpending <= mem_sniff_read(to_integer(r_id)).numpending - 1;
              if(mem_sniff_read(to_integer(r_id)).full = '1') then
                mem_sniff_read(to_integer(r_id)).full <= '0';
              end if; --end full
            end if; --end not for the same fifo
          else
          --Req in and not req out
            assert (mem_sniff_read(to_integer(ar_id)).full = '0') report "Test: mem_sniff_read fifo is full!!!, Too much read request for this axi id bus. \n Case: Req in and not req out." severity failure;
            numpending_reads <= numpending_reads + 1;
            if ((mem_sniff_read(to_integer(ar_id)).write_ptr + 1) = MAX_PENDING_REQ) then
              mem_sniff_read(to_integer(ar_id)).write_ptr <= 0;
            else
              mem_sniff_read(to_integer(ar_id)).write_ptr <= mem_sniff_read(to_integer(ar_id)).write_ptr + 1;
            end if;
            mem_sniff_read(to_integer(ar_id)).request(mem_sniff_read(to_integer(ar_id)).write_ptr).pending <= '1';
            mem_sniff_read(to_integer(ar_id)).request(mem_sniff_read(to_integer(ar_id)).write_ptr).qos <= ar_qos;
            mem_sniff_read(to_integer(ar_id)).numpending <= mem_sniff_read(to_integer(ar_id)).numpending + 1;
            if ((mem_sniff_read(to_integer(ar_id)).numpending + 1) = MAX_PENDING_REQ) then
              mem_sniff_read(to_integer(ar_id)).full <= '1';
            end if; --end full
          end if; --Req in and not req out
        elsif(r_valid = '1' and r_last = '1' and r_ready = '1') then
        --Req out and not Req in
          numpending_reads <= numpending_reads - 1;
          if ((mem_sniff_read(to_integer(r_id)).read_ptr + 1) = MAX_PENDING_REQ) then
            mem_sniff_read(to_integer(r_id)).read_ptr <= 0;
          else
            mem_sniff_read(to_integer(r_id)).read_ptr <= mem_sniff_read(to_integer(r_id)).read_ptr + 1;
          end if;
          mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr).pending <= '0';
          mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr).qos <= (others => '-');
          mem_sniff_read(to_integer(r_id)).numpending <= mem_sniff_read(to_integer(r_id)).numpending - 1;
          if(mem_sniff_read(to_integer(r_id)).full = '1') then
            mem_sniff_read(to_integer(r_id)).full <= '0';
          end if;--end full
        end if; --Req out and not Req in
       end if; --clk
    end process;
    process(clkm) --Pending and serving read requests per core id
    begin
       if rstn = '0' then
          for i in 0 to (NUM_CORES-1) loop
            mem_sniff_coreID_read(i).pending <= '0';
            mem_sniff_coreID_read(i).serving <= '0';
          end loop;
       elsif rising_edge(clkm) then
        if (ar_valid = '1' and ar_ready = '1') then
        --Req in
          mem_sniff_coreID_read(to_integer(ar_qos)).pending <= not (mem_sniff_coreID_read(to_integer(ar_qos)).serving);
        end if; --Req in
        --if (r_valid = '1' and r_ready = '1') then
        if (r_valid = '1' and r_ready = '1') then
        --serving
          mem_sniff_coreID_read(to_integer(mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr).qos)).pending <= '0';
          mem_sniff_coreID_read(to_integer(mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr).qos)).serving <= '1';
          --assert (or_reduce(Std_logic_vector(mem_sniff_coreID_read_serving) and Std_logic_vector(unsigned_one rol to_integer(mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr).qos))) = '0') report "Test: mem_sniff_read More than one serving is enabled!!!, This case is not supported by the SafeSU." severity failure;
          if ((mem_sniff_read(to_integer(r_id)).read_ptr + 1) = MAX_PENDING_REQ) then
            if ((mem_sniff_read(to_integer(r_id)).request(0).pending /= '1') or (mem_sniff_read(to_integer(r_id)).request(0).pending = '1' and (mem_sniff_read(to_integer(r_id)).request(0).qos /= mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr).qos))) then
            -- last serving
              mem_sniff_coreID_read(to_integer(mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr).qos)).serving <= '0';
            end if;-- last serving
          else
            if ((mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr + 1).pending /= '1') or (mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr + 1).pending = '1' and (mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr + 1).qos /= mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr).qos))) then
            -- last serving
              mem_sniff_coreID_read(to_integer(mem_sniff_read(to_integer(r_id)).request(mem_sniff_read(to_integer(r_id)).read_ptr).qos)).serving <= '0';
            end if; -- last serving
          end if; --read ptr
        end if; -- serving
       end if; --clk
    end process;
  process(clkm)
    begin
       if rstn = '0' then
          numpending_writes <= 0;
          for i in 0 to (NUM_INITIATORS-1) loop
            mem_sniff_write(i).full <= '0';
            mem_sniff_write(i).write_ptr <= 0;
            mem_sniff_write(i).read_ptr <= 0;
            mem_sniff_write(i).numpending <= 0;
          end loop;
       elsif rising_edge(clkm) then
        if (aw_valid = '1' and aw_ready = '1') then
        --Req in
          if (b_valid = '1' and b_ready = '1') then
          --Req out
            if (to_integer(aw_id) = to_integer(b_id)) then
            --Req in and out for the same fifo
              if ((mem_sniff_write(to_integer(aw_id)).write_ptr + 1) = MAX_PENDING_REQ) then
                mem_sniff_write(to_integer(aw_id)).write_ptr <= 0;
              else
                mem_sniff_write(to_integer(aw_id)).write_ptr <= mem_sniff_write(to_integer(aw_id)).write_ptr + 1;
              end if;
              if ((mem_sniff_write(to_integer(b_id)).read_ptr + 1) = MAX_PENDING_REQ) then
                mem_sniff_write(to_integer(b_id)).read_ptr <= 0;
              else
                mem_sniff_write(to_integer(b_id)).read_ptr <= mem_sniff_write(to_integer(b_id)).read_ptr + 1;
              end if;
              mem_sniff_write(to_integer(aw_id)).request(mem_sniff_write(to_integer(aw_id)).write_ptr).pending <= '1';
              mem_sniff_write(to_integer(aw_id)).request(mem_sniff_write(to_integer(aw_id)).write_ptr).qos <= aw_qos;
              if(mem_sniff_write(to_integer(aw_id)).full = '0') then
              --Req in and out for the same fifo and not full
                mem_sniff_write(to_integer(b_id)).request(mem_sniff_write(to_integer(b_id)).read_ptr).pending <= '0';
                mem_sniff_write(to_integer(b_id)).request(mem_sniff_write(to_integer(b_id)).read_ptr).qos <= (others => '-');
              end if;--end full
            else
            --Req in and out not for the same fifo
              assert (mem_sniff_write(to_integer(aw_id)).full = '0') report "Test: mem_sniff_write fifo is full!!!, Too much read request for this axi id bus. \n Case: Req in and out not for the same fifo." severity failure;
              if ((mem_sniff_write(to_integer(aw_id)).write_ptr + 1) = MAX_PENDING_REQ) then
                mem_sniff_write(to_integer(aw_id)).write_ptr <= 0;
              else
                mem_sniff_write(to_integer(aw_id)).write_ptr <= mem_sniff_write(to_integer(aw_id)).write_ptr + 1;
              end if;
              mem_sniff_write(to_integer(aw_id)).request(mem_sniff_write(to_integer(aw_id)).write_ptr).pending <= '1';
              mem_sniff_write(to_integer(aw_id)).request(mem_sniff_write(to_integer(aw_id)).write_ptr).qos <= aw_qos;
              mem_sniff_write(to_integer(aw_id)).numpending <= mem_sniff_write(to_integer(aw_id)).numpending + 1;
              if ((mem_sniff_write(to_integer(aw_id)).numpending + 1) = MAX_PENDING_REQ) then
                mem_sniff_write(to_integer(aw_id)).full <= '1';
              end if; --end full
              if ((mem_sniff_write(to_integer(b_id)).read_ptr + 1) = MAX_PENDING_REQ) then
                mem_sniff_write(to_integer(b_id)).read_ptr <= 0;
              else
                mem_sniff_write(to_integer(b_id)).read_ptr <= mem_sniff_write(to_integer(b_id)).read_ptr + 1;
              end if;
              mem_sniff_write(to_integer(b_id)).request(mem_sniff_write(to_integer(b_id)).read_ptr).pending <= '0';
              mem_sniff_write(to_integer(b_id)).request(mem_sniff_write(to_integer(b_id)).read_ptr).qos <= (others => '-');
              mem_sniff_write(to_integer(b_id)).numpending <= mem_sniff_write(to_integer(b_id)).numpending - 1;
              if(mem_sniff_write(to_integer(b_id)).full = '1') then
                mem_sniff_write(to_integer(b_id)).full <= '0';
              end if; --end full
            end if; --end not for the same fifo
          else
          --Req in and not req out
            assert (mem_sniff_write(to_integer(aw_id)).full = '0') report "Test: mem_sniff_write fifo is full!!!, Too much read request for this axi id bus. \n Case: Req in and not req out." severity failure;
            numpending_writes <= numpending_writes + 1;
            if ((mem_sniff_write(to_integer(aw_id)).write_ptr + 1) = MAX_PENDING_REQ) then
              mem_sniff_write(to_integer(aw_id)).write_ptr <= 0;
            else
              mem_sniff_write(to_integer(aw_id)).write_ptr <= mem_sniff_write(to_integer(aw_id)).write_ptr + 1;
            end if;
            mem_sniff_write(to_integer(aw_id)).request(mem_sniff_write(to_integer(aw_id)).write_ptr).pending <= '1';
            mem_sniff_write(to_integer(aw_id)).request(mem_sniff_write(to_integer(aw_id)).write_ptr).qos <= aw_qos;
            mem_sniff_write(to_integer(aw_id)).numpending <= mem_sniff_write(to_integer(aw_id)).numpending + 1;
            if ((mem_sniff_write(to_integer(aw_id)).numpending + 1) = MAX_PENDING_REQ) then
              mem_sniff_write(to_integer(aw_id)).full <= '1';
            end if; --end full
          end if; --Req in and not req out
        elsif(b_valid = '1' and b_ready = '1') then
        --Req out and not Req in
          numpending_writes <= numpending_writes - 1;
          if ((mem_sniff_write(to_integer(b_id)).read_ptr + 1) = MAX_PENDING_REQ) then
            mem_sniff_write(to_integer(b_id)).read_ptr <= 0;
          else
            mem_sniff_write(to_integer(b_id)).read_ptr <= mem_sniff_write(to_integer(b_id)).read_ptr + 1;
          end if;
          mem_sniff_write(to_integer(b_id)).request(mem_sniff_write(to_integer(b_id)).read_ptr).pending <= '0';
          mem_sniff_write(to_integer(b_id)).request(mem_sniff_write(to_integer(b_id)).read_ptr).qos <= (others => '-');
          mem_sniff_write(to_integer(b_id)).numpending <= mem_sniff_write(to_integer(b_id)).numpending - 1;
          if(mem_sniff_write(to_integer(b_id)).full = '1') then
            mem_sniff_write(to_integer(b_id)).full <= '0';
          end if;--end full
        end if; --Req out and not Req in
       end if; --clk
    end process;
    process(clkm) --Pending and serving write requests per core id
    begin
       if rstn = '0' then
          for i in 0 to (NUM_CORES-1) loop
            mem_sniff_coreID_write(i).pending <= '0';
            mem_sniff_coreID_write(i).serving <= '0';
          end loop;
       elsif rising_edge(clkm) then
        if (aw_valid = '1' and aw_ready = '1') then
        --Req in
          mem_sniff_coreID_write(to_integer(aw_qos)).pending <= not (mem_sniff_coreID_write(to_integer(aw_qos)).serving);
        end if; --Req in
        if (b_valid = '1' and b_ready = '1') then
        --serving
          mem_sniff_coreID_write(to_integer(mem_sniff_write(to_integer(b_id)).request(mem_sniff_write(to_integer(b_id)).read_ptr).qos)).pending <= '0';
          mem_sniff_coreID_write(to_integer(mem_sniff_write(to_integer(b_id)).request(mem_sniff_write(to_integer(b_id)).read_ptr).qos)).serving <= '1';
          --assert (or_reduce(Std_logic_vector(mem_sniff_coreID_write_serving) and Std_logic_vector(unsigned_one rol to_integer(mem_sniff_write(to_integer(b_id)).request(mem_sniff_write(to_integer(b_id)).read_ptr).qos))) = '0') report "Test: mem_sniff_write More than one serving is enabled!!!, This case is not supported by the SafeSU." severity failure;
          if ((mem_sniff_write(to_integer(b_id)).read_ptr + 1) = MAX_PENDING_REQ) then
            if ((mem_sniff_write(to_integer(b_id)).request(0).pending /= '1') or (mem_sniff_write(to_integer(b_id)).request(0).pending = '1' and (mem_sniff_write(to_integer(b_id)).request(0).qos /= mem_sniff_write(to_integer(b_id)).request(mem_sniff_write(to_integer(b_id)).read_ptr).qos))) then
            -- last serving
              mem_sniff_coreID_write(to_integer(mem_sniff_write(to_integer(b_id)).request(mem_sniff_write(to_integer(b_id)).read_ptr).qos)).serving <= '0';
            end if;-- last serving
          else
            if ((mem_sniff_write(to_integer(b_id)).request(mem_sniff_write(to_integer(b_id)).read_ptr + 1).pending /= '1') or (mem_sniff_write(to_integer(b_id)).request(mem_sniff_write(to_integer(b_id)).read_ptr + 1).pending = '1' and (mem_sniff_write(to_integer(b_id)).request(mem_sniff_write(to_integer(b_id)).read_ptr + 1).qos /= mem_sniff_write(to_integer(b_id)).request(mem_sniff_write(to_integer(b_id)).read_ptr).qos))) then
            -- last serving
              mem_sniff_coreID_write(to_integer(mem_sniff_write(to_integer(b_id)).request(mem_sniff_write(to_integer(b_id)).read_ptr).qos)).serving <= '0';
            end if; -- last serving
          end if; --read ptr
        end if; -- serving
       end if; --clk
    end process;

    ----------------------------------------------------------------------
    ---  END MEM SNIFF  ------------------------------------------------------
    ----------------------------------------------------------------------

end;

