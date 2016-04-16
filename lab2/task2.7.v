`timescale 1 ns /1 ps
module four_in_and (o_out, i_in0, i_in1, i_in2, i_in3);

	output	o_out;
	input	i_in0, i_in1, i_in2, i_in3;

	wire c1,c2;

	and (c1, i_in0, i_in1);
	and (c2, i_in3, i_in2);
	and (o_out, c1, c2);

endmodule

module five_in_or(o_out, i_in);

	output			o_out;
	input	[4:0]	i_in;

	wire c1,c2,c3;

	or(c1, i_in[0], i_in[1]);
	or(c2, i_in[2], i_in[3]);
	or(c3, c1 , c2);
	or(o_out, i_in[4], c3);

endmodule

module one_bit_mux(i_in0, i_in1, i_in2, i_in3, i_in4, i_ctrl, o_out);

	input	i_in0, i_in1, i_in2, i_in3, i_in4;
	input	[2:0] i_ctrl;
	output	o_out;

	wire [4:0] select;

	wire [2:0] not_ctrl;

	not n1 (not_ctrl[0], i_ctrl[0]);
	not n2 (not_ctrl[1], i_ctrl[1]);
	not n3 (not_ctrl[2], i_ctrl[2]);

	four_in_and and1 (select[0], i_in0, not_ctrl[0],	not_ctrl[1],	not_ctrl[2]);
	four_in_and and2 (select[1], i_in1, i_ctrl[0],		not_ctrl[1],	not_ctrl[2]);
	four_in_and and3 (select[2], i_in2, not_ctrl[0],	i_ctrl[1],		not_ctrl[2]);
	four_in_and and4 (select[3], i_in3, i_ctrl[0],		i_ctrl[1],		not_ctrl[2]);
	four_in_and and5 (select[4], i_in4, not_ctrl[0],	not_ctrl[1],	i_ctrl[2]);

	five_in_or or1 (o_out, select);

endmodule

module mux(i_data0, i_data1, i_data2, i_data3, i_data4, i_ctrl, o_data);

	parameter WIDTH=4;

	input	[WIDTH-1:0]	i_data0, i_data1, i_data2, i_data3, i_data4;
	input	[2:0]	i_ctrl;

	output	[WIDTH-1:0] 	o_data;

	genvar i;

	generate
		for (i=0; i<WIDTH; i=i+1) begin:mux
			one_bit_mux stage (.i_in0(i_data0[i]),
							   .i_in1(i_data1[i]),
							   .i_in2(i_data2[i]),
							   .i_in3(i_data3[i]),
							   .i_in4(i_data4[i]),
							   .i_ctrl(i_ctrl),
							   .o_out(o_data[i])
							   );
		end //mux
	endgenerate

endmodule