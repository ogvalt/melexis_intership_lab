`timescale 1 ns / 1 ps
module edge2_tb;
parameter period = 4;
reg clk, rst_n, in;
wire out;
edge2 inst1(.clk(clk),
		  .rst_n(rst_n),
		  .in(in),
		  .out(out)
		 );
initial begin
	clk = 0;
	forever #(period/2) clk = ~clk;
end
initial begin
	rst_n = 0;
	in = 0;
	@(negedge clk) rst_n = 1;
	@(negedge clk) in = 1;
	@(negedge clk);
	@(negedge clk) in = 0;
	repeat (2)	@(negedge clk);
	@(negedge clk) in = 1;
	repeat (2)	@(negedge clk);
	$finish;
end
endmodule
