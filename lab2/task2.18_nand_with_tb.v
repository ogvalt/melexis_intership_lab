`timescale 1 ns /1 ps

module bitwise_nand(i_op1, i_op2, o_nand);

	parameter WIDTH = 4;

	input	[WIDTH-1:0] i_op1, i_op2;
	output	[WIDTH-1:0] o_nand;

	genvar i;

	generate
		for (i=0; i<WIDTH; i=i+1) begin:not_and
			nand n (o_nand[i],i_op1[i],i_op2[i]);
		end //nand
	endgenerate

endmodule

module bitwise_nand_tb;
	parameter WIDTH = 8;
	reg  [WIDTH-1:0]  op1, op2;
	wire [WIDTH-1:0]  out;

	bitwise_nand #(.WIDTH(WIDTH)) noand(.i_op1(op1),
				 	  .i_op2(op2),
				 	  .o_nand(out)
				 	 );		   		

	integer i, j, res, error = 0;

	initial begin
		for (i=0; i<2**WIDTH; i=i+1) begin: outer
			for(j=0;j<2*WIDTH; j=j+1) begin: inner
				op1 = i;
				op2 = j;
				res = {~(op1&op2)};
				#1;
				if (res!==out) begin
					error = error + 1;
					$display("Error at %d: op1=%d, op2=%d, nand output=%d, true nand=%d",$time, 
					op1, op2, out, res);
				end
			end
		end
		if (error==0) $display("!!!Test completed succesfully");
		else $display("Error counter: %d", error);
	end // initial
endmodule // lb2_tb