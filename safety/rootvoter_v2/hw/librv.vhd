library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.stdlib.all;
use grlib.amba.all;

package librv is
   
  constant C_S_AXI_ADDR_WIDTH  : integer := 12;
  constant C_S_AXI_DATA_WIDTH  : integer := 128;
  
  
  type axi_rv_slv_out is record --AXI-lite slave interface
    s_axi_control_awready:    std_logic;
    s_axi_control_wready:     std_logic;
    s_axi_control_arready:    std_logic;
    s_axi_control_rvalid:     std_logic;
    s_axi_control_rdata:     std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    s_axi_control_rresp:     std_logic_vector(1 downto 0);
    s_axi_control_bvalid:    std_logic;
    s_axi_control_bresp:     std_logic_vector(1 downto 0);
  end record;
  
  type axi_rv_slv_in is record
    s_axi_control_awvalid:   std_logic;
    s_axi_control_awaddr:    std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_control_wvalid:    std_logic;
    s_axi_control_wdata:     std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    s_axi_control_wstrb:     std_logic_vector(C_S_AXI_DATA_WIDTH/8-1 downto 0);
    s_axi_control_arvalid:   std_logic;
    s_axi_control_araddr:    std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_control_rready:    std_logic;
    s_axi_control_bready:    std_logic;
  end record; 
  
  component rv_wrapper
    generic (
      RVC_ID             : integer := 1;    
      MAX_DATASETS       : integer := 9;
      COUNT_MATCHES      : integer := 1;
      LIST_MATCHES       : integer := 0;
      LIST_FAILURES      : integer := 1              
    );
    port (
      clk:              in std_logic;
      rst_n:            in std_logic;
      axi_in:           in axi_mosi_type;
      axi_out:          out axi_somi_type;
      interrupt:        out std_logic
    );  
  end component;

  component rootvoter is
    generic (
      RVC_ID             :   integer := 1;
      C_S_AXI_DATA_WIDTH : integer := 32; 
      C_S_AXI_ADDR_WIDTH : integer := 6;
      REG_DATA_WIDTH     : integer := 64;
      MAX_DATASETS       : integer := 9;
      COUNT_MATCHES      : integer := 1;
      LIST_MATCHES       : integer := 0;
      LIST_FAILURES      : integer := 1  
    );
    port (
      S_AXI_ACLK_i                      : in std_logic;
      S_AXI_ARESETN_i                   : in std_logic;
      S_AXI_ACLK_EN_i: in std_logic;
    -- AXI4-Lite slave interface
      S_AXI_AWVALID_i: in std_logic;
      S_AXI_AWREADY_o: out std_logic;
      S_AXI_AWADDR_i: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_WVALID_i: in std_logic;
      S_AXI_WREADY_o: out std_logic;
      S_AXI_WDATA_i: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_WSTRB_i: in std_logic_vector(C_S_AXI_DATA_WIDTH/8-1 downto 0);
      S_AXI_ARVALID_i: in std_logic;
      S_AXI_ARREADY_o: out  std_logic;
      S_AXI_ARADDR_i: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_RVALID_o: out std_logic;
      S_AXI_RREADY_i: in std_logic;
      S_AXI_RDATA_o: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_RRESP_o: out std_logic_vector(1 downto 0);
      S_AXI_BVALID_o: out std_logic;
      S_AXI_BREADY_i: in std_logic;
      S_AXI_BRESP_o: out std_logic_vector(1 downto 0);
      INTERRUPT: out std_logic
    );
    end component;
    
end package;


