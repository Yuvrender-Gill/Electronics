// ALU to DE1 interface module

module aluregister(SW, KEY, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	input [9:0] SW;
	input [2:0] KEY;
	output [9:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	wire [7:0] AL; // wire to handle the alu outputs 
	wire [7:0] REG_out; // wire to handle the reguster's output.
	
	alu_i A1(
				.A(SW[3:0]),
				.B(REG_out[3:0]),
				.functions(SW[7:5]),
				.ALUout(LEDR[7:0])
				);
	
	alu_i A2(
				.A(SW[3:0]),
				.B(REG_out[3:0]),
				.functions(SW[7:5]),
				.ALUout(AL[7:0])
				);
	
	hexDisplay hex0(
		.HEX_in(SW[3:0]),
		.HEX_out(HEX0 [6:0])
	);	
	hexDisplay hex4(
		.HEX_in(REG_out[3:0]),
		.HEX_out(HEX4 [6:0])
	);
	hexDisplay hex5(
		.HEX_in(REG_out[7:4]),
		.HEX_out(HEX5 [6:0])
	);
	register R1(
					.d(AL[7:0]),
					.clock(KEY[0]),
					.reset_n(SW[9]),
					.q(REG_out[7:0])
					);
	
endmodule

// Implementing Register
module register(d, clock, reset_n, q);
		input [7:0] d; // Data input fr the given register
		input clock; //Clock signal
		input reset_n; //to reset the register 
		output [7:0] q; // output of the register. 
		reg [7:0] q;
		always @(posedge clock)
		
		begin
			if (reset_n == 1'b0)
				q <= 8'b00000000;
				
			else
			
				q <= d;
		end
endmodule 


// Implementing ALU
module alu_i(A, B, functions, ALUout);
	input [3:0] A;
	input [3:0] B;
	input  [2:0] functions;
	output [7:0] ALUout;
	wire carry_out_1, carry_out_2; // A wire to handle the carry in ALUout 
	wire [3:0] sum_out_1, sum_out_2; // Sum out from the riplle adder after inputing A and B
	
	reg [7:0] Out; // Out is a 8-bit output 
	
	always @(*)
	begin
		case (functions)
			3'b000: Out = {3'b000, carry_out_2, sum_out_2}; // Function 0
			3'b001: Out = {3'b000, carry_out_1, sum_out_1}; // Function 1
			3'b010: Out = {4'b0000, A + B}; // Function 2
			3'b011: Out = {A | B, A ^ B}; // Function 3
			3'b100: Out = (A | B != 4'b0000) ? 8'b0000_0001 : 8'b0000_0000; // Function 4
			3'b101: Out = B << A; // Function 5
			3'b110: Out = A >> B; //Function 6
			3'b111: Out = A * B; //Function 7
			default: Out = 8'b0000_0000;
		endcase
	end
	
	// Ripple full adder for function1
	ripple_full_adder RFA1(
								.R_in1(A),
								.R_in2(B),
								.Cin(1'b0),
								.Cout(carry_out_1),
								.S_out(sum_out_1)
								);
	
	// Ripple full adder for function0							
	ripple_full_adder RFA0(
								.R_in1(A),
								.R_in2(4'b0001),
								.Cin(1'b0),
								.Cout(carry_out_2),
								.S_out(sum_out_2)
								);
								

	assign ALUout[7:0] = Out; 

endmodule

	
//===============================================================================
// A 4-bit ripple full adder implementation

module ripple_full_adder(R_in1, R_in2, Cin, S_out, Cout);
	input [3:0] R_in1, R_in2;
	input Cin;
	output [3:0] S_out;
	output Cout;
	
	wire connection_1; // Connectes FA0 to FA1
	wire connection_2; // Connectes FA1 to FA2
	wire connection_3; // Connectes FA2 to FA3
	
	// Instanciating the full adders to get the ripple adder
	
	// Instanciating FA0
	full_adder FA0(
					.A_adder(R_in1[0]),
					.B_adder(R_in2[0]),
					.cin(Cin),  // R_in[8] is the carry in
					.S_adder(S_out[0]),
					.cout(connection_1)
					); 
					
	// Instanciating FA1
	full_adder FA1(
					.A_adder(R_in1[1]),
					.B_adder(R_in2[1]),
					.cin(connection_1),
					.S_adder(S_out[1]),
					.cout(connection_2)
					);
					
	// Instanciating FA2	
	full_adder FA2(
					.A_adder(R_in1[2]),
					.B_adder(R_in2[2]),
					.cin(connection_2),
					.S_adder(S_out[2]),
					.cout(connection_3)
					);
					
	// Instanciating FA3				
	full_adder FA3(
					.A_adder(R_in1[3]),
					.B_adder(R_in2[3]),
					.cin(connection_3),
					.S_adder(S_out[3]),
					.cout(Cout)
					);
					
endmodule

// A full adder implementation  
module full_adder(A_adder, B_adder, cin, S_adder, cout);
	input A_adder;
	input B_adder;
	input cin;
	output S_adder;
	output cout;
	
	
	assign S_adder = A_adder ^ B_adder ^ cin;
	// Using basic gates 
	// S = ((~A) & B & (~cin)) | (A & (~B) & (~cin)) | ((~A) & (~B) & cin) | (A & B & cin);
	assign cout = (A_adder & B_adder) | (B_adder & cin) | (A_adder & cin);

endmodule 

// =================================================================================================

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
	