`timescale 1 ns/1 ps

module task215;

	reg [ 3:0]  op1, op2;
	reg [ 2:0]  ctrl;
	wire[ 7:0]  out_beh;
	reg [ 7:0]  out_rtl;

	behavioral_alu alu_beh(.i_op1(op1), 
						   .i_op2(op2), 
						   .i_ctrl(ctrl), 
						   .o_data(out_beh)
						   );
	alu 		   alu_rtl(.i_op1(op1), 
						   .i_op2(op2), 
						   .i_ctrl(ctrl), 
						   .o_data(out_rtl)
						   );

	integer i, j, res, error = 0;

	initial begin
		for (i=0; i<500; i=i+1) begin: test
			op1 = $random();
			op2 = $random();
			ctrl = {$random} % 5;
			#1;
			if (ctrl!=2) begin 
				if (out_beh[3:0]!==out_rtl[3:0]) begin
					error = error + 1;
					$display("Error at %d: op1=%d, op2=%d, ctrl=%d, behavioral_alu=%d, rtl_alu=%d",$time, 
					op1, op2, ctrl, out_beh[3:0], out_rtl[3:0]);
				end
			end
			else begin
				if (out_beh!==out_rtl) begin
					error = error + 1;
					$display("Error at %d: op1=%d, op2=%d, ctrl=%d, behavioral_alu=%d, rtl_alu=%d",$time, 
					op1, op2, ctrl, out_beh, out_rtl);
				end
			end
		end //test
		if (error==0) $display("!!!Test completed succesfully");
		else $display("Error counter: %d", error);
	end // initial
endmodule // lb2_tb