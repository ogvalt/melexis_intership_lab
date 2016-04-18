`timescale 1ns/1ns
module vending_machine( i_clk, 		// clock signal
						i_rst_n,	// reset signal
						i_money,	// code of demonination of banknote or coin 
						i_product,  // product code
						i_buy,		// start bit, buy enable
						i_product_ready, // bit that inform that product ready to taste or already eject
						i_change_ready,  // bit that inform that change is delivery
						o_busy, // inform that fsm is busy
						o_no_money, // inform that there is no money
						o_money,	// size of change
						o_product,	// product code
						o_product_strobe, // product strobe
						o_money_strobe // change strobe
						);
	// available products
	localparam ESPRESSO  = 1,
			   AMERICANO = 2,
			   LATTE	 = 3,
			   TEA		 = 4,
			   MILK		 = 5,
			   CHOCOLATE = 6,
			   NUTS	     = 7,
			   SNICKERS  = 8;
	// products prices		   
	parameter  PRICE_PROD_ONE   = 320, //ESPRESSO
			   PRICE_PROD_TWO   = 350, //AMERICANO
			   PRICE_PROD_THREE = 400, //LATTE
			   PRICE_PROD_FOUR  = 420, //TEA
			   PRICE_PROD_FIVE  = 450, //MILK
			   PRICE_PROD_SIX   = 300, //CHOCOLATE
			   PRICE_PROD_SEVEN = 900, //NUTS
			   PRICE_PROD_EIGHT = 800; //SHICKERS
	// denominations codes and values
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
	// amount of each denominations 
	localparam AMOUNT_500 = 0,
			   AMOUNT_200 = 0,
			   AMOUNT_100 = 0,
			   AMOUNT_50  = 0,
			   AMOUNT_20  = 20,
			   AMOUNT_10  = 20,
			   AMOUNT_5   = 20,
			   AMOUNT_2   = 20,
			   AMOUNT_1   = 20,
			   AMOUNT0_50 = 20,
			   AMOUNT0_25 = 20,
			   AMOUNT0_10 = 20,
			   AMOUNT0_05 = 20,
			   AMOUNT0_02 = 20,
			   AMOUNT0_01 = 20;
	// FSM states
	localparam	IDLE = 0, CHOOSE_PRODUCT = 1, ENTER_MONEY = 2, GIVE_PRODUCT = 3, GIVE_CHANGE = 4;

	input 				i_clk, i_rst_n;
	input		[3:0]	i_money;
	input		[3:0]	i_product;
	input				i_buy, i_product_ready, i_change_ready;

	output  reg			o_busy, o_no_money, o_product_strobe, o_money_strobe;
	output  reg	[31:0]	o_money;
	output	reg	[3:0]	o_product;

	reg			[31:0] 	amount_500, amount_200, amount_100, 
						amount_50, 	amount_20, 	amount_10, 
						amount_5, 	amount_2, 	amount_1,
						amount0_50,	amount0_25, amount0_10,
						amount0_05, amount0_02, amount0_01;
	reg			[31:0] 	amount_500_n, 	amount_200_n, 	amount_100_n, 
						amount_50_n, 	amount_20_n, 	amount_10_n, 
						amount_5_n, 	amount_2_n, 	amount_1_n,
						amount0_50_n,	amount0_25_n, 	amount0_10_n,
						amount0_05_n, 	amount0_02_n, 	amount0_01_n;

	reg			[31:0]	product_cost_one, 	product_cost_two, 
						product_cost_three, product_cost_four,
						product_cost_five, 	product_cost_six,
						product_cost_seven, product_cost_eigth;

	reg 		[2:0]	state;
	reg			[31:0]  money_account;
	reg			[31:0]	change;
	reg			[31:0]  total;

	reg			[3:0]	product;
	reg			[31:0]	product_cost;

	always @(posedge i_clk or posedge i_rst_n) begin : state_operation_block 
		if(i_rst_n) begin
			amount_500       <= AMOUNT_500;		  
			amount_200       <= AMOUNT_200; 
			amount_100       <= AMOUNT_100; 
			amount_50        <= AMOUNT_50;	
			amount_20        <= AMOUNT_20;	
			amount_10        <= AMOUNT_10;
			amount_5         <= AMOUNT_5;	
			amount_2         <= AMOUNT_2;	
			amount_1         <= AMOUNT_1;
			amount0_50       <= AMOUNT0_50;	
			amount0_25       <= AMOUNT0_25; 
			amount0_10       <= AMOUNT0_10;
			amount0_05       <= AMOUNT0_05; 
			amount0_02       <= AMOUNT0_02; 
			amount0_01       <= AMOUNT0_01;

	   		amount_500_n		<= 0; 
			amount_200_n		<= 0;
			amount_100_n		<= 0;
			amount_50_n			<= 0;
			amount_20_n			<= 0;
			amount_10_n			<= 0;
			amount_5_n			<= 0;
			amount_2_n			<= 0;
			amount_1_n			<= 0; 
			amount0_50_n		<= 0;
			amount0_25_n		<= 0;
			amount0_10_n		<= 0;
			amount0_05_n		<= 0;
			amount0_02_n		<= 0;
			amount0_01_n		<= 0;

			state			 <= IDLE;			
		end else begin
			amount_500       <= amount_500 + amount_500_n;
			amount_200       <= amount_200 + amount_200_n; 
			amount_100       <= amount_500 + amount_100_n; 
			amount_50        <= amount_500 + amount_50_n;	
			amount_20        <= amount_500 + amount_20_n;	
			amount_10        <= amount_500 + amount_10_n;
			amount_5         <= amount_500 + amount_5_n;	
			amount_2         <= amount_500 + amount_2_n;	
			amount_1         <= amount_500 + amount_1_n;
			amount0_50       <= amount0_50 + amount0_50_n;	
			amount0_25       <= amount0_25 + amount0_25_n; 
			amount0_10       <= amount0_10 + amount0_10_n;
			amount0_05       <= amount0_05 + amount0_05_n; 
			amount0_02       <= amount0_02 + amount0_02_n; 
			amount0_01       <= amount0_01 + amount0_01_n;

			total  <= amount_500*DENOMINATION_500 + amount_200*DENOMINATION_200 + amount_100*DENOMINATION_100 + amount_50*DENOMINATION_50 +
						amount_20*DENOMINATION_20 + amount_10*DENOMINATION_10 + amount_5*DENOMINATION_5 + amount_2*DENOMINATION_2 +
						amount_1*DENOMINATION_1 + amount0_50*DENOMINATION0_50 + amount0_25*DENOMINATION0_25 + amount0_10*DENOMINATION0_10 +
						amount0_05*DENOMINATION0_05 + amount0_02*DENOMINATION0_02 + amount0_01*DENOMINATION0_01;
			case(state)
				IDLE: 
					begin  			
						if(i_buy===1) state = CHOOSE_PRODUCT;
						else state = IDLE;
						money_account <= 0;
					end

				CHOOSE_PRODUCT: 
					begin
						if(product_cost!==0) state = ENTER_MONEY;
						else state = CHOOSE_PRODUCT;
					end

				ENTER_MONEY: 
					begin 
						if(money_account>=product_cost) state = GIVE_PRODUCT;
						else begin
							state = ENTER_MONEY;
							case(i_money)
							   DENOMINATION_CODE_500 : 
							   		begin
							   			amount_500_n	<= amount_500_n + 1;
							   			money_account   <= money_account + DENOMINATION_500;
							   		end
							   DENOMINATION_CODE_200 : 
							   		begin
							   			amount_200_n  <= amount_200_n + 1;
							   			money_account <= money_account + DENOMINATION_200;
							   		end
							   DENOMINATION_CODE_100 : 
							   		begin
							   			amount_100_n  <= amount_100_n + 1;	
							   			money_account <= money_account + DENOMINATION_100;
							   		end
							   DENOMINATION_CODE_50  : 
							   		begin 
							   			amount_50_n   <= amount_50_n + 1;	
							   			money_account <= money_account + DENOMINATION_50;
							   		end
							   DENOMINATION_CODE_20  : 
							   		begin 
							   			amount_20_n   <= amount_20_n + 1;	
							   			money_account <= money_account + DENOMINATION_20;
							   		end
							   DENOMINATION_CODE_10  : 
							   		begin 
							   			amount_10_n	  <= amount_10_n + 1;
							   			money_account <= money_account + DENOMINATION_10;
							   		end
							   DENOMINATION_CODE_5   : 
							   		begin 
							   			amount_5_n    <= amount_5_n  + 1; 
							   			money_account <= money_account + DENOMINATION_5;
							   		end
							   DENOMINATION_CODE_2   : 
							   		begin 
							   			amount_2_n	  <= amount_2_n  + 1;
							   			money_account <= money_account + DENOMINATION_2;
							   		end
							   DENOMINATION_CODE_1   : 
							   		begin 
							   			amount_1_n	  <= amount_1_n  + 1;
							   			money_account <= money_account + DENOMINATION_1;
							   		end
							   DENOMINATION_CODE0_50 : 
							   		begin 
							   			amount0_50_n  <= amount0_50_n + 1;
							   			money_account <= money_account + DENOMINATION0_50;
							   		end
							   DENOMINATION_CODE0_25 : 
							   		begin 
							   			amount0_25_n  <= amount0_25_n + 1; 
							   			money_account <= money_account + DENOMINATION0_25;
							   		end
							   DENOMINATION_CODE0_10 : 
							   		begin 
							   			amount0_10_n  <= amount0_10_n + 1;	
							   			money_account <= money_account + DENOMINATION0_10;
							   		end
							   DENOMINATION_CODE0_05 : 
							   		begin 
							   			amount0_05_n  <= amount0_05_n + 1;	
							   			money_account <= money_account + DENOMINATION0_05;
							   		end
							   DENOMINATION_CODE0_02 : 
							   		begin 
							   			amount0_02_n  <= amount0_02_n + 1;	
							   			money_account <= money_account + DENOMINATION0_02;
							   		end
							   DENOMINATION_CODE0_01 : 
							   		begin 
							   			amount0_50_n  <= amount0_50_n + 1;	
							   			money_account <= money_account + DENOMINATION0_01;
							   		end
							   	default: money_account <= money_account;
							endcase // i_money
						end
					end

				GIVE_PRODUCT:
					begin   
						if(i_product_ready===1) state = GIVE_CHANGE;
						else state = GIVE_PRODUCT;
					end

				GIVE_CHANGE: 
					begin
						if(i_change_ready||o_no_money===1) state = IDLE;
						else state = GIVE_CHANGE;
					end
				default: state = IDLE;
			endcase 
		end 
	end

	always @(state) begin : output_logic
		o_busy 				= 0;
		o_no_money 			= 0; 
		o_product_strobe 	= 0; 
		o_money_strobe 		= 0;
		o_money 			= 0;
		o_product 			= 0;
		case(state)
			IDLE: begin
					product 	  = 0;
					product_cost  = 0;
				end
			CHOOSE_PRODUCT: begin 
				product = i_product;
				case(product)
					ESPRESSO: 	product_cost = PRICE_PROD_ONE;
			   		AMERICANO: 	product_cost = PRICE_PROD_TWO;
			   		LATTE:		product_cost = PRICE_PROD_THREE;
			   		TEA:		product_cost = PRICE_PROD_FOUR;
			   		MILK:		product_cost = PRICE_PROD_FIVE;
			   		CHOCOLATE:	product_cost = PRICE_PROD_SIX;		
			   		NUTS:		product_cost = PRICE_PROD_SEVEN;
			   		SNICKERS:	product_cost = PRICE_PROD_EIGHT;
			   		default: 	product_cost = 0;
			   	endcase
			   	end
			ENTER_MONEY: ;
			GIVE_PRODUCT: begin
				o_product 		 = product;
				o_busy 	  		 = 1;
				o_product_strobe = 1;
				end	

			GIVE_CHANGE: begin
				o_busy			= 1;
				o_money_strobe	= 1;
				change 			= money_account - product_cost;
				if (change >= total) o_no_money = 1;
				else o_money = change;
				end
		endcase
	end //output_logic

endmodule