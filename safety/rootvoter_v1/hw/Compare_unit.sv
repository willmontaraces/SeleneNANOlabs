/* verilator lint_off DECLFILENAME */
/* verilator lint_off WIDTH */


module Cmp #(
	parameter int unsigned MAX_DATASETS = 9
)(
    input en,
    input clk,
    input reset,
    input [64-1:0] set_A,
    input [64-1:0] set_B,
    input [64-1:0] set_C,
    input [64-1:0] set_D,
    input [64-1:0] set_E,
    input [64-1:0] set_F,
    input [64-1:0] set_G,
    input [64-1:0] set_H,
    input [64-1:0] set_I,
    input [1:0] vote_type,
    //output [63:0]cmp_result,
    output reg [7:0]res_A,
    output reg [7:0]res_B,
    output reg [7:0]res_C,
    output reg [7:0]res_D,
    output reg [7:0]res_E,
    output reg [7:0]res_F,
    output reg [7:0]res_G,
    output reg [7:0]res_H,
    output reg [7:0]res_I,
    output reg done);
    
    localparam v2oo2 = 2'b00,
               v2oo3 = 2'b01,
               v4oo7 = 2'b10,
               v5oo9 = 2'b11;

    logic [7:0] cnt, cnt_to;

    //assign cmp_result = {res_C, res_B, res_A};



	always_comb begin
		unique case(vote_type)
			v2oo2: cnt_to = 8'h01;
			v2oo3: cnt_to = 8'h02;
			v4oo7: cnt_to = 8'h14;
			v5oo9: cnt_to = 8'h23;		
		endcase;
	end


    always @(posedge clk) begin
        if (reset == 1'b1) begin
            ////$display("-- Reset Compare unit\n");
            res_A <= 8'h00;
            res_B <= 8'h00;
            res_C <= 8'h00;
            res_D <= 8'h00;
            res_E <= 8'h00;
            res_F <= 8'h00;
            res_G <= 8'h00;
            res_H <= 8'h00;
            res_I <= 8'h00;
            done <= 1'b0;
            cnt <= 8'h00;
        end
        else if(en == 1'b1) begin
		
			if(MAX_DATASETS >= 2) begin
				if (vote_type == v2oo2 || vote_type == v2oo3 || vote_type == v4oo7 || vote_type == v5oo9) begin
					if (set_A === set_B && cnt == 8'h00) begin
						//$display("## CMP set_A == set _B\n");
						res_A <= res_A + 1;
						res_B <= res_B + 1;
					end
				end
			end

			if(MAX_DATASETS >= 3) begin
				if (vote_type == v2oo3 || vote_type == v4oo7 || vote_type == v5oo9) begin
					if (set_A === set_C && cnt == 8'h01) begin
						//$display("## CMP set_A == set _C\n");
						res_A <= res_A + 1;
						res_C <= res_C + 1;
					end
					if (set_B === set_C && cnt == 8'h02) begin
						//$display("## CMP set_B == set_C\n");
						res_B <= res_B + 1;
						res_C <= res_C + 1;
					end
				end
			end
				
			if(MAX_DATASETS >= 7) begin
				if (vote_type == v4oo7 || vote_type == v5oo9) begin
					if (set_A === set_D && cnt == 8'h03) begin
						//$display("## CMP set_A == set_D\n");
						res_A <= res_A + 1;
						res_D <= res_D + 1;
					end
					if (set_A === set_E && cnt == 8'h04) begin
						//$display("## CMP set_A == set_E\n");
						res_A <= res_A + 1;
						res_E <= res_E + 1;
					end
					if (set_A === set_F && cnt == 8'h05) begin
						//$display("## CMP set_A == set_F\n");
						res_A <= res_A + 1;
						res_F <= res_F + 1;
					end
					if (set_A === set_G && cnt == 8'h06) begin
						//$display("## CMP set_B == set_G\n");
						res_A <= res_A + 1;
						res_G <= res_G + 1;
					end
					if (set_B === set_D && cnt == 8'h07) begin
						//$display("## CMP set_B == set_D\n");
						res_B <= res_B + 1;
						res_D <= res_D + 1;
					end
					if (set_B === set_E && cnt == 8'h08) begin
						//$display("## CMP set_B == set_E\n");
						res_B <= res_B + 1;
						res_E <= res_E + 1;
					end
					if (set_B === set_F && cnt == 8'h09) begin
						//$display("## CMP set_B == set_F\n");
						res_B <= res_B + 1;
						res_F <= res_F + 1;
					end
					if (set_B === set_G && cnt == 8'h0A) begin
						//$display("## CMP set_B == set_G\n");
						res_B <= res_B + 1;
						res_G <= res_G + 1;
					end
					if (set_C === set_D && cnt == 8'h0B) begin
						//$display("## CMP set_C == set_D\n");
						res_C <= res_C + 1;
						res_D <= res_D + 1;
					end
					if (set_C === set_E && cnt == 8'h0C) begin
						//$display("## CMP set_C == set_E\n");
						res_C <= res_C + 1;
						res_E <= res_E + 1;
					end
					if (set_C === set_F && cnt == 8'h0D) begin
						//$display("## CMP set_C == set_F\n");
						res_C <= res_C + 1;
						res_F <= res_F + 1;
					end
					if (set_C === set_G && cnt == 8'h0E) begin
						//$display("## CMP set_C == set_G\n");
						res_C <= res_C + 1;
						res_G <= res_G + 1;
					end
					if (set_D === set_E && cnt == 8'h0F) begin
						//$display("## CMP set_D == set_E\n");
						res_D <= res_D + 1;
						res_E <= res_E + 1;
					end
					if (set_D === set_F && cnt == 8'h10) begin
						//$display("## CMP set_D == set_F\n");
						res_D <= res_D + 1;
						res_F <= res_F + 1;
					end
					if (set_D === set_G && cnt == 8'h11) begin
						//$display("## CMP set_D == set_G\n");
						res_D <= res_D + 1;
						res_G <= res_G + 1;
					end
					if (set_E === set_F && cnt == 8'h12) begin
						//$display("## CMP set_E == set_F\n");
						res_E <= res_E + 1;
						res_F <= res_F + 1;
					end
					if (set_E === set_G && cnt == 8'h13) begin
						//$display("## CMP set_F == set_G\n");
						res_E <= res_E + 1;
						res_G <= res_G + 1;
					end
					if (set_F === set_G && cnt == 8'h14) begin
						//$display("## CMP set_F == set_G\n");
						res_F <= res_F + 1;
						res_G <= res_G + 1;
					end
				end
			end
			
			if(MAX_DATASETS >= 9) begin
				if (vote_type == v5oo9) begin
					if (set_A === set_H && cnt == 8'h15) begin
						res_A <= res_A + 1;
						res_H <= res_H + 1;
					end
					if (set_A === set_I && cnt == 8'h16) begin
						res_A <= res_A + 1;
						res_I <= res_I + 1;
					end
					if (set_B === set_H && cnt == 8'h17) begin
						res_B <= res_B + 1;
						res_H <= res_H + 1;
					end
					if (set_B === set_I && cnt == 8'h18) begin
						res_B <= res_B + 1;
						res_I <= res_I + 1;
					end
					if (set_C === set_H && cnt == 8'h19) begin
						res_C <= res_C + 1;
						res_H <= res_H + 1;
					end
					if (set_C === set_I && cnt == 8'h1A) begin
						res_C <= res_C + 1;
						res_I <= res_I + 1;
					end
					if (set_D === set_H && cnt == 8'h1B) begin
						res_D <= res_D + 1;
						res_H <= res_H + 1;
					end
					if (set_D === set_I && cnt == 8'h1C) begin
						res_D <= res_D + 1;
						res_I <= res_I + 1;
					end
					if (set_E === set_H && cnt == 8'h1D) begin
						res_E <= res_E + 1;
						res_H <= res_H + 1;
					end
					if (set_E === set_I && cnt == 8'h1E) begin
						res_E <= res_E + 1;
						res_I <= res_I + 1;
					end
					if (set_F === set_H && cnt == 8'h1F) begin
						res_F <= res_F + 1;
						res_H <= res_H + 1;
					end
					if (set_F === set_I && cnt == 8'h20) begin
						res_F <= res_F + 1;
						res_I <= res_I + 1;
					end

					if (set_G === set_H && cnt == 8'h21) begin
						res_G <= res_G + 1;
						res_H <= res_H + 1;
					end
					if (set_G === set_I && cnt == 8'h22) begin
						res_G <= res_G + 1;
						res_I <= res_I + 1;
					end

					if (set_H === set_I && cnt == 8'h23) begin
						res_H <= res_H + 1;
						res_I <= res_I + 1;
					end
				end
			end

			if (cnt >= cnt_to) begin
				done <= 1'b1;
			end;
			
			cnt <= cnt + 1;
		
        end
		
    end


endmodule
