// Verilog code for a 7-to-1 Multiplexer using always block and if statements. 

module mux(SW, LEDR);
	input [9:0]SW;
	output [1:0]LEDR;
	
	reg Out;
	
	always @(*)   // decalring the always block
	begin
		case (SW[9:7])  // Selects assigned to switches 9 to 7
			3'b000: Out = SW[0]; // Case 0
			3'b001: Out = SW[1];	// Case 1
			3'b010: Out = SW[2]; // Case 2
			3'b011: Out = SW[3]; // Case 3
			3'b100: Out = SW[4]; // Case 4
			3'b101: Out = SW[5]; // Case 5
			3'b110: Out = SW[6]; // Case 6
			default: Out = SW[7];
		endcase
	end
	assign LEDR[0] = Out;

endmodule 
		