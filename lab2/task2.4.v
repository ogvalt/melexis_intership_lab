`timescale 1 ns/1 ps

module task24;

	reg [ 3:0]  op1, op2;
	reg 	    borrow_in;
	reg [ 3:0]  subtract;
	reg 		borrow_out;

	reg signed [ 4:0]  borrow_concat_sub;

	four_bit_subtractor four_bit_subtractor(.i_op1(op1), 
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