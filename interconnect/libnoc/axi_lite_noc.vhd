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

entity axi_lite_noc is
  generic(
    NoInitiators : integer;
    NoTargets    : integer
  );
  port (
    clk: in std_logic;
    rst: in std_logic;
    axi_from_target   : in  axi_somi_vector_type;
    axi_to_target     : out axi_mosi_vector_type;
    axi_from_initiator: in  axi_mosi_vector_type;
    axi_to_initiator  : out axi_somi_vector_type
  ); 
end entity;

architecture RTL of axi_lite_noc is
  --SIGNAL INSTANTIATION
  signal slv_ports_req  : slv_req_t_vector  (NoInitiators-1 downto 0);
  signal slv_ports_resp : slv_resp_t_vector (NoInitiators -1 downto 0);
  signal mst_ports_req  : mst_req_t_vector  (NoTargets -1 downto 0);
  signal mst_ports_resp : mst_resp_t_vector (NoTargets-1 downto 0);
  
  constant IdWidthInitiators : integer := AxiIdWidthSlaves; --AxiIdWidthSlvPorts;


begin
  fromInitiator: for i in 0 to NoInitiators-1 generate 
    slv_ports_req(i).aw.id    <= axi_from_initiator(i).aw.id(IdWidthInitiators-1 downto 0); -- NOTE WARNING
    slv_ports_req(i).aw.addr  <= axi_from_initiator(i).aw.addr;
    slv_ports_req(i).aw.len   <= X"0" & axi_from_initiator(i).aw.len;
    slv_ports_req(i).aw.size  <= axi_from_initiator(i).aw.size;
    slv_ports_req(i).aw.burst <= axi_from_initiator(i).aw.burst;
    slv_ports_req(i).aw.lock  <= axi_from_initiator(i).aw.lock(0); 
    slv_ports_req(i).aw.cache <= axi_from_initiator(i).aw.cache;
    slv_ports_req(i).aw.prot  <= axi_from_initiator(i).aw.prot;
    slv_ports_req(i).aw.qos   <= (others => '0'); --not used on grlib but commented out on amba.vhd
    slv_ports_req(i).aw.region<= (others => '0'); --not used on grlib AXI Transaction region type
    slv_ports_req(i).aw.atop  <= (others => '0'); --not used on grlib ATOMIC OPERATIONS
    slv_ports_req(i).aw.user  <= (others => '0'); --not used on grlib
    slv_ports_req(i).aw_valid <= axi_from_initiator(i).aw.valid;

    slv_ports_req(i).w.data   <= axi_from_initiator(i).w.data;
    slv_ports_req(i).w.strb   <= axi_from_initiator(i).w.strb;
    slv_ports_req(i).w.last   <= axi_from_initiator(i).w.last;
    slv_ports_req(i).w.user   <= (others => '0'); --not used on grlib
    slv_ports_req(i).w_valid  <= axi_from_initiator(i).w.valid;
    
    slv_ports_req(i).b_ready  <= axi_from_initiator(i).b.ready;

    slv_ports_req(i).ar.id    <= axi_from_initiator(i).ar.id(IdWidthInitiators-1 downto 0); -- NOTE WARNING
    slv_ports_req(i).ar.addr  <= axi_from_initiator(i).ar.addr;
    slv_ports_req(i).ar.len   <= X"0" & axi_from_initiator(i).ar.len;
    slv_ports_req(i).ar.size  <= axi_from_initiator(i).ar.size;
    slv_ports_req(i).ar.burst <= axi_from_initiator(i).ar.burst;
    slv_ports_req(i).ar.lock  <= axi_from_initiator(i).ar.lock(0); 
    slv_ports_req(i).ar.cache <= axi_from_initiator(i).ar.cache;
    slv_ports_req(i).ar.prot  <= axi_from_initiator(i).ar.prot;
    slv_ports_req(i).ar.qos   <= (others => '0'); --not used on grlib but commented out on amba.vhd
    slv_ports_req(i).ar.region<= (others => '0'); --not used on grlib
    slv_ports_req(i).ar.user  <= (others => '0'); --not used on glrib
    slv_ports_req(i).ar_valid <= axi_from_initiator(i).ar.valid;
    
    slv_ports_req(i).r_ready  <= axi_from_initiator(i).r.ready; 
  end generate fromInitiator;
  
  toTarget: for i in 0 to NoTargets-1 generate 
    axi_to_target(i).aw.id(IdWidthInitiators-1 downto 0)     <=  mst_ports_req(i).aw.id(AxiIdWidthMasters-1 downto IdWidthInitiators); --NOTE WARNING
    axi_to_target(i).aw.addr   <=  mst_ports_req(i).aw.addr;
    axi_to_target(i).aw.len    <=  mst_ports_req(i).aw.len(3 downto 0);
    axi_to_target(i).aw.size   <=  mst_ports_req(i).aw.size;
    axi_to_target(i).aw.burst  <=  mst_ports_req(i).aw.burst;
    axi_to_target(i).aw.lock   <=  (0 => mst_ports_req(i).aw.lock, others => '0');
    axi_to_target(i).aw.cache  <=  mst_ports_req(i).aw.cache;
    axi_to_target(i).aw.prot   <=  mst_ports_req(i).aw.prot;
    axi_to_target(i).aw.valid  <=  mst_ports_req(i).aw_valid;

    axi_to_target(i).w.data    <=  mst_ports_req(i).w.data;
    axi_to_target(i).w.strb    <=  mst_ports_req(i).w.strb;
    axi_to_target(i).w.last    <=  mst_ports_req(i).w.last;
    axi_to_target(i).w.valid   <=  mst_ports_req(i).w_valid;
    
    axi_to_target(i).b.ready   <=  mst_ports_req(i).b_ready;

    axi_to_target(i).ar.id(IdWidthInitiators-1 downto 0)     <= mst_ports_req(i).ar.id(AxiIdWidthMasters-1 downto IdWidthInitiators);
    axi_to_target(i).ar.addr   <= mst_ports_req(i).ar.addr;
    axi_to_target(i).ar.len    <= mst_ports_req(i).ar.len(3 downto 0);
    axi_to_target(i).ar.size   <= mst_ports_req(i).ar.size;
    axi_to_target(i).ar.burst  <= mst_ports_req(i).ar.burst;
    axi_to_target(i).ar.lock   <= (0=>mst_ports_req(i).ar.lock, others => '0'); 
    axi_to_target(i).ar.cache  <= mst_ports_req(i).ar.cache;
    axi_to_target(i).ar.prot   <= mst_ports_req(i).ar.prot;
    axi_to_target(i).ar.valid  <= mst_ports_req(i).ar_valid;
                                 
    axi_to_target(i).r.ready   <= mst_ports_req(i).r_ready;
  end generate toTarget;

  toInitiator: for i in 0 to NoInitiators-1 generate
    axi_to_initiator(i).aw.ready  <= slv_ports_resp(i).aw_ready;
    axi_to_initiator(i).w.ready   <= slv_ports_resp(i).w_ready;
   
    axi_to_initiator(i).b.id (IdWidthInitiators-1 downto 0) <= slv_ports_resp(i).b.id;
    axi_to_initiator(i).b.id (AXI_ID_WIDTH-1 downto IdWidthInitiators)<= (others => '0'); 
    axi_to_initiator(i).b.resp    <= slv_ports_resp(i).b.resp;
    axi_to_initiator(i).b.valid   <= slv_ports_resp(i).b_valid;
    
    axi_to_initiator(i).ar.ready  <= slv_ports_resp(i).ar_ready;

    axi_to_initiator(i).r.id(IdWidthInitiators-1 downto 0) <= slv_ports_resp(i).r.id;
    axi_to_initiator(i).r.id (AXI_ID_WIDTH-1 downto IdWidthInitiators)  <= (others => '0');
    axi_to_initiator(i).r.data    <= slv_ports_resp(i).r.data;
    axi_to_initiator(i).r.resp    <= slv_ports_resp(i).r.resp;
    axi_to_initiator(i).r.last    <= slv_ports_resp(i).r.last;
    axi_to_initiator(i).r.valid   <= slv_ports_resp(i).r_valid;  
  end generate toInitiator;

  fromTarget: for i in 0 to NoTargets-1 generate
    mst_ports_resp(i).aw_ready        <= axi_from_target(i).aw.ready;
    mst_ports_resp(i).ar_ready        <= axi_from_target(i).ar.ready;
    mst_ports_resp(i).w_ready         <= axi_from_target(i).w.ready;

    mst_ports_resp(i).b_valid         <= axi_from_target(i).b.valid;
    mst_ports_resp(i).b.id(AxiIdWidthMasters-1 downto IdWidthInitiators)            <= axi_from_target(i).b.id(IdWidthInitiators-1 downto 0);
    mst_ports_resp(i).b.id(IdWidthInitiators-1 downto 0)  <= (others => '0');
    mst_ports_resp(i).b.resp          <= axi_from_target(i).b.resp;
    mst_ports_resp(i).b.user          <= (others => '0');
    
    mst_ports_resp(i).r_valid         <= axi_from_target(i).r.valid;
    mst_ports_resp(i).r.id(AxiIdWidthMasters-1 downto IdWidthInitiators)            <= axi_from_target(i).r.id(IdWidthInitiators-1 downto 0);
    mst_ports_resp(i).r.id(IdWidthInitiators-1 downto 0)  <= (others => '0');
    mst_ports_resp(i).r.data          <= axi_from_target(i).r.data;
    mst_ports_resp(i).r.resp          <= axi_from_target(i).r.resp;
    mst_ports_resp(i).r.last          <= axi_from_target(i).r.last;
    mst_ports_resp(i).r.user          <= (others => '0'); 
  end generate fromTarget;


  axi_noc : axi_xbar_lite_wrapper
    generic map (
      NoMasters         => NoInitiators,         
      NoSlaves          => NoTargets,        
      AxiAddrWidth      => AxiAddrWidth,      
      AxiDataWidth      => AxiDataWidth,      
      AxiStrbWidth      => AxiStrbWidth,      
      MaxMstTrans       => MaxMstTrans,       
      MaxSlvTrans       => MaxSlvTrans          
    )
    port map(
    clk_i   => clk,
    rst_ni  => rst,
    test_i  => '0', --test mode disabled
    slv_ports_req_i  => slv_ports_req, 
    slv_ports_resp_o => slv_ports_resp,
    mst_ports_req_o  => mst_ports_req,
    mst_ports_resp_i => mst_ports_resp
  );

end;
