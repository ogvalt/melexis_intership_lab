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

module four_bit_adder(i_op1, i_op2, i_carry_in, o_sum, o_carry_out);

	input  [ 3:0] i_op1, i_op2;
	input 		  i_carry_in;
	output [ 3:0] o_sum;
	output 		  o_carry_out;

	wire   [ 3:0] carry;

	assign o_carry_out = carry[3];

	genvar i;

	generate 
		for(i=0; i<4; i=i+1) begin : adder_iteration
			if(i==0) 
				full_adder cl(.i_op1(i_op1[i]),
								 .i_op2(i_op2[i]),
								 .i_carry_prev(i_carry_in),
								 .o_sum(o_sum[i]),
								 .o_carry(carry[i])
								);
			
			else 
				full_adder cl(.i_op1(i_op1[i]),
								 .i_op2(i_op2[i]),
								 .i_carry_prev(carry[i-1]),
								 .o_sum(o_sum[i]),
								 .o_carry(carry[i])
								);
			
		end
	endgenerate
endmodule