/* This document consist of two modules reg_8bit_we_mod and reg_8bit_we_mod_tb
Last one is the test bench of first module*/ 

`timescale 1 ns / 1 ps
module reg_8bit_we_mod(clk, rst_n, we_n, data_in, data_out);
input 			  clk, rst_n, we_n;
input 		[7:0] data_in;
output reg  [7:0] data_out;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		data_out <= 0;
	end else begin
		if(!we_n) begin
			data_out <= data_in;
		end else begin
			data_out <= data_out;
		end
	end
end
endmodule

module reg_8bit_we_mod_tb;
parameter period = 4;
reg 	   clk, rst_n, we_n;
reg  [7:0] data_in;
wire [7:0] data_out;
integer    i;
reg_8bit_we_mod inst1(.clk(clk), 
			  .rst_n(rst_n),
			  .we_n(we_n),
			  .data_in(data_in), 
			  .data_out(data_out)
			  );
initial begin 
	clk = 0;
	forever #(period/2) clk = ~clk;
end		
initial begin
	rst_n = 0;
	data_in = 0;
	@(negedge clk) rst_n = 1;
	for(i=0; i<256; i++) begin
		@(negedge clk) data_in = i;
	end
	@(negedge clk);
	$finish;
end
initial begin
	we_n = 0;
	repeat(10) @(negedge clk);
	we_n = 1;
	repeat(10) @(negedge clk);
	we_n = 0;
end
endmodule
