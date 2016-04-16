`timescale 1 ns /1 ps
module half_adder (i_op1, i_op2, o_sum, o_carry);
	
	input  i_op1, i_op2;
	output o_sum, o_carry;

	xor (o_sum, i_op1, i_op2);
	and (o_carry, i_op1, i_op2);

endmodule

module full_adder(i_op1, i_op2, i_carry_prev, o_sum, o_carry);
	
	input  i_op1, i_op2, i_carry_prev;
	output o_sum, o_carry;

	wire   sum1, carry1, carry2;

	or or1 (o_carry, carry1, carry2);

	half_adder first_half_adder(.i_op1(i_op1),
								.i_op2(i_op2),
								.o_sum(sum1),
								.o_carry(carry1)
								);

	half_adder second_half_adder(.i_op1(sum1),
								 .i_op2(i_carry_prev),
								 .o_sum(o_sum),
								 .o_carry(carry2)
								 );

endmodule

module param_adder (i_op1, i_op2, i_carry_in, o_sum, o_carry_out);

	parameter WIDTH = 4;

	input  [WIDTH-1:0] i_op1, i_op2;
	input 		  	   i_carry_in;
	output [WIDTH-1:0] o_sum;
	output 		       o_carry_out;

	wire   [WIDTH-1:0] carry;

	assign o_carry_out = carry[WIDTH-1];

	genvar i;

	generate 
		for(i=0; i<WIDTH; i=i+1) begin : adder_iteration
			if(i==0) 
				full_adder cl (.i_op1(i_op1[i]),
								 .i_op2(i_op2[i]),
								 .i_carry_prev(i_carry_in),
								 .o_sum(o_sum[i]),
								 .o_carry(carry[i])
								);
			
			else 
				full_adder cl (.i_op1(i_op1[i]),
								 .i_op2(i_op2[i]),
								 .i_carry_prev(carry[i-1]),
								 .o_sum(o_sum[i]),
								 .o_carry(carry[i])
								);
			
		end
	endgenerate
endmodule

`timescale 1 ns/1 ps

module adder_tb;
	parameter WIDTH = 8;
	reg  [WIDTH-1:0] op1, op2;
	reg 	    carry_in;
	wire [WIDTH-1:0] sum;
	wire 		carry_out;

	reg [WIDTH:0]  carry_concat_sum;

	param_adder #(.WIDTH(WIDTH)) add(.i_op1(op1), 
								 .i_op2(op2), 
								 .i_carry_in(carry_in), 
								 .o_sum(sum), 
								 .o_carry_out(carry_out)
								 );
	integer i, j, res, error = 0;

	initial begin
		carry_in = 0;
		for (i=0; i<2**WIDTH; i=i+1) begin
			for (j=0; j<2**WIDTH; j=j+1) begin
				res = i + j;
				op1 = i;
				op2 = j;
				#1;
				carry_concat_sum = {carry_out, sum};
				if (res!==carry_concat_sum) begin
					error = error + 1;
					$display("Error at %d: i=%d, j=%d, i+j=%d, op1=%d, op2=%d, op1+op2=%d, carry_out=%d, sum=%d",$time, 
						i,j,res,op1,op2,carry_concat_sum, carry_out, sum);
				end // if (res!= sum)
			end // for (j=0; j<16; j=j+1)
		end // for (i=0; i<16; i=i+1)
		carry_in = 1;
		for (i=0; i<2**WIDTH; i=i+1) begin
			for (j=0; j<2**WIDTH; j=j+1) begin
				res = i + j + carry_in;
				op1 = i;
				op2 = j;
				#1;
				carry_concat_sum = {carry_out, sum};
				if (res!==carry_concat_sum) begin
					error = error + 1;
					$display("Error at %d: i=%d, j=%d, i+j=%d, op1=%d, op2=%d, op1+op2=%d, carry_out=%d, sum=%d",$time, 
						i,j,res,op1,op2,carry_concat_sum, carry_out, sum);
				end // if (res!= sum)
			end // for (j=0; j<16; j=j+1)
		end // for (i=0; i<16; i=i+1)
		if (error==0) $display("!!!Test completed succesfully");
		else $display("Error counter: %d", error);
	end // initial
endmodule // lb2_tb
