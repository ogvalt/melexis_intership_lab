`timescale 1 ns /1 ps

//`include "task2.1.v"
//`include "task2.3.v"
//`include "task2.5.v"
//`include "task2.7.v"
//`include "task2.9.v"
//`include "task2.11.v"

module subtractor_without_borrow_in (i_op1, i_op2, o_subtract, o_borrow_out);

	input  [ 3:0] i_op1, i_op2;
	output [ 3:0] o_subtract;
	output 		  o_borrow_out;

	wire   [ 3:0] borrow;

	assign o_borrow_out = borrow[3];

	genvar i;

	generate 
		for(i=0; i<4; i=i+1) begin : adder_iteration
			if(i==0) 
				half_subtractor cl (.i_op1(i_op1[i]),
									 .i_op2(i_op2[i]),
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

module alu(i_op1, i_op2, i_ctrl, o_data);

	input	[3:0] 		i_op1, i_op2;
	input 	[2:0] 		i_ctrl;

	output	[7:0] 		o_data;

	wire	[3:0] 		add_result, sub_result, nand_result, nor_result;
	wire	[7:0] 		mult_result;

	wire 				not_ctrl, zero_wire;

	not n1 (not_ctrl, i_ctrl[0]);
	and a1 (zero_wire, i_ctrl[0], not_ctrl);

	adder_without_carry_in adder(.i_op1(i_op1), 
							     .i_op2(i_op2), 
							     .o_sum(add_result),
							     .o_carry_out()
							    );

	subtractor_without_borrow_in subtractor(.i_op1(i_op1), 
											.i_op2(i_op2), 
											.o_subtract(sub_result), 
											.o_borrow_out()
											);

	multiple multiplier(.i_op1(i_op1),
					 	.i_op2(i_op2), 
					 	.o_mult(mult_result)
					 	);

	bitwise_nand not_and(.i_op1(i_op1), 
						 .i_op2(i_op2), 
						 .o_nand(nand_result)
						 );

	bitwise_nor not_or(.i_op1(i_op1), 
					   .i_op2(i_op2), 
					   .o_nor(nor_result)
					   );

	mux #(.WIDTH(8)) multiplexer (.i_data1({{4{zero_wire}},add_result}), 
								  .i_data2({{4{zero_wire}},sub_result}), 
								  .i_data3(mult_result), 
								  .i_data4({{4{zero_wire}},nand_result}), 
								  .i_data5({{4{zero_wire}},nor_result}), 
								  .i_ctrl(i_ctrl), 
								  .o_data(o_data)
								  );

endmodule

module behavioral_alu(i_op1, i_op2, i_ctrl, o_data);

	input	[3:0] 		i_op1, i_op2;
	input 	[2:0] 		i_ctrl;

	output reg	[7:0] 	o_data;

	always @* begin
		case(i_ctrl)
			0: o_data <= i_op1+i_op2;
			1: o_data <= i_op1-i_op2;
			2: o_data <= i_op1*i_op2;
			3: o_data <= ~(i_op1&i_op2);
			4: o_data <= ~(i_op1|i_op2);
			default: o_data <= 0;
		endcase // i_ctrl
	end
endmodule