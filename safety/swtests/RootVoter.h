#ifndef ROOTVOTER_DEFS
#define ROOTVOTER_DEFS

#define RVC0_BASE 0xfffc0100
#define RVC1_BASE 0xfffc0200
#define RVC2_BASE 0xfffc0300
#define RVC3_BASE 0xfffc0400



/* ---- RVC memory map ----------------------------------
            offset    (uint64* ptr)      Register
            ------    -------------     -----------------
base_adr    +0          (+0)            config (slv_reg[0] : write only)
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
---------------------------------------------------------        
*/
typedef struct {
    char         id;          //RVC identifier (index)
    uint64_t*    base_adr;    //RVC base address
    uint64_t     timeout;     //Max amount of CLK cycles to load all datasets
    char         cell_type;   //0: v2oo2, 1: v2oo3, 2: v4oo7, 3: v5oo9 
    char         state;       //1: idle, 2: wait_datasets, 4: voting, 8: timeout, 16: result  
} RootVoterDescriptor;



typedef struct {
    char mode;        //0x0: 2oo2,  0x1: 2oo3, 0x2: v4oo7, 0x3: v5oo9, 0xFF - unknown
    char agreement;   //1(0): agreement reached (not reached)     
    char status_a;    //0 - fail (not matches majority of datasets), 1 - pass (matches the majority of datasets), 2 - timeout  
    char status_b;
    char status_c;
    char status_d;
    char status_e;
    char status_f;
    char status_g;
    char status_h;
    char status_i;
    char res_a;       //number of matches with the rest of datasets 
    char res_b;
    char res_c;
    char res_d;
    char res_e;
    char res_f;
    char res_g;
    char res_h;
    char res_i;
} VoteResult;


int RVC_reset(RootVoterDescriptor* RVC);
int RVC_load_dataset(RootVoterDescriptor* RVC, uint64_t dataset_id, uint64_t dataset);
VoteResult RVC_vote(RootVoterDescriptor* RVC);
void print_vote_result(VoteResult* v);

#endif


