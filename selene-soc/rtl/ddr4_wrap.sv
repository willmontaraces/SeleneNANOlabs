// systemverilog wrapper for DDR4_IF
module ddr4_wrap
#(
  parameter CONFIGURED_DQ_BITS = 8
) 
(
   input [1 : 0] CK ,
   input ACT_n,
   input RAS_n_A16 ,
   input CAS_n_A15 ,
   input WE_n_A14  ,
   output ALERT_n  ,
   input PARITY   ,
   input RESET_n   ,
   input TEN      ,
   input CS_n     ,
   input CKE     ,
   input ODT     ,
   input [2 : 0] C, 
   input [0 : 0] BG ,
   input [1 : 0] BA ,
   input [13 : 0] ADDR,
   input ADDR_17,
   input [ 7 : 0 ] DM_n,
   inout wire [ 63 : 0 ] DQ,
   inout wire [ 7 : 0 ] DQS_t,
   inout wire [ 7 : 0 ] DQS_c,
   input ZQ,
   input PWR,
   input VREF_CA,
   input VREF_DQ
);
  
  parameter int CONFIGURED_DENSITY = 4;
  parameter int CONFIGURED_RANKS = 1; 
  wire model_enable;
  reg model_enable_val;
  assign model_enable = model_enable_val;



  DDR4_if #( .CONFIGURED_DQ_BITS(CONFIGURED_DQ_BITS) ) idimm();

  // ddr4 model instantiation
  ddr4_model 
  #(.CONFIGURED_DQ_BITS(CONFIGURED_DQ_BITS), 
    .CONFIGURED_DENSITY(CONFIGURED_DENSITY), 
    .CONFIGURED_RANKS(CONFIGURED_RANKS)
   )
  golden_model
   (.model_enable(model_enable),
    .iDDR4(idimm));
  
  bidi_feedthru #( .WIDTH( 8 ) ) dqst_alias( DQS_t, idimm.DQS_t );
  bidi_feedthru #( .WIDTH( 8 ) ) dqsc_alias( DQS_c, idimm.DQS_c );
  bidi_feedthru #( .WIDTH( 64 ) ) ddr_d_alias( DQ, idimm.DQ );
  assign CK = idimm.CK;
  assign ACT_n= idimm.ACT_n ;
  assign RAS_n_A16 = idimm.RAS_n_A16 ;
  assign CAS_n_A15 = idimm.CAS_n_A15 ;
  assign WE_n_A14  = idimm.WE_n_A14 ;
  assign ALERT_n  = idimm.ALERT_n ;
  assign PARITY   = idimm.PARITY ;
  assign RESET_n   = idimm.RESET_n ;
  assign TEN      = idimm.TEN ;
  assign CS_n     = idimm.CS_n ;
  assign CKE     = idimm.CKE ;
  assign ODT     = idimm.ODT ;
  assign C = idimm.C ; 
  assign BG = idimm.BG ;
  assign BA = idimm.BA ;
  assign  ADDR = idimm.ADDR ;
  assign ADDR_17 = idimm.ADDR_17 ;
  assign  DM_n = idimm.DM_n ;
  assign ZQ = idimm.ZQ ;
  assign PWR = idimm.PWR ;
  assign VREF_CA = idimm.PWR ;
  assign VREF_DQ = idimm.VREF_DQ ;

  initial begin
    model_enable_val = 1;
  end


endmodule
