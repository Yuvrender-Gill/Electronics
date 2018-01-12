// Part 2 skeleton

module VGA
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
	 
	 wire ldx, ldy, ldc;
    // Instansiate datapath
	datapath d0(.clk(CLOCK_50),
					.resetn(resetn),
					.ld_x(ldx),
					.ld_y(ldy),
					.ld_c(ldc),
					.coordinate_in(SW[6:0]),
					.color_in(SW[9:7]),
					.x_out(x),
					.y_out(y),
					.color_out(colour));

    // Instansiate FSM control
   control c0(.clk(CLOCK_50),
				.resetn(resetn),
				.go(KEY[3]),
				.draw(KEY[1]),
				.ld_x(ldx),
				.ld_y(ldy),
				.ld_c(ldc),
				.writeEn(writeEn));
    
endmodule

//====================================================================================================
// Control Path

module control(
    input clk,
    input resetn,
    input go, draw,

    output reg  ld_x, ld_y, ld_c, writeEn
    );

    reg [2:0] current_state, next_state; 
    
    localparam  S_LOAD_X        = 3'd0,
                S_LOAD_X_WAIT   = 3'd1,
                S_LOAD_Y_C      = 3'd2,
                S_LOAD_Y_C_WAIT = 3'd3,
                S_CYCLE_0       = 3'd4;
             
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X;
                S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT : S_LOAD_Y_C;
                S_LOAD_Y_C: next_state = draw ? S_LOAD_Y_C_WAIT : S_LOAD_Y_C;
                S_LOAD_Y_C_WAIT: next_state = draw ? S_LOAD_Y_C_WAIT : S_CYCLE_0;
                S_CYCLE_0: next_state = S_LOAD_X; 
            default:     next_state = S_LOAD_X;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_x = 1'b0;
        ld_y = 1'b0;
        ld_c = 1'b0;
		  
        case (current_state)
            S_LOAD_X: begin
                ld_x = 1'b1;
					 writeEn = 1'b0;
                end
            S_LOAD_Y_C: begin
                ld_y = 1'b1;
					 ld_c = 1'b1;
					 writeEn = 1'b0;
                end
            S_CYCLE_0: begin
					writeEn = 1'b1;
					end
        endcase
    end 
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD_X;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

//====================================================================================================================================
// Data Path

module datapath(
    input clk, resetn, ld_x, ld_y, ld_c,
    input [6:0] coordinate_in,
	 input [2:0] color_in,

    output [7:0] x_out,
	 output [6:0] y_out,
	 output [2:0] color_out
    );
	 
	 reg [7:0] x ;
	 reg [6:0] y ;
	 reg [2:0] color;
    
    // Registers x, y, color with respective input logic
    always @ (posedge clk) begin
		  if (!resetn) begin
            x <= 8'd0; 
            y <= 7'd0; 
            color <= 3'd0; 
        end
        else begin
            if (ld_x)
                x <= {1'b0, coordinate_in}; 
            if (ld_y)
                y <= coordinate_in; 
            if (ld_c)
                color <= color_in;
        end
    end
	 
	 wire [1:0] Q1, Q2;
	 
	 counter_2_bit c1(clk, 2'b11, resetn, Q1);
	 counter_2_bit c2(clk, Q1, resetn, Q2);
	 assign x_out = x + Q1;
	 assign y_out = y + Q2;
	 assign color_out = color;
    
endmodule

module counter_2_bit(clk, enable, resetn, Q);
	input clk, resetn;
	input [1:0] enable;
	output reg [1:0] Q = 0;
	always @ (posedge clk) begin
		  if (!resetn) begin
            Q <= 0;
        end else if (enable == 2'b11) begin
				Q <= Q + 1;
				end
		  else begin
		  Q <= Q;
		  end
	end
endmodule



