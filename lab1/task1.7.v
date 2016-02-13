`timescale 1 ns / 1 ps
module paral_shift(clk, rst_n, dir, data_in, data_out);
input 			  clk, rst_n, dir;
input 		[7:0] data_in;
output reg  [7:0] data_out;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		data_out <= 0;
	end else begin
		if(dir) begin
			data_out <= data_in << 1 ;
		end else begin
			data_out <= data_in >> 1;
		end
	end
end
endmodule

module paral_shift_tb;
parameter period = 4;
reg clk, rst_n, dir;
reg [7:0] data_in;
wire [7:0] data_out;
paral_shift inst1(.clk(clk), 
			  .rst_n(rst_n),
			  .dir(dir),
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
	data_in = 10;
	dir = 0;
	repeat(5) @(negedge clk);
	dir = 1;
	repeat(5) @(negedge clk);
	dir = 0; 
	@(negedge clk);
	$finish;
end
endmodule