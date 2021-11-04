/*

Voter communicates with the SoC via 32 memory-mapped registers:
            offset    (uint64* ptr)      Register
            ------    -------------     -----------------
BASE_ADR    +0          (+0)            config (slv_reg[0] : write only)
            +8          (+1)            set_a  (slv_reg[1] : write only)
            +16         (+2)            set_b  (slv_reg[2] : write only)
            +24         (+3)            set_c  (slv_reg[3] : write only)
            +32         (+4)            set_d  (slv_reg[4] : write only)
            +40         (+5)            set_e  (slv_reg[5] : write only)
            +48         (+6)            set_f  (slv_reg[6] : write only)
            +56         (+7)            set_g  (slv_reg[7] : write only)
            +64         (+8)            set_h  (slv_reg[8] : write only)
            +72         (+9)            set_i  (slv_reg[9] : write only)            
            +80         (+10)           res_A  (slv_reg[10] : read only)
            +88         (+11)           res_B  (slv_reg[11] : read only)
            +96         (+12)           res_C  (slv_reg[12] : read only)
            +104        (+13)           res_D  (slv_reg[13] : read only)
            +112        (+14)           res_E  (slv_reg[14] : read only)
            +120        (+15)           res_F  (slv_reg[15] : read only)
            +128        (+16)           res_G  (slv_reg[16] : read only)
            +136        (+17)           res_H  (slv_reg[17] : read only)
            +144        (+18)           res_I  (slv_reg[18] : read only)
            +152        (+19)           state  (slv_reg[19] : read only)
            +160        (+20)           status (slv_reg[20] : read only)
            +248        (+31)           reset control (write 0xF to clear all registers)

IMPORTANT: Base Address should be aligned by 256 bytes, i.e. BASE_ADR = AXI_ADDR & 8'hFF
*/

`include "RVCell.sv"

module rootvoter
#(
    parameter C_S_AXI_ADDR_WIDTH = 12,
    parameter C_S_AXI_DATA_WIDTH = 128,
    parameter REG_DATA_WIDTH = 64,
    parameter MAX_DATASETS = 3
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
    output wire                          INTERRUPT // or whatever output the rootvoter produces

);
    
	localparam WRITE_LOW_ADR = 0;
	localparam WRITE_REG_NUM = 10;
	localparam WRITE_HIGH_ADR = WRITE_LOW_ADR + WRITE_REG_NUM-1;
    localparam CMD_ADR       = 31;
    localparam ADR_MASK = { {(C_S_AXI_ADDR_WIDTH-8){1'b0}}, {8{1'b1}} };
	
	localparam READ_LOW_ADR = WRITE_HIGH_ADR + 1;
	localparam READ_REG_NUM = 11;
	localparam READ_HIGH_ADR = READ_LOW_ADR + READ_REG_NUM-1;

	localparam TOTAL_REGS = WRITE_REG_NUM + READ_REG_NUM; 

	localparam integer AXI_ALIGN_FACTOR = C_S_AXI_DATA_WIDTH/REG_DATA_WIDTH;
	
	
	localparam REG_DATA_BYTES = REG_DATA_WIDTH / 8;
	localparam integer ADDR_LSB = $clog2(REG_DATA_BYTES); // 32bit: ADDR_LSB=2, 64bit: ADDR_LSB=3, 128bit: ADDR_LSB=4  
	localparam integer ADDR_MSB = C_S_AXI_ADDR_WIDTH-1;
	localparam integer SETNUM = 9;

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

//----------------------------------------------
//-----RootVoter memory mapped registers signals
//----------------------------------------------
	wire [7:0]  res_data[SETNUM];
	wire [13:0] status;
	wire [7:0]  state_internal;

	
	 
    reg [REG_DATA_WIDTH-1:0]     slv_reg [0:WRITE_REG_NUM-1];
	reg [REG_DATA_BYTES-1:0]     slv_reg_valid [0:WRITE_REG_NUM-1];
    reg [REG_DATA_WIDTH-1:0]     read_reg [0:READ_REG_NUM-1];
	reg set_valid [SETNUM];
	
    wire                         slv_reg_rden;
    wire                         slv_reg_wren;
    reg [C_S_AXI_DATA_WIDTH-1:0] reg_data_out;
    integer                      byte_index; 
    reg                          aw_en;


    assign S_AXI_AWREADY_o	= axi_awready;
    assign S_AXI_WREADY_o	= axi_wready;
    assign S_AXI_BRESP_o	= axi_bresp;
    assign S_AXI_BVALID_o	= axi_bvalid;
    assign S_AXI_ARREADY_o	= axi_arready;
    assign S_AXI_RDATA_o	= axi_rdata;
    assign S_AXI_RRESP_o	= axi_rresp;
    assign S_AXI_RVALID_o	= axi_rvalid;

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
        	integer i;
        	for (i=WRITE_LOW_ADR; i<=WRITE_HIGH_ADR; i=i+1) begin
				slv_reg[i] <={REG_DATA_WIDTH{1'b0}};
				slv_reg_valid[i] <= {REG_DATA_BYTES{1'b0}};
			end
	    end 
	  else begin
	    if (slv_reg_wren)
	      begin : strobes
            integer write_address, offset;

            /* verilator lint_off WIDTH */
            // Width mismatch between integer 32B and MSB due to aligment of 
            // addresses
              write_address = axi_awaddr[ADDR_MSB:ADDR_LSB];      //register index

			  //clear all registers
			  if (write_address == CMD_ADR && S_AXI_WSTRB_i[REG_DATA_BYTES-1:0] != 0 ) begin
				if (S_AXI_WDATA_i[3:0]==4'b1111) begin
					integer i;				
					for (i=WRITE_LOW_ADR+1; i<=WRITE_HIGH_ADR; i=i+1) begin
						slv_reg[i] <={REG_DATA_WIDTH{1'b0}};
						slv_reg_valid[i] <= {REG_DATA_BYTES{1'b0}};
					end;
					slv_reg[WRITE_LOW_ADR] <= { {1'b1}, {(REG_DATA_WIDTH-1){1'b0}} };	//reset
				end
			  end
			  else if (write_address >= WRITE_LOW_ADR && write_address <= WRITE_HIGH_ADR) begin
                    for (byte_index = 0; byte_index <= REG_DATA_BYTES-1; byte_index = byte_index+1 )
                        if ( S_AXI_WSTRB_i[byte_index] == 1 ) begin
							// Respective byte enables are asserted as per write strobes 
							slv_reg[write_address][(byte_index*8) +: 8] <= S_AXI_WDATA_i[(byte_index*8) +: 8];
							slv_reg_valid[write_address][byte_index] <= 1; 
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

   
   


assign reset = (~S_AXI_ARESETN_i) | slv_reg[WRITE_LOW_ADR][REG_DATA_WIDTH-1];


genvar set_id;
generate 
	for(set_id = 0; set_id <= SETNUM-1; set_id++)begin
		assign set_valid[set_id] = slv_reg_valid[set_id+1] == {REG_DATA_BYTES{1'b1}};
		assign read_reg[set_id] = {{(REG_DATA_WIDTH-8){1'b0}}, res_data[set_id]};
	end;
endgenerate


assign read_reg[SETNUM] = {{(REG_DATA_WIDTH-8){1'b0}}, state_internal};
assign read_reg[SETNUM+1] = {{(REG_DATA_WIDTH-14){1'b0}}, status};



RVCell #(.REG_DATA_WIDTH(REG_DATA_WIDTH), 
         .MAX_DATASETS(MAX_DATASETS)) RVC0 (
	.clk(S_AXI_ACLK_i),          // clock
	.reset(reset),          	 // Reset
	.cfg(slv_reg[0][31:0]),      // Config register
	.set_A(slv_reg[1]),          // Set Reigsters A - I
	.set_B(slv_reg[2]),
	.set_C(slv_reg[3]),
	.set_D(slv_reg[4]),
	.set_E(slv_reg[5]),
	.set_F(slv_reg[6]),
	.set_G(slv_reg[7]),
	.set_H(slv_reg[8]),
	.set_I(slv_reg[9]),
	.valid_A(set_valid[0]),
	.valid_B(set_valid[1]),
	.valid_C(set_valid[2]),
	.valid_D(set_valid[3]),
	.valid_E(set_valid[4]),
	.valid_F(set_valid[5]),
	.valid_G(set_valid[6]),
	.valid_H(set_valid[7]),
	.valid_I(set_valid[8]),
	.res_A(res_data[0]),          // Result Register A - I        
	.res_B(res_data[1]),
	.res_C(res_data[2]),
	.res_D(res_data[3]),
	.res_E(res_data[4]),
	.res_F(res_data[5]),
	.res_G(res_data[6]),
	.res_H(res_data[7]),
	.res_I(res_data[8]),
	.state_internal(state_internal),
	.status(status));

endmodule

