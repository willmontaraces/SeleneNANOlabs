module CompareUnit #(
    parameter int unsigned REG_DATA_WIDTH = 64,
    parameter int unsigned MAX_DATASETS = 9,
    parameter int unsigned COUNT_MATCHES = 1,
    parameter int unsigned LIST_MATCHES = 0
)(
    input logic clk,
    input logic reset,
    input logic en,
    input logic [REG_DATA_WIDTH-1:0] sets [MAX_DATASETS],
    input logic [3:0] used_datasets,
    
    output logic [119:0] match_vector,
    output logic [3:0]  match_cnt [MAX_DATASETS],
    output logic done
    );
    
    parameter MBITS = MAX_DATASETS*(MAX_DATASETS-1)/2;
    
    
    logic [3:0] i, j;    //set pointers
    logic bitmatch_res;

    assign bitmatch_res = (sets[i] == sets[j]);
    
    always @(posedge clk) begin
        if (reset == 1'b1) begin    
            i <= 4'h0;
            j <= 4'h1;
            match_vector <= 120'b0;
            done <= 1'b0;
            match_cnt <= '{default:0};
        end

        else if(en == 1'b1) begin
            if(LIST_MATCHES==1)begin
                if(done==0)begin
                    match_vector[MBITS-1:0] <= {match_vector[MBITS-2:0], bitmatch_res};
                end;
            end;

            if(COUNT_MATCHES == 1)begin
                if(done==0 && i!=j)begin
                    if(bitmatch_res==1'b1) begin
                        match_cnt[i] <= match_cnt[i] + 1;
                        match_cnt[j] <= match_cnt[j] + 1;
                    end;
                end;
            end;
            
            if(i >= used_datasets-2)begin
                done <= 1'b1;
            end
            else begin
                if(j < used_datasets-1)begin
                    j <= j+1;
                end
                else begin
                    i <= i+1;
                    j <= i+2;
                end
            end
        end
    end;
        
endmodule
    
    