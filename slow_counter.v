`timescale 1ns / 1ns
module slow_counter(SW, HEX0, CLOCK_50);
	
	input [9:0] SW;
	input CLOCK_50;
	output [6:0] HEX0;
	wire [3:0] rate_out;
	rate_divider R1(.clock(CLOCK_50), .reset_n(SW[9]), .par_load(SW[3]), .enable(SW[2]), .select(SW[1:0]), .q(rate_out[3:0]));
	
	hexDisplay hex(.HEX_in(rate_out[3:0]), .HEX_out(HEX0[6:0]));
endmodule

//==========================================================================================================================================
// Rate divider module which connects the display counter with differtent outputs of the RDcounter.

module rate_divider(clock, reset_n, par_load, enable, select, q);
	wire [27:0] d;
	input [1:0] select;
	input clock, reset_n, par_load, enable;
	output [3:0] q;
	wire [27:0] w1, w2, w3;
	wire [3:0] w;
	assign q[3:0] = w[3:0]; 
	
	reg Out;
	
	RDcounter case2(.load({2'b00, 26'd4999999}), .clock(clock), .reset_n(reset_n), .enable(enable), .q(w1));
	RDcounter case3(.load({1'b0, 27'd99999999}), .clock(clock), .reset_n(reset_n), .enable(enable), .q(w2));
	RDcounter case4(.load({28'd199999999}), .clock(clock), .reset_n(reset_n), .enable(enable), .q(w3));
	
	display_counter disp_count(.enable(Out), .load(4'b000), .clock(clock), .par_load(par_load), .reset_n(reset_n),  .q(w[3:0]));  
	
	always @(*)
		begin
			case(select)
				2'b00: Out = enable;
				2'b01: Out = (w1 == 0) ? 1 :0;
				2'b10: Out = (w2 == 0) ? 1 :0;
				2'b11: Out = (w3 == 0) ? 1 :0;
				default: Out = 1'b1;
			endcase 

		end
endmodule

//================================================================================================================================
//Display counter

module display_counter(enable, load, par_load, clock, reset_n, q);
	input enable, clock, par_load, reset_n;
	input [3:0] load;
	output reg [3:0] q;
	
	always @(posedge clock, negedge reset_n)
	begin
		if (reset_n == 1'b0)
			q <= 4'b0000;
		else if (par_load == 1'b1)
			q <= load;
		else if (enable == 1'b1)
			begin
				if (q == 4'b1111)
					q <= 4'b0000;
				else
					q <= q + 1'b1;
			end
	end
endmodule

//========================================================
// Rate divider counter

module RDcounter(enable, load, clock, reset_n, q);
	input enable, clock, reset_n;
	input [27:0] load;
	output reg [27:0] q;
	
	always @(posedge clock)
	begin
		if (reset_n == 1'b0)
			q <= load;
		else if (enable == 1'b1)
			begin
				if (q == 0)
					q <= load;
				else
					q <= q - 1'b1;
			end
	end
endmodule


//=================================================================================================================
// HEX Display 
// ** Hex display code==========================================x=================================================x

module hexDisplay(HEX_in, HEX_out);
	
	input [3:0] HEX_in;
	output [6:0] HEX_out;
	
	segment0 ZERO(.c3(HEX_in[3]), .c2(HEX_in[2]), .c1(HEX_in[1]), .c0(HEX_in[0]), .x(HEX_out[0]));
	
	segment1 ONE(.c3(HEX_in[3]), .c2(HEX_in[2]), .c1(HEX_in[1]), .c0(HEX_in[0]), .x(HEX_out[1]));
	
	segment2 TWO(.c3(HEX_in[3]), .c2(HEX_in[2]), .c1(HEX_in[1]), .c0(HEX_in[0]), .x(HEX_out[2]));
	
	segment3 THREE(.c3(HEX_in[3]), .c2(HEX_in[2]), .c1(HEX_in[1]), .c0(HEX_in[0]), .x(HEX_out[3]));
	
	segment4 FOUR(.c3(HEX_in[3]), .c2(HEX_in[2]), .c1(HEX_in[1]), .c0(HEX_in[0]), .x(HEX_out[4]));
	
	segment5 FIVE(.c3(HEX_in[3]), .c2(HEX_in[2]), .c1(HEX_in[1]), .c0(HEX_in[0]), .x(HEX_out[5]));
	
	segment6 SIX(.c3(HEX_in[3]), .c2(HEX_in[2]), .c1(HEX_in[1]), .c0(HEX_in[0]), .x(HEX_out[6]));

endmodule

// ** Segments Code ========================x==============================x======================================
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