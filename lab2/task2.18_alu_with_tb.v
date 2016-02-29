`timescale 1 ns /1 ps

`include "task2.18_multiplier_with_tb.v"
`include "task2.18_nand_with_tb.v"
`include "task2.18_nor_with_tb.v"
`include "task2.7.v"

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

module subtractor_without_borrow_in (i_op1, i_op2, o_subtract, o_borrow_out);

	parameter WIDTH = 4;

	input  [WIDTH-1:0] i_op1, i_op2;
	output [WIDTH-1:0] o_subtract;
	output 		  	   o_borrow_out;

	wire   [WIDTH-1:0] borrow;

	assign o_borrow_out = borrow[WIDTH-1];

	genvar i;

	generate 
		for(i=0; i<WIDTH; i=i+1) begin : subtractor_iteration
			if(i==0) 
				half_subtractor cell (.i_op1(i_op1[i]),
									 .i_op2(i_op2[i]),
									 .o_subtract(o_subtract[i]),
									 .o_borrow(borrow[i])
									);
			
			else 
				full_subtractor cell (.i_op1(i_op1[i]),
									 .i_op2(i_op2[i]),
									 .i_borrow_in(borrow[i-1]),
									 .o_subtract(o_subtract[i]),
									 .o_borrow(borrow[i])
									);
			
		end
	endgenerate
endmodule

module alu(i_op1, i_op2, i_ctrl, o_data);

	parameter WIDTH = 4;

	input	[WIDTH-1:0] 		i_op1, i_op2;
	input 	[2:0] 				i_ctrl;

	output	[2*WIDTH-1:0] 		o_data;

	wire	[WIDTH-1:0] 		add_result, sub_result, nand_result, nor_result;
	wire	[2*WIDTH-1:0] 		mult_result;

	wire 						not_ctrl, zero_wire;

	not n1 (not_ctrl, i_ctrl[0]);
	and a1 (zero_wire, i_ctrl[0], not_ctrl);

	adder_without_carry_in #(.WIDTH(WIDTH)) adder(.i_op1(i_op1), 
											     .i_op2(i_op2), 
											     .o_sum(add_result),
											     .o_carry_out()
											    );

	subtractor_without_borrow_in #(.WIDTH(WIDTH)) subtractor(.i_op1(i_op1), 
															.i_op2(i_op2), 
															.o_subtract(sub_result), 
															.o_borrow_out()
															);

	param_multiplier #(.WIDTH(WIDTH)) multiplier(.i_op1(i_op1),
											 	.i_op2(i_op2), 
											 	.o_mult(mult_result)
											 	);

	bitwise_nand #(.WIDTH(WIDTH)) not_and(.i_op1(i_op1), 
										 .i_op2(i_op2), 
										 .o_nand(nand_result)
										 );

	bitwise_nor #(.WIDTH(WIDTH)) not_or(.i_op1(i_op1), 
									   .i_op2(i_op2), 
									   .o_nor(nor_result)
									   );

	mux #(.WIDTH(2*WIDTH)) multiplexer (.i_data1({{WIDTH{zero_wire}},add_result}), 
										  .i_data2({{WIDTH{zero_wire}},sub_result}), 
										  .i_data3(mult_result), 
										  .i_data4({{WIDTH{zero_wire}},nand_result}), 
										  .i_data5({{WIDTH{zero_wire}},nor_result}), 
										  .i_ctrl(i_ctrl), 
										  .o_data(o_data)
										  );

endmodule

module behavioral_alu(i_op1, i_op2, i_ctrl, o_data);

	parameter WIDTH = 4;

	input	[WIDTH-1:0] 		i_op1, i_op2;
	input 	[2:0] 				i_ctrl;

	output reg	[2*WIDTH-1:0] 	o_data;

	always @* begin
		case(i_ctrl)
			0: o_data <= i_op1+i_op2;
			1: o_data <= i_op1-i_op2;
			2: o_data <= i_op1*i_op2;
			3: o_data <= ~(i_op1&i_op2);
			4: o_data <= ~(i_op1|i_op2);
		endcase // i_ctrl
	end
endmodule

module alu_tb;

	reg [ 3:0]  op1, op2;
	reg [ 2:0]  ctrl;
	wire[ 7:0]  out_beh;
	reg [ 7:0]  out_rtl;

	behavioral_alu #(.WIDTH(4)) alu_beh(.i_op1(op1), 
									   .i_op2(op2), 
									   .i_ctrl(ctrl), 
									   .o_data(out_beh)
									   );
	alu #(.WIDTH(4)) alu_rtl(.i_op1(op1), 
							   .i_op2(op2), 
							   .i_ctrl(ctrl), 
							   .o_data(out_rtl)
							   );

	integer i, j, res, error = 0;

	initial begin
		for (i=0; i<500; i=i+1) begin: test
			op1 = $random();
			op2 = $random();
			ctrl = {$random} % 5;
			#1;
			if (ctrl!=2) begin 
				if (out_beh[3:0]!==out_rtl[3:0]) begin
					error = error + 1;
					$display("Error at %d: op1=%d, op2=%d, ctrl=%d, behavioral_alu=%d, rtl_alu=%d",$time, 
					op1, op2, ctrl, out_beh[3:0], out_rtl[3:0]);
				end
			end
			else begin
				if (out_beh!==out_rtl) begin
					error = error + 1;
					$display("Error at %d: op1=%d, op2=%d, ctrl=%d, behavioral_alu=%d, rtl_alu=%d",$time, 
					op1, op2, ctrl, out_beh, out_rtl);
				end
			end
		end //test
		if (error==0) $display("!!!Test completed succesfully");
		else $display("Error counter: %d", error);
	end // initial
endmodule // lb2_tb