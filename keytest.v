/*
* A module to test the KEyboard
*/

module keytest(SW, KEY, CLOCK_50, LEDR, PS2_DAT, PS2_CLK);

	input [9:0] SW;
	input [3:0] KEY;
	input CLOCK_50, PS2_CLK, PS2_DAT;
	output [9:0] LEDR;
	
	
	wire Read;
	wire Scan_ready;
	wire [7:0] Scan_code;
	reg [7:0] scan_history [1:4];
	
	always @(posedge Scan_ready)
	begin
		scan_history[2] <= scan_history[1];
		scan_history[1] <= Scan_code;
	end
	
	
	
	keyboard(.keyboard_clk(PS2_CLK), 
				.keyboard_data(PS2_DAT),
				.clock50(CLOCK_50),
				.reset(0),
				.read(Read),
				.scan_ready(Scan_ready),
				.scan_code(Scan_code));
	oneshot(.pulse_out(Read),
			  .trigger_in(Scan_ready),
			  .clk(CLOCK_50));
			  
	assign LEDR[0] = ((scan_history[1] == 'h1d) && (scan_history[2][7:4] != 'hF));
	assign LEDR[1] = ((scan_history[1] == 'h1b) && (scan_history[2][7:4] != 'hF));

endmodule 