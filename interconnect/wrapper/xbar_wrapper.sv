//MIT License
//
//Copyright (c) 2021 UPV 
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

`include "axi/assign.svh"
`include "axi/typedef.svh"

import axi_xbar_typedef_pkg::*;

module axi_xbar_wrapper #(
  parameter type rule_t                     = axi_pkg::xbar_rule_32_t,
  parameter int unsigned NoMasters          = 1,
  parameter int unsigned NoSlaves           = 1, 
  parameter int unsigned AxiIdWidthMasters  = 4,
  parameter int unsigned AxiIdUsed          = 1, // Has to be <= AxiIdWidthMasters
  parameter int unsigned AxiIdWidthSlaves   = AxiIdWidthMasters + $clog2(NoMasters),
  parameter int unsigned AxiAddrWidth       = 32,    // Axi Address Width
  parameter int unsigned AxiDataWidth       = 128,    // Axi Data Width
  parameter int unsigned AxiStrbWidth       = 16,//AxiDataWidth / 8;
  parameter int unsigned AxiUserWidth       = 5,
  parameter int unsigned MaxMstTrans        = 32, // TODO put correct number
  parameter int unsigned MaxSlvTrans        = 32, // TODO put correct number
  parameter logic        FallThrough        = 0,  // TODO
  parameter logic [9:0]  LatencyMode        = 0, //No latency mode
  parameter int unsigned AxiIdWidthSlvPorts = 4, //same as GRLIB AMBA
  parameter int unsigned AxiIdUsedSlvPorts  = 1,	
  parameter int unsigned NoAddrRules        = 1
) (
  input  logic                       clk_i,
  input  logic                       rst_ni,
  input  logic                       test_i,
  input  slv_req_t         slv_ports_req_i [NoMasters-1:0],
  output slv_resp_t        slv_ports_resp_o[NoMasters-1:0],
  output mst_req_t         mst_ports_req_o [NoSlaves-1:0],
  input  mst_resp_t        mst_ports_resp_i[NoSlaves-1:0]
);


  localparam axi_pkg::xbar_cfg_t xbar_cfg = '{
    NoSlvPorts:         NoMasters,
    NoMstPorts:         NoSlaves,
    MaxMstTrans:        MaxMstTrans,
    MaxSlvTrans:        MaxSlvTrans,
    FallThrough:        1'b0,
    LatencyMode:        axi_pkg::CUT_ALL_AX,
    AxiIdWidthSlvPorts: AxiIdWidthSlaves,
    AxiIdUsedSlvPorts:  AxiIdUsed,
    AxiAddrWidth:       AxiAddrWidth,
    AxiDataWidth:       AxiDataWidth,
    NoAddrRules:        NoAddrRules 
  };

  localparam rule_t [xbar_cfg.NoAddrRules-1:0] AddrMap = '{
    '{idx: 32'd0, start_addr: 32'h0000_0000, end_addr: 32'h3fff_ffff}
  };

  localparam int unsigned AxiIdWidthMstPorts = xbar_cfg.AxiIdWidthSlvPorts + $clog2(xbar_cfg.NoSlvPorts);

  slv_req_t  [xbar_cfg.NoSlvPorts-1:0]       slv_ports_req_i_p;
  slv_resp_t [xbar_cfg.NoSlvPorts-1:0]       slv_ports_resp_o_p; 
  mst_req_t  [xbar_cfg.NoMstPorts-1:0]       mst_ports_req_o_p;
  mst_resp_t [xbar_cfg.NoMstPorts-1:0]       mst_ports_resp_i_p; 


  genvar i;
  generate
   for (i=0; i< xbar_cfg.NoSlvPorts; i++) begin
    assign slv_ports_req_i_p[i]  =  slv_ports_req_i [i];
    assign slv_ports_resp_o[i]   = slv_ports_resp_o_p[i];
   end
  endgenerate

  generate
   for (i=0; i< xbar_cfg.NoMstPorts; i++) begin
    assign mst_ports_resp_i_p[i] =  mst_ports_resp_i[i];
    assign mst_ports_req_o [i]   = mst_ports_req_o_p[i];
   end
  endgenerate

localparam int unsigned MaxWTrans     = 32'd8;
  // If enabled, this multiplexer is purely combinatorial
  // add spill register on write master ports, adds a cycle latency on write channels
  localparam bit          SpillAw       = 1'b1;
  localparam bit          SpillW        = 1'b0;
  localparam bit          SpillB        = 1'b0;
  // add spill register on read master ports, adds a cycle latency on read channels
  localparam bit          SpillAr       = 1'b1;
  localparam bit          SpillR        = 1'b0;

/*
   axi_mux #(
    .SlvAxiIDWidth ( AxiIdWidthSlvPorts),
    .slv_aw_chan_t ( slv_aw_chan_t    ), // AW Channel Type, slave ports
    .mst_aw_chan_t ( mst_aw_chan_t    ), // AW Channel Type, master port
    .w_chan_t      ( w_chan_t         ), //  W Channel Type, all ports
    .slv_b_chan_t  ( slv_b_chan_t     ), //  B Channel Type, slave ports
    .mst_b_chan_t  ( mst_b_chan_t     ), //  B Channel Type, master port
    .slv_ar_chan_t ( slv_ar_chan_t    ), // AR Channel Type, slave ports
    .mst_ar_chan_t ( mst_ar_chan_t    ), // AR Channel Type, master port
    .slv_r_chan_t  ( slv_r_chan_t     ), //  R Channel Type, slave ports
    .mst_r_chan_t  ( mst_r_chan_t     ), //  R Channel Type, master port
    .slv_req_t     ( slv_req_t        ),
    .slv_resp_t    ( slv_resp_t       ),
    .mst_req_t     ( mst_req_t        ),
    .mst_resp_t    ( mst_resp_t       ),
    .NoSlvPorts    ( xbar_cfg.NoSlvPorts), // Number of slave ports
    .MaxWTrans     ( 32'd1      ),
    .FallThrough   ( 1'b0     ),
    .SpillAw       ( SpillAw         ),
    .SpillW        ( SpillR          ),
    .SpillB        ( SpillB          ),
    .SpillAr       ( SpillAr         ),
    .SpillR        ( SpillR          )
  ) i_axi_mux (
    .clk_i       ( clk_i     ), // Clock
    .rst_ni      ( rst_ni    ), // Asynchronous reset active low
    .test_i      ( 32'd0         ), // Test Mode enable
    .slv_reqs_i  ( slv_ports_req_i_p ),
    .slv_resps_o ( slv_ports_resp_o_p),
    .mst_req_o   ( mst_ports_req_o_p ),
    .mst_resp_i  ( mst_ports_resp_i_p)
  );
*/
  axi_xbar #(
    .Cfg  (xbar_cfg),
    .slv_aw_chan_t  ( slv_aw_chan_t ),
    .mst_aw_chan_t  ( mst_aw_chan_t ),
    .w_chan_t       ( w_chan_t      ),
    .slv_b_chan_t   ( slv_b_chan_t  ),
    .mst_b_chan_t   ( mst_b_chan_t  ),
    .slv_ar_chan_t  ( slv_ar_chan_t ),
    .mst_ar_chan_t  ( mst_ar_chan_t ),
    .slv_r_chan_t   ( slv_r_chan_t  ),
    .mst_r_chan_t   ( mst_r_chan_t  ),
    .slv_req_t      ( slv_req_t     ),
    .slv_resp_t     ( slv_resp_t    ),
    .mst_req_t      ( mst_req_t     ),
    .mst_resp_t     ( mst_resp_t    ),
    .rule_t         ( rule_t        )
  ) i_xbar (
    .clk_i,
    .rst_ni,
    .test_i,
    .slv_ports_req_i       (slv_ports_req_i_p),
    .slv_ports_resp_o      (slv_ports_resp_o_p),
    .mst_ports_req_o       (mst_ports_req_o_p),
    .mst_ports_resp_i      (mst_ports_resp_i_p),
    .addr_map_i            (AddrMap),
    .en_default_mst_port_i ('1),
    .default_mst_port_i    ('1)
  );

endmodule
