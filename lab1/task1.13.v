`timescale 1 ns / 1 ps
module jcnt(clk, rst_n, out);
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

module complex_latch(rst_n, data_in, jcnt_in, data_out);
	parameter width = 4;

	input  rst_n;
	input  [width-1:0] data_in;
	input  [width-1:0] jcnt_in;
	output reg [width-1:0] data_out;

	always @(rst_n, data_in, jcnt_in) begin
		if(!rst_n) begin
			data_out <= 0;
		end else begin
			if(~((jcnt_in[3]^jcnt_in[2])|
(jcnt_in[2]^jcnt_in[1])|
(jcnt_in[1]^jcnt_in[0]))) 
				data_out <= data_in; 
		end
	end
endmodule

module task13_tb;
parameter period = 4;
parameter width = 4;
reg clk, rst_n;
reg  [width-1:0] data_in;
wire [width-1:0] jcnt_out;
wire [width-1:0] out;

jcnt #(.width(width)) inst1(.clk(clk),
		  				   .rst_n(rst_n),
		  				   .out(jcnt_out)
		 				  );

complex_latch #(.width(width)) inst2(.rst_n(rst_n),
							  .data_in(data_in),
							  .jcnt_in(jcnt_out), 
							  .data_out(out)
									 );

initial begin
	clk = 0;
	forever #(period/2) clk = ~clk;
end
initial begin
	rst_n = 0;
	data_in = 4'b100;
	@(negedge clk) rst_n = 1;
	@(negedge clk);
	@(negedge clk) data_in = 4'b0001;
	@(negedge clk) data_in = 4'b1001;
	@(negedge clk) data_in = 4'b0011;
	@(negedge clk) data_in = 4'b1101;
	@(negedge clk);
	@(negedge clk) data_in = 4'b0101;
	@(negedge clk) data_in = 4'b0010;
	@(posedge clk);
	$finish;
end
endmodule
