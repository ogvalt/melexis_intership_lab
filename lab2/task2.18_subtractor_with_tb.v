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

module param_subtractor (i_op1, i_op2, i_borrow_in, o_subtract, o_borrow_out);

	parameter WIDTH = 4;

	input  [WIDTH-1:0] i_op1, i_op2;
	input 		  	   i_borrow_in;
	output [WIDTH-1:0] o_subtract;
	output 		       o_borrow_out;

	wire   [WIDTH-1:0] borrow;

	assign o_borrow_out = borrow[WIDTH-1];

	genvar i;

	generate 
		for(i=0; i<WIDTH; i=i+1) begin : sub_iteration
			if(i==0) 
				full_subtractor cell (.i_op1(i_op1[i]),
								 .i_op2(i_op2[i]),
								 .i_borrow_in(i_borrow_in),
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

module param_subtractor_tb;

	reg [ 3:0]  op1, op2;
	reg 	    borrow_in;
	reg [ 3:0]  subtract;
	reg 		borrow_out;

	reg signed [ 4:0]  borrow_concat_sub;

	param_subtractor #(.WIDTH(4)) four_bit_subtractor(.i_op1(op1), 
					   		.i_op2(op2), 
					   		.i_borrow_in(borrow_in),
					   		.o_subtract(subtract),
					   		.o_borrow_out(borrow_out)
							);

	integer i, j, res, error = 0;

	initial begin
		borrow_in = 0;
		for (i=0; i<16; i=i+1) begin
			for (j=0; j<16; j=j+1) begin
				res = i - j;
				op1 = i;
				op2 = j;
				#1;
				borrow_concat_sub = $signed({borrow_out, subtract});
				if (res!=borrow_concat_sub) begin
					error = error + 1;
					$display("Error at %d: i=%d, j=%d, i-j=%d, op1=%d, op2=%d, op1-op2=%d, borrow_out=%d, subtract=%d",$time, 
						i, j, res, op1, op2, borrow_concat_sub, borrow_out, subtract);
				end // if (res!= sum)
			end // for (j=0; j<16; j=j+1)
		end // for (i=0; i<16; i=i+1)
		if (error==0) $display("!!!Test completed succesfully");
		else $display("Error counter: %d", error);
	end // initial
endmodule // lb2_tb