module traffic_light(i_clk, i_rst_n, o_red, o_yellow, o_green);

	input		i_clk, i_rst_n;
	output reg  o_red, o_yellow, o_green;

	reg		[1:0] state;
	reg 	[7:0] counter;
	
	parameter RED = 0, YELLOW1 = 1, YELLOW2 = 2, GREEN = 3;
	parameter RED_DELAY = 5, YELLOW_DELAY = 5, GREEN_DELAY = 5;

	always @ (state) begin
		case (state)
			RED: 
				begin
					o_red = 1;
					o_yellow = 0;
					o_green = 0;
				end
			YELLOW1:
				begin
					o_red = 0;
					o_yellow = 1;
					o_green = 0;
				end
			YELLOW2:
				begin
					o_red = 0;
					o_yellow = 1;
					o_green = 0;
				end
			GREEN:
				begin
					o_red = 0;
					o_yellow = 0;
					o_green = 1;
				end
			default:
				begin
					o_red = 0;
					o_yellow = 0;
					o_green = 0;
				end
		endcase
	end
	always @ (posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			state <= RED;
			counter <= 0;
		end
		else
			case (state)
				RED:
					if (counter == RED_DELAY-1) begin
						state <= YELLOW2;
						counter <= 0;
					end
					else begin
						state <= RED;
						counter <= counter + 1;
					end
				YELLOW1:
					if (counter == YELLOW_DELAY-1) begin
						state <= RED;
						counter <= 0;
					end
					else begin
						state <= YELLOW1;
						counter <= counter + 1;
					end
				YELLOW2:
					if (counter == YELLOW_DELAY-1) begin
						state <= GREEN;
						counter <= 0;
					end
					else begin
						state <= YELLOW2;
						counter <= counter + 1;
					end
				GREEN:
					if (counter == GREEN_DELAY-1) begin
						state <= YELLOW1;
						counter <= 0;
					end
					else begin
						state <= GREEN;
						counter <= counter + 1;
					end
			endcase
	end

endmodule