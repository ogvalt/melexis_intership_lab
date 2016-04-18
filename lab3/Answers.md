Question 3.1

	Behavior of will be the same. 
	rst_counter is synchronous flip-flop that change its value 
	after changing state of FSM.  
	rst_counter_next is a wire that drives synchronous flip-flop and change its value simultaneously
	with changing the state FSM.
	Perhaps, there will be some difference in pre-synthesis simulation in different simulators.

Question 3.2

	In pdf
	
Question 3.3

	Because there are no additional decoding/encoding logic that provides signal delay
	
Question 3.4
	
	It's provide safety from glitches and signals race in the FSM output ports.
	
Question 3.5

	We use full_case directive if we sure that there will no more combinations of inputs instead
	of that we are listed in case expression. Its provides scheme with less hardware costs.
	We use parallel_case directive if we sure that case items are mutualy exclusive. Without this directive priority
	logic will be synthesized. So its also provide scheme with less hardware costs.

	
	
