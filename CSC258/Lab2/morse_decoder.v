module alphabet_select(select, Out);
	input [2:0] select;
	output Out;
	
	reg Out;
	
	always @(*)
		begin
			case(select)
			3'b000: Out = 
			3'b001: Out = 
			3'b010: Out =
			3'b011: Out = 
			3'b100: Out =
			3'b101: Out = 
			3'b110: Out = 
			3'b111: Out = 
			endcase
		end
endmodule 