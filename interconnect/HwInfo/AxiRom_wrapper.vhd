library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.stdlib.all;
use grlib.amba.all;

library interconnect;
use interconnect.libaxirom.all;


entity AxiRom_wrapper is
    generic (
        REG_DATA_WIDTH     : integer := ROM_WORD_SIZE;
        REGNUM             : integer := ROM_WORD_NUM;
        INIT               : std_logic_vector(ROM_WORD_SIZE*ROM_WORD_NUM-1 downto 0) := (others=>'0')
    );
    port (
        clk:              in std_logic;
        rst_n:            in std_logic;
        axi_in:           in axi_mosi_type;
        axi_out:          out axi_somi_type;
        acc_sw_reset_n:        out std_logic
    );  
end entity;



architecture RTL of AxiRom_wrapper is

signal rv_slv_in:    axi_rv_slv_in;
signal rv_slv_out:   axi_rv_slv_out;

begin
-- slv AXI-lite out
  axi_out.aw.ready   <= rv_slv_out.s_axi_control_awready; 
  axi_out.w.ready    <= rv_slv_out.s_axi_control_wready; 
  axi_out.ar.ready   <= rv_slv_out.s_axi_control_arready;
  axi_out.r.valid    <= rv_slv_out.s_axi_control_rvalid;
  axi_out.r.data     <= rv_slv_out.s_axi_control_rdata;     
  axi_out.r.resp     <= rv_slv_out.s_axi_control_rresp;     
  axi_out.r.last     <= '0';
  axi_out.r.id       <= "0000";
  axi_out.b.valid    <= rv_slv_out.s_axi_control_bvalid;    
  axi_out.b.resp     <= rv_slv_out.s_axi_control_bresp;
  axi_out.b.id       <= "0000";
-- slv AXI-lite in
  rv_slv_in.s_axi_control_awvalid <= axi_in.aw.valid;
  rv_slv_in.s_axi_control_awaddr  <= axi_in.aw.addr(C_S_AXI_ADDR_WIDTH-1 downto 0);
  rv_slv_in.s_axi_control_wvalid  <= axi_in.w.valid;
  rv_slv_in.s_axi_control_wdata   <= axi_in.w.data;
  --This is a workaround to adapt the 32 bit wide control axi to the 128 bit wide input channel
 rv_slv_in.s_axi_control_wstrb(3 downto 0)   <= axi_in.w.strb(3 downto 0) or axi_in.w.strb(11 downto 8);  

 rv_slv_in.s_axi_control_wstrb(7 downto 4)   <= axi_in.w.strb(7 downto 4) or axi_in.w.strb(15 downto 12);  

 rv_slv_in.s_axi_control_wstrb(15 downto 8) <= (others => '0');

  --rv_slv_in.s_axi_control_wstrb <= axi_in.w.strb;

  rv_slv_in.s_axi_control_arvalid <= axi_in.ar.valid;  
  rv_slv_in.s_axi_control_araddr  <= axi_in.ar.addr(C_S_AXI_ADDR_WIDTH-1 downto 0); 
  rv_slv_in.s_axi_control_rready  <= axi_in.r.ready;
  rv_slv_in.s_axi_control_bready  <= axi_in.b.ready;


ROM_inst : AxiRom
  generic map(
    C_S_AXI_DATA_WIDTH  => 128,
    C_S_AXI_ADDR_WIDTH  => C_S_AXI_ADDR_WIDTH,
    REG_DATA_WIDTH      => ROM_WORD_SIZE,
    REGNUM              => ROM_WORD_NUM,
    INIT                => INIT
  )
  port map (
    S_AXI_ACLK_i    => clk,
    S_AXI_ARESETN_i  => rst_n,
    S_AXI_ACLK_EN_i   => '1', -- TODO currently unused
    -- AXI4-Lite slave interface
    S_AXI_AWVALID_i => rv_slv_in.s_axi_control_awvalid,
    S_AXI_AWREADY_o => rv_slv_out.s_axi_control_awready,
    S_AXI_AWADDR_i  => rv_slv_in.s_axi_control_awaddr, 
    S_AXI_WVALID_i  => rv_slv_in.s_axi_control_wvalid,
    S_AXI_WREADY_o  => rv_slv_out.s_axi_control_wready, 
    S_AXI_WDATA_i   => rv_slv_in.s_axi_control_wdata, 
    S_AXI_WSTRB_i   => rv_slv_in.s_axi_control_wstrb, 
    S_AXI_ARVALID_i => rv_slv_in.s_axi_control_arvalid, 
    S_AXI_ARREADY_o => rv_slv_out.s_axi_control_arready,
    S_AXI_ARADDR_i  => rv_slv_in.s_axi_control_araddr,
    S_AXI_RVALID_o  => rv_slv_out.s_axi_control_rvalid,
    S_AXI_RREADY_i  => rv_slv_in.s_axi_control_rready,
    S_AXI_RDATA_o   => rv_slv_out.s_axi_control_rdata, 
    S_AXI_RRESP_o   => rv_slv_out.s_axi_control_rresp,
    S_AXI_BVALID_o  => rv_slv_out.s_axi_control_bvalid,
    S_AXI_BREADY_i  => rv_slv_in.s_axi_control_bready,
    S_AXI_BRESP_o   => rv_slv_out.s_axi_control_bresp,
    acc_sw_reset_n    => acc_sw_reset_n    
  );


end;
