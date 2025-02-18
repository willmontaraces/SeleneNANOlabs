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

library accelerators;
use accelerators.dot_prod_pkg.all;

entity dot_prod_krnl is
    port (
      clk:              in  std_logic;
      rst_n:            in  std_logic;
      axi_control_in:   in  axi_mosi_type;
      axi_control_out:  out axi_somi_type; 
      axi_to_mem_1:     out axi4wide_mosi_type;
      axi_from_mem_1:   in  axiwide_somi_type;
      axi_to_mem_2:     out axi4wide_mosi_type;
      axi_from_mem_2:   in  axiwide_somi_type;
      interrupt:        out std_logic
   );   
end entity;

architecture RTL of dot_prod_krnl is


  signal acc_mst_in_1:  axi_acc_mst_in;
  signal acc_mst_out_1: axi_acc_mst_out;
  
  signal acc_mst_in_2:  axi_acc_mst_in;
  signal acc_mst_out_2: axi_acc_mst_out;
  
  
  signal acc_slv_in:    axi_acc_slv_in;
  signal acc_slv_out:   axi_acc_slv_out;
  


  signal aux_1_axi_awaddr:    std_logic_vector(C_M_AXI_GMEM1_ADDR_WIDTH-1 downto 0);
  signal aux_1_axi_araddr:    std_logic_vector(C_M_AXI_GMEM1_ADDR_WIDTH-1 downto 0);
  
  signal aux_2_axi_awaddr:    std_logic_vector(C_M_AXI_GMEM2_ADDR_WIDTH-1 downto 0);
  signal aux_2_axi_araddr:    std_logic_vector(C_M_AXI_GMEM2_ADDR_WIDTH-1 downto 0);
  
  


--INSERT aux_axi_addr definitions
constant C_M_AXI_CURRENT_gmem_ADDR_WIDTH   : integer := 32;
constant C_M_AXI_CURRENT_gmem2_ADDR_WIDTH   : integer := 32;


begin
  axi_to_mem_1.aw.valid  <= acc_mst_out_1.m00_axi_awvalid; 
  axi_to_mem_1.aw.addr   <= acc_mst_out_1.m00_axi_awaddr(C_M_AXI_CURRENT_GMEM_ADDR_WIDTH-1 downto 0);
  axi_to_mem_1.aw.len    <= acc_mst_out_1.m00_axi_awlen;
  axi_to_mem_1.aw.id     <= acc_mst_out_1.m00_axi_awid;
  axi_to_mem_1.aw.size   <= acc_mst_out_1.m00_axi_awsize; --log2(data width in bytes)
  axi_to_mem_1.aw.burst  <= acc_mst_out_1.m00_axi_awburst; 
  axi_to_mem_1.aw.lock   <= acc_mst_out_1.m00_axi_awlock(0);
  axi_to_mem_1.aw.cache  <= acc_mst_out_1.m00_axi_awcache;
  axi_to_mem_1.aw.prot   <= acc_mst_out_1.m00_axi_awprot;
 
  axi_to_mem_1.w.valid   <= acc_mst_out_1.m00_axi_wvalid;
  axi_to_mem_1.w.data(C_M_AXI_GMEM1_DATA_WIDTH-1 downto 0)    <= acc_mst_out_1.m00_axi_wdata(C_M_AXI_GMEM1_DATA_WIDTH-1 downto 0); 
  axi_to_mem_1.w.strb(C_M_AXI_GMEM1_DATA_WIDTH/8-1 downto 0)    <= acc_mst_out_1.m00_axi_wstrb(C_M_AXI_GMEM1_DATA_WIDTH/8-1 downto 0);
  axi_to_mem_1.w.last    <= acc_mst_out_1.m00_axi_wlast; 
  axi_to_mem_1.b.ready   <= acc_mst_out_1.m00_axi_bready;
  axi_to_mem_1.ar.valid <= acc_mst_out_1.m00_axi_arvalid;
  axi_to_mem_1.ar.addr  <= acc_mst_out_1.m00_axi_araddr(C_M_AXI_CURRENT_GMEM_ADDR_WIDTH-1 downto 0);
  axi_to_mem_1.ar.len   <= acc_mst_out_1.m00_axi_arlen;
  axi_to_mem_1.ar.id    <= acc_mst_out_1.m00_axi_arid;
  axi_to_mem_1.ar.size  <= acc_mst_out_1.m00_axi_arsize;
  axi_to_mem_1.ar.burst <= acc_mst_out_1.m00_axi_arburst;
  axi_to_mem_1.ar.lock  <= acc_mst_out_1.m00_axi_arlock(0);
  axi_to_mem_1.ar.cache <= acc_mst_out_1.m00_axi_arcache;
  axi_to_mem_1.ar.prot  <= acc_mst_out_1.m00_axi_arprot;
  axi_to_mem_1.r.ready  <= acc_mst_out_1.m00_axi_rready;
 
  axi_to_mem_1.aw.qos   <= "0000";
  axi_to_mem_1.ar.qos   <= "0000";
 
 -- mst1 AXI4 interface IN
  acc_mst_in_1.m00_axi_awready <= axi_from_mem_1.aw.ready;
  acc_mst_in_1.m00_axi_wready  <= axi_from_mem_1.w.ready;
  acc_mst_in_1.m00_axi_bvalid  <= axi_from_mem_1.b.valid;
  acc_mst_in_1.m00_axi_bresp   <= axi_from_mem_1.b.resp;
  acc_mst_in_1.m00_axi_bid     <= axi_from_mem_1.b.id;
  acc_mst_in_1.m00_axi_arready <= axi_from_mem_1.ar.ready;
  acc_mst_in_1.m00_axi_rvalid  <= axi_from_mem_1.r.valid;
  acc_mst_in_1.m00_axi_rdata(C_M_AXI_GMEM1_DATA_WIDTH-1 downto 0)   <= axi_from_mem_1.r.data(C_M_AXI_GMEM1_DATA_WIDTH-1 downto 0);
  acc_mst_in_1.m00_axi_rlast   <= axi_from_mem_1.r.last;
  acc_mst_in_1.m00_axi_rid     <= axi_from_mem_1.r.id;
  acc_mst_in_1.m00_axi_rresp   <= axi_from_mem_1.r.resp;
 
 
-- mst2 AXI4 interface OUT
  axi_to_mem_2.aw.valid  <= acc_mst_out_2.m00_axi_awvalid; 
  axi_to_mem_2.aw.addr   <= acc_mst_out_2.m00_axi_awaddr(C_M_AXI_CURRENT_GMEM_ADDR_WIDTH-1 downto 0);
  axi_to_mem_2.aw.len    <= acc_mst_out_2.m00_axi_awlen;
  axi_to_mem_2.aw.id     <= acc_mst_out_2.m00_axi_awid;
  axi_to_mem_2.aw.size   <= acc_mst_out_2.m00_axi_awsize; --log2(data width in bytes)
  axi_to_mem_2.aw.burst  <= acc_mst_out_2.m00_axi_awburst; 
  axi_to_mem_2.aw.lock   <= acc_mst_out_2.m00_axi_awlock(0);
  axi_to_mem_2.aw.cache  <= acc_mst_out_2.m00_axi_awcache;
  axi_to_mem_2.aw.prot   <= acc_mst_out_2.m00_axi_awprot;
 
  axi_to_mem_2.w.valid   <= acc_mst_out_2.m00_axi_wvalid;
  axi_to_mem_2.w.data(C_M_AXI_GMEM2_DATA_WIDTH-1 downto 0)    <= acc_mst_out_2.m00_axi_wdata(C_M_AXI_GMEM2_DATA_WIDTH-1 downto 0); 
  axi_to_mem_2.w.strb(C_M_AXI_GMEM2_DATA_WIDTH/8-1 downto 0)    <= acc_mst_out_2.m00_axi_wstrb(C_M_AXI_GMEM2_DATA_WIDTH/8-1 downto 0);
  axi_to_mem_2.w.last    <= acc_mst_out_2.m00_axi_wlast; 
  axi_to_mem_2.b.ready   <= acc_mst_out_2.m00_axi_bready;
  axi_to_mem_2.ar.valid <= acc_mst_out_2.m00_axi_arvalid;
  axi_to_mem_2.ar.addr  <= acc_mst_out_2.m00_axi_araddr(C_M_AXI_CURRENT_GMEM_ADDR_WIDTH-1 downto 0);
  axi_to_mem_2.ar.len   <= acc_mst_out_2.m00_axi_arlen;
  axi_to_mem_2.ar.id    <= acc_mst_out_2.m00_axi_arid;
  axi_to_mem_2.ar.size  <= acc_mst_out_2.m00_axi_arsize;
  axi_to_mem_2.ar.burst <= acc_mst_out_2.m00_axi_arburst;
  axi_to_mem_2.ar.lock  <= acc_mst_out_2.m00_axi_arlock(0);
  axi_to_mem_2.ar.cache <= acc_mst_out_2.m00_axi_arcache;
  axi_to_mem_2.ar.prot  <= acc_mst_out_2.m00_axi_arprot;
  axi_to_mem_2.r.ready  <= acc_mst_out_2.m00_axi_rready;
 
  axi_to_mem_2.aw.qos   <= "0000";
  axi_to_mem_2.ar.qos   <= "0000";
 
 -- mst2 AXI4 interface IN
  acc_mst_in_2.m00_axi_awready <= axi_from_mem_2.aw.ready;
  acc_mst_in_2.m00_axi_wready  <= axi_from_mem_2.w.ready;
  acc_mst_in_2.m00_axi_bvalid  <= axi_from_mem_2.b.valid;
  acc_mst_in_2.m00_axi_bresp   <= axi_from_mem_2.b.resp;
  acc_mst_in_2.m00_axi_bid     <= axi_from_mem_2.b.id;
  acc_mst_in_2.m00_axi_arready <= axi_from_mem_2.ar.ready;
  acc_mst_in_2.m00_axi_rvalid  <= axi_from_mem_2.r.valid;
  acc_mst_in_2.m00_axi_rdata(C_M_AXI_GMEM2_DATA_WIDTH-1 downto 0)   <= axi_from_mem_2.r.data(C_M_AXI_GMEM2_DATA_WIDTH-1 downto 0);
  acc_mst_in_2.m00_axi_rlast   <= axi_from_mem_2.r.last;
  acc_mst_in_2.m00_axi_rid     <= axi_from_mem_2.r.id;
  acc_mst_in_2.m00_axi_rresp   <= axi_from_mem_2.r.resp;





-- slv AXI-lite out
axi_control_out.aw.ready   <= acc_slv_out.s_axi_control_awready; 
axi_control_out.w.ready    <= acc_slv_out.s_axi_control_wready; 
axi_control_out.ar.ready   <= acc_slv_out.s_axi_control_arready;
axi_control_out.r.valid    <= acc_slv_out.s_axi_control_rvalid;
axi_control_out.r.data((C_S_AXI_CONTROL_DATA_WIDTH*1)-1 downto C_S_AXI_CONTROL_DATA_WIDTH*0) <= acc_slv_out.s_axi_control_rdata;
axi_control_out.r.data((C_S_AXI_CONTROL_DATA_WIDTH*2)-1 downto C_S_AXI_CONTROL_DATA_WIDTH*1) <= acc_slv_out.s_axi_control_rdata;
axi_control_out.r.data((C_S_AXI_CONTROL_DATA_WIDTH*3)-1 downto C_S_AXI_CONTROL_DATA_WIDTH*2) <= acc_slv_out.s_axi_control_rdata;
axi_control_out.r.data((C_S_AXI_CONTROL_DATA_WIDTH*4)-1 downto C_S_AXI_CONTROL_DATA_WIDTH*3) <= acc_slv_out.s_axi_control_rdata; 
  
axi_control_out.r.resp     <= acc_slv_out.s_axi_control_rresp;     
axi_control_out.r.last     <= '0';
axi_control_out.r.id       <= "0000";
axi_control_out.b.valid    <= acc_slv_out.s_axi_control_bvalid;    
axi_control_out.b.resp     <= acc_slv_out.s_axi_control_bresp;
axi_control_out.b.id       <= "0000";

-- slv AXI-lite in
acc_slv_in.s_axi_control_awvalid <= axi_control_in.aw.valid;
acc_slv_in.s_axi_control_awaddr  <= axi_control_in.aw.addr(C_S_AXI_CONTROL_ADDR_WIDTH-1 downto 0);
acc_slv_in.s_axi_control_wvalid  <= axi_control_in.w.valid;
acc_slv_in.s_axi_control_wdata   <= axi_control_in.w.data(C_S_AXI_CONTROL_DATA_WIDTH-1 downto 0);
--This is a workaround to adapt the 32 bit wide control axi to the 128 bit wide input channel
acc_slv_in.s_axi_control_wstrb(3 downto 0)   <= axi_control_in.w.strb(3 downto 0) or
                                    axi_control_in.w.strb(7 downto 4) or
                                    axi_control_in.w.strb(11 downto 8) or
                                    axi_control_in.w.strb(15 downto 12);  
acc_slv_in.s_axi_control_arvalid <= axi_control_in.ar.valid;  
acc_slv_in.s_axi_control_araddr  <= axi_control_in.ar.addr(C_S_AXI_CONTROL_ADDR_WIDTH-1 downto 0); 
acc_slv_in.s_axi_control_rready  <= axi_control_in.r.ready;
acc_slv_in.s_axi_control_bready  <= axi_control_in.b.ready;


acc_mst_out_1.m00_axi_awaddr(C_M_AXI_CURRENT_GMEM_ADDR_WIDTH-1 downto 0) <= aux_1_axi_awaddr(C_M_AXI_CURRENT_GMEM_ADDR_WIDTH-1 downto 0);
acc_mst_out_1.m00_axi_araddr(C_M_AXI_CURRENT_GMEM_ADDR_WIDTH-1 downto 0) <= aux_1_axi_araddr(C_M_AXI_CURRENT_GMEM_ADDR_WIDTH-1 downto 0);

acc_mst_out_2.m00_axi_awaddr(C_M_AXI_CURRENT_GMEM_ADDR_WIDTH-1 downto 0) <= aux_2_axi_awaddr(C_M_AXI_CURRENT_GMEM_ADDR_WIDTH-1 downto 0);
acc_mst_out_2.m00_axi_araddr(C_M_AXI_CURRENT_GMEM_ADDR_WIDTH-1 downto 0) <= aux_2_axi_araddr(C_M_AXI_CURRENT_GMEM_ADDR_WIDTH-1 downto 0);




--INSERT acc_inst
  acc_inst : dot_prod_kernel 
  generic map(
    C_S_AXI_CONTROL_DATA_WIDTH => C_S_AXI_CONTROL_DATA_WIDTH,
    C_S_AXI_CONTROL_ADDR_WIDTH => C_S_AXI_CONTROL_ADDR_WIDTH,
    C_M_AXI_gmem1_ID_WIDTH     => C_M_AXI_GMEM1_ID_WIDTH, 
    C_M_AXI_gmem1_ADDR_WIDTH   => C_M_AXI_GMEM1_ADDR_WIDTH,
    C_M_AXI_gmem1_DATA_WIDTH   => C_M_AXI_GMEM1_DATA_WIDTH,
    C_M_AXI_GMEM1_AWUSER_WIDTH => C_M_AXI_GMEM1_AWUSER_WIDTH,
    C_M_AXI_GMEM1_WUSER_WIDTH  => C_M_AXI_GMEM1_WUSER_WIDTH,
    C_M_AXI_GMEM1_ARUSER_WIDTH => C_M_AXI_GMEM1_ARUSER_WIDTH,
    C_M_AXI_GMEM1_RUSER_WIDTH  => C_M_AXI_GMEM1_RUSER_WIDTH,
    C_M_AXI_GMEM1_BUSER_WIDTH  => C_M_AXI_GMEM1_BUSER_WIDTH,
    C_M_AXI_GMEM2_ADDR_WIDTH   => C_M_AXI_GMEM2_ADDR_WIDTH,
    C_M_AXI_GMEM2_ID_WIDTH     => C_M_AXI_GMEM2_ID_WIDTH,
    C_M_AXI_GMEM2_AWUSER_WIDTH => C_M_AXI_GMEM2_AWUSER_WIDTH,
    C_M_AXI_GMEM2_DATA_WIDTH   => C_M_AXI_GMEM2_DATA_WIDTH,
    C_M_AXI_GMEM2_WUSER_WIDTH  => C_M_AXI_GMEM2_WUSER_WIDTH,
    C_M_AXI_GMEM2_ARUSER_WIDTH => C_M_AXI_GMEM2_ARUSER_WIDTH,
    C_M_AXI_GMEM2_RUSER_WIDTH  => C_M_AXI_GMEM2_RUSER_WIDTH,
    C_M_AXI_GMEM2_BUSER_WIDTH  => C_M_AXI_GMEM2_BUSER_WIDTH,
    C_M_AXI_GMEM1_USER_VALUE   => C_M_AXI_GMEM1_USER_VALUE,
    C_M_AXI_GMEM1_PROT_VALUE   => C_M_AXI_GMEM1_PROT_VALUE,
    C_M_AXI_GMEM1_CACHE_VALUE  => C_M_AXI_GMEM1_CACHE_VALUE,
    C_M_AXI_GMEM2_USER_VALUE   => C_M_AXI_GMEM2_USER_VALUE,
    C_M_AXI_GMEM2_PROT_VALUE   => C_M_AXI_GMEM2_PROT_VALUE,
    C_M_AXI_GMEM2_CACHE_VALUE  => C_M_AXI_GMEM2_CACHE_VALUE

  )
  port map (
    ap_clk               => clk,
    ap_rst_n             => rst_n,
  
    --m_axi_gmem1
    m_axi_gmem1_AWVALID   => acc_mst_out_1.m00_axi_awvalid,
    m_axi_gmem1_AWREADY   => acc_mst_in_1.m00_axi_awready,
    m_axi_gmem1_AWADDR    => aux_1_axi_awaddr,
    m_axi_gmem1_AWID      => acc_mst_out_1.m00_axi_awid(C_M_AXI_GMEM1_ID_WIDTH-1 downto 0), 
    m_axi_gmem1_AWLEN     => acc_mst_out_1.m00_axi_awlen,
    m_axi_gmem1_AWSIZE    => acc_mst_out_1.m00_axi_awsize, 
    m_axi_gmem1_AWBURST   => acc_mst_out_1.m00_axi_awburst, 
    m_axi_gmem1_AWLOCK    => acc_mst_out_1.m00_axi_awlock, 
    m_axi_gmem1_AWCACHE   => acc_mst_out_1.m00_axi_awcache, 
    m_axi_gmem1_AWPROT    => acc_mst_out_1.m00_axi_awprot, 
    m_axi_gmem1_AWQOS     => acc_mst_out_1.m00_axi_awqos,      --not used
    m_axi_gmem1_AWREGION  => acc_mst_out_1.m00_axi_awregion, --not used
    m_axi_gmem1_AWUSER    => open,
    m_axi_gmem1_WVALID    => acc_mst_out_1.m00_axi_wvalid,
    m_axi_gmem1_WREADY    => acc_mst_in_1.m00_axi_wready,
    m_axi_gmem1_WDATA     => acc_mst_out_1.m00_axi_wdata(C_M_AXI_GMEM1_DATA_WIDTH-1 downto 0),
    m_axi_gmem1_WSTRB     => acc_mst_out_1.m00_axi_wstrb(C_M_AXI_GMEM1_DATA_WIDTH/8-1 downto 0),
    m_axi_gmem1_WID       => open,
    m_axi_gmem1_WUSER     => open,
    m_axi_gmem1_WLAST     => acc_mst_out_1.m00_axi_wlast,
    m_axi_gmem1_ARVALID   => acc_mst_out_1.m00_axi_arvalid, 
    m_axi_gmem1_ARREADY   => acc_mst_in_1.m00_axi_arready,
    m_axi_gmem1_ARADDR    => aux_1_axi_araddr,
    m_axi_gmem1_ARID      => acc_mst_out_1.m00_axi_arid(C_M_AXI_GMEM1_ID_WIDTH-1 downto 0), 
    m_axi_gmem1_ARLEN     => acc_mst_out_1.m00_axi_arlen,
    m_axi_gmem1_ARSIZE    => acc_mst_out_1.m00_axi_arsize, 
    m_axi_gmem1_ARBURST   => acc_mst_out_1.m00_axi_arburst,  
    m_axi_gmem1_ARLOCK    => acc_mst_out_1.m00_axi_arlock, 
    m_axi_gmem1_ARCACHE   => acc_mst_out_1.m00_axi_arcache, 
    m_axi_gmem1_ARPROT    => acc_mst_out_1.m00_axi_arprot,  
    m_axi_gmem1_ARQOS     => acc_mst_out_1.m00_axi_arqos, 
    m_axi_gmem1_ARREGION  => acc_mst_out_1.m00_axi_arregion, 
    m_axi_gmem1_ARUSER    => open,
    m_axi_gmem1_RVALID    => acc_mst_in_1.m00_axi_rvalid,
    m_axi_gmem1_RREADY    => acc_mst_out_1.m00_axi_rready,
    m_axi_gmem1_RDATA     => acc_mst_in_1.m00_axi_rdata(C_M_AXI_GMEM1_DATA_WIDTH-1 downto 0),
    m_axi_gmem1_RLAST     => acc_mst_in_1.m00_axi_rlast,
    m_axi_gmem1_RUSER     => "0",
    m_axi_gmem1_RID       => acc_mst_in_1.m00_axi_rid(C_M_AXI_GMEM1_ID_WIDTH-1 downto 0),  
    m_axi_gmem1_RRESP     => acc_mst_in_1.m00_axi_rresp, 
    m_axi_gmem1_BVALID    => acc_mst_in_1.m00_axi_bvalid,
    m_axi_gmem1_BREADY    => acc_mst_out_1.m00_axi_bready,
    m_axi_gmem1_BRESP     => acc_mst_in_1.m00_axi_bresp, 
    m_axi_gmem1_BID       => acc_mst_in_1.m00_axi_bid(C_M_AXI_GMEM1_ID_WIDTH-1 downto 0), 
    m_axi_gmem1_BUSER     => "0",

    --m_axi_gmem2
    m_axi_gmem2_AWVALID   => acc_mst_out_2.m00_axi_awvalid,
    m_axi_gmem2_AWREADY   => acc_mst_in_2.m00_axi_awready,
    m_axi_gmem2_AWADDR    => aux_2_axi_awaddr,
    m_axi_gmem2_AWID      => acc_mst_out_2.m00_axi_awid(C_M_AXI_GMEM2_ID_WIDTH-1 downto 0), 
    m_axi_gmem2_AWLEN     => acc_mst_out_2.m00_axi_awlen,
    m_axi_gmem2_AWSIZE    => acc_mst_out_2.m00_axi_awsize, 
    m_axi_gmem2_AWBURST   => acc_mst_out_2.m00_axi_awburst, 
    m_axi_gmem2_AWLOCK    => acc_mst_out_2.m00_axi_awlock, 
    m_axi_gmem2_AWCACHE   => acc_mst_out_2.m00_axi_awcache, 
    m_axi_gmem2_AWPROT    => acc_mst_out_2.m00_axi_awprot, 
    m_axi_gmem2_AWQOS     => acc_mst_out_2.m00_axi_awqos,      --not used
    m_axi_gmem2_AWREGION  => acc_mst_out_2.m00_axi_awregion, --not used
    m_axi_gmem2_AWUSER    => open,
    m_axi_gmem2_WVALID    => acc_mst_out_2.m00_axi_wvalid,
    m_axi_gmem2_WREADY    => acc_mst_in_2.m00_axi_wready,
    m_axi_gmem2_WDATA     => acc_mst_out_2.m00_axi_wdata(C_M_AXI_GMEM2_DATA_WIDTH-1 downto 0),
    m_axi_gmem2_WSTRB     => acc_mst_out_2.m00_axi_wstrb(C_M_AXI_GMEM2_DATA_WIDTH/8-1 downto 0),
    m_axi_gmem2_WID       => open,
    m_axi_gmem2_WUSER     => open,
    m_axi_gmem2_WLAST     => acc_mst_out_2.m00_axi_wlast,
    m_axi_gmem2_ARVALID   => acc_mst_out_2.m00_axi_arvalid, 
    m_axi_gmem2_ARREADY   => acc_mst_in_2.m00_axi_arready,
    m_axi_gmem2_ARADDR    => aux_2_axi_araddr,
    m_axi_gmem2_ARID      => acc_mst_out_2.m00_axi_arid(C_M_AXI_GMEM2_ID_WIDTH-1 downto 0), 
    m_axi_gmem2_ARLEN     => acc_mst_out_2.m00_axi_arlen,
    m_axi_gmem2_ARSIZE    => acc_mst_out_2.m00_axi_arsize, 
    m_axi_gmem2_ARBURST   => acc_mst_out_2.m00_axi_arburst,  
    m_axi_gmem2_ARLOCK    => acc_mst_out_2.m00_axi_arlock, 
    m_axi_gmem2_ARCACHE   => acc_mst_out_2.m00_axi_arcache, 
    m_axi_gmem2_ARPROT    => acc_mst_out_2.m00_axi_arprot,  
    m_axi_gmem2_ARQOS     => acc_mst_out_2.m00_axi_arqos, 
    m_axi_gmem2_ARREGION  => acc_mst_out_2.m00_axi_arregion, 
    m_axi_gmem2_ARUSER    => open,
    m_axi_gmem2_RVALID    => acc_mst_in_2.m00_axi_rvalid,
    m_axi_gmem2_RREADY    => acc_mst_out_2.m00_axi_rready,
    m_axi_gmem2_RDATA     => acc_mst_in_2.m00_axi_rdata(C_M_AXI_GMEM2_DATA_WIDTH-1 downto 0),
    m_axi_gmem2_RLAST     => acc_mst_in_2.m00_axi_rlast,
    m_axi_gmem2_RUSER     => "0",
    m_axi_gmem2_RID       => acc_mst_in_2.m00_axi_rid(C_M_AXI_GMEM2_ID_WIDTH-1 downto 0),  
    m_axi_gmem2_RRESP     => acc_mst_in_2.m00_axi_rresp, 
    m_axi_gmem2_BVALID    => acc_mst_in_2.m00_axi_bvalid,
    m_axi_gmem2_BREADY    => acc_mst_out_2.m00_axi_bready,
    m_axi_gmem2_BRESP     => acc_mst_in_2.m00_axi_bresp, 
    m_axi_gmem2_BID       => acc_mst_in_2.m00_axi_bid(C_M_AXI_GMEM2_ID_WIDTH-1 downto 0), 
    m_axi_gmem2_BUSER     => "0",

        -- AXI4-Lite slave interface
    s_axi_control_AWVALID => acc_slv_in.s_axi_control_awvalid,
    s_axi_control_AWREADY => acc_slv_out.s_axi_control_awready,
    s_axi_control_AWADDR  => acc_slv_in.s_axi_control_awaddr, 
    s_axi_control_WVALID  => acc_slv_in.s_axi_control_wvalid,
    s_axi_control_WREADY  => acc_slv_out.s_axi_control_wready, 
    s_axi_control_WDATA   => acc_slv_in.s_axi_control_wdata, 
    s_axi_control_WSTRB   => acc_slv_in.s_axi_control_wstrb(3 downto 0), 
--    s_axi_control_WSTRB(15 downto 4)  => (others => '0'),
    s_axi_control_ARVALID => acc_slv_in.s_axi_control_arvalid, 
    s_axi_control_ARREADY => acc_slv_out.s_axi_control_arready,
    s_axi_control_ARADDR  => acc_slv_in.s_axi_control_araddr,
    s_axi_control_RVALID  => acc_slv_out.s_axi_control_rvalid,
    s_axi_control_RREADY  => acc_slv_in.s_axi_control_rready,
    s_axi_control_RDATA   => acc_slv_out.s_axi_control_rdata, 
    s_axi_control_RRESP   => acc_slv_out.s_axi_control_rresp,
    s_axi_control_BVALID  => acc_slv_out.s_axi_control_bvalid,
    s_axi_control_BREADY  => acc_slv_in.s_axi_control_bready,
    s_axi_control_BRESP   => acc_slv_out.s_axi_control_bresp,
    interrupt             => interrupt    
  );


end;
