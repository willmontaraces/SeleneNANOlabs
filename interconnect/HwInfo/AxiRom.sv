
module AxiRom
#(
    parameter int unsigned C_S_AXI_ADDR_WIDTH = 12,
    parameter int unsigned C_S_AXI_DATA_WIDTH = 128,
    parameter int unsigned REG_DATA_WIDTH = 64,
    parameter int unsigned REGNUM = 16,
    parameter logic [REG_DATA_WIDTH*REGNUM-1:0] INIT = '{default:0}
)(
    // axi4 lite slave signals
    input  wire                          S_AXI_ACLK_i,
    input  wire                          S_AXI_ARESETN_i,
    input  wire                          S_AXI_ACLK_EN_i,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR_i,
    input  wire                          S_AXI_AWVALID_i,
    output wire                          S_AXI_AWREADY_o,
    input  wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA_i,
    input  wire [C_S_AXI_DATA_WIDTH/8-1:0] S_AXI_WSTRB_i,
    input  wire                          S_AXI_WVALID_i,
    output wire                          S_AXI_WREADY_o,
    output wire [1:0]                    S_AXI_BRESP_o,
    output wire                          S_AXI_BVALID_o,
    input  wire                          S_AXI_BREADY_i,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR_i,
    input  wire                          S_AXI_ARVALID_i,
    output wire                          S_AXI_ARREADY_o,
    output wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA_o,
    output wire [1:0]                    S_AXI_RRESP_o,
    output wire                          S_AXI_RVALID_o,
    input  wire                          S_AXI_RREADY_i,
    output logic                         acc_sw_reset_n // or whatever output the rootvoter produces                        
);
    
    
    localparam READ_LOW_ADR  = 0;
    localparam READ_HIGH_ADR = REGNUM;
    localparam CMD_ADR       = 31;
    localparam ADR_MASK = { {(C_S_AXI_ADDR_WIDTH-8){1'b0}}, {8{1'b1}} };
    localparam integer AXI_ALIGN_FACTOR = C_S_AXI_DATA_WIDTH/REG_DATA_WIDTH;
    localparam REG_DATA_BYTES = REG_DATA_WIDTH / 8;
    localparam integer ADDR_LSB = $clog2(REG_DATA_BYTES); // 32bit: ADDR_LSB=2, 64bit: ADDR_LSB=3, 128bit: ADDR_LSB=4  
    localparam integer ADDR_MSB = C_S_AXI_ADDR_WIDTH-1;
    
    logic [REG_DATA_WIDTH-1:0] read_reg [REGNUM];


    genvar idx;
    generate 
        for(idx = 0; idx < REGNUM; idx++)begin
            assign read_reg[idx] = INIT[(idx+1)*REG_DATA_WIDTH-1:idx*REG_DATA_WIDTH];
        end;
    endgenerate



//----------------------------------------------
//------------ AXI4LITE signals
//----------------------------------------------

    //Lower bits are not used due to 32 bit address aligment
    reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_awaddr;
    reg                            axi_awready;
    reg                            axi_wready;
    reg [1 : 0]                    axi_bresp;
    reg                            axi_bvalid;
   
    //Lower bits are not used due to 32 bit address aligment
    reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_araddr;
    reg                            axi_arready;
    reg [C_S_AXI_DATA_WIDTH-1 : 0] axi_rdata;
    reg [1 : 0]                    axi_rresp;
    reg                            axi_rvalid;

    wire                         slv_reg_rden;
    wire                         slv_reg_wren;
    reg [C_S_AXI_DATA_WIDTH-1:0] reg_data_out;
    integer                      byte_index; 
    reg                          aw_en;

    assign S_AXI_AWREADY_o   = axi_awready;
    assign S_AXI_WREADY_o    = axi_wready;
    assign S_AXI_BRESP_o     = axi_bresp;
    assign S_AXI_BVALID_o    = axi_bvalid;
    assign S_AXI_ARREADY_o   = axi_arready;
    assign S_AXI_RDATA_o     = axi_rdata;
    assign S_AXI_RRESP_o     = axi_rresp;
    assign S_AXI_RVALID_o    = axi_rvalid;

    // Implement axi_awready generation
    // axi_awready is asserted for one S_AXI_ACLK_i clock cycle when both
    // S_AXI_AWVALID_i and S_AXI_WVALID_i are asserted. axi_awready is
    // de-asserted when reset is low.

    always @( posedge S_AXI_ACLK_i) // Synchronous reset is more reliable
      begin
        if ( S_AXI_ARESETN_i == 1'b0 )
          begin
            axi_awready <= 1'b0;
            aw_en <= 1'b1;
      end 
    else
          begin    
            if (~axi_awready && S_AXI_AWVALID_i && S_AXI_WVALID_i && aw_en)
              begin
                // slave is ready to accept write address when 
                // there is a valid write address and write data
                // on the write address and data bus. This design 
                // expects no outstanding transactions. 
            axi_awready <= 1'b1;
            aw_en <= 1'b0;
          end
        else if (S_AXI_BREADY_i && axi_bvalid)
              begin
                aw_en <= 1'b1;
                axi_awready <= 1'b0;
              end
          else           
            begin
              axi_awready <= 1'b0;
            end
        end 
    end       

     // Implement axi_awaddr latching
     // This process is used to latch the address when both 
     // S_AXI_AWVALID_i and S_AXI_WVALID_i are valid. 
     always @( posedge S_AXI_ACLK_i, negedge S_AXI_ARESETN_i)
    begin
      if ( S_AXI_ARESETN_i == 1'b0 )
        begin
          axi_awaddr <= {C_S_AXI_ADDR_WIDTH{1'b0}};
        end 
      else
        begin    
          if (~axi_awready && S_AXI_AWVALID_i && S_AXI_WVALID_i && aw_en)
            begin
              // Write Address latching 
              axi_awaddr <= S_AXI_AWADDR_i & ADR_MASK;
            end
        end 
    end       

    // Implement axi_wready generation
    // axi_wready is asserted for one S_AXI_ACLK_i clock cycle when both
    // S_AXI_AWVALID_i and S_AXI_WVALID_i are asserted. axi_wready is 
    // de-asserted when reset is low. 

    always @( posedge S_AXI_ACLK_i)
    begin
      if ( S_AXI_ARESETN_i == 1'b0 )
        begin
          axi_wready <= 1'b0;
        end 
      else
        begin    
          if (~axi_wready && S_AXI_WVALID_i && S_AXI_AWVALID_i && aw_en )
            begin
              // slave is ready to accept write data when 
              // there is a valid write address and write data
              // on the write address and data bus. This design 
              // expects no outstanding transactions. 
              axi_wready <= 1'b1;
            end
          else
            begin
              axi_wready <= 1'b0;
            end
        end 
    end       

    // Implement memory mapped register select and write logic generation
    // The write data is accepted and written to memory mapped registers when
    // axi_awready, S_AXI_WVALID_i, axi_wready and S_AXI_WVALID_i are asserted. Write strobes are used to
    // select byte enables of slave registers while writing.
    // These registers are cleared when reset (active low) is applied.
    // Slave register write enable is asserted when valid address and data are available
    // and the slave is ready to accept the write address and write data.
    assign slv_reg_wren = axi_wready && S_AXI_WVALID_i && axi_awready && S_AXI_AWVALID_i;

    always @( posedge S_AXI_ACLK_i )
    begin
      if ( S_AXI_ARESETN_i == 1'b0 )
        begin : reset_all
          acc_sw_reset_n <= 1'b0;
        end 
      else begin
        
        if (S_AXI_ARESETN_i == 1'b1 & acc_sw_reset_n== 1'b0) begin
          acc_sw_reset_n <= 1'b1;
        
        end else if (slv_reg_wren) begin : strobes
            integer write_address, offset;
            
            write_address = axi_awaddr[ADDR_MSB:ADDR_LSB];      //register index
            if (write_address == CMD_ADR && S_AXI_WSTRB_i[REG_DATA_BYTES-1:0] != 0 ) begin
                if (S_AXI_WDATA_i[3:0]==4'b1111) begin          
                    acc_sw_reset_n <= 1'b0;
                end
            end
            
        end 
      end
    end
          


    // Implement write response logic generation
    // The write response and response valid signals are asserted by the slave 
    // when axi_wready, S_AXI_WVALID_i, axi_wready and S_AXI_WVALID_i are asserted.  
    // This marks the acceptance of address and indicates the status of 
    // write transaction.

    always @( posedge S_AXI_ACLK_i )
    begin
      if ( S_AXI_ARESETN_i == 1'b0 )
        begin
          axi_bvalid  <= 0;
          axi_bresp   <= 2'b0;
        end 
      else
        begin    
          if (axi_awready && S_AXI_AWVALID_i && ~axi_bvalid && axi_wready && S_AXI_WVALID_i)
            begin
              // indicates a valid write response is available
              axi_bvalid <= 1'b1;
              axi_bresp  <= 2'b0; // 'OKAY' response 
            end                   // work error responses in future
          else
            begin
              if (S_AXI_BREADY_i && axi_bvalid) 
                //check if bready is asserted while bvalid is high) 
                //(there is a possibility that bready is always asserted high)   
                begin
                  axi_bvalid <= 1'b0; 
                end  
            end
        end
    end   

    // Implement axi_arready generation
    // axi_arready is asserted for one S_AXI_ACLK_i clock cycle when
    // S_AXI_ARVALID_i is asserted. axi_awready is 
    // de-asserted when reset (active low) is asserted. 
    // The read address is also latched when S_AXI_ARVALID_i is 
    // asserted. axi_araddr is reset to zero on reset assertion.

    always @( posedge S_AXI_ACLK_i )
    begin
      if ( S_AXI_ARESETN_i == 1'b0 )
        begin
          axi_arready <= 1'b0;
          axi_araddr  <= {C_S_AXI_ADDR_WIDTH{1'b0}};
        end 
      else
        begin    
          if (~axi_arready && S_AXI_ARVALID_i)
            begin
              // indicates that the slave has acceped the valid read address
              axi_arready <= 1'b1;
              // Read address latching
              axi_araddr  <= S_AXI_ARADDR_i & ADR_MASK;
            end
          else
            begin
              axi_arready <= 1'b0;
            end
        end 
    end       

    // Implement axi_arvalid generation
    // axi_rvalid is asserted for one S_AXI_ACLK_i clock cycle when both 
    // S_AXI_ARVALID_i and axi_arready are asserted. The slave registers 
    // data are available on the axi_rdata bus at this instance. The 
    // assertion of axi_rvalid marks the validity of read data on the 
    // bus and axi_rresp indicates the status of read transaction.axi_rvalid 
    // is deasserted on reset (active low). axi_rresp and axi_rdata are 
    // cleared to zero on reset (active low).  
    always @( posedge S_AXI_ACLK_i )
    begin
      if ( S_AXI_ARESETN_i == 1'b0 )
        begin
          axi_rvalid <= 0;
          axi_rresp  <= 0;
        end 
      else
        begin    
          if (axi_arready && S_AXI_ARVALID_i && ~axi_rvalid)
            begin
              // Valid read data is available at the read data bus
              axi_rvalid <= 1'b1;
              axi_rresp  <= 2'b0; // 'OKAY' response
            end   
          else if (axi_rvalid && S_AXI_RREADY_i)
            begin
              // Read data is accepted by the master
              axi_rvalid <= 1'b0;
            end                
        end
    end    

    // Implement memory mapped register select and read logic generation
    // Slave register read enable is asserted when valid address is available
    // and the slave is ready to accept the read address.
    assign slv_reg_rden = axi_arready & S_AXI_ARVALID_i & ~axi_rvalid;
    always @(*)
    begin :decode_read
          // Address decoding for reading registers
          // Address read as integer to avoid width mismatch
          integer read_address;
          read_address = axi_araddr[ADDR_MSB:ADDR_LSB];         
          reg_data_out ={C_S_AXI_DATA_WIDTH{1'b0}};
          //check if the address is out of the range of R registers
          if(read_address >= READ_LOW_ADR && read_address <= READ_HIGH_ADR) begin
            reg_data_out ={AXI_ALIGN_FACTOR{read_reg[read_address-READ_LOW_ADR]}};
          end
    end
    // Output register or memory read data
    always @( posedge S_AXI_ACLK_i)
    begin
      if ( S_AXI_ARESETN_i == 1'b0 )
        begin
          axi_rdata  <= 0;
        end 
      else
        begin    
          // When there is a valid read address (S_AXI_ARVALID_i) with 
          // acceptance of read address by the slave (axi_arready), 
          // output the read dada 
          if (slv_reg_rden)
            begin
              axi_rdata <= reg_data_out;     // register read data
            end   
        end
    end    

   // // Output Interrupt to make ACC SW RESET
   //  always @( posedge S_AXI_ACLK_i)
   //  begin
   //    if ( S_AXI_ARESETN_i == 1'b0 )
   //      begin
   //        acc_sw_reset_n  <= 0;
   //      end 
   //    else
   //      begin    
   //        // When there is a valid read address (S_AXI_ARVALID_i) with 
   //        // acceptance of read address by the slave (axi_arready), 
   //        // output the read dada 
   //        if (slv_reg_rden && reg_data_out == 0X56777777) 
   //          begin
   //            axi_rdata <= reg_data_out;     // register read data
   //          end   
   //      end
   //  end  
   



endmodule







