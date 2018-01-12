

module EnemyPath
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
		VGA_B, 
		HEX0, HEX1	//	VGA Blue[9:0]
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
	output	[9:0]	VGA_B;  
	output [6:0] HEX0, HEX1;	//	VGA Blue[9:0]
	
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [7:0] y;
	wire writeEn;
	wire enable,ld_c;

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
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		
		
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
		
		wire [7:0] enemy1_x, enemy1_y, enemy2_x, enemy2_y, enemy3_x, enemy3_y;
	   wire 	[2:0]	enemy1_c, enemy2_c, enemy3_c;
		wire [7:0] enemyx_out, enemyy_out;
		wire [2:0] enemyc_out;
		wire w05hz;
		wire [7:0] missed;
		
		
		collision c1(SW[1], CLOCK_50, ~KEY[0], SW[9], SW[3],SW[4], SW[5],enemy1_x, enemy1_y, enemy2_x, enemy2_y, enemy3_x, enemy3_y,
enemy1_c, enemy2_c, enemy3_c, missed);
		collision_to_vga c2(CLOCK_50, SW[9], 
							enemy1_x, enemy1_y, 
							enemy2_x, enemy2_y, 
							enemy3_x, enemy3_y,
							enemy1_c, enemy2_c, 
							enemy3_c,
							x, y,
							colour, writeEn);
		hex_decoder h0(missed[3:0], HEX0[6:0]);
		hex_decoder h1(missed[7:4], HEX1[6:0]);

    
endmodule

module collision_to_vga(clock, reset_n, enemy1_x, enemy1_y,
								enemy2_x, enemy2_y,
								enemy3_x, enemy3_y,
								enemy1_c, enemy2_c,
								enemy3_c, 
								enemy1_p, enemy2_p, enemy3_p,
								enemyx_out, enemyy_out,
								enemyc_out, enemyp_out);
		input clock, reset_n;					
		input [7:0] enemy1_x, enemy1_y, enemy2_x, enemy2_y, enemy3_x, enemy3_y;
		input [2:0]	enemy1_c, enemy2_c, enemy3_c;
		input enemy1_p, enemy2_p, enemy3_p;
		output reg [7:0] enemyx_out, enemyy_out;
		output reg [2:0] enemyc_out;
		output reg enemyp_out;
		wire [1:0] c1;
		
		counter m1(clock,reset_n,1'b1,c1);
		
		always @ (posedge clock)
		begin
			if (c1 == 0)
				begin 
				enemyx_out <= enemy1_x;
				enemyy_out <= enemy1_y;
				enemyc_out <= enemy1_c;
				enemyp_out <= enemy1_p;
				end
			else if (c1 == 1)
				begin 
				enemyx_out <= enemy2_x;
				enemyy_out <= enemy2_y;
				enemyc_out <= enemy2_c;
				enemyp_out <= enemy2_p;
				end
			else if (c1 == 2)
				begin 
				enemyx_out <= enemy3_x;
				enemyy_out <= enemy3_y;
				enemyc_out <= enemy3_c;
				enemyp_out <= enemy3_p;
				end
		end	
		
endmodule
								


/*
* Module to show how many boxes have been missed.
*/
module collision(go,enable,clock, load, reset_n, c1, c2,c3,
enemy1_x, enemy1_y, enemy2_x, enemy2_y, enemy3_x, enemy3_y,
enemy1_c, enemy2_c, enemy3_c, e1_plot, e2_plot, e3_plot, missed);
	input go,enable,clock, load, reset_n;
	input c1, c2, c3;
	
	output reg [7:0] enemy1_x, enemy1_y, enemy2_x, enemy2_y, enemy3_x, enemy3_y;
	output reg [2:0] enemy1_c, enemy2_c, enemy3_c;
	output reg e1_plot, e2_plot, e3_plot;
	output reg [7:0] missed;
	
	// 8-bit wires to get the enemy coordinates out
	wire [7:0] e1_x, e1_y, e2_x, e2_y, e3_x, e3_y;
	wire e1_p, e2_p, e3_p;
	wire [2:0] e1_c, e2_c, e3_c;
	
	
	// Checking if the enemy is out of bound if the y position of enemy is more than 120 pixels 
	// enemy will spawn again at the original position. 
	assign e1_out = (e1_y >= 8'd120) ? 1 : 0;
	Enemy enemy1(go,load,clock,e1_out,c1,100, 8'd40,e1_x,e1_y,e1_c,e1_p);
	assign e2_out = (e2_y >= 8'd120) ? 1 : 0;
	Enemy enemy2(go,load,clock,e2_out,c2,010,8'd70,e2_x,e2_y,e2_c,e2_p);
	assign e3_out = (e3_y >= 8'd120) ? 1 : 0;
	Enemy enemy3(go,load,clock,e3_out,c3,110,8'd130,e3_x,e3_y,e3_c,e3_p);
	
	// Store the values of all the parameters for enemies in the registers. 
	
	always @(posedge clock)
	begin
		enemy1_x <= e1_x;
		enemy2_x <= e2_x;
		enemy3_x <= e3_x;
		enemy1_y <= e1_y;
		enemy2_y <= e2_y;
		enemy3_y <= e3_y;
		enemy1_c <= e1_c;
		enemy2_c <= e2_c;
		enemy3_c <= e3_c;
		e1_plot <= e1_p;
		e2_plot <= e2_p;
		e3_plot <= e3_p;
		missed <=  missed + {7'd0, e1_y} +{7'd0, e2_y} + {7'd0, e3_y};
	end
		
	reg e1_collision, e2_collision, e3_collision;
	
//	always @ (posedge clock)
//		if ((enemy1_x +1 == enemy2_x) || (enemy2_x +1 == enemy1_x))
//			begin
//			e1_collision <= 1;
//			e2_collision <= 1;
//			end
//		if ((enemy1_x +1 == enemy3_x) || (enemy3_x +1 == enemy1_x))
//			begin
//			e1_collision <= 1;
//			e2_collision <= 1;
//			end
//		if ((enemy2_x +1 == enemy3_x) || (enemy2_x +1 == enemy3_x))
//			begin
//			e1_collision <= 1;
//			e2_collision <= 1;
//			end	
	
endmodule

///////////////////////////////////////////////////////////////////////////////////////////////

             ///////////////////////////////////////////////
				 ////////                              /////////
				 //////////////////////  /////////////////////////////////////////////
				 /////                                            ///////////////////////////
				 ////////               Enemy                       ////////////////// 
				 /////////                                  ////////////////
				 /////////////////////////////////////////////////
				 
// generates the enemy 

module Enemy(go,load,clock,reset_n, collision_sig, colour, x_input, X,Y,Colour_out, plot);
	input go,load,clock,reset_n, collision_sig;
	input [2:0] colour;
	input [7:0] x_input;
	output [7:0] X,Y;
	output [2:0] Colour_out;
	output plot;
	
	wire ld_c, enable_n;
	
	control m1(clock,reset_n,go,enable_n,ld_c,plot);
	datapath m2(load, enable_n, clock, ld_c, colour, reset_n, collision_sig, x_input, X,Y,Colour_out);

endmodule

module datapath(load,enable,clock,ld_c,colour,reset_n, collision_sig, x_input,
						X,Y,colour_out);
	input load,enable,clock,reset_n,ld_c, collision_sig;
	input [2:0] colour;
	input [7:0] x_input;
	output[7:0] X,Y;
	output[2:0] colour_out;
	
	
	
	wire[19:0] c0;
	wire[3:0] c1;
	wire signal_x,signal_y;
	wire[7:0] x_in,y_in;
	wire[2:0] colour_1;
	
//	delay_counter m1(load,clock,reset_n,enable,c0);
//	assign enable_1 = (c0 ==  20'b11001110111001100001) ? 1 : 0;
	frame_counter m2(load,clock,reset_n,enable,c1);
	assign enable_2 = (c1 == 4'b1111) ? 1 : 0;
	h_register m6(clock,reset_n,x_in, collision_sig, signal_x);
	assign colour_1 = (c1 == 4'b1111) ? 3'b000 : colour;
	x_counter m3(load,clock,reset_n,enable_2,signal_x,x_input,x_in);
	y_counter m4(load,clock,reset_n,enable_2,y_in);
	
	draw1x1 m7(load,x_in,y_in,colour_1,ld_c,clock,reset_n,enable,X,Y,colour_out);
	
endmodule


module counter(clock,reset_n,enable,q);
	input clock,reset_n,enable;
	output reg [1:0] q;
	
	always @(posedge clock)
	begin
		if(reset_n)
			q <= 2'b00;
		else if(enable == 1'b1)
		begin
		  if(q == 2'b11)
			  q <= 2'b00;
		  else
			  q <= q + 1'b1;
		end
   end
endmodule

module rate_counter(clock,reset_n,enable,q);
		input clock;
		input reset_n;
		input enable;
		output reg [1:0] q;
		
		always @(posedge clock)
		begin
			if(reset_n)
				q <= 2'b11;
			else if(enable ==1'b1)
			begin
			   if ( q == 2'b00 )
					q <= 2'b11;
				else
					q <= q - 1'b1;
			end
		end
endmodule	




module delay_counter(load,clock,reset_n,enable,q);
		input clock;
		input reset_n;
		input enable;
		input load;
		output reg [19:0] q;
		
		always @(posedge clock)
		begin
			if(reset_n)
				q <= 20'd0;
			else if(load)
				q <= 20'd0;
			else if(enable ==1'b1)
			begin
			   if ( q == 20'b11001110111001100001 )
					q <= 20'd0;
				else
					q <= q + 1'b1;
			end
		end
endmodule


module frame_counter(load,clock,reset_n,enable,q);
	input load,clock,reset_n,enable;
	output reg [3:0] q;
	
	always @(posedge clock)
	begin
		if(reset_n)
			q <= 4'b0000;
		else if (load) 
			q <= 4'b0;
		else if(enable == 1'b1)
		begin
		  if(q == 4'b1111)
			  q <= 4'b0000;
		  else
			  q <= q + 1'b1;
		end
   end
endmodule

/*
*A y_counter which increases the y co-ordinate of the object everytime. 
*
*/

module y_counter(load,clock,reset_n,enable,q);
	input load,clock,enable,reset_n;
	output reg[7:0] q;
	
	always@(posedge clock)
	begin
		if(reset_n)
		q <= 8'b00111100;
		else if (load) // used once at start
		q <= 8'b00111100;
	    else if (enable)
		q <= q + 1'b1;	
	end
	
endmodule

/*
* x_counter increases the x coordinate of the object at negedge of the clock.
* Value of x increases or decreases with the direction signal. 
*/

module x_counter(load,clock,reset_n,enable,direction, x_in, q);
	input load,clock,reset_n,enable,direction;
	input [7:0] x_in;
	output reg[7:0] q;
	
	always@(posedge clock)
	begin
			if(reset_n)
			q <= 8'd40;
			
			else if (load) // used once at start
				q <= x_in;
			
	   	else if (enable) begin
				if(direction == 1'b1)
					q <= q + 1'b1;
				else
					q <= q - 1'b1;
			end
	end
	
	
endmodule

/*
* A register to trace the direction of the objects in the x direction.
* If x = 159 it sets direction to 0. If x = 0  it sets direction to 1. 
*/

module h_register(clock, reset_n, x, collision_sig, direction);
	input clock,reset_n, collision_sig;
	input [7:0] x;
	output reg direction;
	
	always@(posedge clock)
	begin
		if(reset_n)
			direction <= 1'b1;
		else begin
			if(direction == 1'b1) begin
				if(x + 1 > 8'b10011111)
					direction <= 1'b0;
				else
					direction <= 1'b1;
					
				if (collision_sig)  // if the external signal of collision comes then reverses the direction.
					direction <= 1'b0;
			end else begin
				if(x == 8'b00000000)
					direction <= 1'b1;
				else
					direction <= 1'b0;
					
				if (collision_sig)  // if the external signal of collision comes then reverses the direction.
					direction <= 1'b1;
			end
		end
	end
endmodule

module draw1x1(load,x,y,colour,ld_c,clock,reset_n,enable,X,Y,Colour);
	input load,reset_n,enable,clock,ld_c;
	input [7:0] x,y;
	input [2:0] colour;
	output[7:0] X;
	output [7:0] Y;
	output [2:0] Colour;
	reg [7:0] x1,y1,co1;
	
	wire [1:0] c1,c2,c3;
	
	always @ (posedge clock) begin
        if (reset_n) begin
            x1 <= 8'd40; 
            y1 <= 8'd60;
				co1 <= 3'b0;
        end
		  else if (load) 
				co1 <= colour;
        else begin
                x1 <= x;
                y1 <= y;
				if(ld_c == 1)
					co1 <= colour;
        end
    end
//	counter m1(clock,reset_n,enable,c1);
//	rate_counter m2(clock,reset_n,enable,c2);
//	assign enable_1 = (c2 == 2'b00) ? 1 : 0;
//	counter m3(clock,reset_n,enable_1,c3);
	assign X = x1 ;
	assign Y = y1 ;
	assign Colour = co1;
endmodule


module control(clock,reset_n,go,enable,ld_c,plot);
	input clock,reset_n,go;
	output reg enable,ld_c,plot;	
	
	reg [3:0] current_state, next_state;
	
	localparam  S_LOAD_C       = 4'd0,
                S_LOAD_C_WAIT   = 4'd1,
					 S_CYCLE_0        = 4'd2;
	
	always@(*)
      begin: state_table 
            case (current_state)
                S_LOAD_C: next_state = go ? S_LOAD_C_WAIT : S_LOAD_C; 
                S_LOAD_C_WAIT: next_state = go ? S_LOAD_C_WAIT : S_CYCLE_0;  
                S_CYCLE_0: next_state = S_CYCLE_0;
            default:     next_state = S_LOAD_C;
        endcase
      end 
   
	always @ (*)
      begin: enable_signals
        // By default make all our signals 0
        ld_c = 1'b0;
		  enable = 1'b0;
		  plot = 1'b0;
		  
		  case(current_state)
				S_LOAD_C:begin
					end
				S_CYCLE_0:begin
				   ld_c = 1'b1;
					enable = 1'b1;
					plot = 1'b1;
					end
		  endcase
    end
	 
	 always@(posedge clock)
      begin: state_FFs
        if(reset_n)
            current_state <= S_LOAD_C;
        else
            current_state <= next_state;
      end 
endmodule

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule
