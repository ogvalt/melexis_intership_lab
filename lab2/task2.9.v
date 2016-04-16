`timescale 1 ns /1 ps

module bitwise_nand(i_op1, i_op2, o_nand);

	input	[ 3:0] i_op1, i_op2;
	output	[ 3:0] o_nand;

	genvar i;

	generate
		for (i=0; i<4; i=i+1) begin:not_and
			nand n (o_nand[i],i_op1[i],i_op2[i]);
		end //nand
	endgenerate

endmodule