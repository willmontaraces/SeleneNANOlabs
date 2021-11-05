`include "Counter.sv"
`include "CompareUnit.sv"


module RVCell #(
    parameter int unsigned RVC_ID = 1,
    parameter int unsigned REG_DATA_WIDTH = 64,
    parameter int unsigned MAX_DATASETS = 9,
    parameter int unsigned COUNT_MATCHES = 1,
    parameter int unsigned LIST_MATCHES = 0,
    parameter int unsigned LIST_FAILURES = 1
    )
    (
    input logic clk,
    input logic reset,
    input logic [REG_DATA_WIDTH-1:0] cfg,
    input logic [REG_DATA_WIDTH-1:0] sets [MAX_DATASETS],
    input logic [MAX_DATASETS-1:0] valid,
    
    output logic [3:0] match_cnt [MAX_DATASETS],
    output logic [119:0] match_vector,    
    output reg [39:0] status,
    output reg [19:0] state_internal);


    typedef enum logic[4:0] {
        state_idle                = 5'b00001,
        state_wait_datasets        = 5'b00010,
        state_voting             = 5'b00100, 
        state_timeout            = 5'b01000,
        state_result               = 5'b10000} state_enc_t;

    state_enc_t state_reg, state_next;   // FSM state register and next (comb) state

    logic [11:0] RVC_info;
    logic config_ok;
    logic [3:0] dataset_cnt;
    logic all_datasets_loaded;    
    logic [3:0] used_datasets, datasets_min;
    logic [MAX_DATASETS-1:0] timeout, timeout_reg;
    logic [MAX_DATASETS-1:0] failvec, failvec_res;
    logic [MAX_DATASETS-1:0] mask;
    
    // Counter
    wire counter_expired;
    logic counter_en;
    wire [31:0] data_counter;
    logic counter_load;
    logic ready;

    // Compare unit
    logic compare_en;
    logic compare_reset;
    logic compare_done;


    assign RVC_info[3:0]    = RVC_ID;
    assign RVC_info[8:4]    = MAX_DATASETS;
    assign RVC_info[9]      = LIST_FAILURES;
    assign RVC_info[10]     = LIST_MATCHES;
    assign RVC_info[11]     = COUNT_MATCHES;
    

    assign status           = { {(16-MAX_DATASETS){1'b0}}, failvec_res,  
                                {(16-MAX_DATASETS){1'b0}}, timeout_reg,    
                                {7'b0},                    ready};
                                                             
    assign state_internal   = {RVC_info, compare_reset, compare_en, compare_done, state_reg};
    
    assign datasets_min     = cfg[7:4];
    assign used_datasets    = cfg[3:0];
    assign data_counter     = cfg[39:8];
    
    
    
    
    // time out counter
    Counter #(.DWIDTH(32)) C0 (
            .load(counter_load),
            .d(data_counter),
            .en(counter_en),
            .clk(clk),
            .reset(reset),
            .expired(counter_expired));


    // Compare unit 
    CompareUnit #(
            .REG_DATA_WIDTH(REG_DATA_WIDTH),
            .MAX_DATASETS(MAX_DATASETS),
            .COUNT_MATCHES(COUNT_MATCHES),
            .LIST_MATCHES(LIST_MATCHES)) 
        Cmp0(
            .clk(clk),
            .reset(compare_reset),
            .en(compare_en),            
            .sets(sets),
            .used_datasets(used_datasets),
            .match_vector(match_vector),
            .match_cnt(match_cnt),
            .done(compare_done)
            );


    //Number of loaded datasets is derived from validity flags
    integer bit_id;
    always@(valid) begin
        dataset_cnt = 4'h0;
        for(bit_id=0;bit_id<MAX_DATASETS;bit_id++)begin
            dataset_cnt = dataset_cnt + valid[bit_id];
        end;
    end
    
    assign all_datasets_loaded = (dataset_cnt >= used_datasets);
    assign config_ok = (used_datasets >= 2) && (used_datasets <= MAX_DATASETS) && (datasets_min <= used_datasets);

    genvar i;
    generate 
        if(LIST_FAILURES==1)begin
            for(i=0;i<MAX_DATASETS;i++)begin
                assign failvec[i] = (match_cnt[i]+1 < datasets_min);
            end;
        end
        else begin
            assign failvec = {MAX_DATASETS{1'b0}};
        end        
    endgenerate 

    genvar j;
    generate 
        for(j=0;j<MAX_DATASETS;j++)begin
            assign mask[j] = (j < used_datasets);
        end;
    endgenerate 
    


    always @(posedge clk) begin
        if(reset==1)
            begin
                state_reg <= state_idle;
                timeout_reg <= {MAX_DATASETS{1'b0}};
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
        failvec_res = {MAX_DATASETS{1'b0}};
        {compare_en, compare_reset, counter_en, counter_load, ready}  = 5'b00000;

        unique case(state_reg)
            state_idle: begin
                compare_reset = 1'b1;
                if(config_ok == 1) begin
                    state_next = state_wait_datasets;
                    counter_load  = 1'b1;
                    timeout = {MAX_DATASETS{1'b0}};
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
                    timeout = (~valid) & mask;                
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
                failvec_res = failvec & mask;
                if (cfg[7:0] == 0) begin
                    state_next = state_idle;
                end
            end
            
            state_result: begin
                $display("## State_result");
                ready  = 1'b1;
                failvec_res = failvec & mask;                
                if(cfg[7:0] == 0) begin
                    state_next = state_idle;
                end
            end
            
            default: begin
                state_next = state_idle;
            end
        endcase
    end: FSM

endmodule





