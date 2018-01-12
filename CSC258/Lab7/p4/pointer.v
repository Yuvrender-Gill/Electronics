

module pointer(left, right, up, down, clock, reset_n, X, Y, colour_out);
	input left, right, up, down; // Direction input signals. 
	input clock,reset_n; // Default circuit conrollers. 
	output[7:0] X,Y; // output coordinate
	output[2:0] colour_out; // output color. 
	
	
	wire[19:0] c0;
	wire[3:0] c1;
	
	wire[7:0] x_in,y_in,x_out, y_out;
	wire[2:0] color_out;
	
	delay_counter m1(clock,reset_n,enable,c0);
	assign enable_1 = (c0 ==  20'd0) ? 1 : 0;
	frame_counter m2(clock,reset_n,enable_1,c1);
	assign enable_2 = (c1 == 4'b1111) ? 1 : 0;
	
	// Controller to defing the states of the position and color of the pointer. 
	// Running the fsm with the slow clock to sync with vga drawing rate. 
	control cont(left, right, up, down, go, clock, reset_n, x_in, y_in, x_out, y_out, color_out);
	
	// Assigning the outputs
	reg [7:0] store_x = x_out;
	reg [7:0] store_y = y_out;
	assign X = store_x;
	assign Y = store_y;
	assign colour_out = color_out;
	
endmodule

/*
* Control path which draws thered box then makes it black and then  changes coordinates of pointer with direction signal.
* Then draws the new box. 
*/
module control(left, right, up, down, go, clock, reset_n,x_in, y_in, x, y, color);
	input clock,reset_n, go; //Defaults for fsm
	input left, right, up, down; // direction controls
	input [7:0] x_in, y_in;
	output reg [7:0] x, y;
	output reg [2:0] color;	
	
	reg [3:0] current_state, next_state;
	
	localparam  DRAW_COLOR_BOX       = 4'd0,
               DRAW_BLACK_BOX       = 4'd1,
					CHANGE_DIR           = 4'd2;
	
	always @(*)
      begin: state_table 
            case (current_state)
                DRAW_COLOR_BOX: next_state = go ? DRAW_BLACK_BOX : DRAW_COLOR_BOX; 
					 DRAW_BLACK_BOX: next_state = go ? CHANGE_DIR : DRAW_BLACK_BOX;
                CHANGE_DIR: next_state = DRAW_COLOR_BOX;
					 default:    next_state = DRAW_COLOR_BOX;
				endcase
      end 
		
	always @ (*)
   begin: enable_signals
        // By default make all our signals 
        x = 8'd100;
		  y = 8'd100;
		  color = 100;
		  
		  case(current_state)
				DRAW_COLOR_BOX:begin // Draws red box at the given x and y
					x = x_in;
					y = y_in;
					color = 100;
					end
				DRAW_BLACK_BOX:begin // Draws black box at the given x and y
				   x = x_in;
					y = y_in;
					color = 000;
					end
				CHANGE_DIR:begin // Changes the coordinates of the box according to the given direction signal.
					if (left)
						x = x_in - 1;
					if (right)
						x = x_in + 1;
						
					if (up)
						y = y_in + 1;
						
					if (down)
						y = y_in - 1;
					
					end
		  endcase
    end
	 
	 always@(posedge clock)
      begin: state_FFs
        if(reset_n)
            current_state <= DRAW_COLOR_BOX;
        else
            current_state <= next_state;
      end 
		
endmodule 

/*
* Slows down the clock rate to per second. 
*/
module delay_counter(clock,reset_n,enable,q);
		input clock;
		input reset_n;
		input enable;
		output reg [19:0] q;
		
		always @(posedge clock)
		begin
			if(reset_n == 1'b0)
				q <= 20'b11001110111001100001;
			else if(enable ==1'b1)
			begin
			   if ( q == 20'd0 )
					q <= 20'b11001110111001100001;
				else
					q <= q - 1'b1;
			end
		end
endmodule

/*
* Slows the rate to fit the frame cycle. 
*/
module frame_counter(clock,reset_n,enable,q);
	input clock,reset_n,enable;
	output reg [3:0] q;
	
	always @(posedge clock)
	begin
		if(reset_n == 1'b0)
			q <= 4'b0000;
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
* Draws 1by 1 box. 
*/
module draw1x1(x,y,colour, clock, reset_n,enable, X, Y,Colour);
	input reset_n,enable,clock;
	input [7:0] x,y;
	input [2:0] colour;
	output[7:0] X, Y;
	output [2:0] Colour;
	reg [7:0] x1,y1;
	reg [2:0] co1;
	
	wire [1:0] c1,c2,c3;
	
	always @ (posedge clock) begin
        if (reset_n) begin
            x1 <= 7'b100; 
            y1 <= 7'd100;
				co1 <= 3'b100;
        end
        else begin
                x1 <= x;
                y1 <= y;
					 co1 <= colour;
        end
    end
	assign X = x1 ;
	assign Y = y1 ;
	assign Colour = co1;
endmodule