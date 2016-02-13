`timescale 1 ns / 1 ps
module johnson(clk, rst_n, out);
parameter width = 4;
input clk, rst_n;
output [width-1:0] out;

reg [width-1:0] tmp;

always @(posedge clk, negedge rst_n) begin 
	if(!rst_n) begin
		tmp <= 0;
	end else begin
		tmp <= tmp >> 1;
		tmp[width-1] <= ~tmp[0];
	end
end
assign out = tmp;
endmodule

module johnson_tb;
parameter period = 4;
parameter width = 4;
reg clk, rst_n;
wire [width-1:0] out;
johnson #(.width(width)) inst1(.clk(clk),
		  				   .rst_n(rst_n),
		  				   .out(out)
		 				  );
initial begin
	clk = 0;
	forever #(period/2) clk = ~clk;
end
initial begin
	rst_n = 0;
	@(negedge clk);
	@(negedge clk) rst_n = 1;
	repeat(13) @(posedge clk);
	$finish;
end
endmodule
