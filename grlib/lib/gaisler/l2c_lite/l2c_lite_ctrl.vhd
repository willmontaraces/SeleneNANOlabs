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
use grlib.devices.all;

library techmap;
use techmap.gencomp.all;

entity l2c_lite_ctrl is
    generic (
        hsindex  : integer          := 0;
        haddr    : integer          := 16#000#;
        hmask    : integer          := 16#000#;
        ioaddr   : integer          := 16#000#;
        waysize  : integer          := 32;
        linesize : integer          := 32;
        cached   : std_logic_vector := x"FFFF";
        repl     : integer          := 0;
        ways     : integer          := 2);
    port (
        rstn   : in std_ulogic;
        clk    : in std_ulogic;
        ctrlo  : out cache_ctrli_type;
        ctrli  : in cache_ctrlo_type;
        ahbsi  : in ahb_slv_in_type;
        ahbso  : out ahb_slv_out_type;
        bm_out : in bm_out_type;
        bm_in  : out bm_in_type);
        

end entity l2c_lite_ctrl;

architecture rtl of l2c_lite_ctrl is


    constant addr_depth : integer := log2ext(waysize * (2 ** 10) / linesize);
    constant tag_len    : integer := 32 - addr_depth - log2ext(linesize);
    constant tag_dbits  : integer := tag_len + 2;
    constant owners	: integer := 2 ** ahbsi.hmaster'length;
    constant totalRegisters : integer := register_count + owners;


    -- RANGES -- 
    subtype TAG_R is natural range 31 downto addr_depth + log2ext(linesize);
    subtype TAG_DATA_R is natural range tag_dbits - 1 downto 2;
    subtype INDEX_R is natural range (addr_depth + log2ext(linesize) - 1) downto log2ext(linesize);
    subtype TAG_INDEX_R is natural range 31 downto log2ext(linesize);
    subtype OFFSET_R is natural range log2ext(linesize) - 1 downto 0;
    
    constant hconfig : ahb_config_type := (
        0      => ahb_device_reg (VENDOR_GAISLER, GAISLER_L2CL, 0, 0, 0),
        4      => gen_pnp_bar(haddr, hmask, 2, 1, 1),
        5      => gen_pnp_bar(ioaddr, IO_ADDR_MASK, 1, 0, 0),
        6      => gen_pnp_bar(16#000#, 16#000#, 0, 0, 0),
        7      => gen_pnp_bar(16#000#, 16#000#, 0, 0, 0),
        others => zero32
    );

    type reg_type is record
        control_state : state_type;
        bw_state      : bw_state_type;
        hsel  : std_logic_vector(0 to NAHBSLV - 1);
        haddr : std_logic_vector(31 downto 0);
        hwrite : std_ulogic;
        htrans : std_logic_vector(1 downto 0);
        hsize  : std_logic_vector(2 downto 0);
        hburst : std_logic_vector(2 downto 0);
        hwdata : std_logic_vector(AHBDW - 1 downto 0);
        hready : std_ulogic;
        hrdata : std_logic_vector(AHBDW - 1 downto 0);
        hresp  : std_logic_vector(1 downto 0);
        hmbsel : std_logic_vector(0 to NAHBAMR - 1);
        bmrd_addr : std_logic_vector(32 - 1 downto 0);
        bmrd_size : std_logic_vector(log2ext(max_size) - 1 downto 0);
        bmrd_req  : std_logic;
        bmwr_addr : std_logic_vector(32 - 1 downto 0);
        bmwr_size : std_logic_vector(log2ext(max_size) - 1 downto 0);
        bmwr_req  : std_logic;
    	internal_repl : integer range 0 to 3; -- DETERMINES REPLACEMENT POLICY OF CACHE --
        bmwr_data : std_logic_vector(bm_dw - 1 downto 0);
        cache_data_temp : std_logic_vector(linesize * 8 - 1 downto 0);
        bm_counter      : integer range 0 to linesize * 8/bm_dw + 1;
        fetch_delay : std_ulogic;
        write_delay : std_logic_vector(0 to 1);
        IO_wr : std_ulogic;
        seq_restart : std_ulogic;
        cache_registers : std_logic_vector(register_count * 32 - 1 downto 0);
        offset : integer range 0 to 63;
        haddr_buffer : std_logic_vector(31 downto 0);
        hwrite_buffer : std_ulogic;
        hsize_buffer  : std_logic_vector(2 downto 0);
        hburst_buffer : std_logic_vector(2 downto 0);
        hmbsel_buffer : std_logic_vector( 0 to NAHBAMR - 1);
    end record;


    signal fetch_ready : std_ulogic := '0';
    signal r, rin      : reg_type;

begin

    ahbso.hconfig <= hconfig;
    ahbso.hindex  <= hsindex;
    ahbso.hirq    <= (others => '0');
    ahbso.hsplit  <= (others => '0');
    ahbso.hresp   <= HRESP_OKAY;

    ctrlo.cachectrl_s <= r.control_state; 
    ctrlo.backendw_s  <= r.bw_state;
    ctrlo.fetch_ready <= fetch_ready;
    ctrlo.seq_restart <= r.seq_restart;

    comb : process (r, ahbsi, rstn, ctrli, bm_out, fetch_ready)
        variable v                         : reg_type;
        variable hit_trigger, miss_trigger : std_ulogic;
    	variable dirty_evict               : std_ulogic;
        variable counter                   : integer range 0 to AHBDW/8;
        variable c_offset                  : integer range 0 to linesize-1;
        variable cache_en                  : std_ulogic;
    begin
        v := r;
        ---- SAMPLE FRONTEND BUS ----
        v.haddr  := ahbsi.haddr;
        v.htrans := ahbsi.htrans;
        v.hburst := ahbsi.hburst;
        v.hwrite := ahbsi.hwrite;
        v.hsel   := ahbsi.hsel;
        v.hwdata := ahbsi.hwdata;
        v.hsize  := ahbsi.hsize;
        v.hmbsel := ahbsi.hmbsel;
        v.hrdata := (others => 'U');

        ---- BACKEND ----
        v.bmrd_req  := '0';
        v.bmrd_addr := (others => '0');
        v.bmrd_size := (others => '0');
        v.bmwr_req  := '0';
        v.bmwr_addr := (others => '0');
        v.bmwr_size := (others => '0');

        v.write_delay               := (others => '0');
        v.fetch_delay               := '0';
        v.seq_restart               := '0';
        v.IO_wr                     := '0';
        hit_trigger                 := '0';
        miss_trigger                := '0';
    	dirty_evict                 := '0';
        fetch_ready                 <= '0';
        cache_en                    := '1';
        ctrlo.cache_data_in_backend <= (others => 'U');

        
        case r.control_state is
            when IDLE_S =>
                
                if ((r.seq_restart and r.hsel(hsindex) and r.htrans(1)) or (ahbsi.hsel(hsindex) and ahbsi.htrans(1))) = '1' then -- REQUEST AVAILABLE --
                    
                    if (r.seq_restart and r.hsel(hsindex) and r.htrans(1)) = '1' then         -- PIPELINED REQUEST --
                        v.hready        := '0';                    

                        v.hwrite_buffer := r.hwrite;
                        v.hsize_buffer  := r.hsize;
                        v.hburst_buffer := r.hburst;
                        v.haddr_buffer  := r.haddr;
                        v.hmbsel_buffer := r.hmbsel;

                    else                               -- NORMAL REQUEST --
                    
                        v.hwrite_buffer := v.hwrite;
                        v.hsize_buffer  := v.hsize;
                        v.hburst_buffer := v.hburst;
                        v.haddr_buffer  := v.haddr;
                        v.hmbsel_buffer := v.hmbsel;

                    end if;

                    if bank_select(v.hmbsel_buffer and active_mem_banks) then -- REQUEST TO CACHE DATA --
                        
                        if v.hwrite_buffer = '0' then       -- READ
                            
                            if is_cachable(v.haddr_buffer(31 downto 28), cached) then
                                v.control_state := READ_S;
                            else
                                v.control_state := DIRECT_READ_S;
                            end if;
                        
                        else                                -- WRITE
                            
                            if is_cachable(v.haddr_buffer(31 downto 28), cached) then
                                v.control_state := WRITE_S;
                            else
                                v.control_state := DIRECT_WRITE_S;
                            end if;

                        end if;
                   
                     elsif bank_select(v.hmbsel_buffer and active_IO_banks) then -- IO REQUEST --

                        v.offset := IO_offset(v.haddr_buffer);
                        
                        if v.hwrite_buffer = '0' then
                            v.control_state := IO_READ_S;                            
                        else
                            v.control_state := IO_WRITE_S;
                        end if;

                     end if;
                end if;


            when READ_S =>
                v.hready := '0';
                if (ctrli.c_miss = '1') and (r.fetch_delay = '0') then -- CACHE MISS

		            if ctrli.not_owner = '1' then
			            v.control_state := DIRECT_READ_S;
		            else 
                    	v.control_state := BACKEND_READ_S;
                    	miss_trigger    := '1';
		            end if;

                elsif ctrli.c_hit = '1' then

                    v.hready    := '1';
                    hit_trigger := '1';

                    counter  := 0;
                    c_offset := to_integer(unsigned(r.haddr_buffer(OFFSET_R)));

                    for i in 0 to AHBDW/8 - 1 loop
                        v.hrdata(AHBDW - 8 * i - 1 downto AHBDW - (i + 1) * 8) :=
                        ctrli.frontend_buf(linesize * 8 - (c_offset + counter) * 8 - 1 downto linesize * 8 - (c_offset + counter + 1) * 8);
                        if counter = size_vector_to_int(r.hsize_buffer) - 1 then
                            counter := 0;
                        else
                            counter := counter + 1;
                        end if;
                    end loop;

                    if endianess = 1 then
                        v.hrdata := reversedata(v.hrdata, 8);
                    end if;

                    if v.htrans = HTRANS_IDLE then

                        v.control_state := IDLE_S;

                    elsif r.hburst_buffer = HBURST_INCR then

                        v.control_state := R_INCR_S;

                        if r.haddr_buffer(TAG_INDEX_R) /= v.haddr(TAG_INDEX_R) or v.htrans /= HTRANS_SEQ then
                            v.control_state := IDLE_S;
                            v.seq_restart   := '1';
                        end if;

                    else
                        ---- UNLESS THE BUS SHOWS IDLE THIS CYCLE,         ----
                        ---- WE NEED TO HANDLE THE NEXT ACCESS IMMEDIATELY ----
                        v.control_state := IDLE_S;
                        v.seq_restart   := '1';

                    end if;
                end if;

            when WRITE_S =>
                v.hready := '0';

                if (ctrli.c_miss = '1') then
		    
        		    if ctrli.not_owner = '1' then
		            	v.control_state := DIRECT_WRITE_S;
		            else 
                    	v.control_state := BACKEND_READ_S;
                    	miss_trigger    := '1';
		            end if;

                elsif ctrli.c_hit = '1' then
                    
                    if v.htrans = HBURST_INCR then
                        
                        v.control_state := W_INCR_S;
                        
                        if r.haddr_buffer(TAG_INDEX_R) /= v.haddr(TAG_INDEX_R) or v.htrans /=  HTRANS_SEQ then
                            v.control_state := WRITE_S;
                        end if;

                    else
                        hit_trigger     := '1';
                        v.hready        := '1';
                        v.control_state := IDLE_S;
                    end if;

                    hit_trigger         := '1';
                    v.hready            := '1';

                    if v.htrans /= HTRANS_IDLE then
                        v.seq_restart := '1';
                    end if;


                    -- if r.write_delay(0) = '1' then ---- DELAY FOR SINGLE WRITES ----

                    --     v.control_state := IDLE_S;
                    --     v.hready        := '1';

                    --     if v.htrans /= HTRANS_IDLE then
                    --         v.seq_restart := '1';
                    --     end if;

                    -- elsif r.write_delay(1) = '1' then ---- DELAY FOR INCREMENT WRITES ----

                    --     v.control_state := IDLE_S;
                    --     v.seq_restart   := '1';
                    --     v.hready        := '1';

                    -- elsif v.htrans = HTRANS_IDLE then

                    --     v.write_delay(0) := '1';
                    --     hit_trigger      := '1';

                    -- elsif r.hburst_buffer = HBURST_INCR then

                    --     v.control_state := W_INCR_S;
                    --     hit_trigger     := '1';

                    --     if r.haddr_buffer(TAG_INDEX_R) /= v.haddr(TAG_INDEX_R) or v.htrans /= HTRANS_SEQ then
                    --         v.write_delay(1) := '1';
                    --         v.control_state  := WRITE_S;
                    --     end if;
                    -- else
                    --     v.write_delay(1) := '1';
                    --     hit_trigger      := '1';
                    -- end if;
                end if;

            when R_INCR_S =>
                v.hready    := '1';
                hit_trigger := '1';

                counter  := 0;
                c_offset := to_integer(unsigned(r.haddr(OFFSET_R)));
                for i in 0 to AHBDW/8 - 1 loop
                    v.hrdata(AHBDW - 8 * i - 1 downto AHBDW - (i + 1) * 8) :=
                    ctrli.frontend_buf(linesize * 8 - (c_offset + counter) * 8 - 1 downto linesize * 8 - (c_offset + counter + 1) * 8);

                    if counter = size_vector_to_int(r.hsize_buffer) - 1 then
                        counter := 0;
                    else
                        counter := counter + 1;
                    end if;
                end loop;

                if endianess = 1 then
                    v.hrdata := reversedata(v.hrdata, 8);
                end if;

                if v.htrans = HTRANS_IDLE then

                    v.control_state := IDLE_S;

                elsif (v.htrans = HTRANS_SEQ) and r.haddr_buffer(TAG_INDEX_R) = v.haddr(TAG_INDEX_R) then

                else
                    v.seq_restart   := '1';
                    v.control_state := IDLE_S;
                end if;

            when W_INCR_S =>
                v.hready    := '1';
                hit_trigger := '1';

                if v.htrans = HTRANS_IDLE then

                    v.control_state := IDLE_S;

                elsif (v.htrans = HTRANS_SEQ) and r.haddr_buffer(TAG_INDEX_R) = v.haddr(TAG_INDEX_R) then

                else
                    v.seq_restart   := '1';
                    v.control_state := IDLE_S;
                end if;



            when IO_READ_S =>
                
                v.hready := '1';
                
                if r.offset < register_count  then -- ACCESS TO CONTROL MODULE REGISTERS --

                    for i in 0 to 3 loop
                        v.hrdata(i*32 + 31 downto i*32) := r.cache_registers((register_count - r.offset) * 32 - 1
                                                                              downto (register_count - (r.offset + 1))*32);
                    end loop;

                elsif r.offset < register_count + ways + owners then                           -- ACCESS TO MEMORY MODULE REGISTERS  --

                    for i in 0 to 3 loop
                        v.hrdata(i*32 + 31 downto i*32) := ctrli.frontend_buf(31 downto 0);
                    end loop;
                end if;

                if v.htrans /= HTRANS_IDLE then 
                    v.seq_restart   := '1';
                end if;

                v.control_state := IDLE_S;
                    


            when IO_WRITE_S =>
                
                v.hready := '1';
                
                if r.offset < register_count then -- ACCESS TO CONTROL REGISTERS --

                    if r.offset = register_count - 2 then -- CACHE INFO REGISTER --

                        v.internal_repl := to_integer(unsigned(ahbsi.hwdata(31 downto 30))); -- CHANGES REPLACEMENT POLICY

                    else                                  

                        v.cache_registers((register_count - r.offset) * 32 - 1 downto (register_count - (r.offset + 1))*32) := ahbsi.hwdata(31 downto 0);

                    end if;
                end if;

                if v.htrans /= HTRANS_IDLE then
                    v.seq_restart := '1';
                end if;

                v.control_state := IDLE_S;


            when BACKEND_READ_S =>

                if r.fetch_delay = '1' then

                    ctrlo.cache_data_in_backend(linesize * 8 - 1 downto 0) <= r.cache_data_temp;

                    fetch_ready <= '1';
                    v.bm_counter := 0;

                    if r.hwrite_buffer = '0' then
                        v.control_state := READ_S;
                    else
                        v.control_state := WRITE_S;
                    end if;

                    v.fetch_delay := '1';

                elsif bm_out.bmrd_req_granted = '1' then
                    v.bmrd_req            := '1';
                    v.bmrd_addr           := r.haddr_buffer;
                    v.bmrd_addr(OFFSET_R) := (others => '0');
                    v.bmrd_size           := conv_std_logic_vector(linesize - 1, r.bmwr_size'length);
                    v.bm_counter          := 0;

                elsif bm_out.bmrd_valid = '1' then

                    v.cache_data_temp(linesize * 8 - bm_dw * r.bm_counter - 1
                    downto linesize * 8 - bm_dw * (1 + r.bm_counter)) := bm_out.bmrd_data;

                    if bm_out.bmrd_done = '1' then

                        ctrlo.cache_data_in_backend(linesize * 8 - 1 downto 0) <= r.cache_data_temp;

                        v.fetch_delay := '1';
                    else
                        v.bm_counter := r.bm_counter + 1;
                    end if;

                end if;

            when DIRECT_READ_S =>
                v.hready := '0';

                if bm_out.bmrd_req_granted = '1' then
                    v.bmrd_req  := '1';
                    v.bmrd_addr := r.haddr_buffer;
                    v.bmrd_size := conv_std_logic_vector(size_vector_to_int(r.hsize_buffer) - 1, r.bmrd_size'length);

                elsif (bm_out.bmrd_valid and bm_out.bmrd_done) = '1' then

                    counter  := 0;
                    c_offset := to_integer(unsigned(r.haddr_buffer(OFFSET_R)));
                    for i in 0 to AHBDW/8 - 1 loop
                        v.hrdata(AHBDW - 8 * i - 1 downto AHBDW - (i + 1) * 8) :=
                        bm_out.bmrd_data(bm_dw - (counter) * 8 - 1 downto bm_dw - (counter + 1) * 8);

                        if counter = size_vector_to_int(r.hsize_buffer) - 1 then
                            counter := 0;
                        else
                            counter := counter + 1;
                        end if;
                    end loop;

                    if endianess = 1 then
                        v.hrdata := reversedata(v.hrdata, 8);
                    end if;

                    v.hready        := '1';
                    v.control_state := IDLE_S;

                    if v.htrans /= HTRANS_IDLE then
                        v.seq_restart := '1';
                    end if;

                end if;

            when DIRECT_WRITE_S =>
                v.hready := '0';

                if r.write_delay(0) = '1' then

                elsif bm_out.bmwr_req_granted = '1' then
                    v.hready    := '0';
                    v.bmwr_req  := '1';
                    v.bmwr_addr := r.haddr_buffer;
                    v.bmwr_size := conv_std_logic_vector(size_vector_to_int(r.hsize_buffer) - 1, r.bmwr_size'length);

                    if endianess = 1 then
                        v.hwdata := reversedata(v.hwdata, 8);
                    end if;

                    counter := 0;
                    for i in 0 to AHBDW/8 - 1 loop
                        if counter < size_vector_to_int(r.hsize_buffer) then
                            v.bmwr_data(bm_dw - 8 * counter - 1 downto bm_dw - 8 * (counter + 1)) :=
                            v.hwdata(AHBDW - 8 * counter - 1 downto AHBDW - 8 * (counter + 1));
                            counter := counter + 1;
                        end if;
                    end loop;

                elsif bm_out.bmwr_done = '1' then
                    v.control_state := IDLE_S;
                    v.hready        := '1';

                    if v.htrans /= HTRANS_IDLE then
                        v.seq_restart := '1';
                    end if;

                end if;

            when FLUSH_S =>
                v.hready := '0';

                if ctrli.f_done = '1' then
                    v.hready        := '1';
                    v.control_state := IDLE_S;
                    v.cache_registers(register_count * 32 - 1
                    downto (register_count - 1) * 32) := (others => '0');
                end if;

            when others =>
        end case;
        ---- BACKEND EVICTION INTERFACE ----
        case r.bw_state is
            when IDLE_S =>

                if (ctrli.evict = '1') and ((fetch_ready = '1') or (r.control_state = FLUSH_S)) then
                    v.bw_state := BACKEND_WRITE_S;
		    dirty_evict := '1';


                end if;

            when BACKEND_WRITE_S =>

                if bm_out.bmwr_req_granted = '1' then

                    v.bmwr_req   := '1';
                    v.bmwr_addr  := ctrli.backend_buf_addr;
                    v.bmwr_size  := conv_std_logic_vector(linesize - 1, r.bmwr_size'length);
                    v.bmwr_data  := ctrli.backend_buf(linesize * 8 - 1 downto linesize * 8 - bm_dw);
                    v.bm_counter := 0;

                end if;
                if bm_out.bmwr_full = '0' and (r.bm_counter < linesize * 8/bm_dw - 1) then

                    v.bm_counter := r.bm_counter + 1;

                    v.bmwr_data := ctrli.backend_buf(linesize * 8 - bm_dw * v.bm_counter - 1
                    downto linesize * 8 - bm_dw * (1 + v.bm_counter));

                end if;
                
                if v.bm_counter >= linesize *8 /bm_dw - 1 then

                    v.bm_counter    := 0;
                    v.bw_state      := IDLE_S;
                    
                end if;
                
                -- BACKEND DOES NOT WAIT FOR BACKEND WRITE TO BE DONE

                -- if bm_out.bmwr_done = '1' then

                --     v.bw_state   := IDLE_S;
                --     v.bm_counter := 0;

                -- else

                -- end if;

            when others =>
        end case;

        ---- FLUSH TRIGGER ----
        if v.cache_registers(register_count * 32 - 32) = '1' then
            v.control_state := FLUSH_S;
            v.hready        := '0';
        end if;

        ---- UPDATES INTERNAL CACHE REGISTERS ----
        if hit_trigger = '1' then	
            v.cache_registers((register_count - 1) * 32 - 1 downto (register_count - (1 + 1)) * 32) := conv_std_logic_vector((
            to_integer(unsigned(r.cache_registers((register_count - 1) * 32 - 1 downto (register_count - (1 + 1)) * 32))) + 1), 32);
        end if;
        if miss_trigger = '1' then
            v.cache_registers((register_count - 2) * 32 - 1 downto (register_count - (2 + 1)) * 32) := conv_std_logic_vector((
            to_integer(unsigned(r.cache_registers((register_count - 2) * 32 - 1 downto (register_count - (2 + 1)) * 32))) + 1), 32);
        end if;

	    if dirty_evict = '1' then
	        v.cache_registers((register_count - 4) * 32 - 1 downto (register_count - (4 + 1)) * 32) := conv_std_logic_vector((
	        to_integer(unsigned(r.cache_registers((register_count - 4) * 32 - 1 downto (register_count - (4 + 1)) * 32))) + 1), 32);
    	end if;

        v.cache_registers((register_count - 3) * 32 - 1 downto (register_count - 3) * 32 - 2)   := conv_std_logic_vector(v.internal_repl, 2); 
        v.cache_registers((register_count - 3) * 32 - 5 downto (register_count - 3) * 32 - 12)  := conv_std_logic_vector(ways-1, 8); 
        v.cache_registers((register_count - 3) * 32 - 13 downto (register_count - 3) * 32 - 16) := conv_std_logic_vector(log2ext(linesize)-4, 4);
        v.cache_registers((register_count - 3) * 32 - 19 downto (register_count - 3) * 32 - 32) := conv_std_logic_vector(waysize, 14);

        --------  OUTPUTS  --------
        bm_in.bmwr_req  <= v.bmwr_req;
        bm_in.bmwr_addr <= v.bmwr_addr;
        bm_in.bmwr_size <= v.bmwr_size;
        bm_in.bmwr_data <= v.bmwr_data;

        bm_in.bmrd_req  <= v.bmrd_req;
        bm_in.bmrd_addr <= v.bmrd_addr;
        bm_in.bmrd_size <= v.bmrd_size;

        ahbso.hready <= v.hready;
        ahbso.hrdata <= v.hrdata;

	    ctrlo.internal_repl <= v.internal_repl;

        rin <= v;

    end process;
    ---- ASYNC RESET ----
    regs : process (clk, rstn)
    begin
        if rstn = '0' then
            r.hready          <= '1';
            r.cache_registers <= (others => '0');
            r.control_state   <= IDLE_S;
            r.bw_state        <= IDLE_S;
	        r.internal_repl     <= repl;

        elsif rising_edge(clk) then
            r <= rin;
        end if;
    end process;

end architecture rtl;
