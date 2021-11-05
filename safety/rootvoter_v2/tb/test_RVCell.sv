
interface cnt_inf #(NSETS)();
	logic clk, reset;
	logic [63:0] cfg;
	logic [63:0] sets [NSETS];
	logic [NSETS-1:0] valid; 
	logic [3:0]  match_cnt [NSETS];
	logic [104:0] match_vector;
	logic [39:0] status;
	logic [14:0]  state_internal;
endinterface;


class RVC_datapack#(NSETS);
	logic [63:0] reference_value; 
	logic [63:0] sets [NSETS];
	logic valid [NSETS]; 	
	logic [63:0] cfg;
	int nerrors, ntimeouts;
	
	function new(int maxerrors, int maxtimeouts);
		this.cfg = 64'h000000000000FF47; //timeout = 256 clk cycles, vote 4oo7 
		reference_value = $urandom(); 
		this.nerrors = $urandom_range(0, maxerrors);
		this.ntimeouts = $urandom_range(0, maxtimeouts);
		
		for(int i=0;i<NSETS;i++)begin
			this.sets[i]=reference_value;
			this.valid[i] = 1;
		end;
		//simulate data errors
		for(int i=0;i<this.nerrors;i++)begin
			int index = $urandom_range(0, NSETS-1);
			this.sets[index] ^= 64'h00000000FFFFFFFF; 
		end
		//simulate timeouts
		for(int i=0;i<this.ntimeouts;i++)begin
			int index = $urandom_range(0, NSETS-1);
			this.sets[index] = 64'h0;
			this.valid[index] = 0;
		end
		
	endfunction;
endclass;



class RVC_transactor #(NSETS);
	virtual interface cnt_inf#(NSETS) dif;
	RVC_datapack#(NSETS) queue[$];
	
	function new(virtual interface cnt_inf#(NSETS) dif);
		this.dif = dif;
	endfunction;

	task clk_gen();
		dif.clk = 0;
		forever begin
			#5 dif.clk = ~dif.clk;
		end;		
	endtask
	
	task generate_transactions();
		RVC_datapack#(NSETS) d;
		forever begin
			wait(queue.size < 10);
			d = new(2, 2);
			queue.push_back(d);
		end
	endtask;

	task drive_transactions();
		RVC_datapack#(NSETS) d;
		forever begin
			wait(queue.size > 0);
			d = queue.pop_front();
			dif.reset=1;
			dif.sets = {default:0};
			dif.valid =0;
			dif.cfg = 64'h0;
			#31 dif.reset = 0;
			
			dif.cfg = d.cfg;
			for(int i=0;i<NSETS;i++)begin
				@(posedge dif.clk);
				dif.valid[i] = d.valid[i];				
				if(d.valid[i]==1)begin
					#1 dif.sets[i] = d.sets[i];
				end;
			end;
			
			wait(dif.status[0] == 1);
			repeat(3) @(posedge dif.clk);
		end
	endtask;

	task run();
		fork
			clk_gen();
			generate_transactions();
			drive_transactions();
		join;
	endtask;

endclass; 





module RVC_test;

	parameter N = 7;
	cnt_inf#(.NSETS(N)) dif();
	RVC_transactor#(.NSETS(N)) transactor;

	RVCell #(
		.REG_DATA_WIDTH(64),
		.MAX_DATASETS(N),
		.COUNT_MATCHES(1),
		.LIST_MATCHES(0),
		.LIST_FAILURES(1)) 
	RVC_inst(
		.clk(dif.clk),
		.reset(dif.reset),
		.cfg(dif.cfg),
		.sets(dif.sets),
		.valid(dif.valid),
		.match_cnt(dif.match_cnt),
		.match_vector(dif.match_vector),
		.status(dif.status),
		.state_internal(dif.state_internal)
	);


	initial begin
		transactor = new(dif);
		transactor.run();		
	end


endmodule

//vsim -voptargs="+acc" work.RVC_test 
