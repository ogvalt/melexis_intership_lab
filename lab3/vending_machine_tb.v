`timescale 1ns/1ns
module vending_machine_tb;

	localparam ESPRESSO  = 1,
			   AMERICANO = 2,
			   LATTE	 = 3,
			   TEA		 = 4,
			   MILK		 = 5,
			   CHOCOLATE = 6,
			   NUTS	     = 7,
			   SNICKERS  = 8;

    parameter  PRICE_PROD_ONE   = 320, //ESPRESSO
			   PRICE_PROD_TWO   = 350, //AMERICANO
			   PRICE_PROD_THREE = 400, //LATTE
			   PRICE_PROD_FOUR  = 420, //TEA
			   PRICE_PROD_FIVE  = 450, //MILK
			   PRICE_PROD_SIX   = 300, //CHOCOLATE
			   PRICE_PROD_SEVEN = 900, //NUTS
			   PRICE_PROD_EIGHT = 800; //SHICKERS

	localparam DENOMINATION_CODE_500 = 1,  DENOMINATION_500 = 50000,
			   DENOMINATION_CODE_200 = 2,  DENOMINATION_200 = 20000,
			   DENOMINATION_CODE_100 = 3,  DENOMINATION_100 = 10000,
			   DENOMINATION_CODE_50  = 4,  DENOMINATION_50  = 5000,
			   DENOMINATION_CODE_20  = 5,  DENOMINATION_20  = 2000,
			   DENOMINATION_CODE_10  = 6,  DENOMINATION_10  = 1000,
			   DENOMINATION_CODE_5   = 7,  DENOMINATION_5   = 500,
			   DENOMINATION_CODE_2   = 8,  DENOMINATION_2   = 200,
			   DENOMINATION_CODE_1   = 9,  DENOMINATION_1   = 100,
			   DENOMINATION_CODE0_50 = 10, DENOMINATION0_50 = 50, 
			   DENOMINATION_CODE0_25 = 11, DENOMINATION0_25 = 25,
			   DENOMINATION_CODE0_10 = 12, DENOMINATION0_10 = 10,
			   DENOMINATION_CODE0_05 = 13, DENOMINATION0_05 = 5,
			   DENOMINATION_CODE0_02 = 14, DENOMINATION0_02 = 2,
			   DENOMINATION_CODE0_01 = 15, DENOMINATION0_01 = 1;

	reg			clk, rst_n;
	reg	[3:0]	money;
	reg	[3:0]	i_product;
	reg			buy, product_ready, change_ready;

	wire		busy, no_change, product_strobe, change_strobe;
	wire [31:0]	change;
	wire [3:0]  o_product;

	integer den_iter, prod_iter, error, product_cost, money_account, true_change;

	vending_machine vm( .i_clk(clk), 
						.i_rst_n(rst_n),
						.i_money(money),
						.i_product(i_product),
						.i_buy(buy),
						.i_product_ready(product_ready),
						.i_change_ready(change_ready),
						.o_busy(busy),
						.o_no_money(no_change),
						.o_money(change),
						.o_product(o_product),
						.o_product_strobe(product_strobe),
						.o_money_strobe(change_strobe)
						);

	initial begin
		clk = 0;
		forever #2 clk = ~clk;
	end
	initial begin
		error = 0;
		buy = 0;
		product_ready = 0;
		change_ready  = 0; 
		money_account = 0;
		true_change = 0;
		rst_n = 0;
		#1;
		rst_n = 1;
		#1;
		rst_n = 0;
		#1;
		for (den_iter=1; den_iter<16; den_iter = den_iter + 1) begin
			for (prod_iter = 1; prod_iter<9; prod_iter = prod_iter + 1) begin
				i_product = prod_iter;
				money = den_iter;
				@(negedge clk);
				buy = 1;
				repeat(3) @(negedge clk);
				while (!product_strobe) begin
					case(den_iter)
						DENOMINATION_CODE_500 :					   		  				
				   			money_account = money_account + DENOMINATION_500;
				   		DENOMINATION_CODE_200 :					   		  			  
				   			money_account = money_account + DENOMINATION_200;
				   		DENOMINATION_CODE_100 :					   		  			  
				   			money_account = money_account + DENOMINATION_100;
				   		DENOMINATION_CODE_50  :					   		   			  	
				   			money_account = money_account + DENOMINATION_50;
				   		DENOMINATION_CODE_20  :					   		   			  	
				   			money_account = money_account + DENOMINATION_20;
				   		DENOMINATION_CODE_10  :					   		   			  
				   			money_account = money_account + DENOMINATION_10;
				   		DENOMINATION_CODE_5   :					   		   			   
				   			money_account = money_account + DENOMINATION_5;
				   		DENOMINATION_CODE_2   :					   		   			 
				   			money_account = money_account + DENOMINATION_2;
				   		DENOMINATION_CODE_1   :					   		   			 
				   			money_account = money_account + DENOMINATION_1;
				   		DENOMINATION_CODE0_50 :					   		   			  
				   			money_account = money_account + DENOMINATION0_50;
				   		DENOMINATION_CODE0_25 :					   		   			 
				   			money_account = money_account + DENOMINATION0_25;
				   		DENOMINATION_CODE0_10 :					   		   			 	
				   			money_account = money_account + DENOMINATION0_10;
				   		DENOMINATION_CODE0_05 : 
				   			money_account = money_account + DENOMINATION0_05;
				   		DENOMINATION_CODE0_02 : 	  	
				   			money_account = money_account + DENOMINATION0_02;
				   		DENOMINATION_CODE0_01 : 
				   		    money_account = money_account + DENOMINATION0_01;
					   	default: money_account = money_account;
					endcase // den_iter
					@(negedge clk);
				end
				buy = 0;
				if (o_product!==prod_iter) begin
					$display("Error at %d: True product code = %d, fsm product output = %d",$time,prod_iter, o_product);
					error = error + 1;
				end
				@(negedge clk);
				product_ready = 1;
				@(negedge clk);
				product_ready = 0;
				while(!change_strobe) @(negedge clk);
				case(prod_iter)
					ESPRESSO :  product_cost = PRICE_PROD_ONE;
					AMERICANO:  product_cost = PRICE_PROD_TWO;
					LATTE: 	    product_cost = PRICE_PROD_THREE;	
					TEA	: 	    product_cost = PRICE_PROD_FOUR;
					MILK: 		product_cost = PRICE_PROD_FIVE;
					CHOCOLATE: 	product_cost = PRICE_PROD_SIX;
					NUTS:		product_cost = PRICE_PROD_SEVEN;
					SNICKERS: 	product_cost = PRICE_PROD_EIGHT;
					default:	product_cost = 0;
				endcase
				true_change = money_account - product_cost;
				if(no_change===0) begin
					if (change!==true_change) begin
						$display("Error at %d: True change = %d, fsm change = %d",$time,true_change, change);
						error = error + 1;
						end
					end
				else begin	
					if(change!==0) begin
						$display("Error at %d: no_change = 1, true change = 0, fsm product output = %d",$time,change);
						error = error + 1;
					end 
				end
				@(negedge clk);
				change_ready = 1;
				@(negedge clk);
				change_ready = 0;
				true_change = 0;
				money_account = 0;
			end
		end
		if (error==0) $display("!!! Test complete successfully");
		$finish;
	end

endmodule // vending_machine_tb