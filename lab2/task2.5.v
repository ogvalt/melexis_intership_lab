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

module adder_without_carry_in(i_op1, i_op2, o_sum, o_carry_out);

	parameter WIDTH = 4;

	input  [WIDTH-1:0] i_op1, i_op2;
	output [WIDTH-1:0] o_sum;
	output 		       o_carry_out;

	wire   [WIDTH-1:0] carry;

	assign o_carry_out = carry[WIDTH-1];

	genvar i;

	generate 
		for(i=0; i<WIDTH; i=i+1) begin : adder_iteration
			if(i==0) 
				half_adder cell (.i_op1(i_op1[i]),
								 .i_op2(i_op2[i]),
								 .o_sum(o_sum[i]),
								 .o_carry(carry[i])
								);
			
			else 
				full_adder cell (.i_op1(i_op1[i]),
								 .i_op2(i_op2[i]),
								 .i_carry_prev(carry[i-1]),
								 .o_sum(o_sum[i]),
								 .o_carry(carry[i])
								);
			
		end
	endgenerate
endmodule
module multiple(i_op1, i_op2, o_mult);

	parameter WIDTH = 4;

	input	[WIDTH-1:0] i_op1, i_op2;
	output 	[2*WIDTH-1:0] o_mult;

	wire [4*WIDTH-1:0] connect;
	//wire [2*WIDTH-1:0] result, result1;

	genvar i,j;
	
	generate begin:multiplier
		for (i=0; i<WIDTH; i=i+1) begin:outer
			for (j=0; j<WIDTH; j=j+1) begin:inner
				and a1(connect[WIDTH*i+j], i_op1[i], i_op2[j]);
				end //inner
			end //outer
		end //multplier
	endgenerate

	wire [2:0] sum_first_stage;
	wire [3:0] sum_second_stage, sum_third_stage;
	wire carry_first_stage, carry_second_stage, carry_third_stage;
	wire b12, c12;

	assign o_mult[0] = connect[0];

	adder_without_carry_in #(.WIDTH(3)) first_stage (.i_op1(connect[3:1]),
									.i_op2(connect[6:4]),
									.o_sum(sum_first_stage),
									.o_carry_out(carry_first_stage)
									);
	assign o_mult[1] = sum_first_stage[0];
	half_adder between12 (.i_op1(connect[7]),
						  .i_op2(carry_first_stage),
						  .o_sum(b12),
						  .o_carry(c12)
						  ); 
	adder_without_carry_in #(.WIDTH(4)) second_stage (.i_op1({c12,b12,sum_first_stage[2:1]}),
									 .i_op2(connect[11:8]),
									 .o_sum(sum_second_stage),
									 .o_carry_out(carry_second_stage)
									 );
	assign o_mult[2] = sum_second_stage[0];
	adder_without_carry_in #(.WIDTH(4)) third_stage (.i_op1({carry_second_stage, sum_second_stage[3:1]}),
									.i_op2(connect[15:12]),
									.o_sum(sum_third_stage),
									.o_carry_out(carry_third_stage)
									);
	assign o_mult[7:3] = {carry_third_stage, sum_third_stage}; 
	connect[(i+2)*WIDTH:(i+1)*WIDTH]
endmodule