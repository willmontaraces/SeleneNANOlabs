------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2014, Aeroflex Gaisler
--  Copyright (C) 2015 - 2022, Cobham Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library gaisler;
use gaisler.l2c_lite.all;
library grlib;
use grlib.stdlib.all;
use grlib.amba.all;

library techmap;
use techmap.gencomp.all;

entity l2c_lite_mem is
    generic (
        hsindex  : integer := 0;
        tech     : integer := 0;
        waysize  : integer := 32;
        linesize : integer := 32;
        ways     : integer := 2
);
    port (
        rstn  : in std_ulogic;
        clk   : in std_ulogic;
        ctrli : in cache_ctrli_type;
        ctrlo : out cache_ctrlo_type;
        ahbsi : in ahb_slv_in_type;
        le_owner : out std_logic_vector(15 downto 0);
        lr_owner : out std_logic_vector(15 downto 0));

end entity l2c_lite_mem;

architecture rtl of l2c_lite_mem is

    constant addr_depth : integer := log2ext(waysize * (2 ** 10) / linesize);
    constant tag_len    : integer := 32 - addr_depth - log2ext(linesize);
    constant tagvd_len  : integer := tag_len + 2;
    constant ownerbits  : integer := ahbsi.hmaster'length;
    constant tag_dbits  : integer := tagvd_len + ownerbits;
    constant owners	    : integer := 2 ** ownerbits;
    constant bitmaskbits: integer := log2ext(bitmasks);
    -- Register directioning --
    constant leftRegisterStart   	: natural := register_count + bitmasks;
    constant rightRegisterStart     : natural := leftRegisterStart + bitmasks;
    constant ownerBitmasksStart 	: natural := rightRegisterStart + bitmasks;
    constant numOwnerBitmasks   	: natural := owners / (32 / bitmaskbits); 
    constant partitionCountersStart	: natural := ownerBitmasksStart + numOwnerBitmasks;
    
    -- RANGES --
    subtype TAG_R is natural range 31 downto addr_depth + log2ext(linesize);
    subtype TAG_DATA_R is natural range tagvd_len - 1 downto 2;
    subtype TAG_OWNER_DATA_R is natural range tag_dbits - 1 downto 2;
    subtype OWNER_DATA_R is natural range tag_dbits - 1 downto tagvd_len;
    subtype INDEX_R is natural range (addr_depth + log2ext(linesize) - 1) downto log2ext(linesize);
    subtype TAG_INDEX_R is natural range 31 downto log2ext(linesize);
    subtype OFFSET_R is natural range log2ext(linesize) - 1 downto 0;

    type pLRU_data_t is array (0 to 2 ** addr_depth) of std_logic_vector(0 to ways - 2);
    type pLRU_partition_vector_t is array(0 to bitmasks-1) of std_logic_vector(0 to ways-2);

    type tag_data_t is array (0 to ways - 1) of std_logic_vector(tag_dbits - 1 downto 0);
    type cache_data_t is array (0 to ways - 1) of std_logic_vector(linesize * 8 - 1 downto 0);

    -- Cache partitionintmasksB --

    type tag_match_ret_type is record
        index : integer range 0 to ways - 1;
        hit   : std_ulogic;
    end record;

    type reg_type is record
        pr_counter       : integer range 0 to ways;
        rep_index        : integer range 0 to ways;
        tag_temp         : std_logic_vector(TAG_OWNER_DATA_R);
        cache_w_seq      : std_ulogic;
        backend_buf      : std_logic_vector(linesize * 8 - 1 downto 0);
        backend_buf_addr : std_logic_vector(31 downto 0);
        backend_buf_hmaster    : std_logic_vector(ahbsi.hmaster'range);
        hburst           : std_logic_vector(2 downto 0);
        htrans           : std_logic_vector(1 downto 0);
        hsize            : std_logic_vector(2 downto 0);
        hsel             : std_logic_vector(0 to NAHBSLV - 1);
        hwrite           : std_ulogic;
        hmbsel           : std_logic_vector(0 to NAHBAMR - 1);
        hwdata           : std_logic_vector(AHBDW - 1 downto 0);
        haddr            : std_logic_vector(31 downto 0);
        hmaster          : std_logic_vector(ahbsi.hmaster'range);
        cache_data_in_frontend : std_logic_vector(linesize * 8 - 1 downto 0);
        pLRU_data              : pLRU_data_t;
    	pLRU_partition_left  : pLRU_partition_vector_t;
	    pLRU_partition_right : pLRU_partition_vector_t;
    	owner_to_bitmask : std_logic_vector(numOwnerBitmasks * 32 - 1 downto 0);
    	partitionCounters : std_logic_vector(ways * 32 - 1 downto 0);
        tag_match_ret : tag_match_ret_type;
        haddr_buffer : std_logic_vector(31 downto 0);
        hwrite_buffer : std_ulogic;
        hmbsel_buffer : std_logic_vector(0 to NAHBAMR - 1);
        hsize_buffer  : std_logic_vector(2 downto 0);
        tagstat : std_logic_vector(1 downto 0);
        evict : std_ulogic;
        frontend_buf : std_logic_vector(linesize * 8 - 1 downto 0);
        f_way_counter               : integer range 0 to ways;
        f_addr_counter              : integer range 0 to waysize * (2 ** 10) / linesize;
        f_index                     : integer range 0 to waysize * (2 ** 10) / linesize;
        f_addr                      : std_logic_vector(addr_depth - 1 downto 0);
        f_entry_delay, f_exit_delay : std_ulogic;
	    IO_wr			    : std_ulogic;
	    IO_offset		    : integer range 0 to 63;
    end record;

    ----------------------- FUNCTIONS -------------------------------

    ---- FUNCTION DESCRIPTION:
    --          Compares incomming accesses tag and compares to what is present in the memory at that address index. If there is a match,
    --          and the valid bit is set to '1' we return the match index and a hit flag.
    function tag_match (tag_ways : tag_data_t; tag_request : std_logic_vector(tag_len - 1 downto 0)) return tag_match_ret_type is
        variable temp : tag_match_ret_type := (0, '0');
    begin
        for i in 0 to ways - 1 loop
            if tag_ways(i)(TAG_DATA_R) = tag_request and tag_ways(i)(VALID_BIT) = '1' then
                temp.index := i; -- HIT
                temp.hit   := '1';
                return(temp);
            end if;
        end loop;
        return(temp);
    end;

    ---- FUNCTION DESCRIPTION:
    -- 	 Returns the identifier from the bitmask the owner belongs to
    function getOwnerBitmask ( ownerToBitmask : std_logic_vector(numOwnerBitmasks * 32 - 1 downto 0); owner : std_logic_vector(ahbsi.hmaster'range)) return integer is
	    variable intOwner : integer := to_integer(unsigned(owner));
    begin
	    return(to_integer(unsigned(ownerToBitmask((intOwner + 1) * bitmaskBits - 1 downto intOwner * bitmaskBits))));
    end;

    ---- PROCEDURE DESCRIPTION:
    --          Updates the pLRU bits to indicate which was the most recent access.
procedure pLRU_update (variable pLRU_data_out : out std_logic_vector(0 to ways - 2);
    variable pLRU_data                        : in  std_logic_vector(0 to ways - 2);
    variable hit_index			      : in integer range 0 to ways - 1;
    variable pLRU_left			      : in std_logic_vector(0 to ways -2);
    variable pLRU_right			      : in std_logic_vector(0 to ways -2))  is
    variable index                            : integer range 0 to ways - 1 := hit_index;
begin
    pLRU_data_out := pLRU_data;
    index := hit_index / 2 + (ways/2 - 1);
    if(pLRU_left(index) = '0' and pLRU_right(index) = '0') then
	 if (hit_index rem 2) = 0 then
		pLRU_data_out(index) := '0';
   	 else
        	pLRU_data_out(index) := '1';
    	end if;
    end if;
    for i in 1 to log2ext(ways - 1) loop
        if (index rem 2) = 0 then
            index                := index/2 - 1;
	    if(pLRU_left(index) = '0' and pLRU_right(index) = '0') then
	            pLRU_data_out(index) := '1';
	    end if;
        else
            index                := index/2; 
	    if(pLRU_left(index) = '0' and pLRU_right(index) = '0') then
	            pLRU_data_out(index) := '0';
 	    end if;
        end if;
    end loop;
end pLRU_update;

---- PROCEDURE DESCRIPTION:
--          Traverses the pLRU tree to find the "Least recently used" index.
procedure pLRU_evict(variable pLRU_data : in std_logic_vector(0 to ways - 2);
    variable output_index               : out integer range 0 to ways;
    variable pLRU_left  	        : in std_logic_vector(0 to ways - 2);
    variable pLRU_right        		: in std_logic_vector(0 to ways - 2))
    is
    variable index                      : integer range 0 to ways := 0;
begin
    if pLRU_left(0) = '1'  and pLRU_right(0) = '1' then
		output_index := ways; -- CPU HAS NO WAYS ASSIGNED
    else
		
    	for i in 1 to log2ext(ways - 1) loop
	        if (pLRU_data(index) = '0' and pLRU_left(index) = '0') or pLRU_right(index) = '1' then
        	    index := 2 * index + 1 + 1;
       		 else
            	    index := 2 * index + 1;
        	end if;
   	 end loop;

    	if (pLRU_data(index) = '0' and pLRU_left(index) = '0') or pLRU_right(index) = '1'  then
		output_index := 2 * (index - (ways/2 - 1 )) + 1;
    	else
        	output_index := 2 * (index - (ways/2 - 1));
    	end if;
    end if;
end pLRU_evict;



---- PROCEDURE DESCRIPTION:
--          Checks whether or not cache-line should be evicted. If it should be evicted the correct address and data is
--          forwarded to the backend interface together with an eviction flag.
procedure line_evict(signal tag_data : tag_data_t;
    signal cache_data               : in cache_data_t;
    signal address                  : in std_logic_vector(32 - 1 downto 0);
    variable rep_index              : in integer range 0 to ways - 1;
    variable data_buffer            : out std_logic_vector(linesize * 8 - 1 downto 0);
    variable address_buffer         : out std_logic_vector(32 - 1 downto 0);
    variable evict_flag             : out std_ulogic) is
begin
    if (tag_data(rep_index)(VALID_BIT) and tag_data(rep_index)(DIRTY_BIT)) = '1' then
        data_buffer             := cache_data(rep_index);
        address_buffer          := (others => '0');
        address_buffer(TAG_R)   := tag_data(rep_index)(TAG_DATA_R);
        address_buffer(INDEX_R) := address(INDEX_R);
        evict_flag              := '1';
    else
        data_buffer             := (others => '0');
        address_buffer          := (others => '0');
        evict_flag              := '0';
    end if;
end procedure;

constant init_r : reg_type := (pr_counter => 0,
    rep_index                             => 0,
    tag_temp                              => (others => '0'),
    cache_w_seq                           => '0',
    backend_buf                           => (others => 'U'),
    backend_buf_addr                      => (others => '0'),
    backend_buf_hmaster                   => (others => '0'),
    hburst                                => (others => '0'),
    htrans                                => (others => '0'),
    hsel                                  => (others => '0'),
    hwrite                                => '0',
    hmbsel                                => (others => '0'),
    hsize                                 => (others => '0'),
    hwdata                                => (others => '0'),
    haddr                                 => (others => '0'),
    hmaster                               => (others => '0'),
    cache_data_in_frontend                => (others => '0'),
    pLRU_data                             => (others => (others => '0')),
    pLRU_partition_left                   => (others => (others => '0')),
    pLRU_partition_right                  => (others => (others => '0')),
    owner_to_bitmask                      => (others => '0'),
    partitionCounters                     => (others => '0'),
    tag_match_ret                         => (0, '0'),
    haddr_buffer                          => (others => '0'),
    hwrite_buffer                         => '0',
    hmbsel_buffer                         => (others => '0'),
    hsize_buffer                          => (others => '0'),
    tagstat                               => (others => '0'),
    evict                                 => '0',
    frontend_buf                          => (others => '0'),
    f_way_counter                         => 0,
    f_addr_counter                        => 0,
    f_index                               => 0,
    f_addr                                => (others => '0'),
    f_entry_delay                         => '1',
    f_exit_delay                          => '1',
    IO_wr				                  => '0',
    IO_offset				              => 0
);

component randomWayElection is
	Generic(
		ways		 : positive;
		numBitmasks 	 : positive
	);
	Port(
		clk		         : in std_ulogic;
		rstn 	 	     : in std_ulogic;
		enable 		     : in std_ulogic;
		write 	 	     : in std_ulogic;
		renable 	     : in std_ulogic;
		bitmask_select 	 : in natural range 0 to numBitmasks - 1;
		bitmask_write 	 : in std_logic_vector(ways-1 downto 0);
		wayElected	     : out natural range 0 to ways;
		bitmask_read     : out std_logic_vector(ways - 1 downto 0)
	    );
end component;

---- SIGNALS ----
signal cachedataout  : cache_data_t;
signal w_en          : std_logic_vector(0 to ways - 1);
signal r_en          : std_ulogic;

signal tagdatain     : std_logic_vector(tag_dbits - 1 downto 0);
signal c_hit, c_miss : std_ulogic;

signal rwaddr        : std_logic_vector(addr_depth - 1 downto 0);

signal cachedatain   : std_logic_vector(linesize * 8 - 1 downto 0);
signal tagdataout    : tag_data_t;
signal repl	         : integer range 0 to 3 := 0;

signal r             : reg_type;
signal rin           : reg_type;

-- RandomWayElector signals --
signal enableWayElection : std_ulogic := '1';
signal partitionWenable  : std_ulogic;
signal bitmask_select    : natural range 0 to bitmasks - 1;
signal bitmask_write     : std_logic_vector(ways -1 downto 0);
signal randomWayElected  : natural range 0 to ways;
signal partitionReadEnable  : std_ulogic;
signal partitionBitmaskDataOut : std_logic_vector(ways - 1 downto 0);


begin

ctrlo.backend_buf(linesize * 8 - 1 downto 0) <= r.backend_buf;
ctrlo.backend_buf_addr                       <= r.backend_buf_addr;
le_owner(r.hmaster'length - 1 downto 0)         <= reversedata(r.backend_buf_hmaster, r.hmaster'length);
le_owner(le_owner'high downto r.hmaster'length) <= (others => '0');
lr_owner(r.hmaster'length - 1 downto 0)         <= reversedata(r.hmaster, r.hmaster'length);
lr_owner(lr_owner'high downto r.hmaster'length) <= (others => '0');

---- GENERATE SYNCRAM FOR TAG DATA ----
-- The syncram module generates memory blocks in multiple of 8 bits,
-- so for 15+2 bits (tag + vd flags), a 24 bit memory is implemented
--[24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00]
--|           mem(2)         |         mem(1)        |         mem(0)        |-- Memory block implemented
--|  Unused   |   Owner   |                     Tag                    | v| d|-- Bit use
tag_ram_gen : for i in 0 to ways - 1 generate
    tag_ram : syncram_2p
    generic map(
        tech     => tech,
        abits    => addr_depth,
        dbits    => tag_dbits,
        sepclk   => 0,
        wrfst    => 1,
        testen   => 0,
        pipeline => 0)
    port map(
        rclk     => clk,
        renable  => r_en,
        raddress => rwaddr,
        dataout  => tagdataout(i),
        wclk     => clk,
        write    => w_en(i),
        waddress => rwaddr,
        datain   => tagdatain);
end generate;

---- GENERATE SYNCRAM FOR CACHE DATA ----
cache_ram_gen : for i in 0 to ways - 1 generate
    cache_ram : syncram_2p
    generic map(
        tech     => tech,
        abits    => addr_depth,
        dbits    => linesize * 8,
        sepclk   => 0,
        wrfst    => 1,
        testen   => 0,
        pipeline => 0)
    port map(
        rclk     => clk,
        renable  => r_en,
        raddress => rwaddr,
        dataout  => cachedataout(i),
        wclk     => clk,
        write    => w_en(i),
        waddress => rwaddr,
        datain   => cachedatain);
end generate;

randomWayElector : randomWayElection
	generic map(
		ways 		    => ways,
		numBitmasks 	=> bitmasks
	)
	port map(
		clk		        => clk,
		rstn 		    => rstn,
		enable 		    => enableWayElection,
		write 		    => partitionWenable,
		renable		    => partitionReadEnable,
		bitmask_select 	=> bitmask_select,
		bitmask_write	=> bitmask_write,
		wayElected 	    => randomWayElected,
		bitmask_read    => partitionBitmaskDataOut
		);


comb : process (r, ahbsi, rstn, ctrli, tagdataout, cachedataout, randomWayElected, partitionBitmaskDataOut, repl)
    variable v        		    : reg_type;
    variable temp	            : std_logic_vector(ownerbits-1 downto 0);
    variable pLRU_left, pLRU_right  : std_logic_vector(0 to ways-2);
    variable counter  		    : integer range 0 to AHBDW/8;
    variable c_offset 		    : integer range 0 to linesize-1;
    variable partitionCountersIndex  : integer range 0 to ways*2;
begin
    ---- SAMPLE FRONTEND BUS ----
    v         := r;
    v.hburst  := ahbsi.hburst;
    v.htrans  := ahbsi.htrans;
    v.haddr   := ahbsi.haddr;
    v.hwdata  := ahbsi.hwdata;
    v.hsize   := ahbsi.hsize;
    v.hsel    := ahbsi.hsel;
    v.hmaster := ahbsi.hmaster;
    v.hmbsel  := ahbsi.hmbsel;

    repl <= ctrli.internal_repl;
    ---- RESET ----
    r_en                <= '0';
    w_en                <= (others => '0');
    v.cache_w_seq       := '0';
    v.tag_temp          := (others => '0');
    ctrlo.c_miss        <= '0';
    ctrlo.c_hit         <= '0';
    ctrlo.f_done        <= '0';
    ctrlo.not_owner     <= '0';
    v.IO_wr             := '0';
    partitionReadEnable <= '0';
    bitmask_select      <=  0 ;
    partitionWenable    <= '0';
    bitmask_write       <= (others => '0');

    case ctrli.cachectrl_s is
        when IDLE_S =>
            v.evict := '0';
            r_en <= '1'; -- TODO:REVISAR --

            if ((ctrli.seq_restart and r.hsel(hsindex) and r.htrans(1)) or (ahbsi.hsel(hsindex) and ahbsi.htrans(1))) = '1' then -- REQUEST TO CACHE

                if (ctrli.seq_restart and r.hsel(hsindex) and r.htrans(1))= '1' then --PIPELINED REQUEST

                    v.haddr_buffer  := r.haddr;
                    v.hsize_buffer  := r.hsize;
                    v.hmbsel_buffer := r.hmbsel;         
                else
                    v.haddr_buffer  := ahbsi.haddr;                     
                    v.hsize_buffer  := v.hsize;
                    v.hmbsel_buffer := v.hmbsel;
                end if;
                
                if bank_select(v.hmbsel_buffer and active_mem_banks) then -- NORMAL ACCESS
                    r_en <= '1';

                elsif bank_select(v.hmbsel_buffer and active_IO_banks) then -- IO ACCESS

                    v.IO_offset := IO_offset(v.haddr_buffer);

                end if;
		    	
            end if;


        when READ_S =>

            v.tag_match_ret := tag_match(tagdataout, r.haddr_buffer(TAG_R));
            r_en <= '1'; 

            if v.tag_match_ret.hit = '0' then ---- CACHE MISS & BACKEND NOT BUSY ----
                if ctrli.backendw_s = IDLE_S then
                    ctrlo.c_miss <= '1';


                    if repl = 1 then ---- PLRU ----
			pLRU_right := v.pLRU_partition_right(getOwnerBitmask(v.owner_to_bitmask, r.hmaster));
			pLRU_left  := v.pLRU_partition_left(getOwnerBitmask(v.owner_to_bitmask, r.hmaster));
                        pLRU_evict(v.pLRU_data(to_integer(unsigned(r.haddr_buffer(INDEX_R)))), v.rep_index, pLRU_left, pLRU_right);

                    else ---- P_RANDOM ----
			
			bitmask_select       <= getOwnerBitmask(v.owner_to_bitmask,r.hmaster);
			v.rep_index 	     := randomWayElected;

                    end if;
		    if v.rep_index = ways then
			ctrlo.not_owner <= '1';
		    else
                    	v.tagstat(DIRTY_BIT) := '0';
	                v.tagstat(VALID_BIT) := '1';
        	        line_evict(tagdataout, cachedataout, r.haddr_buffer, v.rep_index, v.backend_buf, v.backend_buf_addr, v.evict);
                	v.backend_buf_hmaster    := tagdataout(v.rep_index)(OWNER_DATA_R);

		    end if;
                end if;

            else ---- CACHE HIT ----

                if repl = 1 then
		    
		    pLRU_right := v.pLRU_partition_right(getOwnerBitmask(v.owner_to_bitmask, r.hmaster));
                    pLRU_left  := v.pLRU_partition_left(getOwnerBitmask(v.owner_to_bitmask, r.hmaster));
                    pLRU_update(v.pLRU_data(to_integer(unsigned(r.haddr_buffer(INDEX_R)))), v.pLRU_data(to_integer(unsigned(r.haddr_buffer(INDEX_R)))), v.tag_match_ret.index, pLRU_left, pLRU_right);
		end if;
		
                r_en        <= '1';
                ctrlo.c_hit <= '1';
                v.frontend_buf := cachedataout(v.tag_match_ret.index);

            end if;

        when WRITE_S =>

            v.tag_match_ret := tag_match(tagdataout, r.haddr_buffer(TAG_R));
            r_en <= '1';

            if v.tag_match_ret.hit = '0' then
                if ctrli.backendw_s = IDLE_S then ---- CACHE MISS & BACKEND NOT BUSY ----
                    ctrlo.c_miss <= '1';

                    if repl = 1 then ---- PLRU ----
			
			pLRU_right := v.pLRU_partition_right(getOwnerBitmask(v.owner_to_bitmask, r.hmaster));
			pLRU_left  := v.pLRU_partition_left(getOwnerBitmask(v.owner_to_bitmask, r.hmaster));
                        pLRU_evict(v.pLRU_data(to_integer(unsigned(r.haddr_buffer(INDEX_R)))), v.rep_index, pLRU_left, pLRU_right);
	
                    else ---- P_RANDOM ----
			
			bitmask_select       <= getOwnerBitmask(v.owner_to_bitmask,r.hmaster);
			v.rep_index 	     := randomWayElected;

                    end if;
		    if v.rep_index = ways then
			ctrlo.not_owner <= '1';
		    else
			v.tagstat(DIRTY_BIT) := '0';
	                v.tagstat(VALID_BIT) := '1';
        	        line_evict(tagdataout, cachedataout, r.haddr_buffer, v.rep_index, v.backend_buf, v.backend_buf_addr, v.evict);
                	v.backend_buf_hmaster    := tagdataout(v.rep_index)(OWNER_DATA_R);
		    end if;

                end if;

            else ---- CACHE HIT ----

                if repl = 1 then

	        	    pLRU_right := v.pLRU_partition_right(getOwnerBitmask(v.owner_to_bitmask, r.hmaster));
                    pLRU_left  := v.pLRU_partition_left(getOwnerBitmask(v.owner_to_bitmask, r.hmaster));
                    pLRU_update(v.pLRU_data(to_integer(unsigned(r.haddr_buffer(INDEX_R)))), v.pLRU_data(to_integer(unsigned(r.haddr_buffer(INDEX_R)))), v.tag_match_ret.index, pLRU_left, pLRU_right);
	    	end if;


                ctrlo.c_hit <= '1';
                v.tagstat(DIRTY_BIT) := '1';
                v.tagstat(VALID_BIT) := '1';
                
                w_en(v.tag_match_ret.index) <= '1';
                v.cache_data_in_frontend := cachedataout(v.tag_match_ret.index);
                -- if r.cache_w_seq = '1' then

                --     w_en(v.tag_match_ret.index) <= '1';
                --     r_en                        <= '0';

                -- else
                --     v.cache_data_in_frontend := cachedataout(v.tag_match_ret.index);
                --     v.tag_temp               := tagdataout(v.tag_match_ret.index)(TAG_OWNER_DATA_R);

                --     v.cache_w_seq := '1'; -- ONLY CHECKED IF WE STAY IN WRITE STATE.
                --     r_en <= '1';

                -- end if;

                if endianess = 1 then
                    v.hwdata := reversedata(v.hwdata, 8);
                end if;

                counter  := 0;
                c_offset := to_integer(unsigned(r.haddr_buffer(OFFSET_R)));
                for i in 0 to linesize - 1 loop
                    if (i > (c_offset - 1)) and (i < (c_offset + size_vector_to_int(r.hsize_buffer))) then
                        v.cache_data_in_frontend(linesize * 8 - 8 * i - 1 downto linesize * 8 - 8 * (i + 1))
                        := v.hwdata(AHBDW - 8 * counter - 1 downto AHBDW - 8 * (counter + 1));
                        counter := counter + 1;
                    end if;
                end loop;

            end if;

        when W_INCR_S =>

            if endianess = 1 then
                v.hwdata := reversedata(v.hwdata, 8);
            end if;

            counter  := 0;
            c_offset := to_integer(unsigned(r.haddr(OFFSET_R)));
            for i in 0 to linesize - 1 loop
                if (i > (c_offset - 1)) and (i < (c_offset + size_vector_to_int(r.hsize_buffer))) then
                    v.cache_data_in_frontend(linesize * 8 - 8 * i - 1 downto linesize * 8 - 8 * (i + 1))
                    := v.hwdata(AHBDW - 8 * counter - 1 downto AHBDW - 8 * (counter + 1));
                    counter := counter + 1;
                end if;
            end loop;

            w_en(v.tag_match_ret.index) <= '1';
            v.tagstat(DIRTY_BIT) := '1';
            v.tagstat(VALID_BIT) := '1';

        when R_INCR_S =>
            r_en <= '1';
            
        when IO_READ_S =>
       
            if r.IO_offset < register_count             then        -- ACCESS TO CONTROL REGISTERS HANDLED IN CONTROL MODULE
            elsif r.IO_offset < leftRegisterStart       then        -- RANDOM REPLACEMENT BITMASKS    
                
                partitionReadEnable             <= '1';
                bitmask_select                  <= (r.IO_offset - register_count);
                v.frontend_buf(ways-1 downto 0) := partitionBitmaskDataOut;
                v.frontend_buf(31 downto ways)  := (others => '0');

            elsif r.IO_offset < rightRegisterStart      then        -- PLRU BINARY TREE LEFT VECTORS 

                v.frontend_buf(ways-2 downto 0) := r.pLRU_partition_left(r.IO_offset - leftRegisterStart);
                v.frontend_buf(31 downto ways-1):= (others => '0');
 
            elsif r.IO_offset < ownerBitmasksStart      then        -- PLRU BINARY TREE RIGHT VECTORS
            
                v.frontend_buf(ways-2 downto 0) := r.pLRU_partition_right(r.IO_offset - rightRegisterStart);
                v.frontend_buf(31 downto ways-1):= (others => '0');

            elsif r.IO_offset < partitionCountersStart  then        -- OWNER TO BITMASK MAPPING REGISTERS
                
                v.frontend_buf(31 downto 0) := r.owner_to_bitmask((r.IO_offset - ownerBitmasksStart + 1) * 32 - 1 
                                                                  downto (r.IO_offset - ownerBitmasksStart) * 32);

            elsif r.IO_offset < partitionCountersStart + ways then  -- WAY REPLACEMENT COUNTERS
                partitionCountersIndex := partitionCountersStart + ways - r.IO_offset - 1;
                v.frontend_buf(31 downto 0) := r.partitionCounters((partitionCountersIndex + 1) * 32 - 1 
                                                                    downto ((partitionCountersIndex)*32));

            end if;


        when IO_WRITE_S =>
        
            if r.IO_offset < register_count             then        -- ACCESS TO CONTROL REGISTERS HANDLED IN CONTROL MODULE              
            elsif r.IO_offset < leftRegisterStart       then        -- RANDOM REPLACEMENT BITMASKS    

                partitionWenable <= '1';
                bitmask_select   <= (r.IO_offset - register_count);
                bitmask_write    <= v.hwdata(ways-1 downto 0);

            elsif r.IO_offset < rightRegisterStart      then        -- PLRU BINARY TREE LEFT VECTORS 

                v.pLRU_partition_left(r.IO_offset - leftRegisterStart) := v.hwdata(ways - 2 downto 0); 

            elsif r.IO_offset < ownerBitmasksStart      then        -- PLRU BINARY TREE RIGHT VECTORS

                v.pLRU_partition_right(r.IO_offset - rightRegisterStart) := v.hwdata(ways - 2 downto 0);

            elsif r.IO_offset < partitionCountersStart  then        -- OWNER TO BITMASK MAPPING REGISTERS

                v.owner_to_bitmask((r.IO_offset - ownerBitmasksStart + 1) * 32 - 1 downto (r.IO_offset - ownerBitmasksStart) * 32) := v.hwdata(31 downto 0);

            elsif r.IO_offset < partitionCountersStart + ways then  -- WAY REPLACEMENT COUNTERS
                partitionCountersIndex := partitionCountersStart + ways - r.IO_offset - 1;
                v.partitionCounters((partitionCountersIndex + 1) * 32 - 1 downto (partitionCountersIndex) * 32) := v.hwdata(31 downto 0);

            end if;
      
    
           

        when BACKEND_READ_S =>

            ---- ASSERTED WHEN FETCH IS FINISHED ----
            if ctrli.fetch_ready = '1' then
		
                w_en(r.rep_index) <= '1';
                r_en <= '1';

		-- UPDATE REPLACEMENT COUNTERS --
                v.partitionCounters((ways - r.rep_index) * 32 - 1 downto (ways - r.rep_index - 1) * 32) := conv_std_logic_vector(( 
	        to_integer(unsigned(r.partitionCounters((ways - r.rep_index) * 32 - 1 downto (ways - r.rep_index - 1) * 32))) + 1), 32);

            end if;
	


        when FLUSH_S                        =>
            v.cache_data_in_frontend := (others => 'U');
            v.haddr_buffer(TAG_R)    := (others => 'U');

            v.f_index := v.f_addr_counter;
            if r.f_exit_delay = '1' then
                v.f_exit_delay := '0';

            elsif ctrli.backendw_s = IDLE_S then
                r_en <= '1';
                v.f_addr := conv_std_logic_vector(v.f_index, r.f_addr'length);
                if r.f_entry_delay = '0' then

                    if (tagdataout(v.f_way_counter)(VALID_BIT) and tagdataout(v.f_way_counter)(DIRTY_BIT)) = '1' then
                        v.backend_buf                := cachedataout(v.f_way_counter);
                        v.backend_buf_addr(TAG_R)    := tagdataout(v.f_way_counter)(TAG_DATA_R);
                        v.backend_buf_addr(INDEX_R)  := v.f_addr;
                        v.backend_buf_addr(OFFSET_R) := (others => '0');
                        v.backend_buf_hmaster        := tagdataout(v.f_way_counter)(OWNER_DATA_R);
                        v.evict                      := '1';
                        v.rep_index                  := v.f_way_counter;
                    else
                        w_en(v.f_way_counter) <= '1';
                        v.tagstat(VALID_BIT) := '0';
                        v.f_entry_delay      := '1';
                        v.f_exit_delay       := '1';
                    end if;

                    if v.f_way_counter + 1 = ways then
                        v.f_way_counter := 0;                              -- reset way counter
                        if (v.f_addr_counter) = (2 ** addr_depth - 1) then -- ending flush
                            ctrlo.f_done <= '1';
                            v.f_addr_counter := 0;
                        else
                            v.f_addr_counter := r.f_addr_counter + 1; -- regular address incrementing
                        end if;
                    else
                        v.f_way_counter := r.f_way_counter + 1;
                    end if;
                else
                    v.f_entry_delay := '0';
                end if;
            end if;

            if ctrli.backendw_s = BACKEND_WRITE_S and v.evict = '1' then
                v.evict := '0';
                w_en(r.rep_index) <= '1';
                v.tagstat(1)    := '0';
                v.f_entry_delay := '1';
            end if;

        when others => null;
    end case;

    ---- CACHE INPUT MUX ----
    if ctrli.cachectrl_s = BACKEND_READ_S or ctrli.cachectrl_s = READ_S then
        cachedatain <= ctrli.cache_data_in_backend(linesize * 8 - 1 downto 0);
    else
        cachedatain <= v.cache_data_in_frontend;
    end if;

    ---- TAG DATA INPUT MUX ----
    if r.cache_w_seq = '1' then
        tagdatain(TAG_OWNER_DATA_R) <= r.tag_temp;
    else
        tagdatain(TAG_DATA_R) <= r.haddr_buffer(TAG_R);
        tagdatain(OWNER_DATA_R) <= r.hmaster;
    end if;

    ---- TAG & DATA ADDRESS INPUT MUX ----
    if ctrli.cachectrl_s = FLUSH_S then
        rwaddr <= v.f_addr;
    else
        rwaddr <= v.haddr_buffer(INDEX_R);
    end if;

    ---- PSEUDO RANDOM COUNTER ----
    v.pr_counter := r.pr_counter + 1;
    if r.pr_counter = ways - 1 then
        v.pr_counter := 0;
    end if;

    ---- OUTPUTS ----
    tagdatain(1 downto 0)                         <= v.tagstat(1 downto 0);
    ctrlo.frontend_buf(linesize * 8 - 1 downto 0) <= v.frontend_buf;
    ctrlo.evict                                   <= v.evict;


    rin <= v;

end process;

---- ASYNC RESET ----
regs : process (clk, rstn)
begin
    if rstn = '0' then
        r <= init_r;
    elsif rising_edge(clk) then
        r <= rin;
    end if;
end process;

end architecture rtl;