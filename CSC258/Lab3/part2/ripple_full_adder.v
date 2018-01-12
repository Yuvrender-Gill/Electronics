// A 4-bit ripple full adder implementation

module ripple_full_adder(SW, LEDR);
	input [9:0] SW;
	output [9:0] LEDR;
	
	wire connection_1; // Connectes FA0 to FA1
	wire connection_2; // Connectes FA1 to FA2
	wire connection_3; // Connectes FA2 to FA3
	
	// Instanciating the full adders to get the ripple adder
	
	// Instanciating FA0
	full_adder FA0(
					.A(SW[0]),
					.B(SW[4]),
					.cin(SW[8]),
					.S(LEDR[0]),
					.cout(connection_1)
					); 
					
	// Instanciating FA1
	full_adder FA1(
					.A(SW[1]),
					.B(SW[5]),
					.cin(connection_1),
					.S(LEDR[1]),
					.cout(connection_2)
					);
					
	// Instanciating FA2	
	full_adder FA2(
					.A(SW[2]),
					.B(SW[6]),
					.cin(connection_2),
					.S(LEDR[2]),
					.cout(connection_3)
					);
					
	// Instanciating FA3				
	full_adder FA3(
					.A(SW[3]),
					.B(SW[7]),
					.cin(connection_3),
					.S(LEDR[3]),
					.cout(LEDR[4])
					);
					
endmodule

// A full adder gate implementation  
module full_adder(A, B, cin, S, cout);
	input A;
	input B;
	input cin;
	output S;
	output cout;
	
	
	assign S = A ^ B ^ cin;
	// Using basic gates 
	// S = ((~A) & B & (~cin)) | (A & (~B) & (~cin)) | ((~A) & (~B) & cin) | (A & B & cin);
	assign cout = (A & B) | (B & cin) | (A & cin);

endmodule 
	