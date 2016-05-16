module bandpass_filter(i_clk, i_clk_en, 
						i_rst_n, i_data, o_data);

	input 						i_clk, i_clk_en, i_rst_n;
	input		signed	[17:0]	i_data;
	output	reg	signed	[17:0]	o_data;

	reg		signed	[17:0]	pipeline [0:10];
	reg				[3:0] 	counter;
	wire 	signed	[21:0]	mux_out;
	wire					complement;
	wire 	signed	[21:0]	adder_input;
	reg 	signed	[24:0]	acc;
	wire					sync_reset;

	integer i;

	assign	sync_reset = (counter==15) ? 1'b0 : 1'b1;

	always @(posedge i_clk or negedge i_rst_n) begin : count
		if(~i_rst_n) begin
			 counter <= 0;
			 for (i=0; i<11; i=i+1) pipeline[i] <= 0;
		end else begin
			 if (i_clk_en===1) begin
			 	if(counter==15) begin
			 		counter 	 <= 0;
			 		pipeline [0] <= i_data;
					for (i=0; i<10; i=i+1) begin
						pipeline[i+1] <= pipeline[i];
					end
			 	end
			 	else begin
			 		counter 	<= counter + 1;
			 	end
			 end // if (i_clk_en)
		end
	end // counter 

	assign mux_out = (counter==0) ?	pipeline[0] 	:
					 (counter==1) ?	pipeline[0]<<1 	:
					 (counter==2) ?	pipeline[1]<<3	:
					 (counter==3) ?	pipeline[2]<<3  :
					 (counter==4) ?	pipeline[4]<<3  :
					 (counter==5) ?	pipeline[4]<<1  :
					 (counter==6) ?	pipeline[4]		:
					 (counter==7) ?	pipeline[5]<<4  :
					 (counter==8) ?	pipeline[6]<<3  :	
					 (counter==9) ?	pipeline[6]<<1  :
					 (counter==10)?	pipeline[6]		:
					 (counter==11)?	pipeline[8]<<3  :
					 (counter==12)?	pipeline[9]<<3  :
					 (counter==13)?	pipeline[10]    :	
					 				pipeline[10]<<1	;

	assign	complement = (counter==0) ?	1'b1	:
						 (counter==1) ?	1'b1 	:
						 (counter==2) ?	1'b1	:
						 (counter==3) ?	1'b1	:
						 (counter==4) ?	1'b0  	:
						 (counter==5) ?	1'b0    :
						 (counter==6) ?	1'b0	:
						 (counter==7) ?	1'b0	:
						 (counter==8) ?	1'b0	:	
						 (counter==9) ?	1'b0	:
						 (counter==10)?	1'b0	:
						 (counter==11)?	1'b1	:
						 (counter==12)?	1'b1	:
						 (counter==13)?	1'b1	:	
						 				1'b1	;

	assign 	adder_input = (complement) ? -mux_out : mux_out;

	always @(posedge i_clk or negedge i_rst_n) begin : accumulation
		if(~i_rst_n) begin
			acc <= 0;
		end else begin
			if (sync_reset==1'b1) begin
				acc <= adder_input + acc;
			end
			else begin
				acc <= 0;
			end
		end
	end

	always @(posedge i_clk or negedge i_rst_n) begin : filter_out
		if(~i_rst_n) begin
			o_data <= 0;
		end else begin
			if (sync_reset===0) begin
				if (~(acc[24]^acc[23])) begin
					o_data <= acc[22:5] + {acc[4]&&(|acc[3:0]||acc[5])};
				end
				else begin
					if(acc[24]) o_data <= 18'h20000;
					else o_data <= 18'h1FFFF;
				end
			end
		end
	end


endmodule // bandpass_filter