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
module stage(i_prev_stage, i_op, i_bit, i_carry, o_carry, o_result);
	parameter WIDTH = 4;
	input  [WIDTH-2:0] i_prev_stage;
	input  [WIDTH-1:0] i_op;
	input  			   i_bit, i_carry;
	output [WIDTH-1:0] o_result;
	output 			   o_carry;

	wire   [WIDTH-1:0] carry_bit;
	wire   [WIDTH-1:0] o_and;
	
	genvar i;

	generate
		for(i=0; i<WIDTH; i=i+1) begin: component_iterarion 
			if(i==0) begin
				and(o_and[i], i_op[i], i_bit);
				half_adder ha(.i_op1(o_and[i]), 
							  .i_op2(i_prev_stage[i]), 
							  .o_sum(o_result[i]), 
							  .o_carry(carry_bit[i]));
			end //(i==0)
			else begin
				if(i==WIDTH-1) begin
					and(o_and[i], i_op[i], i_bit);
					full_adder fa(.i_op1(o_and[i]), 
								  .i_op2(i_carry),
						  		  .i_carry_prev(carry_bit[i-1]), 
						          .o_sum(o_result[i]), 
						  		  .o_carry(o_carry));
				end	//(i==WIDTH-1)
				else begin
					and(o_and[i], i_op[i], i_bit);
					full_adder fa(.i_op1(o_and[i]), 
								  .i_op2(i_prev_stage[i]),
						  		  .i_carry_prev(carry_bit[i-1]), 
						          .o_sum(o_result[i]), 
						  		  .o_carry(carry_bit[i]));
				end //(i!=WIDTH-1)
			end //(i!=0)
		end //component_iteration
	endgenerate
endmodule

module param_multiplier(i_op1, i_op2, o_mult);

	parameter WIDTH = 4;

	input  [   WIDTH-1:0] i_op1, i_op2;
	output [ 2*WIDTH-1:0] o_mult;
	wire   [WIDTH**2-1:0] interconnect;
	wire   [   WIDTH-2:0] carry;

	genvar i, j;

	generate
		for(i=0; i<WIDTH; i=i+1) begin: op2_iteration
			if (i==0) begin: stage0
				for (j=0; j<WIDTH; j=j+1) begin: stage0_iteration
					and (interconnect[j], i_op1[j], i_op2[i]);
				end //stage0_iteration
			end //stage0
			else begin: other_stages
				if (i==1) begin: stage1
					stage #(.WIDTH(WIDTH)) stage(.i_prev_stage(interconnect[(i-1)*WIDTH+1 +: WIDTH-1]), 
										.i_op(i_op1),
										.i_bit(i_op2[i]), 
										.i_carry(1'b0), 
										.o_carry(carry[i-1]), 
										.o_result(interconnect[i*WIDTH +: WIDTH]));
				end //stage1
				else begin: next_stages
					stage #(.WIDTH(WIDTH)) stage(.i_prev_stage(interconnect[(i-1)*WIDTH+1 +: WIDTH-1]), 
										.i_op(i_op1),
										.i_bit(i_op2[i]), 
										.i_carry(carry[i-2]), 
										.o_carry(carry[i-1]), 
										.o_result(interconnect[i*WIDTH +: WIDTH]));
				end //next_stages
			end //other_stages
			if (i==WIDTH-1)
				assign o_mult[i +: WIDTH + 1] = {carry[i-1],interconnect[i*WIDTH +: WIDTH]};
			else 
				assign o_mult[i] = interconnect[i*WIDTH];
		end //op2_iteration
	endgenerate
endmodule

module param_multiplier_tb;
	parameter WIDTH = 7;
	reg  [WIDTH-1:0]  op1, op2;
	wire [2*WIDTH-1:0]  mult;

	param_multiplier #(.WIDTH(WIDTH)) multi(.i_op1(op1), 
						                    .i_op2(op2), 
						   					.o_mult(mult)
						  					);		   		

	integer i, j, res, error = 0;

	initial begin
		for (i=0; i<2**WIDTH; i=i+1) begin
			for (j=0; j<2**WIDTH; j=j+1) begin
				res = i * j;
				op1 = i;
				op2 = j;
				#1;
				if (res!==mult) begin
					error = error + 1;
					$display("Error at %d: i=%d, j=%d, i*j=%d, op1=%d, op2=%d, op1*op2=%d",$time, 
						i, j, res, op1, op2, mult);
				end // if (res!= sum)
			end // for (j=0; j<16; j=j+1)
		end // for (i=0; i<16; i=i+1)
		if (error==0) $display("!!!Test completed succesfully");
		else $display("Error counter: %d", error);
	end // initial
endmodule // lb2_tb