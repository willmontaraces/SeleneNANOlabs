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

module width_converter_wrapper #(
    parameter int unsigned AxiMaxReads         = 1, // Number of outstanding reads
    parameter int unsigned AxiSlvPortDataWidth = 8, // Data width of the slv port
    parameter int unsigned AxiMstPortDataWidth = 8,     // Data width of the mst port
    parameter int unsigned AxiAddrWidth = 32, 
    parameter int unsigned AxiIdWidth = 4
  ) (
    input  logic          clk_i,
    input  logic          rst_ni,
    // Slave interface
    input  slv_req_wide_t  slv_req_i,
    output slv_resp_wide_t slv_resp_o,
    // Master interface
    output slv_req_t  mst_req_o,
    input  slv_resp_t mst_resp_i
  );

  // channels typedef

 /* `AXI_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t, user_t)
  `AXI_TYPEDEF_R_CHAN_T(slv_r_chan_t, data_t, id_slv_t, user_t)
  `AXI_TYPEDEF_R_CHAN_T(mst_r_chan_t, data_t, id_mst_t, user_t)
  `AXI_TYPEDEF_RESP_T(slv_resp_t, slv_b_chan_t, slv_r_chan_t)
  `AXI_TYPEDEF_RESP_T(mst_resp_t, mst_b_chan_t, mst_r_chan_t)*/

  typedef logic [AxiSlvPortDataWidth-1:0]      data_variable_t;
  typedef logic [AxiSlvPortDataWidth/8-1:0]    strb_variable_t;

  `AXI_TYPEDEF_W_CHAN_T(w_chan_slv_variable_t, data_variable_t, strb_variable_t, user_t)
  `AXI_TYPEDEF_R_CHAN_T(r_chan_slv_variable_t, data_variable_t, id_slv_t, user_t)
  `AXI_TYPEDEF_REQ_T(slv_req_variable_t, aw_chan_slv_t, w_chan_slv_variable_t, ar_chan_slv_t)
  `AXI_TYPEDEF_RESP_T(slv_resp_variable_t, b_chan_slv_t, r_chan_slv_variable_t)

  slv_req_variable_t in_width_converter_req;
  slv_resp_variable_t out_width_converter_resp;

  assign in_width_converter_req.aw.id     =  slv_req_i.aw.id    ;  
  assign in_width_converter_req.aw.addr   =  slv_req_i.aw.addr  ;
  assign in_width_converter_req.aw.len    =  slv_req_i.aw.len   ;
  assign in_width_converter_req.aw.size   =  slv_req_i.aw.size  ;
  assign in_width_converter_req.aw.burst  =  slv_req_i.aw.burst ;
  assign in_width_converter_req.aw.lock   =  slv_req_i.aw.lock  ;
  assign in_width_converter_req.aw.cache  =  slv_req_i.aw.cache ;
  assign in_width_converter_req.aw.prot   =  slv_req_i.aw.prot  ;
  assign in_width_converter_req.aw.qos    =  slv_req_i.aw.qos   ;
  assign in_width_converter_req.aw.region =  slv_req_i.aw.region;
  assign in_width_converter_req.aw.atop   =  slv_req_i.aw.atop  ;
  assign in_width_converter_req.aw.user   =  slv_req_i.aw.user  ;
  assign in_width_converter_req.aw_valid  =  slv_req_i.aw_valid ;

  assign in_width_converter_req.w.data    =  slv_req_i.w.data[AxiSlvPortDataWidth-1:0];
  assign in_width_converter_req.w.strb    =  slv_req_i.w.strb[AxiSlvPortDataWidth/8-1:0];
  assign in_width_converter_req.w.last    =  slv_req_i.w.last   ;
  assign in_width_converter_req.w.user    =  slv_req_i.w.user   ;
  assign in_width_converter_req.w_valid   =  slv_req_i.w_valid  ;
    
  assign in_width_converter_req.b_ready   =  slv_req_i.b_ready  ;

  assign in_width_converter_req.ar.id     =  slv_req_i.ar.id    ;
  assign in_width_converter_req.ar.addr   =  slv_req_i.ar.addr  ;
  assign in_width_converter_req.ar.len    =  slv_req_i.ar.len   ;
  assign in_width_converter_req.ar.size   =  slv_req_i.ar.size  ;
  assign in_width_converter_req.ar.burst  =  slv_req_i.ar.burst ;
  assign in_width_converter_req.ar.lock   =  slv_req_i.ar.lock  ;
  assign in_width_converter_req.ar.cache  =  slv_req_i.ar.cache ;
  assign in_width_converter_req.ar.prot   =  slv_req_i.ar.prot  ;
  assign in_width_converter_req.ar.qos    =  slv_req_i.ar.qos   ;
  assign in_width_converter_req.ar.region =  slv_req_i.ar.region;
  assign in_width_converter_req.ar.user   =  slv_req_i.ar.user  ;
  assign in_width_converter_req.ar_valid  =  slv_req_i.ar_valid ;
    
  assign in_width_converter_req.r_ready   =  slv_req_i.r_ready  ;

  assign slv_resp_o.aw_ready = out_width_converter_resp.aw_ready;
  assign slv_resp_o.ar_ready = out_width_converter_resp.ar_ready;
  assign slv_resp_o.w_ready  = out_width_converter_resp.w_ready ;
  assign slv_resp_o.b_valid  = out_width_converter_resp.b_valid ;
  assign slv_resp_o.b.id     = out_width_converter_resp.b.id    ;
  assign slv_resp_o.b.resp   = out_width_converter_resp.b.resp  ;
  assign slv_resp_o.b.user   = out_width_converter_resp.b.user  ;
  assign slv_resp_o.r_valid  = out_width_converter_resp.r_valid ;
  assign slv_resp_o.r.id     = out_width_converter_resp.r.id    ;
  assign slv_resp_o.r.data[AxiSlvPortDataWidth-1:0]   = out_width_converter_resp.r.data;
  if(AxiSlvPortDataWidth<512) begin
    assign slv_resp_o.r.data[512-1:AxiSlvPortDataWidth]   = {(512-AxiSlvPortDataWidth){1'b0}};
  end
  assign slv_resp_o.r.resp   = out_width_converter_resp.r.resp  ;
  assign slv_resp_o.r.last   = out_width_converter_resp.r.last  ;
  assign slv_resp_o.r.user   = out_width_converter_resp.r.user  ;
   
  axi_dw_converter #(
    .AxiMaxReads (AxiMaxReads), 
    .AxiSlvPortDataWidth(AxiSlvPortDataWidth), // Data width of the slv port
    .AxiMstPortDataWidth(AxiMstPortDataWidth), // Data width of the mst port
    .AxiAddrWidth(AxiAddrWidth), // Address width FIXME
    .AxiIdWidth(AxiIdWidth), // ID width
    .aw_chan_t(slv_aw_chan_t), // AW Channel Type
    .mst_w_chan_t(w_chan_t), //  W Channel Type for mst port // output
    .slv_w_chan_t(w_chan_wide_t), //  W Channel Type for slv port // input
    .b_chan_t(slv_b_chan_t), //  B Channel Type
    .ar_chan_t(slv_ar_chan_t), // AR Channel Type
    .mst_r_chan_t(slv_r_chan_t), //  R Channel Type for mst port
    .slv_r_chan_t(r_chan_slv_wide_t), //  R Channel Type for slv port
    .axi_mst_req_t(slv_req_t), // AXI Request Type for mst ports
    .axi_mst_resp_t(slv_resp_t), // AXI Response Type for mst ports
    .axi_slv_req_t(slv_req_variable_t), // AXI Request Type for slv ports
    .axi_slv_resp_t(slv_resp_variable_t)  // AXI Response Type for slv ports
  ) i_slave_ports_width_reduction (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    // Slave interface
    .slv_req_i(in_width_converter_req),
    .slv_resp_o(out_width_converter_resp),
    // Master interface
    .mst_req_o(mst_req_o),
    .mst_resp_i(mst_resp_i)
  ); 
 
endmodule
