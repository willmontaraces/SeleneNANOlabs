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

package template_pkg is

  constant C_M_AXI_ACC_MST_ADDR_WIDTH  : integer := 32;
  constant C_M_AXI_ACC_MST_DATA_WIDTH  : integer := 512;
--INSERT constants  

  type axi_acc_mst_out is record
    m00_axi_awvalid:   std_logic;
    m00_axi_awaddr:    std_logic_vector(C_M_AXI_ACC_MST_ADDR_WIDTH-1 downto 0);       
    m00_axi_awlen:     std_logic_vector(7 downto 0);
    m00_axi_awsize:    std_logic_vector(2 downto 0);
    m00_axi_awid:      std_logic_vector(3 downto 0); 
    m00_axi_wvalid:    std_logic;
    m00_axi_awburst:   std_logic_vector(1 downto 0);
    m00_axi_awlock :   std_logic_vector(1 downto 0);
    m00_axi_awcache:   std_logic_Vector(3 downto 0);
    m00_axi_awprot:    std_logic_vector(2 downto 0);
    m00_axi_awqos:     std_logic_vector(3 downto 0); 
    m00_axi_awregion:  std_logic_vector(3 downto 0);
    m00_axi_wdata:    std_logic_vector(C_M_AXI_ACC_MST_DATA_WIDTH-1 downto 0);
    m00_axi_wstrb:    std_logic_vector(C_M_AXI_ACC_MST_DATA_WIDTH/8-1 downto 0);
    m00_axi_wlast:    std_logic;
    m00_axi_bready:   std_logic;
    m00_axi_arvalid:  std_logic;
    m00_axi_araddr:   std_logic_vector(C_M_AXI_ACC_MST_ADDR_WIDTH-1 downto 0);
    m00_axi_arlen:    std_logic_vector(7 downto 0);
    m00_axi_arid:     std_logic_vector(3 downto 0);
    m00_axi_arsize :  std_logic_vector(2 downto 0);
    m00_axi_arburst:  std_logic_vector(1 downto 0); 
    m00_axi_arlock:   std_logic_vector(1 downto 0);
    m00_axi_arcache:  std_logic_vector(3 downto 0);
    m00_axi_arprot:   std_logic_vector(2 downto 0);
    m00_axi_arqos:    std_logic_vector(3 downto 0);
    m00_axi_arregion: std_logic_vector(3 downto 0);
    m00_axi_rready:   std_logic;
  end record;
  
  type axi_acc_mst_in is record
    m00_axi_rid : std_logic_vector(3 downto 0);
    m00_axi_rresp : std_logic_vector(1 downto 0);
    m00_axi_awready:   std_logic;
    m00_axi_wready:    std_logic;
    m00_axi_bvalid:   std_logic;
    m00_axi_bresp:    std_logic_vector(1 downto 0);
    m00_axi_bid:      std_logic_vector(3 downto 0);
    m00_axi_arready:  std_logic;
    m00_axi_rvalid:   std_logic;
    m00_axi_rdata:    std_logic_vector(C_M_AXI_ACC_MST_DATA_WIDTH-1 downto 0);
    m00_axi_rlast:    std_logic; 
  end record;
  
  type axi_acc_slv_out is record --AXI-lite slave interface
    s_axi_control_awready:    std_logic;
    s_axi_control_wready:     std_logic;
    s_axi_control_arready:    std_logic;
    s_axi_control_rvalid:     std_logic;
    s_axi_control_rdata:     std_logic_vector(C_S_AXI_CONTROL_DATA_WIDTH-1 downto 0);
    s_axi_control_rresp:     std_logic_vector(1 downto 0);
    s_axi_control_bvalid:    std_logic;
    s_axi_control_bresp:     std_logic_vector(1 downto 0);
  end record;
  
  type axi_acc_slv_in is record
    s_axi_control_awvalid:   std_logic;
    s_axi_control_awaddr:    std_logic_vector(C_S_AXI_CONTROL_ADDR_WIDTH-1 downto 0);
    s_axi_control_wvalid:    std_logic;
    s_axi_control_wdata:     std_logic_vector(C_S_AXI_CONTROL_DATA_WIDTH-1 downto 0);
    s_axi_control_wstrb:     std_logic_vector(C_S_AXI_CONTROL_DATA_WIDTH/8-1 downto 0);
    s_axi_control_arvalid:   std_logic;
    s_axi_control_araddr:    std_logic_vector(C_S_AXI_CONTROL_ADDR_WIDTH-1 downto 0);
    s_axi_control_rready:    std_logic;
    s_axi_control_bready:    std_logic;
  end record; 

  component template_kernel
    port (
      clk:              in  std_logic;
      rst_n:            in  std_logic;
      axi_control_in:   in  axi_mosi_type;
      axi_control_out:  out axi_somi_type; 
--INSERT template_kernel in out ports    
      interrupt:        out std_logic
    );  
  end component;

--INSERT component definition
  is
    generic (
      C_S_AXI_CONTROL_DATA_WIDTH : integer := C_S_AXI_CONTROL_DATA_WIDTH;
      --C_M_AXI_ACC_MST_ADDR_WIDTH  : integer := C_M_AXI_ACC_MST_ADDR_WIDTH;
      --C_M_AXI_ACC_MST_DATA_WIDTH  : integer := C_M_AXI_ACC_MST_DATA_WIDTH;
--INSERT component id_width and data_width parameters
    );
    port (
      ap_clk                      : in std_logic;
      ap_rst_n                    : in std_logic;
--INSERT component port fields definition
  
      -- AXI4-Lite slave interface
      s_axi_control_AWVALID: in std_logic;
      s_axi_control_AWREADY: out std_logic;
      s_axi_control_AWADDR: in std_logic_vector(C_S_AXI_CONTROL_ADDR_WIDTH-1 downto 0);
      s_axi_control_WVALID: in std_logic;
      s_axi_control_WREADY: out std_logic;
      s_axi_control_WDATA: in std_logic_vector(C_S_AXI_CONTROL_DATA_WIDTH-1 downto 0);
      s_axi_control_WSTRB: in std_logic_vector(C_S_AXI_CONTROL_DATA_WIDTH/8-1 downto 0);
      s_axi_control_ARVALID: in std_logic;
      s_axi_control_ARREADY: out  std_logic;
      s_axi_control_ARADDR: in std_logic_vector(C_S_AXI_CONTROL_ADDR_WIDTH-1 downto 0);
      s_axi_control_RVALID: out std_logic;
      s_axi_control_RREADY: in std_logic;
      s_axi_control_RDATA: out std_logic_vector(C_S_AXI_CONTROL_DATA_WIDTH-1 downto 0);
      s_axi_control_RRESP: out std_logic_vector(1 downto 0);
      s_axi_control_BVALID: out std_logic;
      s_axi_control_BREADY: in std_logic;
--INSERT component last port fields and interrupt port
    );
    end component;
    
end package;


