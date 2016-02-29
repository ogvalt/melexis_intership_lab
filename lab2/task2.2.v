`timescale 1 ns/1 ps

module task22;

	reg [ 3:0]  op1, op2;
	reg 	    carry_in;
	reg [ 3:0]  sum;
	reg 		carry_out;

	reg [ 4:0]  carry_concat_sum;

	four_bit_adder four_bit_adder(.i_op1(op1), 
					.i_op2(op2), 
					.i_carry_in(carry_in), 
					.o_sum(sum), 
					.o_carry_out(carry_out)
					);

	integer i, j, res, error = 0;

	initial begin
		carry_in = 0;
		for (i=0; i<16; i=i+1) begin
			for (j=0; j<16; j=j+1) begin
				res = i + j;
				op1 = i;
				op2 = j;
				#1;
				carry_concat_sum = {carry_out, sum};
				if (res!=carry_concat_sum) begin
					error = error + 1;
					$display("Error at %d: i=%d, j=%d, i+j=%d, op1=%d, op2=%d, op1+op2=%d, carry_out=%d, sum=%d",$time, i,j,res,op1,op2,carry_concat_sum, carry_out, sum);
				end // if (res!= sum)
			end // for (j=0; j<16; j=j+1)
		end // for (i=0; i<16; i=i+1)
		if (error==0) $display("!!!Test completed succesfully");
		else $display("Error counter: %d", error);
	end // initial
endmodule // lb2_tb