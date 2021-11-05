/*
Voter communicates with the SoC via 32 memory-mapped registers:
            offset    (uint64* ptr)      Register
            ------    -------------     ----------------------------------------------
BASE_ADR    +0          (+0)            config               (slv_reg[ 0] : write only)
            +8          (+1)            set[ 0] (A)          (slv_reg[ 1] : write only)
            +16         (+2)            set[ 1] (B)          (slv_reg[ 2] : write only)
            +24         (+3)            set[ 2] (C)          (slv_reg[ 3] : write only)
            +32         (+4)            set[ 3] (D)          (slv_reg[ 4] : write only)
            +40         (+5)            set[ 4] (E)          (slv_reg[ 5] : write only)
            +48         (+6)            set[ 5] (F)          (slv_reg[ 6] : write only)
            +56         (+7)            set[ 6] (G)          (slv_reg[ 7] : write only)
            +64         (+8)            set[ 7] (H)          (slv_reg[ 8] : write only)
            +72         (+9)            set[ 8] (I)          (slv_reg[ 9] : write only)
            +80         (+10)           set[ 9] (J)          (slv_reg[10] : write only)
            +88         (+11)           set[10] (K)          (slv_reg[11] : write only)
            +96         (+12)           set[11] (L)          (slv_reg[12] : write only)
            +104        (+13)           set[12] (M)          (slv_reg[13] : write only)
            +112        (+14)           set[13] (N)          (slv_reg[14] : write only)
            +120        (+15)           set[14] (O)          (slv_reg[15] : write only)
            +128        (+16)           set[15] (P)          (slv_reg[16] : write only)
            +136        (+17)           match_vector[63:0]   (slv_reg[17] : read only)
            +144        (+18)           match_vector[119:64] (slv_reg[18] : read only)
            +152        (+19)           state                (slv_reg[19] : read only)
            +160        (+20)           status               (slv_reg[20] : read only)
            +168        (+21)           match_counters (16x4)(slv_reg[21] : read only)
            +248        (+31)           reset control        (non-register: write only, 0xF to clear all registers)

NOTE: Base Address should be aligned by 256 bytes, i.e. BASE_ADR = AXI_ADDR & 12'hF00, LOCAL_ADR = AXI_ADR & 12'h0FF

1. Config register (Write-only):
    Voting mode is configured by software as "MooN", where: 
    M = config[7:4]  
    N = config[3:0] 
    NOTE: RVC checks that (N <= MAX_DATASETS) and (M <= N) and (M >= 2), 
    FSM passes to voting state only when these conditions are satisfied. 
    
    The datasets should be loaded during "timeout" clock cycles after setting the config register, where
    timeout = config[39:8] (max clock cycles to wait for datasets)


2. Set registers (Write-only):
    16 datasets reserved in the memry map: slv_reg[ 1] to slv_reg[ 16]
    NOTE: actual number of set registers supported by RVC can be read from state register (HWInfo.MAX_DATASETS in p.5 below)


3. Voting time depends on the number of used datasets N (config[3:0])
     2 sets:   1 clk
     3 sets:   3 clk
     4 sets:   6 clk
     5 sets:  10 clk
     6 sets:  15 clk
     7 sets:  21 clk
     8 sets:  28 clk
     9 sets:  36 clk
    10 sets:  45 clk
    11 sets:  55 clk
    12 sets:  66 clk
    13 sets:  78 clk
    14 sets:  91 clk
    15 sets: 105 clk
    16 sets: 120 clk


4. status register (read-only):
    [0:0]   - ready flag (voting completed)
    [23:8]  - timeout flags for each dataset (16 bits - one per dataset)
    [39:24] - failure flags for each dataset (16 bits - one per dataset)


5. state register (read-only):
    [4:0]   - FSM state: 1: idle, 2: wait_datasets, 4: voting, 8: timeout, 16: result
    [5]     - compare_done
    [6]     - compare_en
    [7]     - compare_reset
    [8:11]  - HWInfo.ID
    [12:16] - HWInfo.MAX_DATASETS
    [17]    - HWInfo.LIST_FAILURES
    [18]    - HWInfo.LIST_MATCHES
    [19]    - HWInfo.COUNT_MATCHES
    [20:31] - RESERVED (not used)
    [63:32] - SYNC WORD (0x55555555)
    

6. match_counters register (read-only):
    number of matches of i-th dataset with the rest of datasets (4 bits), where i=[0 to N]
    [3:0]   - match_count for dataset[0]
    [7:4]   - match_count for dataset[1]
     ...
    [63:60] - match_count for dataset[15]
    
    

7. Match vector (read-only):
    slv_reg[17] and slv_reg[18]
    Comparison flags for each pair of datasets 
    
    Mapping of match vector bits for different N=[2:16]:
    ___________________________________________________________________________________________________________
    matchvec| pair | pair | pair | pair | pair | pair | pair | pair | pair | pair | pair | pair | pair | pair |
        bit | N= 2 | N= 3 | N= 4 | N= 5 | N= 7 | N= 8 | N= 9 | N=10 | N=11 | N=12 | N=13 | N=14 | N=15 | N=16 |
    ________ ______ ______ ______ ______ ______ ______ ______ ______ ______ ______ ______ ______ ______ ______
          0 |  0: 1|  1: 2|  2: 3|  3: 4|  5: 6|  6: 7|  7: 8|  8: 9|  9:10| 10:11| 11:12| 12:13| 13:14| 14:15|
          1 |         0: 2|  1: 3|  2: 4|  4: 6|  5: 7|  6: 8|  7: 9|  8:10|  9:11| 10:12| 11:13| 12:14| 13:15|
          2 |         0: 1|  1: 2|  2: 3|  4: 5|  5: 6|  6: 7|  7: 8|  8: 9|  9:10| 10:11| 11:12| 12:13| 13:14|
          3 |                0: 3|  1: 4|  3: 6|  4: 7|  5: 8|  6: 9|  7:10|  8:11|  9:12| 10:13| 11:14| 12:15|
          4 |                0: 2|  1: 3|  3: 5|  4: 6|  5: 7|  6: 8|  7: 9|  8:10|  9:11| 10:12| 11:13| 12:14|
          5 |                0: 1|  1: 2|  3: 4|  4: 5|  5: 6|  6: 7|  7: 8|  8: 9|  9:10| 10:11| 11:12| 12:13|
          6 |                       0: 4|  2: 6|  3: 7|  4: 8|  5: 9|  6:10|  7:11|  8:12|  9:13| 10:14| 11:15|
          7 |                       0: 3|  2: 5|  3: 6|  4: 7|  5: 8|  6: 9|  7:10|  8:11|  9:12| 10:13| 11:14|
          8 |                       0: 2|  2: 4|  3: 5|  4: 6|  5: 7|  6: 8|  7: 9|  8:10|  9:11| 10:12| 11:13|
          9 |                       0: 1|  2: 3|  3: 4|  4: 5|  5: 6|  6: 7|  7: 8|  8: 9|  9:10| 10:11| 11:12|
         10 |                              1: 6|  2: 7|  3: 8|  4: 9|  5:10|  6:11|  7:12|  8:13|  9:14| 10:15|
         11 |                              1: 5|  2: 6|  3: 7|  4: 8|  5: 9|  6:10|  7:11|  8:12|  9:13| 10:14|
         12 |                              1: 4|  2: 5|  3: 6|  4: 7|  5: 8|  6: 9|  7:10|  8:11|  9:12| 10:13|
         13 |                              1: 3|  2: 4|  3: 5|  4: 6|  5: 7|  6: 8|  7: 9|  8:10|  9:11| 10:12|
         14 |                              1: 2|  2: 3|  3: 4|  4: 5|  5: 6|  6: 7|  7: 8|  8: 9|  9:10| 10:11|
         15 |                              0: 6|  1: 7|  2: 8|  3: 9|  4:10|  5:11|  6:12|  7:13|  8:14|  9:15|
         16 |                              0: 5|  1: 6|  2: 7|  3: 8|  4: 9|  5:10|  6:11|  7:12|  8:13|  9:14|
         17 |                              0: 4|  1: 5|  2: 6|  3: 7|  4: 8|  5: 9|  6:10|  7:11|  8:12|  9:13|
         18 |                              0: 3|  1: 4|  2: 5|  3: 6|  4: 7|  5: 8|  6: 9|  7:10|  8:11|  9:12|
         19 |                              0: 2|  1: 3|  2: 4|  3: 5|  4: 6|  5: 7|  6: 8|  7: 9|  8:10|  9:11|
         20 |                              0: 1|  1: 2|  2: 3|  3: 4|  4: 5|  5: 6|  6: 7|  7: 8|  8: 9|  9:10|
         21 |                                     0: 7|  1: 8|  2: 9|  3:10|  4:11|  5:12|  6:13|  7:14|  8:15|
         22 |                                     0: 6|  1: 7|  2: 8|  3: 9|  4:10|  5:11|  6:12|  7:13|  8:14|
         23 |                                     0: 5|  1: 6|  2: 7|  3: 8|  4: 9|  5:10|  6:11|  7:12|  8:13|
         24 |                                     0: 4|  1: 5|  2: 6|  3: 7|  4: 8|  5: 9|  6:10|  7:11|  8:12|
         25 |                                     0: 3|  1: 4|  2: 5|  3: 6|  4: 7|  5: 8|  6: 9|  7:10|  8:11|
         26 |                                     0: 2|  1: 3|  2: 4|  3: 5|  4: 6|  5: 7|  6: 8|  7: 9|  8:10|
         27 |                                     0: 1|  1: 2|  2: 3|  3: 4|  4: 5|  5: 6|  6: 7|  7: 8|  8: 9|
         28 |                                            0: 8|  1: 9|  2:10|  3:11|  4:12|  5:13|  6:14|  7:15|
         29 |                                            0: 7|  1: 8|  2: 9|  3:10|  4:11|  5:12|  6:13|  7:14|
         30 |                                            0: 6|  1: 7|  2: 8|  3: 9|  4:10|  5:11|  6:12|  7:13|
         31 |                                            0: 5|  1: 6|  2: 7|  3: 8|  4: 9|  5:10|  6:11|  7:12|
         32 |                                            0: 4|  1: 5|  2: 6|  3: 7|  4: 8|  5: 9|  6:10|  7:11|
         33 |                                            0: 3|  1: 4|  2: 5|  3: 6|  4: 7|  5: 8|  6: 9|  7:10|
         34 |                                            0: 2|  1: 3|  2: 4|  3: 5|  4: 6|  5: 7|  6: 8|  7: 9|
         35 |                                            0: 1|  1: 2|  2: 3|  3: 4|  4: 5|  5: 6|  6: 7|  7: 8|
         36 |                                                   0: 9|  1:10|  2:11|  3:12|  4:13|  5:14|  6:15|
         37 |                                                   0: 8|  1: 9|  2:10|  3:11|  4:12|  5:13|  6:14|
         38 |                                                   0: 7|  1: 8|  2: 9|  3:10|  4:11|  5:12|  6:13|
         39 |                                                   0: 6|  1: 7|  2: 8|  3: 9|  4:10|  5:11|  6:12|
         40 |                                                   0: 5|  1: 6|  2: 7|  3: 8|  4: 9|  5:10|  6:11|
         41 |                                                   0: 4|  1: 5|  2: 6|  3: 7|  4: 8|  5: 9|  6:10|
         42 |                                                   0: 3|  1: 4|  2: 5|  3: 6|  4: 7|  5: 8|  6: 9|
         43 |                                                   0: 2|  1: 3|  2: 4|  3: 5|  4: 6|  5: 7|  6: 8|
         44 |                                                   0: 1|  1: 2|  2: 3|  3: 4|  4: 5|  5: 6|  6: 7|
         45 |                                                          0:10|  1:11|  2:12|  3:13|  4:14|  5:15|
         46 |                                                          0: 9|  1:10|  2:11|  3:12|  4:13|  5:14|
         47 |                                                          0: 8|  1: 9|  2:10|  3:11|  4:12|  5:13|
         48 |                                                          0: 7|  1: 8|  2: 9|  3:10|  4:11|  5:12|
         49 |                                                          0: 6|  1: 7|  2: 8|  3: 9|  4:10|  5:11|
         50 |                                                          0: 5|  1: 6|  2: 7|  3: 8|  4: 9|  5:10|
         51 |                                                          0: 4|  1: 5|  2: 6|  3: 7|  4: 8|  5: 9|
         52 |                                                          0: 3|  1: 4|  2: 5|  3: 6|  4: 7|  5: 8|
         53 |                                                          0: 2|  1: 3|  2: 4|  3: 5|  4: 6|  5: 7|
         54 |                                                          0: 1|  1: 2|  2: 3|  3: 4|  4: 5|  5: 6|
         55 |                                                                 0:11|  1:12|  2:13|  3:14|  4:15|
         56 |                                                                 0:10|  1:11|  2:12|  3:13|  4:14|
         57 |                                                                 0: 9|  1:10|  2:11|  3:12|  4:13|
         58 |                                                                 0: 8|  1: 9|  2:10|  3:11|  4:12|
         59 |                                                                 0: 7|  1: 8|  2: 9|  3:10|  4:11|
         60 |                                                                 0: 6|  1: 7|  2: 8|  3: 9|  4:10|
         61 |                                                                 0: 5|  1: 6|  2: 7|  3: 8|  4: 9|
         62 |                                                                 0: 4|  1: 5|  2: 6|  3: 7|  4: 8|
         63 |                                                                 0: 3|  1: 4|  2: 5|  3: 6|  4: 7|
         64 |                                                                 0: 2|  1: 3|  2: 4|  3: 5|  4: 6|
         65 |                                                                 0: 1|  1: 2|  2: 3|  3: 4|  4: 5|
         66 |                                                                        0:12|  1:13|  2:14|  3:15|
         67 |                                                                        0:11|  1:12|  2:13|  3:14|
         68 |                                                                        0:10|  1:11|  2:12|  3:13|
         69 |                                                                        0: 9|  1:10|  2:11|  3:12|
         70 |                                                                        0: 8|  1: 9|  2:10|  3:11|
         71 |                                                                        0: 7|  1: 8|  2: 9|  3:10|
         72 |                                                                        0: 6|  1: 7|  2: 8|  3: 9|
         73 |                                                                        0: 5|  1: 6|  2: 7|  3: 8|
         74 |                                                                        0: 4|  1: 5|  2: 6|  3: 7|
         75 |                                                                        0: 3|  1: 4|  2: 5|  3: 6|
         76 |                                                                        0: 2|  1: 3|  2: 4|  3: 5|
         77 |                                                                        0: 1|  1: 2|  2: 3|  3: 4|
         78 |                                                                               0:13|  1:14|  2:15|
         79 |                                                                               0:12|  1:13|  2:14|
         80 |                                                                               0:11|  1:12|  2:13|
         81 |                                                                               0:10|  1:11|  2:12|
         82 |                                                                               0: 9|  1:10|  2:11|
         83 |                                                                               0: 8|  1: 9|  2:10|
         84 |                                                                               0: 7|  1: 8|  2: 9|
         85 |                                                                               0: 6|  1: 7|  2: 8|
         86 |                                                                               0: 5|  1: 6|  2: 7|
         87 |                                                                               0: 4|  1: 5|  2: 6|
         88 |                                                                               0: 3|  1: 4|  2: 5|
         89 |                                                                               0: 2|  1: 3|  2: 4|
         90 |                                                                               0: 1|  1: 2|  2: 3|
         91 |                                                                                      0:14|  1:15|
         92 |                                                                                      0:13|  1:14|
         93 |                                                                                      0:12|  1:13|
         94 |                                                                                      0:11|  1:12|
         95 |                                                                                      0:10|  1:11|
         96 |                                                                                      0: 9|  1:10|
         97 |                                                                                      0: 8|  1: 9|
         98 |                                                                                      0: 7|  1: 8|
         99 |                                                                                      0: 6|  1: 7|
        100 |                                                                                      0: 5|  1: 6|
        101 |                                                                                      0: 4|  1: 5|
        102 |                                                                                      0: 3|  1: 4|
        103 |                                                                                      0: 2|  1: 3|
        104 |                                                                                      0: 1|  1: 2|
        105 |                                                                                             0:15|
        106 |                                                                                             0:14|
        107 |                                                                                             0:13|
        108 |                                                                                             0:12|
        109 |                                                                                             0:11|
        110 |                                                                                             0:10|
        111 |                                                                                             0: 9|
        112 |                                                                                             0: 8|
        113 |                                                                                             0: 7|
        114 |                                                                                             0: 6|
        115 |                                                                                             0: 5|
        116 |                                                                                             0: 4|
        117 |                                                                                             0: 3|
        118 |                                                                                             0: 2|
        119 |                                                                                             0: 1|
        _______________________________________________________________________________________________________    
*/


`include "RVCell.sv"

module rootvoter
#(
    parameter int unsigned RVC_ID = 1,
    parameter int unsigned C_S_AXI_ADDR_WIDTH = 12,
    parameter int unsigned C_S_AXI_DATA_WIDTH = 128,
    parameter int unsigned REG_DATA_WIDTH = 64,
    parameter int unsigned MAX_DATASETS = 9,
    parameter int unsigned COUNT_MATCHES = 1,
    parameter int unsigned LIST_MATCHES = 0,
    parameter int unsigned LIST_FAILURES = 1    
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
    localparam WRITE_REG_NUM = 17;
    localparam WRITE_HIGH_ADR = WRITE_LOW_ADR + WRITE_REG_NUM-1;
    localparam CMD_ADR       = 31;
    localparam ADR_MASK = { {(C_S_AXI_ADDR_WIDTH-8){1'b0}}, {8{1'b1}} };
    
    localparam READ_LOW_ADR = WRITE_HIGH_ADR + 1;
    localparam READ_REG_NUM = 5;
    localparam READ_HIGH_ADR = READ_LOW_ADR + READ_REG_NUM-1;

    localparam TOTAL_REGS = WRITE_REG_NUM + READ_REG_NUM; 

    localparam integer AXI_ALIGN_FACTOR = C_S_AXI_DATA_WIDTH/REG_DATA_WIDTH;
    
    
    localparam REG_DATA_BYTES = REG_DATA_WIDTH / 8;
    localparam integer ADDR_LSB = $clog2(REG_DATA_BYTES); // 32bit: ADDR_LSB=2, 64bit: ADDR_LSB=3, 128bit: ADDR_LSB=4  
    localparam integer ADDR_MSB = C_S_AXI_ADDR_WIDTH-1;


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
    wire [39:0]  status;
    wire [19:0]  state_internal;
    wire [3:0]   match_cnt [MAX_DATASETS];
    wire [119:0] match_vector;
    wire [MAX_DATASETS*4-1:0] match_cnt_vec;
     
    reg [REG_DATA_WIDTH-1:0]     slv_reg [0:WRITE_REG_NUM-1];
    reg [REG_DATA_BYTES-1:0]     slv_reg_valid [0:WRITE_REG_NUM-1];
    reg [REG_DATA_WIDTH-1:0]     read_reg [0:READ_REG_NUM-1];
    reg [MAX_DATASETS-1:0]       set_valid;
    
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
                    slv_reg[WRITE_LOW_ADR] <= { {1'b1}, {(REG_DATA_WIDTH-1){1'b0}} };    //reset
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
    for(set_id = 0; set_id <= MAX_DATASETS-1; set_id++)begin
        assign set_valid[set_id] = slv_reg_valid[set_id+1] == {REG_DATA_BYTES{1'b1}};
        assign match_cnt_vec[4*(set_id+1)-1:4*set_id] = match_cnt[set_id];
    end;
endgenerate


assign read_reg[4] = { {(REG_DATA_WIDTH-MAX_DATASETS*4){1'b0}}, match_cnt_vec};
assign read_reg[0] = match_vector[63:0];
assign read_reg[1] = match_vector[119:64];
assign read_reg[2] = {32'h55555555, {(REG_DATA_WIDTH-52){1'b0}}, state_internal};
assign read_reg[3] = {{(REG_DATA_WIDTH-40){1'b0}}, status};


RVCell #(.REG_DATA_WIDTH(REG_DATA_WIDTH), 
         .MAX_DATASETS(MAX_DATASETS),
         .COUNT_MATCHES(COUNT_MATCHES | LIST_FAILURES),
         .LIST_MATCHES(LIST_MATCHES),
         .LIST_FAILURES(LIST_FAILURES)) 
  RVC0 (
    .clk(S_AXI_ACLK_i),
    .reset(reset),
    .cfg(slv_reg[0]),
    .sets(slv_reg[1:MAX_DATASETS]),    
    .valid(set_valid),
    .match_cnt(match_cnt),
    .match_vector(match_vector),
    .status(status),
    .state_internal(state_internal)
    );

endmodule

