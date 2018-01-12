module builder(y, out);
	input [7:0] y;
	output [1:0]out;
	
	always (*)
	
	if (y > 8'd60 && y < 8'd80) begin
		out = 0;
	end else if (y >= 8'd80 && y < 8'd100)
		out = 1;
	end else begin
		out = 2;
	end
	end 
endmodule 


		
	