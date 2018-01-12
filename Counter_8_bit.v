//=====================================================
// Implemnting the top module to connect the counter to the FPGA board. ]

module Counter_8_bit(SW, KEY, HEX0, HEX1);
	input [9:0] SW;
	input [3:0] KEY;
	output [6:0] HEX0, HEX1;
	wire [7:0] out; //A wire that used as counter's output and connects the output to the HEX0 and HEX1
	
	counter c1(.enable(SW[1]), .clock(KEY[0]), .clear_b(SW[0]), .Q(out[7:0])); // Instanciating the counter
	hexDisplay hex0(.HEX_in(out[3:0]), .HEX_out(HEX0[6:0])); // Connecting the lower four bits to the HEX0
	hexDisplay hex1(.HEX_in(out[7:4]), .HEX_out(HEX1[6:0])); // Connecting the upper four bits to the HEX1
	
endmodule 
	

//======================================================
// Implementing the counter

module counter(enable, clock, clear_b, Q);
	input enable, clock, clear_b;
	output [7:0] Q;
	
	t_flipflop t1(.t(enable), .clock(clock), .clear_b(clear_b), .q(Q[0]));
	t_flipflop t2(.t(enable & Q[0]), .clock(clock), .clear_b(clear_b), .q(Q[1]));
	t_flipflop t3(.t(enable & Q[0] & Q[1]), .clock(clock), .clear_b(clear_b), .q(Q[2]));
	t_flipflop t4(.t(enable & Q[0] & Q[1] & Q[2]), .clock(clock), .clear_b(clear_b), .q(Q[3]));
	t_flipflop t5(.t(enable & Q[0] & Q[1] & Q[2] & Q[3]), .clock(clock), .clear_b(clear_b), .q(Q[4]));
	t_flipflop t6(.t(enable & Q[0] & Q[1] & Q[2] & Q[3] & Q[4]), .clock(clock), .clear_b(clear_b), .q(Q[5]));
	t_flipflop t7(.t(enable & Q[0] & Q[1] & Q[2] & Q[3] & Q[4] & Q[5]), .clock(clock), .clear_b(clear_b), .q(Q[6]));
	t_flipflop t8(.t(enable & Q[0] & Q[1] & Q[2] & Q[3] & Q[4] & Q[5] & Q[6]), .clock(clock), .clear_b(clear_b), .q(Q[7]));
	
endmodule 

//======================================================
//Implementing a t_flipflop

module t_flipflop(t, clock, clear_b, q);
		input t; // Data input fr the given register
		input clock; //Clock signal
		input clear_b; //to reset the register 
		output q; // output of the register. 
		
		reg q;
		
		always @(posedge clock, negedge clear_b)
		
		begin
			if (clear_b == 1'b0)
				q <= 0;
			else if (t)
				q <= ~q;
		end
endmodule 

//========================================================
// HEX Display 

// Hex display code==========================================x=====================================x
module hexDisplay(HEX_in, HEX_out);
	input [3:0] HEX_in;
	output [6:0] HEX_out;
	
	segment0 ZERO(
		.c3(HEX_in[3]),
		.c2(HEX_in[2]),
		.c1(HEX_in[1]),
		.c0(HEX_in[0]),
		.x(HEX_out[0])
	);
	
	segment1 ONE(
		.c3(HEX_in[3]),
		.c2(HEX_in[2]),
		.c1(HEX_in[1]),
		.c0(HEX_in[0]),
		.x(HEX_out[1])
	);
	
	segment2 TWO(
		.c3(HEX_in[3]),
		.c2(HEX_in[2]),
		.c1(HEX_in[1]),
		.c0(HEX_in[0]),
		.x(HEX_out[2])
	);
	
	segment3 THREE(
		.c3(HEX_in[3]),
		.c2(HEX_in[2]),
		.c1(HEX_in[1]),
		.c0(HEX_in[0]),
		.x(HEX_out[3])
	);
	
	segment4 FOUR(
		.c3(HEX_in[3]),
		.c2(HEX_in[2]),
		.c1(HEX_in[1]),
		.c0(HEX_in[0]),
		.x(HEX_out[4])
	);
	
	segment5 FIVE(
		.c3(HEX_in[3]),
		.c2(HEX_in[2]),
		.c1(HEX_in[1]),
		.c0(HEX_in[0]),
		.x(HEX_out[5])
	);
	
	segment6 SIX(
		.c3(HEX_in[3]),
		.c2(HEX_in[2]),
		.c1(HEX_in[1]),
		.c0(HEX_in[0]),
		.x(HEX_out[6])
	);
endmodule

// Segments Code ========================x==============================x======================================
module segment0(c3, c2, c1, c0, x);
	input c3;
	input c2;
	input c1;
	input c0;
	output x;
	assign x = ~((c3 | c2 | c1 | ~c0) & (c3 | ~c2 | c1 | c0) & (~c3 | ~c2 | c1 | ~c0) & (~c3 | c2 | ~c1 | ~c0));
endmodule

module segment1(c3, c2, c1, c0, x);
	input c3;
	input c2;
	input c1;
	input c0;
	output x;
	assign x = ~((~c1 | ~c0 | ~c3) & (~c1 | c0 | ~c2) & (c1 | c0 | ~c3 | ~c2) & (c1 | ~c0 | c3 | ~c2));
endmodule

module segment2(c3, c2, c1, c0, x);
	input c3;
	input c2;
	input c1;
	input c0;
	output x;
	assign x = ~((~c3 | ~c2 | c1 | c0) & (~c1 | ~c3 | ~c2) & (c3 | c2 | ~c1 | c0));
endmodule

module segment3(c3, c2, c1, c0, x);
	input c3;
	input c2;
	input c1;
	input c0;
	output x;
	assign x = ~((c3 | ~c2 | c1 | c0) & (c2 | c1 | ~c0) & (~c2 | ~c1 | ~c0) & (~c3 | c2 | ~c1 | c0));
endmodule

module segment4(c3, c2, c1, c0, x);
	input c3;
	input c2;
	input c1;
	input c0;
	output x;
	assign x = ~((c1 | c0 | c3 | ~c2) & (c2 | c1 | ~c0) & (~c0 | c3));
endmodule

module segment5(c3, c2, c1, c0, x);
	input c3;
	input c2;
	input c1;
	input c0;
	output x;
	assign x = ~((~c0 | c3 | c2) & (c3 | ~c1 | ~c0) & (~c1 | c3 | c2) & (c1 | ~c0 | ~c3 | ~c2));
endmodule

module segment6(c3, c2, c1, c0, x);
	input c3;
	input c2;
	input c1;
	input c0;
	output x;
	assign x = ~((~c3 | ~c2 | c1 | c0) & (c1 | c3 | c2) & (~c1 | ~c0 | c3 | ~c2));
endmodule

//============================x===========================================x=========================================x
// END of the module. 