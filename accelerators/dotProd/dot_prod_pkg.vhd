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

package dot_prod_pkg is

  constant C_M_AXI_ACC_MST_ADDR_WIDTH  : integer := 32;
  constant C_M_AXI_ACC_MST_DATA_WIDTH  : integer := 512;
  constant    C_S_AXI_CONTROL_DATA_WIDTH : integer := 32;
  constant    C_S_AXI_CONTROL_ADDR_WIDTH : integer := 6;
  constant    C_S_AXI_DATA_WIDTH : integer := 32;
  constant    C_M_AXI_GMEM1_ID_WIDTH : integer := 2;
  constant    C_M_AXI_GMEM1_ADDR_WIDTH : integer := 32;
  constant    C_M_AXI_GMEM1_DATA_WIDTH : integer := 32;
  constant    C_M_AXI_GMEM1_AWUSER_WIDTH : integer := 1;
  constant    C_M_AXI_GMEM1_ARUSER_WIDTH : integer := 1;
  constant    C_M_AXI_GMEM1_WUSER_WIDTH : integer := 1;
  constant    C_M_AXI_GMEM1_RUSER_WIDTH : integer := 1;
  constant    C_M_AXI_GMEM1_BUSER_WIDTH : integer := 1;
  constant    C_M_AXI_GMEM1_USER_VALUE : integer := 0;
  constant    C_M_AXI_GMEM1_PROT_VALUE : integer := 0;
  constant    C_M_AXI_GMEM1_CACHE_VALUE : integer := 3;
  constant    C_M_AXI_DATA_WIDTH : integer := 32;
  constant    C_M_AXI_GMEM2_ID_WIDTH : integer := 2;
  constant    C_M_AXI_GMEM2_ADDR_WIDTH : integer := 32;
  constant    C_M_AXI_GMEM2_DATA_WIDTH : integer := 32;
  constant    C_M_AXI_GMEM2_AWUSER_WIDTH : integer := 1;
  constant    C_M_AXI_GMEM2_ARUSER_WIDTH : integer := 1;
  constant    C_M_AXI_GMEM2_WUSER_WIDTH : integer := 1;
  constant    C_M_AXI_GMEM2_RUSER_WIDTH : integer := 1;
  constant    C_M_AXI_GMEM2_BUSER_WIDTH : integer := 1;
  constant    C_M_AXI_GMEM2_USER_VALUE : integer := 0;
  constant    C_M_AXI_GMEM2_PROT_VALUE : integer := 0;
  constant    C_M_AXI_GMEM2_CACHE_VALUE : integer := 3;
 

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

  component dot_prod_krnl
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
  end component;


  component dot_prod_kernel is
    generic (
      C_S_AXI_CONTROL_ADDR_WIDTH : INTEGER := C_S_AXI_CONTROL_ADDR_WIDTH;
      C_S_AXI_CONTROL_DATA_WIDTH : INTEGER := C_S_AXI_CONTROL_DATA_WIDTH;
      C_M_AXI_GMEM1_ADDR_WIDTH : INTEGER := C_M_AXI_GMEM1_ADDR_WIDTH;
      C_M_AXI_GMEM1_ID_WIDTH : INTEGER := C_M_AXI_GMEM1_ID_WIDTH;
      C_M_AXI_GMEM1_AWUSER_WIDTH : INTEGER := C_M_AXI_GMEM1_AWUSER_WIDTH;
      C_M_AXI_GMEM1_DATA_WIDTH : INTEGER := C_M_AXI_GMEM1_DATA_WIDTH;
      C_M_AXI_GMEM1_WUSER_WIDTH : INTEGER := C_M_AXI_GMEM1_WUSER_WIDTH;
      C_M_AXI_GMEM1_ARUSER_WIDTH : INTEGER := C_M_AXI_GMEM1_ARUSER_WIDTH;
      C_M_AXI_GMEM1_RUSER_WIDTH : INTEGER := C_M_AXI_GMEM1_RUSER_WIDTH;
      C_M_AXI_GMEM1_BUSER_WIDTH : INTEGER := C_M_AXI_GMEM1_BUSER_WIDTH;
      C_M_AXI_GMEM2_ADDR_WIDTH : INTEGER := C_M_AXI_GMEM2_ADDR_WIDTH;
      C_M_AXI_GMEM2_ID_WIDTH : INTEGER := C_M_AXI_GMEM2_ID_WIDTH;
      C_M_AXI_GMEM2_AWUSER_WIDTH : INTEGER := C_M_AXI_GMEM2_AWUSER_WIDTH;
      C_M_AXI_GMEM2_DATA_WIDTH : INTEGER := C_M_AXI_GMEM2_DATA_WIDTH;
      C_M_AXI_GMEM2_WUSER_WIDTH : INTEGER := C_M_AXI_GMEM2_WUSER_WIDTH;
      C_M_AXI_GMEM2_ARUSER_WIDTH : INTEGER := C_M_AXI_GMEM2_ARUSER_WIDTH;
      C_M_AXI_GMEM2_RUSER_WIDTH : INTEGER := C_M_AXI_GMEM2_RUSER_WIDTH;
      C_M_AXI_GMEM2_BUSER_WIDTH : INTEGER := C_M_AXI_GMEM2_BUSER_WIDTH;
      C_M_AXI_GMEM1_USER_VALUE : INTEGER := C_M_AXI_GMEM1_USER_VALUE;
      C_M_AXI_GMEM1_PROT_VALUE : INTEGER := C_M_AXI_GMEM1_PROT_VALUE;
      C_M_AXI_GMEM1_CACHE_VALUE : INTEGER := C_M_AXI_GMEM1_CACHE_VALUE;
      C_M_AXI_GMEM2_USER_VALUE : INTEGER := C_M_AXI_GMEM2_USER_VALUE;
      C_M_AXI_GMEM2_PROT_VALUE : INTEGER := C_M_AXI_GMEM2_PROT_VALUE;
      C_M_AXI_GMEM2_CACHE_VALUE : INTEGER := C_M_AXI_GMEM2_CACHE_VALUE
    );
    port (
      s_axi_control_AWVALID : IN STD_LOGIC;
      s_axi_control_AWREADY : OUT STD_LOGIC;
      s_axi_control_AWADDR : IN STD_LOGIC_VECTOR (C_S_AXI_CONTROL_ADDR_WIDTH-1 downto 0);
      s_axi_control_WVALID : IN STD_LOGIC;
      s_axi_control_WREADY : OUT STD_LOGIC;
      s_axi_control_WDATA : IN STD_LOGIC_VECTOR (C_S_AXI_CONTROL_DATA_WIDTH-1 downto 0);
      s_axi_control_WSTRB : IN STD_LOGIC_VECTOR (C_S_AXI_CONTROL_DATA_WIDTH/8-1 downto 0);
      s_axi_control_ARVALID : IN STD_LOGIC;
      s_axi_control_ARREADY : OUT STD_LOGIC;
      s_axi_control_ARADDR : IN STD_LOGIC_VECTOR (C_S_AXI_CONTROL_ADDR_WIDTH-1 downto 0);
      s_axi_control_RVALID : OUT STD_LOGIC;
      s_axi_control_RREADY : IN STD_LOGIC;
      s_axi_control_RDATA : OUT STD_LOGIC_VECTOR (C_S_AXI_CONTROL_DATA_WIDTH-1 downto 0);
      s_axi_control_RRESP : OUT STD_LOGIC_VECTOR (1 downto 0);
      s_axi_control_BVALID : OUT STD_LOGIC;
      s_axi_control_BREADY : IN STD_LOGIC;
      s_axi_control_BRESP : OUT STD_LOGIC_VECTOR (1 downto 0);
      ap_clk : IN STD_LOGIC;
      ap_rst_n : IN STD_LOGIC;
      interrupt : OUT STD_LOGIC;
      m_axi_gmem1_AWVALID : OUT STD_LOGIC;
      m_axi_gmem1_AWREADY : IN STD_LOGIC;
      m_axi_gmem1_AWADDR : OUT STD_LOGIC_VECTOR (C_M_AXI_GMEM1_ADDR_WIDTH-1 downto 0);
      m_axi_gmem1_AWID : OUT STD_LOGIC_VECTOR (C_M_AXI_GMEM1_ID_WIDTH-1 downto 0);
      m_axi_gmem1_AWLEN : OUT STD_LOGIC_VECTOR (7 downto 0);
      m_axi_gmem1_AWSIZE : OUT STD_LOGIC_VECTOR (2 downto 0);
      m_axi_gmem1_AWBURST : OUT STD_LOGIC_VECTOR (1 downto 0);
      m_axi_gmem1_AWLOCK : OUT STD_LOGIC_VECTOR (1 downto 0);
      m_axi_gmem1_AWCACHE : OUT STD_LOGIC_VECTOR (3 downto 0);
      m_axi_gmem1_AWPROT : OUT STD_LOGIC_VECTOR (2 downto 0);
      m_axi_gmem1_AWQOS : OUT STD_LOGIC_VECTOR (3 downto 0);
      m_axi_gmem1_AWREGION : OUT STD_LOGIC_VECTOR (3 downto 0);
      m_axi_gmem1_AWUSER : OUT STD_LOGIC_VECTOR (C_M_AXI_GMEM1_AWUSER_WIDTH-1 downto 0);
      m_axi_gmem1_WVALID : OUT STD_LOGIC;
      m_axi_gmem1_WREADY : IN STD_LOGIC;
      m_axi_gmem1_WDATA : OUT STD_LOGIC_VECTOR (C_M_AXI_GMEM1_DATA_WIDTH-1 downto 0);
      m_axi_gmem1_WSTRB : OUT STD_LOGIC_VECTOR (C_M_AXI_GMEM1_DATA_WIDTH/8-1 downto 0);
      m_axi_gmem1_WLAST : OUT STD_LOGIC;
      m_axi_gmem1_WID : OUT STD_LOGIC_VECTOR (C_M_AXI_GMEM1_ID_WIDTH-1 downto 0);
      m_axi_gmem1_WUSER : OUT STD_LOGIC_VECTOR (C_M_AXI_GMEM1_WUSER_WIDTH-1 downto 0);
      m_axi_gmem1_ARVALID : OUT STD_LOGIC;
      m_axi_gmem1_ARREADY : IN STD_LOGIC;
      m_axi_gmem1_ARADDR : OUT STD_LOGIC_VECTOR (C_M_AXI_GMEM1_ADDR_WIDTH-1 downto 0);
      m_axi_gmem1_ARID : OUT STD_LOGIC_VECTOR (C_M_AXI_GMEM1_ID_WIDTH-1 downto 0);
      m_axi_gmem1_ARLEN : OUT STD_LOGIC_VECTOR (7 downto 0);
      m_axi_gmem1_ARSIZE : OUT STD_LOGIC_VECTOR (2 downto 0);
      m_axi_gmem1_ARBURST : OUT STD_LOGIC_VECTOR (1 downto 0);
      m_axi_gmem1_ARLOCK : OUT STD_LOGIC_VECTOR (1 downto 0);
      m_axi_gmem1_ARCACHE : OUT STD_LOGIC_VECTOR (3 downto 0);
      m_axi_gmem1_ARPROT : OUT STD_LOGIC_VECTOR (2 downto 0);
      m_axi_gmem1_ARQOS : OUT STD_LOGIC_VECTOR (3 downto 0);
      m_axi_gmem1_ARREGION : OUT STD_LOGIC_VECTOR (3 downto 0);
      m_axi_gmem1_ARUSER : OUT STD_LOGIC_VECTOR (C_M_AXI_GMEM1_ARUSER_WIDTH-1 downto 0);
      m_axi_gmem1_RVALID : IN STD_LOGIC;
      m_axi_gmem1_RREADY : OUT STD_LOGIC;
      m_axi_gmem1_RDATA : IN STD_LOGIC_VECTOR (C_M_AXI_GMEM1_DATA_WIDTH-1 downto 0);
      m_axi_gmem1_RLAST : IN STD_LOGIC;
      m_axi_gmem1_RID : IN STD_LOGIC_VECTOR (C_M_AXI_GMEM1_ID_WIDTH-1 downto 0);
      m_axi_gmem1_RUSER : IN STD_LOGIC_VECTOR (C_M_AXI_GMEM1_RUSER_WIDTH-1 downto 0);
      m_axi_gmem1_RRESP : IN STD_LOGIC_VECTOR (1 downto 0);
      m_axi_gmem1_BVALID : IN STD_LOGIC;
      m_axi_gmem1_BREADY : OUT STD_LOGIC;
      m_axi_gmem1_BRESP : IN STD_LOGIC_VECTOR (1 downto 0);
      m_axi_gmem1_BID : IN STD_LOGIC_VECTOR (C_M_AXI_GMEM1_ID_WIDTH-1 downto 0);
      m_axi_gmem1_BUSER : IN STD_LOGIC_VECTOR (C_M_AXI_GMEM1_BUSER_WIDTH-1 downto 0);
      m_axi_gmem2_AWVALID : OUT STD_LOGIC;
      m_axi_gmem2_AWREADY : IN STD_LOGIC;
      m_axi_gmem2_AWADDR : OUT STD_LOGIC_VECTOR (C_M_AXI_GMEM2_ADDR_WIDTH-1 downto 0);
      m_axi_gmem2_AWID : OUT STD_LOGIC_VECTOR (C_M_AXI_GMEM2_ID_WIDTH-1 downto 0);
      m_axi_gmem2_AWLEN : OUT STD_LOGIC_VECTOR (7 downto 0);
      m_axi_gmem2_AWSIZE : OUT STD_LOGIC_VECTOR (2 downto 0);
      m_axi_gmem2_AWBURST : OUT STD_LOGIC_VECTOR (1 downto 0);
      m_axi_gmem2_AWLOCK : OUT STD_LOGIC_VECTOR (1 downto 0);
      m_axi_gmem2_AWCACHE : OUT STD_LOGIC_VECTOR (3 downto 0);
      m_axi_gmem2_AWPROT : OUT STD_LOGIC_VECTOR (2 downto 0);
      m_axi_gmem2_AWQOS : OUT STD_LOGIC_VECTOR (3 downto 0);
      m_axi_gmem2_AWREGION : OUT STD_LOGIC_VECTOR (3 downto 0);
      m_axi_gmem2_AWUSER : OUT STD_LOGIC_VECTOR (C_M_AXI_GMEM2_AWUSER_WIDTH-1 downto 0);
      m_axi_gmem2_WVALID : OUT STD_LOGIC;
      m_axi_gmem2_WREADY : IN STD_LOGIC;
      m_axi_gmem2_WDATA : OUT STD_LOGIC_VECTOR (C_M_AXI_GMEM2_DATA_WIDTH-1 downto 0);
      m_axi_gmem2_WSTRB : OUT STD_LOGIC_VECTOR (C_M_AXI_GMEM2_DATA_WIDTH/8-1 downto 0);
      m_axi_gmem2_WLAST : OUT STD_LOGIC;
      m_axi_gmem2_WID : OUT STD_LOGIC_VECTOR (C_M_AXI_GMEM2_ID_WIDTH-1 downto 0);
      m_axi_gmem2_WUSER : OUT STD_LOGIC_VECTOR (C_M_AXI_GMEM2_WUSER_WIDTH-1 downto 0);
      m_axi_gmem2_ARVALID : OUT STD_LOGIC;
      m_axi_gmem2_ARREADY : IN STD_LOGIC;
      m_axi_gmem2_ARADDR : OUT STD_LOGIC_VECTOR (C_M_AXI_GMEM2_ADDR_WIDTH-1 downto 0);
      m_axi_gmem2_ARID : OUT STD_LOGIC_VECTOR (C_M_AXI_GMEM2_ID_WIDTH-1 downto 0);
      m_axi_gmem2_ARLEN : OUT STD_LOGIC_VECTOR (7 downto 0);
      m_axi_gmem2_ARSIZE : OUT STD_LOGIC_VECTOR (2 downto 0);
      m_axi_gmem2_ARBURST : OUT STD_LOGIC_VECTOR (1 downto 0);
      m_axi_gmem2_ARLOCK : OUT STD_LOGIC_VECTOR (1 downto 0);
      m_axi_gmem2_ARCACHE : OUT STD_LOGIC_VECTOR (3 downto 0);
      m_axi_gmem2_ARPROT : OUT STD_LOGIC_VECTOR (2 downto 0);
      m_axi_gmem2_ARQOS : OUT STD_LOGIC_VECTOR (3 downto 0);
      m_axi_gmem2_ARREGION : OUT STD_LOGIC_VECTOR (3 downto 0);
      m_axi_gmem2_ARUSER : OUT STD_LOGIC_VECTOR (C_M_AXI_GMEM2_ARUSER_WIDTH-1 downto 0);
      m_axi_gmem2_RVALID : IN STD_LOGIC;
      m_axi_gmem2_RREADY : OUT STD_LOGIC;
      m_axi_gmem2_RDATA : IN STD_LOGIC_VECTOR (C_M_AXI_GMEM2_DATA_WIDTH-1 downto 0);
      m_axi_gmem2_RLAST : IN STD_LOGIC;
      m_axi_gmem2_RID : IN STD_LOGIC_VECTOR (C_M_AXI_GMEM2_ID_WIDTH-1 downto 0);
      m_axi_gmem2_RUSER : IN STD_LOGIC_VECTOR (C_M_AXI_GMEM2_RUSER_WIDTH-1 downto 0);
      m_axi_gmem2_RRESP : IN STD_LOGIC_VECTOR (1 downto 0);
      m_axi_gmem2_BVALID : IN STD_LOGIC;
      m_axi_gmem2_BREADY : OUT STD_LOGIC;
      m_axi_gmem2_BRESP : IN STD_LOGIC_VECTOR (1 downto 0);
      m_axi_gmem2_BID : IN STD_LOGIC_VECTOR (C_M_AXI_GMEM2_ID_WIDTH-1 downto 0);
      m_axi_gmem2_BUSER : IN STD_LOGIC_VECTOR (C_M_AXI_GMEM2_BUSER_WIDTH-1 downto 0)  
    );
    end component;
    
end package;


