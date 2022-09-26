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

package conv_pkg is

  constant C_M_AXI_ACC_MST_ADDR_WIDTH  : integer := 32;
  constant C_M_AXI_ACC_MST_DATA_WIDTH  : integer := 512;
  constant C_S_AXI_CONTROL_ADDR_WIDTH  : integer := 9;
  constant C_S_AXI_CONTROL_DATA_WIDTH  : integer := 32;
  constant C_M_AXI_GMEM_ID_WIDTH     : integer := 1;
  constant C_M_AXI_GMEM_ADDR_WIDTH   : integer := 64;
  constant C_M_AXI_GMEM_DATA_WIDTH   : integer := 128;
  constant C_M_AXI_GMEM1_ID_WIDTH     : integer := 1;
  constant C_M_AXI_GMEM1_ADDR_WIDTH   : integer := 64;
  constant C_M_AXI_GMEM1_DATA_WIDTH   : integer := 32;
  constant C_M_AXI_GMEM2_ID_WIDTH     : integer := 1;
  constant C_M_AXI_GMEM2_ADDR_WIDTH   : integer := 64;
  constant C_M_AXI_GMEM2_DATA_WIDTH   : integer := 128;
  constant C_M_AXI_GMEM3_ID_WIDTH     : integer := 1;
  constant C_M_AXI_GMEM3_ADDR_WIDTH   : integer := 64;
  constant C_M_AXI_GMEM3_DATA_WIDTH   : integer := 128;
  constant C_M_AXI_GMEM5_ID_WIDTH     : integer := 1;
  constant C_M_AXI_GMEM5_ADDR_WIDTH   : integer := 64;
  constant C_M_AXI_GMEM5_DATA_WIDTH   : integer := 128;
  constant C_M_AXI_GMEM6_ID_WIDTH     : integer := 1;
  constant C_M_AXI_GMEM6_ADDR_WIDTH   : integer := 64;
  constant C_M_AXI_GMEM6_DATA_WIDTH   : integer := 512;

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

  component conv_kernel
    port (
      clk:              in  std_logic;
      rst_n:            in  std_logic;
      axi_control_in:   in  axi_mosi_type;
      axi_control_out:  out axi_somi_type; 
      axi_to_mem:     out axi4wide_mosi_type;
      axi_from_mem:   in  axiwide_somi_type;
      axi_to_mem_1:     out axi4wide_mosi_type;
      axi_from_mem_1:   in  axiwide_somi_type;
      axi_to_mem_2:     out axi4wide_mosi_type;
      axi_from_mem_2:   in  axiwide_somi_type;
      axi_to_mem_3:     out axi4wide_mosi_type;
      axi_from_mem_3:   in  axiwide_somi_type;
      axi_to_mem_5:     out axi4wide_mosi_type;
      axi_from_mem_5:   in  axiwide_somi_type;
      axi_to_mem_6:     out axi4wide_mosi_type;
      axi_from_mem_6:   in  axiwide_somi_type;
      interrupt:        out std_logic
    );  
  end component;

  component k_conv2D 
  is
    generic (
      C_S_AXI_CONTROL_DATA_WIDTH : integer := C_S_AXI_CONTROL_DATA_WIDTH;
      --C_M_AXI_ACC_MST_ADDR_WIDTH  : integer := C_M_AXI_ACC_MST_ADDR_WIDTH;
      --C_M_AXI_ACC_MST_DATA_WIDTH  : integer := C_M_AXI_ACC_MST_DATA_WIDTH;
      C_M_AXI_GMEM_ID_WIDTH      : integer := C_M_AXI_GMEM_ID_WIDTH;
      C_M_AXI_GMEM1_ID_WIDTH     : integer := C_M_AXI_GMEM1_ID_WIDTH;
      C_M_AXI_GMEM2_ID_WIDTH     : integer := C_M_AXI_GMEM2_ID_WIDTH;
      C_M_AXI_GMEM3_ID_WIDTH     : integer := C_M_AXI_GMEM3_ID_WIDTH;
      C_M_AXI_GMEM5_ID_WIDTH     : integer := C_M_AXI_GMEM5_ID_WIDTH;
      C_M_AXI_GMEM6_ID_WIDTH     : integer := C_M_AXI_GMEM6_ID_WIDTH;
      C_M_AXI_GMEM1_DATA_WIDTH     : integer := C_M_AXI_GMEM1_DATA_WIDTH;
      C_M_AXI_GMEM2_DATA_WIDTH     : integer := C_M_AXI_GMEM2_DATA_WIDTH;
      C_M_AXI_GMEM3_DATA_WIDTH     : integer := C_M_AXI_GMEM3_DATA_WIDTH;
      C_M_AXI_GMEM5_DATA_WIDTH     : integer := C_M_AXI_GMEM5_DATA_WIDTH;
      C_M_AXI_GMEM6_DATA_WIDTH     : integer := C_M_AXI_GMEM6_DATA_WIDTH
    );
    port (
      ap_clk                      : in std_logic;
      ap_rst_n                    : in std_logic;
      m_axi_gmem_AWVALID          : out std_logic;
      m_axi_gmem_AWREADY          : in std_logic;
      m_axi_gmem_AWADDR           : out std_logic_vector(C_M_AXI_GMEM_ADDR_WIDTH-1 downto 0);       
      m_axi_gmem_AWID             : out std_logic_vector(C_M_AXI_GMEM_ID_WIDTH-1 downto 0);
      m_axi_gmem_AWLEN            : out std_logic_vector(7 downto 0);
      m_axi_gmem_AWSIZE           : out std_logic_vector(2 downto 0);
      m_axi_gmem_AWBURST         : out std_logic_vector (1 downto 0);
      m_axi_gmem_AWLOCK :         out std_logic_vector (1 downto 0);
      m_axi_gmem_AWCACHE :        out std_logic_vector (3 downto 0);
      m_axi_gmem_AWPROT :         out std_logic_vector (2 downto 0);
      m_axi_gmem_AWQOS :          out std_logic_vector (3 downto 0);
      m_axi_gmem_AWREGION :       out std_logic_vector (3 downto 0);
      m_axi_gmem_AWUSER :         out std_logic_vector (0 downto 0);
      m_axi_gmem_WVALID :         out std_logic;
      m_axi_gmem_WREADY :         in  std_logic;
      m_axi_gmem_WDATA :          out std_logic_vector (C_M_AXI_GMEM_DATA_WIDTH-1 downto 0);
      m_axi_gmem_WSTRB :          out std_logic_vector (C_M_AXI_GMEM_DATA_WIDTH/8-1 downto 0);
      m_axi_gmem_WLAST :          out std_logic;
      m_axi_gmem_WID :            out std_logic_vector (C_M_AXI_GMEM_ID_WIDTH -1 downto 0);
      m_axi_gmem_WUSER :          out std_logic_vector (0 downto 0);
      m_axi_gmem_ARVALID :        out std_logic;
      m_axi_gmem_ARREADY :        in  std_logic;
      m_axi_gmem_ARADDR :         out std_logic_vector (C_M_AXI_GMEM_ADDR_WIDTH-1 downto 0);
      m_axi_gmem_ARID :           out std_logic_vector (C_M_AXI_GMEM_ID_WIDTH-1 downto 0);
      m_axi_gmem_ARLEN :          out std_logic_vector (7 downto 0);
      m_axi_gmem_ARSIZE :         out std_logic_vector (2 downto 0);
      m_axi_gmem_ARBURST :        out std_logic_vector (1 downto 0);
      m_axi_gmem_ARLOCK :         out std_logic_vector (1 downto 0);
      m_axi_gmem_ARCACHE :        out std_logic_vector (3 downto 0);
      m_axi_gmem_ARPROT :         out std_logic_vector (2 downto 0);
      m_axi_gmem_ARQOS :          out std_logic_vector (3 downto 0);
      m_axi_gmem_ARREGION :       out std_logic_vector (3 downto 0);
      m_axi_gmem_ARUSER :         out std_logic_vector (0 downto 0);
      m_axi_gmem_RVALID :         in  std_logic;
      m_axi_gmem_RREADY :         out std_logic;
      m_axi_gmem_RDATA :          in  std_logic_vector (C_M_AXI_GMEM_DATA_WIDTH - 1 downto 0);
      m_axi_gmem_RLAST :          in  std_logic;
      m_axi_gmem_RID :            in  std_logic_vector (C_M_AXI_GMEM_ID_WIDTH - 1 downto 0);
      m_axi_gmem_RUSER :          in  std_logic_vector (0 downto 0); 
      m_axi_gmem_RRESP :          in  std_logic_vector (1 downto 0);
      m_axi_gmem_BVALID :         in  std_logic;
      m_axi_gmem_BREADY :         out std_logic;
      m_axi_gmem_BRESP :          in  std_logic_vector (1 downto 0);
      m_axi_gmem_BID :            in  std_logic_vector (C_M_AXI_GMEM_ID_WIDTH - 1 downto 0);
      m_axi_gmem_BUSER :          in  std_logic_vector (0 downto 0);

      m_axi_gmem1_AWVALID          : out std_logic;
      m_axi_gmem1_AWREADY          : in std_logic;
      m_axi_gmem1_AWADDR           : out std_logic_vector(C_M_AXI_GMEM1_ADDR_WIDTH-1 downto 0);       
      m_axi_gmem1_AWID             : out std_logic_vector(C_M_AXI_GMEM1_ID_WIDTH-1 downto 0);
      m_axi_gmem1_AWLEN            : out std_logic_vector(7 downto 0);
      m_axi_gmem1_AWSIZE           : out std_logic_vector(2 downto 0);
      m_axi_gmem1_AWBURST         : out std_logic_vector (1 downto 0);
      m_axi_gmem1_AWLOCK :         out std_logic_vector (1 downto 0);
      m_axi_gmem1_AWCACHE :        out std_logic_vector (3 downto 0);
      m_axi_gmem1_AWPROT :         out std_logic_vector (2 downto 0);
      m_axi_gmem1_AWQOS :          out std_logic_vector (3 downto 0);
      m_axi_gmem1_AWREGION :       out std_logic_vector (3 downto 0);
      m_axi_gmem1_AWUSER :         out std_logic_vector (0 downto 0);
      m_axi_gmem1_WVALID :         out std_logic;
      m_axi_gmem1_WREADY :         in  std_logic;
      m_axi_gmem1_WDATA :          out std_logic_vector (C_M_AXI_GMEM1_DATA_WIDTH-1 downto 0);
      m_axi_gmem1_WSTRB :          out std_logic_vector (C_M_AXI_GMEM1_DATA_WIDTH/8-1 downto 0);
      m_axi_gmem1_WLAST :          out std_logic;
      m_axi_gmem1_WID :            out std_logic_vector (C_M_AXI_GMEM1_ID_WIDTH -1 downto 0);
      m_axi_gmem1_WUSER :          out std_logic_vector (0 downto 0);
      m_axi_gmem1_ARVALID :        out std_logic;
      m_axi_gmem1_ARREADY :        in  std_logic;
      m_axi_gmem1_ARADDR :         out std_logic_vector (C_M_AXI_GMEM1_ADDR_WIDTH-1 downto 0);
      m_axi_gmem1_ARID :           out std_logic_vector (C_M_AXI_GMEM1_ID_WIDTH-1 downto 0);
      m_axi_gmem1_ARLEN :          out std_logic_vector (7 downto 0);
      m_axi_gmem1_ARSIZE :         out std_logic_vector (2 downto 0);
      m_axi_gmem1_ARBURST :        out std_logic_vector (1 downto 0);
      m_axi_gmem1_ARLOCK :         out std_logic_vector (1 downto 0);
      m_axi_gmem1_ARCACHE :        out std_logic_vector (3 downto 0);
      m_axi_gmem1_ARPROT :         out std_logic_vector (2 downto 0);
      m_axi_gmem1_ARQOS :          out std_logic_vector (3 downto 0);
      m_axi_gmem1_ARREGION :       out std_logic_vector (3 downto 0);
      m_axi_gmem1_ARUSER :         out std_logic_vector (0 downto 0);
      m_axi_gmem1_RVALID :         in  std_logic;
      m_axi_gmem1_RREADY :         out std_logic;
      m_axi_gmem1_RDATA :          in  std_logic_vector (C_M_AXI_GMEM1_DATA_WIDTH - 1 downto 0);
      m_axi_gmem1_RLAST :          in  std_logic;
      m_axi_gmem1_RID :            in  std_logic_vector (C_M_AXI_GMEM1_ID_WIDTH - 1 downto 0);
      m_axi_gmem1_RUSER :          in  std_logic_vector (0 downto 0); 
      m_axi_gmem1_RRESP :          in  std_logic_vector (1 downto 0);
      m_axi_gmem1_BVALID :         in  std_logic;
      m_axi_gmem1_BREADY :         out std_logic;
      m_axi_gmem1_BRESP :          in  std_logic_vector (1 downto 0);
      m_axi_gmem1_BID :            in  std_logic_vector (C_M_AXI_GMEM1_ID_WIDTH - 1 downto 0);
      m_axi_gmem1_BUSER :          in  std_logic_vector (0 downto 0);

      m_axi_gmem2_AWVALID          : out std_logic;
      m_axi_gmem2_AWREADY          : in std_logic;
      m_axi_gmem2_AWADDR           : out std_logic_vector(C_M_AXI_GMEM2_ADDR_WIDTH-1 downto 0);       
      m_axi_gmem2_AWID             : out std_logic_vector(C_M_AXI_GMEM2_ID_WIDTH-1 downto 0);
      m_axi_gmem2_AWLEN            : out std_logic_vector(7 downto 0);
      m_axi_gmem2_AWSIZE           : out std_logic_vector(2 downto 0);
      m_axi_gmem2_AWBURST         : out std_logic_vector (1 downto 0);
      m_axi_gmem2_AWLOCK :         out std_logic_vector (1 downto 0);
      m_axi_gmem2_AWCACHE :        out std_logic_vector (3 downto 0);
      m_axi_gmem2_AWPROT :         out std_logic_vector (2 downto 0);
      m_axi_gmem2_AWQOS :          out std_logic_vector (3 downto 0);
      m_axi_gmem2_AWREGION :       out std_logic_vector (3 downto 0);
      m_axi_gmem2_AWUSER :         out std_logic_vector (0 downto 0);
      m_axi_gmem2_WVALID :         out std_logic;
      m_axi_gmem2_WREADY :         in  std_logic;
      m_axi_gmem2_WDATA :          out std_logic_vector (C_M_AXI_GMEM2_DATA_WIDTH-1 downto 0);
      m_axi_gmem2_WSTRB :          out std_logic_vector (C_M_AXI_GMEM2_DATA_WIDTH/8-1 downto 0);
      m_axi_gmem2_WLAST :          out std_logic;
      m_axi_gmem2_WID :            out std_logic_vector (C_M_AXI_GMEM2_ID_WIDTH -1 downto 0);
      m_axi_gmem2_WUSER :          out std_logic_vector (0 downto 0);
      m_axi_gmem2_ARVALID :        out std_logic;
      m_axi_gmem2_ARREADY :        in  std_logic;
      m_axi_gmem2_ARADDR :         out std_logic_vector (C_M_AXI_GMEM2_ADDR_WIDTH-1 downto 0);
      m_axi_gmem2_ARID :           out std_logic_vector (C_M_AXI_GMEM2_ID_WIDTH-1 downto 0);
      m_axi_gmem2_ARLEN :          out std_logic_vector (7 downto 0);
      m_axi_gmem2_ARSIZE :         out std_logic_vector (2 downto 0);
      m_axi_gmem2_ARBURST :        out std_logic_vector (1 downto 0);
      m_axi_gmem2_ARLOCK :         out std_logic_vector (1 downto 0);
      m_axi_gmem2_ARCACHE :        out std_logic_vector (3 downto 0);
      m_axi_gmem2_ARPROT :         out std_logic_vector (2 downto 0);
      m_axi_gmem2_ARQOS :          out std_logic_vector (3 downto 0);
      m_axi_gmem2_ARREGION :       out std_logic_vector (3 downto 0);
      m_axi_gmem2_ARUSER :         out std_logic_vector (0 downto 0);
      m_axi_gmem2_RVALID :         in  std_logic;
      m_axi_gmem2_RREADY :         out std_logic;
      m_axi_gmem2_RDATA :          in  std_logic_vector (C_M_AXI_GMEM2_DATA_WIDTH - 1 downto 0);
      m_axi_gmem2_RLAST :          in  std_logic;
      m_axi_gmem2_RID :            in  std_logic_vector (C_M_AXI_GMEM2_ID_WIDTH - 1 downto 0);
      m_axi_gmem2_RUSER :          in  std_logic_vector (0 downto 0); 
      m_axi_gmem2_RRESP :          in  std_logic_vector (1 downto 0);
      m_axi_gmem2_BVALID :         in  std_logic;
      m_axi_gmem2_BREADY :         out std_logic;
      m_axi_gmem2_BRESP :          in  std_logic_vector (1 downto 0);
      m_axi_gmem2_BID :            in  std_logic_vector (C_M_AXI_GMEM2_ID_WIDTH - 1 downto 0);
      m_axi_gmem2_BUSER :          in  std_logic_vector (0 downto 0);

      m_axi_gmem3_AWVALID          : out std_logic;
      m_axi_gmem3_AWREADY          : in std_logic;
      m_axi_gmem3_AWADDR           : out std_logic_vector(C_M_AXI_GMEM3_ADDR_WIDTH-1 downto 0);       
      m_axi_gmem3_AWID             : out std_logic_vector(C_M_AXI_GMEM3_ID_WIDTH-1 downto 0);
      m_axi_gmem3_AWLEN            : out std_logic_vector(7 downto 0);
      m_axi_gmem3_AWSIZE           : out std_logic_vector(2 downto 0);
      m_axi_gmem3_AWBURST         : out std_logic_vector (1 downto 0);
      m_axi_gmem3_AWLOCK :         out std_logic_vector (1 downto 0);
      m_axi_gmem3_AWCACHE :        out std_logic_vector (3 downto 0);
      m_axi_gmem3_AWPROT :         out std_logic_vector (2 downto 0);
      m_axi_gmem3_AWQOS :          out std_logic_vector (3 downto 0);
      m_axi_gmem3_AWREGION :       out std_logic_vector (3 downto 0);
      m_axi_gmem3_AWUSER :         out std_logic_vector (0 downto 0);
      m_axi_gmem3_WVALID :         out std_logic;
      m_axi_gmem3_WREADY :         in  std_logic;
      m_axi_gmem3_WDATA :          out std_logic_vector (C_M_AXI_GMEM3_DATA_WIDTH-1 downto 0);
      m_axi_gmem3_WSTRB :          out std_logic_vector (C_M_AXI_GMEM3_DATA_WIDTH/8-1 downto 0);
      m_axi_gmem3_WLAST :          out std_logic;
      m_axi_gmem3_WID :            out std_logic_vector (C_M_AXI_GMEM3_ID_WIDTH -1 downto 0);
      m_axi_gmem3_WUSER :          out std_logic_vector (0 downto 0);
      m_axi_gmem3_ARVALID :        out std_logic;
      m_axi_gmem3_ARREADY :        in  std_logic;
      m_axi_gmem3_ARADDR :         out std_logic_vector (C_M_AXI_GMEM3_ADDR_WIDTH-1 downto 0);
      m_axi_gmem3_ARID :           out std_logic_vector (C_M_AXI_GMEM3_ID_WIDTH-1 downto 0);
      m_axi_gmem3_ARLEN :          out std_logic_vector (7 downto 0);
      m_axi_gmem3_ARSIZE :         out std_logic_vector (2 downto 0);
      m_axi_gmem3_ARBURST :        out std_logic_vector (1 downto 0);
      m_axi_gmem3_ARLOCK :         out std_logic_vector (1 downto 0);
      m_axi_gmem3_ARCACHE :        out std_logic_vector (3 downto 0);
      m_axi_gmem3_ARPROT :         out std_logic_vector (2 downto 0);
      m_axi_gmem3_ARQOS :          out std_logic_vector (3 downto 0);
      m_axi_gmem3_ARREGION :       out std_logic_vector (3 downto 0);
      m_axi_gmem3_ARUSER :         out std_logic_vector (0 downto 0);
      m_axi_gmem3_RVALID :         in  std_logic;
      m_axi_gmem3_RREADY :         out std_logic;
      m_axi_gmem3_RDATA :          in  std_logic_vector (C_M_AXI_GMEM3_DATA_WIDTH - 1 downto 0);
      m_axi_gmem3_RLAST :          in  std_logic;
      m_axi_gmem3_RID :            in  std_logic_vector (C_M_AXI_GMEM3_ID_WIDTH - 1 downto 0);
      m_axi_gmem3_RUSER :          in  std_logic_vector (0 downto 0); 
      m_axi_gmem3_RRESP :          in  std_logic_vector (1 downto 0);
      m_axi_gmem3_BVALID :         in  std_logic;
      m_axi_gmem3_BREADY :         out std_logic;
      m_axi_gmem3_BRESP :          in  std_logic_vector (1 downto 0);
      m_axi_gmem3_BID :            in  std_logic_vector (C_M_AXI_GMEM3_ID_WIDTH - 1 downto 0);
      m_axi_gmem3_BUSER :          in  std_logic_vector (0 downto 0);

      m_axi_gmem5_AWVALID          : out std_logic;
      m_axi_gmem5_AWREADY          : in std_logic;
      m_axi_gmem5_AWADDR           : out std_logic_vector(C_M_AXI_GMEM5_ADDR_WIDTH-1 downto 0);       
      m_axi_gmem5_AWID             : out std_logic_vector(C_M_AXI_GMEM5_ID_WIDTH-1 downto 0);
      m_axi_gmem5_AWLEN            : out std_logic_vector(7 downto 0);
      m_axi_gmem5_AWSIZE           : out std_logic_vector(2 downto 0);
      m_axi_gmem5_AWBURST         : out std_logic_vector (1 downto 0);
      m_axi_gmem5_AWLOCK :         out std_logic_vector (1 downto 0);
      m_axi_gmem5_AWCACHE :        out std_logic_vector (3 downto 0);
      m_axi_gmem5_AWPROT :         out std_logic_vector (2 downto 0);
      m_axi_gmem5_AWQOS :          out std_logic_vector (3 downto 0);
      m_axi_gmem5_AWREGION :       out std_logic_vector (3 downto 0);
      m_axi_gmem5_AWUSER :         out std_logic_vector (0 downto 0);
      m_axi_gmem5_WVALID :         out std_logic;
      m_axi_gmem5_WREADY :         in  std_logic;
      m_axi_gmem5_WDATA :          out std_logic_vector (C_M_AXI_GMEM5_DATA_WIDTH-1 downto 0);
      m_axi_gmem5_WSTRB :          out std_logic_vector (C_M_AXI_GMEM5_DATA_WIDTH/8-1 downto 0);
      m_axi_gmem5_WLAST :          out std_logic;
      m_axi_gmem5_WID :            out std_logic_vector (C_M_AXI_GMEM5_ID_WIDTH -1 downto 0);
      m_axi_gmem5_WUSER :          out std_logic_vector (0 downto 0);
      m_axi_gmem5_ARVALID :        out std_logic;
      m_axi_gmem5_ARREADY :        in  std_logic;
      m_axi_gmem5_ARADDR :         out std_logic_vector (C_M_AXI_GMEM5_ADDR_WIDTH-1 downto 0);
      m_axi_gmem5_ARID :           out std_logic_vector (C_M_AXI_GMEM5_ID_WIDTH-1 downto 0);
      m_axi_gmem5_ARLEN :          out std_logic_vector (7 downto 0);
      m_axi_gmem5_ARSIZE :         out std_logic_vector (2 downto 0);
      m_axi_gmem5_ARBURST :        out std_logic_vector (1 downto 0);
      m_axi_gmem5_ARLOCK :         out std_logic_vector (1 downto 0);
      m_axi_gmem5_ARCACHE :        out std_logic_vector (3 downto 0);
      m_axi_gmem5_ARPROT :         out std_logic_vector (2 downto 0);
      m_axi_gmem5_ARQOS :          out std_logic_vector (3 downto 0);
      m_axi_gmem5_ARREGION :       out std_logic_vector (3 downto 0);
      m_axi_gmem5_ARUSER :         out std_logic_vector (0 downto 0);
      m_axi_gmem5_RVALID :         in  std_logic;
      m_axi_gmem5_RREADY :         out std_logic;
      m_axi_gmem5_RDATA :          in  std_logic_vector (C_M_AXI_GMEM5_DATA_WIDTH - 1 downto 0);
      m_axi_gmem5_RLAST :          in  std_logic;
      m_axi_gmem5_RID :            in  std_logic_vector (C_M_AXI_GMEM5_ID_WIDTH - 1 downto 0);
      m_axi_gmem5_RUSER :          in  std_logic_vector (0 downto 0); 
      m_axi_gmem5_RRESP :          in  std_logic_vector (1 downto 0);
      m_axi_gmem5_BVALID :         in  std_logic;
      m_axi_gmem5_BREADY :         out std_logic;
      m_axi_gmem5_BRESP :          in  std_logic_vector (1 downto 0);
      m_axi_gmem5_BID :            in  std_logic_vector (C_M_AXI_GMEM5_ID_WIDTH - 1 downto 0);
      m_axi_gmem5_BUSER :          in  std_logic_vector (0 downto 0);

      m_axi_gmem6_AWVALID          : out std_logic;
      m_axi_gmem6_AWREADY          : in std_logic;
      m_axi_gmem6_AWADDR           : out std_logic_vector(C_M_AXI_GMEM6_ADDR_WIDTH-1 downto 0);       
      m_axi_gmem6_AWID             : out std_logic_vector(C_M_AXI_GMEM6_ID_WIDTH-1 downto 0);
      m_axi_gmem6_AWLEN            : out std_logic_vector(7 downto 0);
      m_axi_gmem6_AWSIZE           : out std_logic_vector(2 downto 0);
      m_axi_gmem6_AWBURST         : out std_logic_vector (1 downto 0);
      m_axi_gmem6_AWLOCK :         out std_logic_vector (1 downto 0);
      m_axi_gmem6_AWCACHE :        out std_logic_vector (3 downto 0);
      m_axi_gmem6_AWPROT :         out std_logic_vector (2 downto 0);
      m_axi_gmem6_AWQOS :          out std_logic_vector (3 downto 0);
      m_axi_gmem6_AWREGION :       out std_logic_vector (3 downto 0);
      m_axi_gmem6_AWUSER :         out std_logic_vector (0 downto 0);
      m_axi_gmem6_WVALID :         out std_logic;
      m_axi_gmem6_WREADY :         in  std_logic;
      m_axi_gmem6_WDATA :          out std_logic_vector (C_M_AXI_GMEM6_DATA_WIDTH-1 downto 0);
      m_axi_gmem6_WSTRB :          out std_logic_vector (C_M_AXI_GMEM6_DATA_WIDTH/8-1 downto 0);
      m_axi_gmem6_WLAST :          out std_logic;
      m_axi_gmem6_WID :            out std_logic_vector (C_M_AXI_GMEM6_ID_WIDTH -1 downto 0);
      m_axi_gmem6_WUSER :          out std_logic_vector (0 downto 0);
      m_axi_gmem6_ARVALID :        out std_logic;
      m_axi_gmem6_ARREADY :        in  std_logic;
      m_axi_gmem6_ARADDR :         out std_logic_vector (C_M_AXI_GMEM6_ADDR_WIDTH-1 downto 0);
      m_axi_gmem6_ARID :           out std_logic_vector (C_M_AXI_GMEM6_ID_WIDTH-1 downto 0);
      m_axi_gmem6_ARLEN :          out std_logic_vector (7 downto 0);
      m_axi_gmem6_ARSIZE :         out std_logic_vector (2 downto 0);
      m_axi_gmem6_ARBURST :        out std_logic_vector (1 downto 0);
      m_axi_gmem6_ARLOCK :         out std_logic_vector (1 downto 0);
      m_axi_gmem6_ARCACHE :        out std_logic_vector (3 downto 0);
      m_axi_gmem6_ARPROT :         out std_logic_vector (2 downto 0);
      m_axi_gmem6_ARQOS :          out std_logic_vector (3 downto 0);
      m_axi_gmem6_ARREGION :       out std_logic_vector (3 downto 0);
      m_axi_gmem6_ARUSER :         out std_logic_vector (0 downto 0);
      m_axi_gmem6_RVALID :         in  std_logic;
      m_axi_gmem6_RREADY :         out std_logic;
      m_axi_gmem6_RDATA :          in  std_logic_vector (C_M_AXI_GMEM6_DATA_WIDTH - 1 downto 0);
      m_axi_gmem6_RLAST :          in  std_logic;
      m_axi_gmem6_RID :            in  std_logic_vector (C_M_AXI_GMEM6_ID_WIDTH - 1 downto 0);
      m_axi_gmem6_RUSER :          in  std_logic_vector (0 downto 0); 
      m_axi_gmem6_RRESP :          in  std_logic_vector (1 downto 0);
      m_axi_gmem6_BVALID :         in  std_logic;
      m_axi_gmem6_BREADY :         out std_logic;
      m_axi_gmem6_BRESP :          in  std_logic_vector (1 downto 0);
      m_axi_gmem6_BID :            in  std_logic_vector (C_M_AXI_GMEM6_ID_WIDTH - 1 downto 0);
      m_axi_gmem6_BUSER :          in  std_logic_vector (0 downto 0);

  
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
      s_axi_control_BRESP: out std_logic_vector(1 downto 0);
      interrupt: out std_logic
    );
    end component;
    
end package;


