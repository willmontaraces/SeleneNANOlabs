module  Counter
    #(parameter DWIDTH = 16)
    (input logic [DWIDTH-1:0] d, 
     input logic clk, 
     logic reset,
     input logic load, 
     input logic en, 
     output logic expired);
 
// Internal counter register
logic [DWIDTH-1:0] cnt;

always @ (posedge clk)
begin
    if(reset==1)begin
        cnt <= 0;
    end
    else if (load) begin
        cnt <= d;
    end
    else if (en) begin
        cnt <= cnt - 1;
    end
end 
    assign expired = (cnt == 'b0);

endmodule
