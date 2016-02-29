`timescale 1 ns/1 ps

module lb2_tb;

	reg [ 3:0]  op1, op2;
	reg [ 7:0]  mult;

	multiple multi(.i_op1(op1), 
			  .i_op2(op2), 
			  .o_mult(mult)
			 );		   		

	integer i, j, res, error = 0;

	initial begin
		for (i=0; i<16; i=i+1) begin
			for (j=0; j<16; j=j+1) begin
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