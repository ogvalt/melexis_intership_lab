`timescale 1 ns / 1 ns
module traffic_light_tb;

	parameter period = 4;
	parameter RED_DELAY = 13, YELLOW_DELAY = 20, GREEN_DELAY = 12;

	reg  clk, reset;
	wire red, yellow, green;
	integer error;

	traffic_light #(.RED_DELAY(RED_DELAY), 
					.YELLOW_DELAY(YELLOW_DELAY), 
					.GREEN_DELAY(GREEN_DELAY)
					)					tl (.i_clk(clk), 
										.i_rst_n(reset), 
										.o_red(red), 
										.o_yellow(yellow), 
										.o_green(green)
										);

	initial begin
		clk = 0;
		forever #(period/2) clk = ~clk;
	end
	initial begin
		error = 0;
		reset = 1;
		#1;
		reset = 0;
		#1;
		reset = 1;
		if (red!=1) begin
			$display("Error at %d. True RED=1, YELLOW=0, GREEN=0, Real RED=%d, YELLOW=%d, GREEN=%d",$time, 
				red, yellow, green);
			error = error + 1;
		end
		repeat (10) begin
			repeat (RED_DELAY) @(negedge clk);
				if (yellow!=1) begin
					$display("Error at %d. True RED=0, YELLOW=1, GREEN=0, Real RED=%d, YELLOW=%d, GREEN=%d",$time, 
							red, yellow, green);
					error = error + 1;
				end
			repeat (YELLOW_DELAY) @(negedge clk);
				if (green!=1) begin
					$display("Error at %d. True RED=0, YELLOW=0, GREEN=1, Real RED=%d, YELLOW=%d, GREEN=%d",$time, 
							red, yellow, green);
					error = error + 1;
				end
			repeat (GREEN_DELAY) @(negedge clk);
				if (yellow!=1) begin
					$display("Error at %d. True RED=0, YELLOW=1, GREEN=0, Real RED=%d, YELLOW=%d, GREEN=%d",$time, 
							red, yellow, green);
					error = error + 1;
				end
			repeat (YELLOW_DELAY) @(negedge clk);
				if (red!=1) begin
					$display("Error at %d. True RED=1, YELLOW=0, GREEN=0, Real RED=%d, YELLOW=%d, GREEN=%d",$time, 
							red, yellow, green);
					error = error + 1;
				end
		end
		if (error==0)
			$display("!!! Test complete successfully");
		else
			$display("There are %d errors", error);
		$finish;
	end
endmodule