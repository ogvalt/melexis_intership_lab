`timescale 1 ns / 1 ps
module dev1(i_clk, i_rst_n, i_A, i_B, i_C, o_Q);
	parameter width = 4;
	input                  i_clk, i_rst_n;
	input      [width-1:0] i_A, i_B, i_C;
	output reg [width-1:0] o_Q;
	reg [width-1:0] A_t, B_t, C_t;
	always @(posedge i_clk or negedge i_rst_n) begin 
		if(~i_rst_n) begin
			o_Q <= 0;
			A_t <= 0;
			B_t <= 0;
			C_t <= 0;
		end else begin
			A_t <= i_A;
			B_t <= i_B;
			C_t <= i_C;
			o_Q <= (A_t + B_t) ^ C_t;
		end
	end
endmodule

module dev2(i_clk, i_rst_n, i_A, i_B, i_C, o_Q_pipe);
	parameter width = 4;
	input                  i_clk, i_rst_n;
	input      [width-1:0] i_A, i_B, i_C;
	output reg [width-1:0] o_Q_pipe;
	reg [width-1:0] A_t, B_t, C_t;
	reg [width-1:0] AB_sum_st2, C_st2;
	always @(posedge i_clk or negedge i_rst_n) begin 
		if(~i_rst_n) begin
			  o_Q_pipe <= 0;
				   A_t <= 0;
				   B_t <= 0;
			  	   C_t <= 0;
		 	AB_sum_st2 <= 0;
		 		 C_st2 <= 0;
		end else begin
				   A_t <= i_A;
				   B_t <= i_B;
				   C_t <= i_C;
			AB_sum_st2 <= A_t + B_t;
				 C_st2 <= C_t;
			  o_Q_pipe <= AB_sum_st2 ^ C_st2;
		end
	end
endmodule

module task14_tb;
parameter period = 4;
parameter width = 4;
reg clk, rst_n;
reg [width-1:0] A,B,C;
wire [width-1:0] Q, Q_pipe;
dev1 #(.width(width)) inst1 (.i_clk(clk), 
							 .i_rst_n(rst_n), 
							 .i_A(A), 
							 .i_B(B), 
							 .i_C(C), 
							 .o_Q(Q)
							);

dev2 #(.width(width)) inst2(.i_clk(clk), 
							.i_rst_n(rst_n), 
							.i_A(A), 
							.i_B(B), 
							.i_C(C), 
							.o_Q_pipe(Q_pipe));
initial begin
	clk = 0;
	forever #(period/2) clk = ~clk;
end
initial begin
	rst_n = 0;
	A = 4'b0100;
	B = 4'b0100;
	C = 4'b0001;
	@(negedge clk) rst_n = 1;
	repeat (14) begin
		@(negedge clk);
		A = $random();
		B = $random();
		C = $random();
	end
	@(posedge clk);
	$finish;
end
endmodule
