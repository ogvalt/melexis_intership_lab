`timescale 1 ns / 1 ps
module paral_shift(clk, rst_n, dir, par_seq, data_in, data_parallel_load, data_out);

parameter WIDTH = 8;

input 			   clk, rst_n;
input 			   dir, par_seq, data_in;
input 		[WIDTH-1:0]  data_parallel_load;
output reg  [WIDTH-1:0]  data_out;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		data_out <= 0;
	end else begin
		if (par_seq) data_out <= data_parallel_load;
		else begin
			if (dir) data_out <= { data_out[WIDTH-2:0], data_in };
			else   	 data_out <= { 1'b0, data_out[WIDTH-1:1]    };
		end
	end
end
endmodule


module paral_shift_tb;
parameter period = 4;
reg clk, rst_n, dir, data_in, par_seq;
reg [7:0] data_parallel_load;
wire [7:0] data_out;
paral_shift inst1(.clk(clk), 
			  	  .rst_n(rst_n),
			  	  .dir(dir),
			  	  .par_seq(par_seq),
			  	  .data_in(data_in),
			  	  .data_parallel_load(data_parallel_load), 
			  	  .data_out(data_out)
			  	 );
initial begin 
	clk = 0;
	forever #(period/2) clk = ~clk;
end
initial begin
	dir = 0;
	par_seq = 0;
	data_parallel_load = 0;
	rst_n = 0;
	data_in = 0;
	@(negedge clk) rst_n = 1;
	par_seq = 1;
	data_parallel_load = 8'b01111111;
	@(negedge clk) par_seq = 0;	
	dir = 0;
	repeat(5) @(negedge clk);
	dir = 1;
	repeat(3) @(negedge clk);
	data_in = 1'b1;
	repeat(3) @(negedge clk);
	dir = 0; 
	@(negedge clk);
	$finish;
end
endmodule