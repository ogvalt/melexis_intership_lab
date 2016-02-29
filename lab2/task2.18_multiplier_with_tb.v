`timescale 1 ns /1 ps
module half_adder (i_op1, i_op2, o_sum, o_carry);
	
	input  i_op1, i_op2;
	output o_sum, o_carry;

	xor (o_sum, i_op1, i_op2);
	and (o_carry, i_op1, i_op2);

endmodule

module full_adder(i_op1, i_op2, i_carry_prev, o_sum, o_carry);
	
	input  i_op1, i_op2, i_carry_prev;
	output o_sum, o_carry;

	wire   sum1, carry1, carry2;

	or or1 (o_carry, carry1, carry2);

	half_adder first_half_adder(.i_op1(i_op1),
								.i_op2(i_op2),
								.o_sum(sum1),
								.o_carry(carry1)
								);

	half_adder second_half_adder(.i_op1(sum1),
								 .i_op2(i_carry_prev),
								 .o_sum(o_sum),
								 .o_carry(carry2)
								 );

endmodule

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
module param_multiplier(i_op1, i_op2, o_mult);

	parameter WIDTH = 4;

	input	[WIDTH-1:0] i_op1, i_op2;
	output 	[2*WIDTH-1:0] o_mult;

	wire [4*WIDTH-1:0] connect;
	wire [WIDTH-2:0] sum_first_stage;
	wire [WIDTH-1:0] sum_stage [0:WIDTH-2];
	wire [WIDTH-1:0] carry_stage;
	wire b12, c12;

	assign o_mult[0] = connect[0];	


	genvar i,j;
	
	generate begin:multiplier
		for (i=0; i<WIDTH; i=i+1) begin:outer
			for (j=0; j<WIDTH; j=j+1) begin:inner
				and a1(connect[WIDTH*i+j], i_op1[i], i_op2[j]);
				end //inner
			end //outer
		for (i=0; i<WIDTH-1; i=i+1) begin:iter
			if(i==0) begin
				adder_without_carry_in #(.WIDTH(WIDTH-1)) first_stage ( .i_op1(connect[WIDTH-1:1]),
																		.i_op2(connect[WIDTH+:(WIDTH-1)]),
																		.o_sum(sum_first_stage),
																		.o_carry_out(carry_stage[i])
																		);
				assign o_mult[i+1] = sum_first_stage[0];
				half_adder between12 (.i_op1(connect[2*WIDTH-1]),
									  .i_op2(carry_stage[i]),
									  .o_sum(b12),
									  .o_carry(c12)
									  ); 
			end
			else begin
				if(i==1) begin
					adder_without_carry_in #(.WIDTH(WIDTH)) second_stage (.i_op1({c12,b12,sum_first_stage[WIDTH-2:1]}),
																		  .i_op2(connect[(i+1)*WIDTH+:WIDTH]),
																		  .o_sum(sum_stage[i-1]),
																		  .o_carry_out(carry_stage[i])
																		  );
					assign o_mult[i+1] = sum_stage[i-1][0];
				end
				else begin
					if(i==(WIDTH-2)) begin
						adder_without_carry_in #(.WIDTH(WIDTH)) last_stage (.i_op1({carry_stage[i-1], sum_stage[i-2][3:1]}),
																			.i_op2(connect[(i+1)*WIDTH+:WIDTH]),
																			.o_sum(sum_stage[i-1]),
																			.o_carry_out(carry_stage[i])
																			);
						assign o_mult[2*WIDTH-1:WIDTH-1] = {carry_stage[i], sum_stage[i-1]}; 
					end
					else begin
						adder_without_carry_in #(.WIDTH(WIDTH)) stage (.i_op1({carry_stage[i-1], sum_stage[i-2][3:1]}),
																	   .i_op2(connect[(i+1)*WIDTH+:WIDTH]),
																	   .o_sum(sum_stage[i-1]),
																	   .o_carry_out(carry_stage[i])
																	  );
						assign o_mult[i+1] = sum_stage[i-1][0];
					end
				end
			end
		end //iter
		end //multplier
	endgenerate
endmodule

`timescale 1 ns/1 ps

module param_multiplier_tb;

	reg [ 3:0]  op1, op2;
	reg [ 7:0]  mult;

	param_multiplier #(.WIDTH(4)) multi(.i_op1(op1), 
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