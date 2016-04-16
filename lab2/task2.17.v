`timescale 1 ns /1 ps
//`include "task2.1.v"
//`include "task2.3.v"

module adder_or_subtractor(i_op1, i_op2, i_carry_borrow_in, o_res, o_carry_borrow_out);

	parameter mode = 1;

	input	[3:0]	i_op1, i_op2;
	input 			i_carry_borrow_in;
	output	[3:0] 	o_res;
	output			o_carry_borrow_out;


	generate
		if(mode==1) 
			four_bit_adder adder (.i_op1(i_op1),
								  .i_op2(i_op2), 
								  .i_carry_in(i_carry_borrow_in),
								  .o_sum(o_res), 
								  .o_carry_out(o_carry_borrow_out)
								  );
		else if(mode==0)
			four_bit_subtractor subtractor (.i_op1(i_op1),
										    .i_op2(i_op2), 
										    .i_borrow_in(i_carry_borrow_in),
										    .o_subtract(o_res), 
										    .o_borrow_out(o_carry_borrow_out)
										   );
		else begin
			initial begin
				$display("There are no defined macros");
				$finish;
			end
		end
	endgenerate
endmodule // adder_or_subtractor


