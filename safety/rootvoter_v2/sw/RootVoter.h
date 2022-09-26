/*  Description:
        RootVoter v.2 API for baremetal applications
            
    Author / Developer: 
        Ilya Tuzov (Universitat Politecnica de Valencia)

*/

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
    [20:23] - HWInfo.RV_VERSION
    [24:31] - RESERVED (not used)
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


#ifndef ROOTVOTER_DEFS
#define ROOTVOTER_DEFS

#define RVC0_BASE 0xfffc0200
#define RVC1_BASE 0xfffc0300
#define RVC2_BASE 0xfffc0400
#define RVC3_BASE 0xfffc0500


typedef struct {
    uint8_t           id;            //RVC identifier (index)
    uint8_t           max_sets;      //Read-back attribute: (2 to 16): Number of set registers 
    uint8_t           count_matches; //Read-back attribute:     (1/0): RVC counts matches for each dataset in the match_counters register (reg[21]) 
    uint8_t           list_matches;  //Read-back attribute      (1/0): RVC provides comparison flags for each pair of datasets in the match_vector register (reg[17] and reg[18])
    uint8_t           list_failures; //Read-back attribute      (1/0): RVC provides failure flags for each dataset in the status[39:24] (reg[20])   
    uint8_t           version;       //Read-back attribute  (1 to 15): RVC version
} RootVoterHWInf;



typedef struct {
    uint64_t*         base_adr;      //RVC base address
    RootVoterHWInf    inf;           //HW features supported by RVC (Read-only)
    uint8_t           mode;          //MooN voting scheme: mode[7:4] = M (min number of matching sets), mode[3:0] = N (total sets to vote)    
    uint64_t          timeout;       //Max amount of CLK cycles to load all datasets
} RootVoterDescriptor;



typedef struct {
    uint8_t           mode;        //MooN voting scheme: mode[7:4] = M (min number of matching sets), mode[3:0] = N (total sets to vote)
    uint16_t          failvec;     //Agreement status per dataset: 0 - pass (at least M-1 matches), 1 - fail (less than M-1 matches)
    uint16_t          timeout;     //Timeout status per dataset: 1/0
    uint64_t          match_cnt;   //Match counters (64 bits - 4 per each dataset)
    uint8_t           agreement;   //Overall agreement status: 1 (reached) / 0 (not reached)
    uint64_t          matchvec_p1; //raw (unparsed) comparison flags (low   part:  64 bits)
    uint64_t          matchvec_p2; //raw (unparsed) comparison flags (upper part:  41 bits)
} VoteResult;



//Synchronizes with RV cell at address BASEADR
//Retrieves RV cell features from state register
//Returns: 0 if sync successful, 1 otherwise
int RVC_sync(RootVoterDescriptor* RVC, uint64_t BASEADR);

//Clears RV cell registers
//Sets RV configuration (voting mode and timeout)
//after execution RV cell remains in wait_datasets state
//Returns: 0 if reset successful, 1 otherwise
int RVC_reset(RootVoterDescriptor* RVC, uint8_t mode, uint64_t max_wait_time);

//Loads a dataset to the set[dataset_id] register of RVC
int RVC_load_dataset(RootVoterDescriptor* RVC, uint8_t dataset_id, uint64_t dataset);

//Waits for completion of RVC voting (polling mode) 
//Returns voting statistics in form of VoteResult structure
VoteResult RVC_vote(RootVoterDescriptor* RVC);

//Logs VoteResult to console
void print_vote_result(VoteResult* v);


#endif


