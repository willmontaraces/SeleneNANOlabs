
interface cnt_inf #(NSETS)();
	logic clk, reset;
	logic [63:0] sets [NSETS];
	logic en;
	logic [7:0] voter_config;
	logic [63:0] match_vector;
	logic [3:0]  match_cnt [NSETS];
	logic done;
endinterface;


class datapack#(NSETS);
	logic [63:0] reference_value; 
	logic [63:0] sets [NSETS];
	
	function new(int nerrors);
		reference_value = $urandom(); 
		for(int i=0;i<NSETS;i++) sets[i]=reference_value;
		for(int i=0;i<nerrors;i++)begin
			int index = $urandom_range(0, NSETS-1);
			this.sets[index] &= 64'h0000FFFF0000FFFF; 
		end
	endfunction;
endclass;



class CMP_transactor #(NSETS);
	virtual interface cnt_inf#(NSETS) dif;
	datapack#(NSETS) queue[$];
	
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
		datapack#(NSETS) d;
		forever begin
			wait(queue.size < 10);
			d = new(2);
			queue.push_back(d);
		end
	endtask;

	task drive_transactions();
		datapack#(NSETS) d;
		forever begin
			wait(queue.size > 0);
			d = queue.pop_front();
			dif.reset=1;
			#31 dif.reset = 0;
			dif.en = 1'b1;
			dif.voter_config = 'h57;
			dif.sets = d.sets;
			wait(dif.done);
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





module CompareUnit_test;

	parameter N = 7;
	cnt_inf#(.NSETS(N)) dif();
	CMP_transactor#(.NSETS(N)) transactor;

	CompareUnit #(
		.REG_DATA_WIDTH(64),
		.MAX_DATASETS(N),
		.COUNT_MATCHES(1),
		.LIST_MATCHES(1)) 
	cmp_inst(
		.clk(dif.clk),
		.reset(dif.reset),
		.en(dif.en),
		.sets(dif.sets),
		.used_datasets(dif.voter_config[3:0]),
		.match_vector(dif.match_vector),
		.match_cnt(dif.match_cnt),
		.done(dif.done)
	);


	initial begin
		transactor = new(dif);
		transactor.run();		
	end


endmodule

//vsim -voptargs="+acc" work.CompareUnit_test 
