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
use accelerators.template_pkg.all;

entity template_kernel is
    port (
      clk:              in  std_logic;
      rst_n:            in  std_logic;
      axi_control_in:   in  axi_mosi_type;
      axi_control_out:  out axi_somi_type;
--INSERT template_kernel in out ports  
      interrupt:        out std_logic
   );   
end entity;

architecture RTL of template_kernel is

--INSERT signal definitions
signal acc_slv_in:    axi_acc_slv_in;
signal acc_slv_out:   axi_acc_slv_out;

--INSERT aux_axi_addr definitions
constant C_M_AXI_CURRENT_GMEM_ADDR_WIDTH   : integer := 32;

begin
--INSERT AXI IN/OUT interfaces


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

--INSERT aux_axi_addr connections


--INSERT acc_inst
  generic map(
    C_S_AXI_CONTROL_DATA_WIDTH => C_S_AXI_CONTROL_DATA_WIDTH,
    --C_M_AXI_ACC_MST_ADDR_WIDTH => C_M_AXI_ACC_MST_ADDR_WIDTH,
    --C_M_AXI_ACC_MST_DATA_WIDTH => C_M_AXI_ACC_MST_DATA_WIDTH,
--INSERT component id_width and data_width parameters
  )
  port map (
    ap_clk               => clk,
    ap_rst_n             => rst_n,
--INSERT component port fields definition

    -- AXI4-Lite slave interface
    s_axi_control_AWVALID => acc_slv_in.s_axi_control_awvalid,
    s_axi_control_AWREADY => acc_slv_out.s_axi_control_awready,
    s_axi_control_AWADDR  => acc_slv_in.s_axi_control_awaddr, 
    s_axi_control_WVALID  => acc_slv_in.s_axi_control_wvalid,
    s_axi_control_WREADY  => acc_slv_out.s_axi_control_wready, 
    s_axi_control_WDATA   => acc_slv_in.s_axi_control_wdata, 
    s_axi_control_WSTRB   => acc_slv_in.s_axi_control_wstrb(3 downto 0), 
    s_axi_control_ARVALID => acc_slv_in.s_axi_control_arvalid, 
    s_axi_control_ARREADY => acc_slv_out.s_axi_control_arready,
    s_axi_control_ARADDR  => acc_slv_in.s_axi_control_araddr,
    s_axi_control_RVALID  => acc_slv_out.s_axi_control_rvalid,
    s_axi_control_RREADY  => acc_slv_in.s_axi_control_rready,
    s_axi_control_RDATA   => acc_slv_out.s_axi_control_rdata, 
    s_axi_control_RRESP   => acc_slv_out.s_axi_control_rresp,
    s_axi_control_BVALID  => acc_slv_out.s_axi_control_bvalid,
    s_axi_control_BREADY  => acc_slv_in.s_axi_control_bready,
--INSERT component last port fields and interrupt port  
  );


end;
