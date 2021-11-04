--MIT License
--
--Copyright (c) 2021 UPV 
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.stdlib.all;
use grlib.amba.all;

library interconnect;
use interconnect.libnoc.all;
use interconnect.libnoc_pkg.all;
--pragma translate_off
use interconnect.axi_xbar_typedef_pkg.all;
--pragma translate_on

 entity axi_dw_wrapper is
  generic(
     AxiMaxReads         : integer;        
     AxiSlvPortDataWidth : integer; 
     AxiMstPortDataWidth : integer
   --  AxiAddrWidth        : integer;
   --  AxiIdWidth          : integer
   );
  port (
    clk: in std_logic;
    rst: in std_logic;
    axi_component_in   : in  axi4wide_mosi_type;
    axi_component_out  : out axiwide_somi_type;
    axi_from_noc: in  axi_somi_type;
    axi_to_noc  : out axi4_mosi_type  
  );   
  end entity;

architecture RTL of axi_dw_wrapper is
  signal slv_port_req  : slv_req_wide_t;
  signal slv_port_resp : slv_resp_wide_t;
  signal mst_port_req  : slv_req_t;
  signal mst_port_resp : slv_resp_t;

begin

    slv_port_req.aw.id    <= axi_component_in.aw.id(AxiIdWidthSlaves-1 downto 0);-- NOTE WARNING
    slv_port_req.aw.addr  <= axi_component_in.aw.addr;
    slv_port_req.aw.len   <= axi_component_in.aw.len;
    slv_port_req.aw.size  <= axi_component_in.aw.size;
    slv_port_req.aw.burst <= axi_component_in.aw.burst;
    slv_port_req.aw.lock  <= axi_component_in.aw.lock; 
    slv_port_req.aw.cache <= axi_component_in.aw.cache;
    slv_port_req.aw.prot  <= axi_component_in.aw.prot;
    slv_port_req.aw.qos   <= (others => '0'); --not used on grlib but commented out on amba.vhd
    slv_port_req.aw.region<= (others => '0'); --not used on grlib AXI Transaction region type
    slv_port_req.aw.atop  <= (others => '0'); --not used on grlib ATOMIC OPERATIONS
    slv_port_req.aw.user  <= (others => '0'); --not used on grlib
    slv_port_req.aw_valid <= axi_component_in.aw.valid;

    slv_port_req.w.data   <= axi_component_in.w.data;
    slv_port_req.w.strb   <= axi_component_in.w.strb;
    slv_port_req.w.last   <= axi_component_in.w.last;
    slv_port_req.w.user   <= (others => '0'); --not used on grlib
    slv_port_req.w_valid  <= axi_component_in.w.valid;
    
    slv_port_req.b_ready  <= axi_component_in.b.ready;

    slv_port_req.ar.id    <= axi_component_in.ar.id(AxiIdWidthSlaves-1 downto 0); -- NOTE WARNING
    slv_port_req.ar.addr  <= axi_component_in.ar.addr;
    slv_port_req.ar.len   <= axi_component_in.ar.len;
    slv_port_req.ar.size  <= axi_component_in.ar.size;
    slv_port_req.ar.burst <= axi_component_in.ar.burst;
    slv_port_req.ar.lock  <= axi_component_in.ar.lock; 
    slv_port_req.ar.cache <= axi_component_in.ar.cache;
    slv_port_req.ar.prot  <= axi_component_in.ar.prot;
    slv_port_req.ar.qos   <= (others => '0'); --not used on grlib but commented out on amba.vhd
    slv_port_req.ar.region<= (others => '0'); --not used on grlib
    slv_port_req.ar.user  <= (others => '0'); --not used on glrib
    slv_port_req.ar_valid <= axi_component_in.ar.valid;
    
    slv_port_req.r_ready  <= axi_component_in.r.ready; 

    axi_to_noc.aw.id(AxiIdWidthSlaves-1 downto 0)    <=  mst_port_req.aw.id; --NOTE WARNING
    axi_to_noc.aw.id(3 downto AxiIdWidthSlaves)      <= (others => '0');
    axi_to_noc.aw.addr   <=  mst_port_req.aw.addr;
    axi_to_noc.aw.len    <=  mst_port_req.aw.len;
    axi_to_noc.aw.size   <=  mst_port_req.aw.size;
    axi_to_noc.aw.burst  <=  mst_port_req.aw.burst;
    axi_to_noc.aw.lock   <=  mst_port_req.aw.lock;
    axi_to_noc.aw.cache  <=  mst_port_req.aw.cache;
    axi_to_noc.aw.prot   <=  mst_port_req.aw.prot;
    axi_to_noc.aw.valid  <=  mst_port_req.aw_valid;

    axi_to_noc.w.data    <=  mst_port_req.w.data;
    axi_to_noc.w.strb    <=  mst_port_req.w.strb;
    axi_to_noc.w.last    <=  mst_port_req.w.last;
    axi_to_noc.w.valid   <=  mst_port_req.w_valid;
    --axi_to_noc.w.id      <=  mst_port_req.aw.id; --(others => '0'); --not defined on pulp_types,
    
    axi_to_noc.b.ready   <=  mst_port_req.b_ready;

    axi_to_noc.ar.id(AxiIdWidthSlaves-1 downto 0)    <= mst_port_req.ar.id;
    axi_to_noc.ar.id(3 downto AxiIdWidthSlaves)      <= (others => '0');
    axi_to_noc.ar.addr   <= mst_port_req.ar.addr;
    axi_to_noc.ar.len    <= mst_port_req.ar.len;
    axi_to_noc.ar.size   <= mst_port_req.ar.size;
    axi_to_noc.ar.burst  <= mst_port_req.ar.burst;
    axi_to_noc.ar.lock   <= mst_port_req.ar.lock;
    axi_to_noc.ar.cache  <= mst_port_req.ar.cache;
    axi_to_noc.ar.prot   <= mst_port_req.ar.prot;
    axi_to_noc.ar.valid  <= mst_port_req.ar_valid;
                                 
    axi_to_noc.r.ready   <= mst_port_req.r_ready;
    slv_port_req.aw.qos   <= (others => '0'); -- NOTE include appropriate value
    slv_port_req.ar.qos   <= (others => '0'); -- "" 


    axi_component_out.aw.ready  <= slv_port_resp.aw_ready;
    axi_component_out.w.ready   <= slv_port_resp.w_ready;
    
    axi_component_out.b.id(AxiIdWidthSlaves-1 downto 0)    <= slv_port_resp.b.id;
    axi_component_out.b.id(3 downto AxiIdWidthSlaves)      <= (others => '0');
    axi_component_out.b.resp    <= slv_port_resp.b.resp;
    axi_component_out.b.valid   <= slv_port_resp.b_valid;
    
    axi_component_out.ar.ready  <= slv_port_resp.ar_ready;

    axi_component_out.r.id(AxiIdWidthSlaves-1 downto 0)    <= slv_port_resp.r.id;
    axi_component_out.r.id(3 downto AxiIdWidthSlaves)      <= (others => '0');
    axi_component_out.r.data    <= slv_port_resp.r.data;
    axi_component_out.r.resp    <= slv_port_resp.r.resp;
    axi_component_out.r.last    <= slv_port_resp.r.last;
    axi_component_out.r.valid   <= slv_port_resp.r_valid;  
 
    mst_port_resp.aw_ready        <= axi_from_noc.aw.ready;
    mst_port_resp.ar_ready        <= axi_from_noc.ar.ready;
    mst_port_resp.w_ready         <= axi_from_noc.w.ready;

    mst_port_resp.b_valid         <= axi_from_noc.b.valid;
    mst_port_resp.b.id            <= axi_from_noc.b.id(AxiIdWidthSlaves-1 downto 0);
    mst_port_resp.b.resp          <= axi_from_noc.b.resp;
    mst_port_resp.b.user          <= (others => '0');
    
    mst_port_resp.r_valid         <= axi_from_noc.r.valid;
    mst_port_resp.r.id            <= axi_from_noc.r.id(AxiIdWidthSlaves-1 downto 0);
    mst_port_resp.r.data          <= axi_from_noc.r.data;
    mst_port_resp.r.resp          <= axi_from_noc.r.resp;
    mst_port_resp.r.last          <= axi_from_noc.r.last;
    mst_port_resp.r.user          <= (others => '0'); 
   
 dw_conv: width_converter_wrapper
   generic map(
     AxiMaxReads => AxiMaxReads,        
     AxiSlvPortDataWidth => AxiSlvPortDataWidth, --AxiSlvPortDataWidth, 
     AxiMstPortDataWidth => AxiMstPortDataWidth,  --AxiSlvPortDataWidth,    
     AxiAddrWidth => AxiAddrWidth, 
     AxiIdWidth => AxiIdWidthSlaves
    ) 
   port map(
    clk_i => clk,
    rst_ni => rst,
    slv_req_i => slv_port_req, 
    slv_resp_o => slv_port_resp,
    mst_req_o => mst_port_req,
    mst_resp_i => mst_port_resp
   );

  


end;
