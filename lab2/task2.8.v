`timescale 1 ns/1 ps

module mux_tb;

	reg [ 3:0]  op1, op2, op3, op4, op5;
	reg	[ 2:0]	ctrl;
	wire[ 3:0]  out;

	mux mux(.i_data0(op1), 
			.i_data1(op2), 
			.i_data2(op3), 
			.i_data3(op4), 
			.i_data4(op5), 
			.i_ctrl(ctrl), 
			.o_data(out)
			);		   		

	integer i, error = 0;

	initial begin
		for (i=0; i<256; i=i+1) begin 
			op1 = $random();
			op2 = $random();
			op3 = $random();
			op4 = $random();
			op5 = $random();
			ctrl = {$random} % 5;
			#1;
			case (ctrl)
				0: begin
					if (op1!==out) begin
						error = error + 1;
						$display("Error at %d: op1=%d, op2=%d, op3=%d, op4=%d, op5=%d, out=%d, ctrl=%d true_out=%d",$time, 
						op1, op2, op3, op4, op5, out, ctrl, op1);
					end
				end
				1: begin
					if (op2!==out) begin
						error = error + 1;
						$display("Error at %d: op1=%d, op2=%d, op3=%d, op4=%d, op5=%d, out=%d, ctrl=%d true_out=%d",$time, 
						op1, op2, op3, op4, op5, out, ctrl, op2);
					end
				end
				2: begin
					if (op3!==out) begin
						error = error + 1;
						$display("Error at %d: op1=%d, op2=%d, op3=%d, op4=%d, op5=%d, out=%d, ctrl=%d true_out=%d",$time, 
						op1, op2, op3, op4, op5, out, ctrl, op3);
					end
				end
				3: begin
					if (op4!==out) begin
						error = error + 1;
						$display("Error at %d: op1=%d, op2=%d, op3=%d, op4=%d, op5=%d, out=%d, ctrl=%d true_out=%d",$time, 
						op1, op2, op3, op4, op5, out, ctrl, op4);
					end
				end
				4: begin
					if (op5!==out) begin
						error = error + 1;
						$display("Error at %d: op1=%d, op2=%d, op3=%d, op4=%d, op5=%d, out=%d, ctrl=%d true_out=%d",$time, 
						op1, op2, op3, op4, op5, out, ctrl, op5);
					end
				end
			
				default : $display("Error ad %d: unexpected ctrl=%d", $time, ctrl);

			endcase
		end

		if (error==0) $display("!!!Test completed succesfully");
		else $display("Error counter: %d", error);
	end // initial
endmodule // lb2_tb