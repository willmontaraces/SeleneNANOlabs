/* verilator lint_off DECLFILENAME */
/* verilator lint_off WIDTH */

`include "Counter.sv"
`include "Compare_unit.sv"


module RVCell #(
	parameter int unsigned REG_DATA_WIDTH = 64,
	parameter int unsigned MAX_DATASETS = 9)
	(
	input wire clk,
	input wire reset,
	input wire [31:0] cfg,
	input wire [REG_DATA_WIDTH-1:0] set_A,
	input wire [REG_DATA_WIDTH-1:0] set_B,
	input wire [REG_DATA_WIDTH-1:0] set_C,
	input wire [REG_DATA_WIDTH-1:0] set_D,
	input wire [REG_DATA_WIDTH-1:0] set_E,
	input wire [REG_DATA_WIDTH-1:0] set_F,
	input wire [REG_DATA_WIDTH-1:0] set_G,
	input wire [REG_DATA_WIDTH-1:0] set_H,
	input wire [REG_DATA_WIDTH-1:0] set_I,
	input wire valid_A,
	input wire valid_B,
	input wire valid_C,
	input wire valid_D,
	input wire valid_E,
	input wire valid_F,
	input wire valid_G,
	input wire valid_H,
	input wire valid_I,
	output reg [7:0] res_A,
	output reg [7:0] res_B,
	output reg [7:0] res_C,
	output reg [7:0] res_D,
	output reg [7:0] res_E,
	output reg [7:0] res_F,
	output reg [7:0] res_G,
	output reg [7:0] res_H,
	output reg [7:0] res_I,
	output reg [13:0] status,
	output reg [7:0] state_internal);


	typedef enum logic[4:0] {
		state_idle				= 5'b00001,
		state_wait_datasets		= 5'b00010,
		state_voting 			= 5'b00100, 
		state_timeout			= 5'b01000,
		state_result   			= 5'b10000} state_enc_t;

    localparam v2oo2 = 2'b00,
               v2oo3 = 2'b01,
               v4oo7 = 2'b10,
               v5oo9 = 2'b11;

    state_enc_t state_reg, state_next;   // Seq part of the FSM

	logic [0:8] validity_flags;
	logic [3:0] dataset_cnt, datasets_min;
	logic all_datasets_loaded;
	
    

    wire [1:0] cell_type;
    assign cell_type = cfg & 2'b11;
	
	logic[8:0] timeout, timeout_reg, timeout_mask;
    
    // Counter
    wire counter_expired;
    logic counter_en;
    wire [29:0] data_counter;
    logic counter_load;
    logic ready;

    // Compare unit
    logic compare_en;
    logic compare_reset;
    logic compare_done;
    
    assign data_counter = (cfg >> 2) & 30'h3FFFFFFF;
    assign state_internal = {compare_reset, compare_en, compare_done, state_reg};
    assign status = {timeout, ready}; 
	
    
    //----------Connect Modules------------------------
    // time out counter
	Counter #(.DWIDTH(30)) C0 (
			.load(counter_load),
			.d(data_counter),
			.en(counter_en),
			.clk(clk),
			.reset(reset),
			.expired(counter_expired));

    // Compare unit 
    Cmp #(.MAX_DATASETS(MAX_DATASETS) ) Cmp0(
			.en(compare_en),
			.reset(compare_reset),
			.clk(clk),
			.done(compare_done),
			.set_A(set_A),
			.set_B(set_B),
			.set_C(set_C),
			.set_D(set_D),
			.set_E(set_E),
			.set_F(set_F),
			.set_G(set_G),
			.set_H(set_H),
			.set_I(set_I),
			.res_A(res_A),
			.res_B(res_B),
			.res_C(res_C),
			.res_D(res_D),
			.res_E(res_E),
			.res_F(res_F),
			.res_G(res_G),
			.res_H(res_H),
			.res_I(res_I),
			.vote_type(cell_type));

    //Number of loaded datasets is derived from validity flags
	assign validity_flags = {valid_I, valid_H, valid_G, valid_F, valid_E, valid_D, valid_C, valid_B, valid_A};
	integer bit_id;
	always@(validity_flags) begin
		dataset_cnt = 4'h0;
		for(bit_id=0;bit_id<9;bit_id++)begin
			dataset_cnt = dataset_cnt + validity_flags[bit_id];
		end;
	end
	
	//Miminal required number of datasets
	always_comb begin
		unique case(cell_type)
			v2oo2: timeout_mask = 9'b000000011;					
			v2oo3: timeout_mask = 9'b000000111;
			v4oo7: timeout_mask = 9'b001111111;
			v5oo9: timeout_mask = 9'b111111111;		
		endcase;
	end

	
	always_comb begin
		unique case(cell_type)
			v2oo2: datasets_min = 4'h2;					
			v2oo3: datasets_min = 4'h2;
			v4oo7: datasets_min = 4'h4;
			v5oo9: datasets_min = 4'h5;		
		endcase;
	end


	//indicate availability of all datasets
	always_comb begin
		unique case(cell_type)
			v2oo2: all_datasets_loaded = valid_A & valid_B;
			v2oo3: all_datasets_loaded = valid_A & valid_B & valid_C;
			v4oo7: all_datasets_loaded = valid_A & valid_B & valid_C & valid_D & valid_E & valid_F & valid_G;
			v5oo9: all_datasets_loaded = valid_A & valid_B & valid_C & valid_D & valid_E & valid_F & valid_G & valid_H & valid_I;
		endcase;
	end
	

	



    always @(posedge clk) begin
        if(reset==1)
            begin
            state_reg <= state_idle;
			timeout_reg <= 9'b000000000;
            end
        else
            begin
            state_reg <= state_next;
			timeout_reg <= timeout;
            end
    end


	always_comb
    begin: FSM
		state_next = state_reg; 
		timeout = timeout_reg;
		{compare_en, compare_reset, counter_en, counter_load, ready}  = 5'b00000;



		unique case(state_reg)
			state_idle: begin
				compare_reset = 1'b1;
				if(cfg != 0) begin
					state_next = state_wait_datasets;
					counter_load  = 1'b1;
					timeout = 9'b000000000;
				end
			end
				
			state_wait_datasets: begin
				$display("## Waiting for datasets\n");
				compare_reset = 1'b1;
				if(counter_expired == 1'b0) begin
					counter_en = 1'b1;										
					if(all_datasets_loaded == 1'b1) begin
						$display("## All datasets available before timeout: voting\n");
						state_next = state_voting;
					end
				end
				else begin
					counter_en = 1'b0;					
					timeout = (~{valid_I, valid_H, valid_G, valid_F, valid_E, valid_D, valid_C, valid_B, valid_A}) & timeout_mask ;				
					if(dataset_cnt >= datasets_min) begin
						$display("## Enough datasets available after timeout: attempting to vote\n");
						state_next = state_voting;						
					end
					else begin
						$display("## Not enough datasets available after timeout: voting not possible\n");
						state_next = state_timeout;
					end
				end
			end
			
			state_voting: begin			
				if (compare_done == 1'b1) begin
					$display("## Voting completed\n");
					state_next = state_result;
				end
				else begin
					compare_en = 1'b1;
				end
			end
			
			state_timeout: begin
			    $display("## State_timeout\n");
				ready  = 1'b1;
				if (cfg == 32'h00000000) begin
					state_next = state_idle;
				end
			end
			
			state_result: begin
				$display("## State_result");
				ready  = 1'b1;				
				if(cfg == 32'h00000000) begin
					state_next = state_idle;
				end
			end
			
			default: begin
				state_next = state_idle;
			end
		endcase
	end: FSM

endmodule


