module vending_machine_tb();

	parameter 	PERIOD = 4;

	parameter  ESPRESSO  = 1, 
			   AMERICANO = 2,
			   LATTE	 = 3,
			   TEA		 = 4,
			   MILK		 = 5,
			   CHOCOLATE = 6,
			   NUTS	     = 7,
			   SNICKERS  = 8;

	parameter  	PRICE_PROD_ONE   = 320, //ESPRESSO
				PRICE_PROD_TWO   = 350, //AMERICANO
				PRICE_PROD_THREE = 400, //LATTE
				PRICE_PROD_FOUR  = 420, //TEA
				PRICE_PROD_FIVE  = 450, //MILK
				PRICE_PROD_SIX   = 300, //CHOCOLATE
				PRICE_PROD_SEVEN = 900, //NUTS
				PRICE_PROD_EIGHT = 800; //SHICKERS

	parameter  DENOMINATION_CODE_500 = 1,  DENOMINATION_VALUE_500 = 50000,
			   DENOMINATION_CODE_200 = 2,  DENOMINATION_VALUE_200 = 20000,
			   DENOMINATION_CODE_100 = 3,  DENOMINATION_VALUE_100 = 10000,
			   DENOMINATION_CODE_50  = 4,  DENOMINATION_VALUE_50  = 5000,
			   DENOMINATION_CODE_20  = 5,  DENOMINATION_VALUE_20  = 2000,
			   DENOMINATION_CODE_10  = 6,  DENOMINATION_VALUE_10  = 1000,
			   DENOMINATION_CODE_5   = 7,  DENOMINATION_VALUE_5   = 500,
			   DENOMINATION_CODE_2   = 8,  DENOMINATION_VALUE_2   = 200,
			   DENOMINATION_CODE_1   = 9,  DENOMINATION_VALUE_1   = 100,
			   DENOMINATION_CODE0_50 = 10, DENOMINATION_VALUE_0_50 = 50, 
			   DENOMINATION_CODE0_25 = 11, DENOMINATION_VALUE_0_25 = 25,
			   DENOMINATION_CODE0_10 = 12, DENOMINATION_VALUE_0_10 = 10,
			   DENOMINATION_CODE0_05 = 13, DENOMINATION_VALUE_0_05 = 5,
			   DENOMINATION_CODE0_02 = 14, DENOMINATION_VALUE_0_02 = 2,
			   DENOMINATION_CODE0_01 = 15, DENOMINATION_VALUE_0_01 = 1;	

	reg 			i_clk, i_rst_n;

	reg		[3:0]	i_money; 
	reg 			i_money_valid;
	reg		[3:0]	i_product_code; // input of product's code

	reg				i_buy;
	reg				i_product_ready;

	reg 		[20:0]	product_price;
	reg 		[20:0]	wallet;
	reg signed	[20:0] 	change;

	wire  [3:0]		o_product_code;
	wire 			o_product_valid; 	// valid product code on o_product_code_output
	wire			o_busy;				// fsm is busy and processing old order

	wire  [3:0]		o_change_denomination_code;	// code of denomination of money change
	wire			o_change_valid;				// valid code on o_change_denomination_code
	wire 			o_no_change; 				// there is no change in VM

	integer 		error, i;

	vending_machine vm_inst1(
								.i_clk(i_clk),
								.i_rst_n(i_rst_n),

								.i_money(i_money),			// code of input denomination
								.i_money_valid(i_money_valid), 		// valid money code on i_money 

								.i_product_code(i_product_code), 	// input product code that 
													// customer what to buy
								.i_buy(i_buy), 				// customer made a choice

								.i_product_ready(i_product_ready), 	// product is already done

								.o_product_code(o_product_code),		// output product code  
								.o_product_valid(o_product_valid), 	// valid product code on o_product
								.o_busy(o_busy),				// fsm is busy and processing old order

								.o_change_denomination_code(o_change_denomination_code),	// code of denomination of money change
								.o_change_valid(o_change_valid),				// valid code on o_change_denomination_code
								.o_no_change(o_no_change) 				// there is no change
							);


	task product_validation();	
		change = 0;
		wallet = 0;
		@(negedge o_busy or posedge i_rst_n);
		i_product_code = ({$random} % 8) + 1;
		i_buy = 1;
		case(i_product_code)
			ESPRESSO: 	product_price = PRICE_PROD_ONE;
   			AMERICANO:	product_price = PRICE_PROD_TWO;
   			LATTE:		product_price = PRICE_PROD_THREE;
   			TEA:		product_price = PRICE_PROD_FOUR;
   			MILK:		product_price = PRICE_PROD_FIVE;
   			CHOCOLATE:	product_price = PRICE_PROD_SIX;
   			NUTS:		product_price = PRICE_PROD_SEVEN;
   			SNICKERS:	product_price = PRICE_PROD_EIGHT; 	
		endcase // i_product_code
		@(negedge i_clk);
		while (wallet < product_price) begin
			@(negedge i_clk);
			i_money = ({$random} % 15) + 1;
			i_money_valid = 1;
			case(i_money)
			   DENOMINATION_CODE_500: wallet <= wallet + DENOMINATION_VALUE_500 ;
			   DENOMINATION_CODE_200: wallet <= wallet + DENOMINATION_VALUE_200 ;
			   DENOMINATION_CODE_100: wallet <= wallet + DENOMINATION_VALUE_100 ;
			   DENOMINATION_CODE_50 : wallet <= wallet + DENOMINATION_VALUE_50  ;						   
			   DENOMINATION_CODE_20 : wallet <= wallet + DENOMINATION_VALUE_20  ;						   
			   DENOMINATION_CODE_10 : wallet <= wallet + DENOMINATION_VALUE_10  ;						 
			   DENOMINATION_CODE_5  : wallet <= wallet + DENOMINATION_VALUE_5   ;					  
			   DENOMINATION_CODE_2  : wallet <= wallet + DENOMINATION_VALUE_2   ;					   
			   DENOMINATION_CODE_1  : wallet <= wallet + DENOMINATION_VALUE_1   ;					   
			   DENOMINATION_CODE0_50: wallet <= wallet + DENOMINATION_VALUE_0_50;						   
			   DENOMINATION_CODE0_25: wallet <= wallet + DENOMINATION_VALUE_0_25;					   
			   DENOMINATION_CODE0_10: wallet <= wallet + DENOMINATION_VALUE_0_10;					   
			   DENOMINATION_CODE0_05: wallet <= wallet + DENOMINATION_VALUE_0_05;				   
			   DENOMINATION_CODE0_02: wallet <= wallet + DENOMINATION_VALUE_0_02;				   
			   DENOMINATION_CODE0_01: wallet <= wallet + DENOMINATION_VALUE_0_01;		
			endcase // i_money
		end

		@(negedge i_clk);
		i_product_ready = 1;
		@(posedge o_product_valid);
		i_product_ready = 0;
		i_buy = 0;
		i_money_valid = 0;
		if (i_product_code !== o_product_code) begin
			error = error + 1;
			$display("[%t] ERROR. Product code does not match.\n i_product_code = %d, o_product_code = %d \n",$time, i_product_code, o_product_code);
		end

		@(posedge o_change_valid);
		while(o_change_valid) begin
			@(negedge i_clk);
			case(o_change_denomination_code)
			   DENOMINATION_CODE_500: change <= change + DENOMINATION_VALUE_500 ;
			   DENOMINATION_CODE_200: change <= change + DENOMINATION_VALUE_200 ;
			   DENOMINATION_CODE_100: change <= change + DENOMINATION_VALUE_100 ;
			   DENOMINATION_CODE_50 : change <= change + DENOMINATION_VALUE_50  ;						   
			   DENOMINATION_CODE_20 : change <= change + DENOMINATION_VALUE_20  ;						   
			   DENOMINATION_CODE_10 : change <= change + DENOMINATION_VALUE_10  ;						 
			   DENOMINATION_CODE_5  : change <= change + DENOMINATION_VALUE_5   ;					  
			   DENOMINATION_CODE_2  : change <= change + DENOMINATION_VALUE_2   ;					   
			   DENOMINATION_CODE_1  : change <= change + DENOMINATION_VALUE_1   ;					   
			   DENOMINATION_CODE0_50: change <= change + DENOMINATION_VALUE_0_50;						   
			   DENOMINATION_CODE0_25: change <= change + DENOMINATION_VALUE_0_25;					   
			   DENOMINATION_CODE0_10: change <= change + DENOMINATION_VALUE_0_10;					   
			   DENOMINATION_CODE0_05: change <= change + DENOMINATION_VALUE_0_05;				   
			   DENOMINATION_CODE0_02: change <= change + DENOMINATION_VALUE_0_02;				   
			   DENOMINATION_CODE0_01: change <= change + DENOMINATION_VALUE_0_01;		
			endcase // i_money
		end
		if (change !== wallet - product_price) begin
			error = error + 1;
			$display("[%t] ERROR. Change does not match.\n change = %d, wallet - product_price = %d \n",$time, change, wallet - product_price);
		end
	endtask : product_validation

	task no_change();
		@(posedge o_no_change);
		if (error !== 0) begin
			$display("TEST FAILED. # of errors: %d", error);
		end else begin
			$display("TEST COMPLETE SUCCESSFULLY (# of iteration: %d)", i);
		end
		$finish;
	endtask : no_change

	initial begin
		i_clk = 0;
		forever #(PERIOD/2) i_clk = !i_clk;
	end

	initial begin
		fork
			begin
				repeat(1) @(posedge i_clk);
				repeat (1000) begin 
					product_validation();
					i = i + 1;
				end
				if (error !== 0) begin
					$display("TEST FAILED. # of errors: %d", error);
				end else begin
					$display("TEST COMPLETE SUCCESSFULLY (# of iteration: %d)", i);
				end
				$finish;
			end
			no_change();
		join
	end

	initial begin
		i = 0;
		i_rst_n = 0;
		i_money = 0;
		i_money_valid = 0;
		i_product_code = 0;
		i_product_ready = 0;
		i_buy = 0;
		error = 0;
		repeat(1) @(negedge i_clk);
		i_rst_n = 1;
	end

endmodule // vending_machine_tb