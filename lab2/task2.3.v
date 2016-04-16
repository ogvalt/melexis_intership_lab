`timescale 1 ns /1 ps
module half_subtractor (i_op1, i_op2, o_subtract, o_borrow);
	
	input  i_op1, i_op2;
	output o_subtract, o_borrow;

	xor (o_subtract, i_op1, i_op2);
	and (o_borrow, ~i_op1, i_op2);

endmodule

module full_subtractor(i_op1, i_op2, i_borrow_in, o_subtract, o_borrow);
	
	input  i_op1, i_op2, i_borrow_in;
	output o_subtract, o_borrow;

	wire   sub1, bor1, bor2;

	or or1 (o_borrow, bor1, bor2);

	half_subtractor first_half_subtractor(.i_op1(i_op1),
										  .i_op2(i_op2),
										  .o_subtract(sub1),
								          .o_borrow(bor1)
								         );

	half_subtractor second_half_subtractor(.i_op1(sub1),
								 		   .i_op2(i_borrow_in),
								           .o_subtract(o_subtract),
										   .o_borrow(bor2)
								 		  );

endmodule

module four_bit_subtractor (i_op1, i_op2, i_borrow_in, o_subtract, o_borrow_out);

	input  [ 3:0] i_op1, i_op2;
	input 		  i_borrow_in;
	output [ 3:0] o_subtract;
	output 		  o_borrow_out;

	wire   [ 3:0] borrow;

	assign o_borrow_out = borrow[3];

	genvar i;

	generate 
		for(i=0; i<4; i=i+1) begin : adder_iteration
			if(i==0) 
				full_subtractor cl (.i_op1(i_op1[i]),
								 .i_op2(i_op2[i]),
								 .i_borrow_in(i_borrow_in),
								 .o_subtract(o_subtract[i]),
								 .o_borrow(borrow[i])
								);
			
			else 
				full_subtractor cl (.i_op1(i_op1[i]),
								 .i_op2(i_op2[i]),
								 .i_borrow_in(borrow[i-1]),
								 .o_subtract(o_subtract[i]),
								 .o_borrow(borrow[i])
								);
			
		end
	endgenerate
endmodule