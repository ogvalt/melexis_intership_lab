`timescale 1 ns /1 ps

module bitwise_nor(i_op1, i_op2, o_nor);

	input	[ 3:0] i_op1, i_op2;
	output	[ 3:0] o_nor;

	genvar i;

	generate
		for (i=0; i<4; i=i+1) begin:not_or
			nor n (o_nor[i],i_op1[i],i_op2[i]);
		end //nor
	endgenerate

endmodule