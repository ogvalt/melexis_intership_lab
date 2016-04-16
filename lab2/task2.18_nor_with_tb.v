`timescale 1 ns /1 ps

module bitwise_nor(i_op1, i_op2, o_nor);

	parameter WIDTH = 4;

	input	[WIDTH-1:0] i_op1, i_op2;
	output	[WIDTH-1:0] o_nor;

	genvar i;

	generate
		for (i=0; i<WIDTH; i=i+1) begin:not_or
			nor n (o_nor[i],i_op1[i],i_op2[i]);
		end //nor
	endgenerate

endmodule

module bitwise_nor_tb;
	parameter WIDTH = 8;
	reg  [WIDTH-1:0]  op1, op2;
	wire [WIDTH-1:0]  out;

	bitwise_nor #(.WIDTH(WIDTH)) notor(.i_op1(op1),
				 	  .i_op2(op2),
				 	  .o_nor(out)
				 	 );		   		

	integer i, j, res, error = 0;

	initial begin
		for (i=0; i<2**WIDTH; i=i+1) begin: outer
			for(j=0;j<2**WIDTH; j=j+1) begin: inner
				op1 = i;
				op2 = j;
				res = {~(op1|op2)};
				#1;
				if (res!==out) begin
					error = error + 1;
					$display("Error at %d: op1=%d, op2=%d, nor output=%d, true nor=%d",$time, 
					op1, op2, out, res);
				end
			end
		end
		if (error==0) $display("!!!Test completed succesfully");
		else $display("Error counter: %d", error);
	end // initial
endmodule // lb2_tb