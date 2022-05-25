/*  Description:
        Configurable comparator of datasets
        Iteratively compares each pair of datasets (from the input "sets[MAX_DATASETS]" array) 
        One pair of datasets is compared each clock cycle
        Range of compared datasets is determined by the input "used_datasets" 
        Comparison starts once "en" input goes active high
        
        On the output produces:
            1. match_cnt:    item i equals the number matches of dataset i with the rest of datasets
            2. match_vector: match flags for each pair of datasets         
        
        
    Author / Developer: 
        Ilya Tuzov (Universitat Politecnica de Valencia)

*/

module CompareUnit #(
    parameter int unsigned REG_DATA_WIDTH = 64,     // Dataset word size
    parameter int unsigned MAX_DATASETS = 9,        // Max. number of supported set registers
    parameter int unsigned COUNT_MATCHES = 1,       // enable/disable match count logic
    parameter int unsigned LIST_MATCHES = 0         // enable/disable listing of matches for each pair of datasets 
)(
    input logic clk,                                
    input logic reset,
    input logic en,                                         // compare enable flag
    input logic [REG_DATA_WIDTH-1:0] sets [MAX_DATASETS],   // datasets to compare
    input logic [3:0] used_datasets,                        // number of used datasets (range 0 to used_datasets)
    output logic [119:0] match_vector,                      // list of matches for each pair of datasets
    output logic [3:0]  match_cnt [MAX_DATASETS],           // count of matches of each dataset i with the rest of datasets
    output logic done                                       // 0 - compare in process / 1 - compare is finished
    );
    
    parameter MBITS = MAX_DATASETS*(MAX_DATASETS-1)/2;
    
    
    logic [3:0] i, j;    //set pointers
    logic bitmatch_res;

    //compare logic: match flag for a selected pair of datasets
    assign bitmatch_res = (sets[i] == sets[j]);
    
    
    //Multiplexing logic to select the next pair of datasets each clock cycle
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
                    //push match flag (for the selected pair of datasets) into a shift register 
                    match_vector[MBITS-1:0] <= {match_vector[MBITS-2:0], bitmatch_res};
                end;
            end;

            if(COUNT_MATCHES == 1)begin
                if(done==0 && i!=j)begin
                    if(bitmatch_res==1'b1) begin
                        //When set[i] matches set[j] - increment match counters for both of them
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
    
    