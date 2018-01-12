 module enemy_delay_2_seconds(delay_clock, CLOCK_50);
 output reg  delay_clock;
 input CLOCK_50;
 reg [26:0] counting; 
 always @(posedge CLOCK_50) 
 begin
  if(counting == 27'd100_000_000) 
   begin
    counting<=27'd0;
    delay_clock<=delay_clock+1; 
   end
   
  else 
   begin
    counting<=counting+1; 
    delay_clock <=1'b0;   
   end
 end
endmodule
 
 
 module clock_delay(delay_clock, CLOCK_50); //generates random numbers each clock cycle
 output reg  delay_clock;
 input CLOCK_50;
 reg [26:0] counting; 
 
 always @(posedge CLOCK_50) 
 begin
  if(counting == 27'd100_000_000) 
  begin
   counting<=27'd0;
   delay_clock<=delay_clock+1; 
  end
   
  else 
   begin
    counting<=counting+1; 
    delay_clock <=1'b0;    
   end
 end
endmodule
 
  module one_second_clock(delay_clock, CLOCK_50); //clock for enemy movement
 output reg  delay_clock;
 input CLOCK_50;
 reg [26:0] counting; 
 
 always @(posedge CLOCK_50) 
 begin
  if(counting == 27'd500000) 
  begin
   counting<=27'd0;
   delay_clock<=delay_clock+1; 
  end
   
  else 
   begin
    counting<=counting+1; 
    delay_clock <=1'b0;    
   end
 end
endmodule
 
 
module random_number( //making random numbers
  CLOCK_50,
  reset_,
  rand_out
);
 input CLOCK_50;
 //input [17:0] SW;
 //output[17:11] LEDR;
 input reset_;
 output [6:0]rand_out;
 
 wire enemy_delay;
 clock_delay delay(enemy_delay,CLOCK_50);
 
 wire clk;
 wire rst_n;
 reg [6:0]data;
 
 assign clk = enemy_delay;
 assign rst_n = reset_;
 assign rand_out[6:0] = data[6:0];
 wire feedback = data[4] ^ data[1] ;
 always @(posedge clk or negedge rst_n)
 if (~rst_n) 
  data <= 6'h3f;
 else
  data <= {data[5:0], feedback} ;
endmodule
 
module new_clock_delay(delay_clock, CLOCK_50); //for movement of the spaceship
 output reg  delay_clock;
 input CLOCK_50;
 reg [25:0] counting; 
 always @(posedge CLOCK_50) 
 begin
  if(counting == 26'd773370)
   begin
    counting<=26'd0;
    delay_clock<=delay_clock+1; 
   end
   
  else 
   begin
    counting<=counting+1; 
    delay_clock <=1'b0;    
   end
 end
endmodule
module ship_animation
 (
  CLOCK_50,      // On Board 50 MHz
  KEY,       // Push Button[3:0]
  SW,        // DPDT Switch[17:0]
  VGA_CLK,         // VGA Clock
  VGA_HS,       // VGA H_SYNC
  VGA_VS,       // VGA V_SYNC
  VGA_BLANK,      // VGA BLANK
  VGA_SYNC,      // VGA SYNC
  VGA_R,         // VGA Red[9:0]
  VGA_G,        // VGA Green[9:0]
  VGA_B,        // VGA Blue[9:0]
  LEDG,
  LEDR
  
 );
 input   CLOCK_50;    // 50 MHz
 input [3:0] KEY;     // Button[3:0]
 input [17:0]SW;      // Switches[17:0]
 output   VGA_CLK;       // VGA Clock
 output   VGA_HS;     // VGA H_SYNC
 output   VGA_VS;     // VGA V_SYNC
 output   VGA_BLANK;    // VGA BLANK
 output   VGA_SYNC;    // VGA SYNC
 output [9:0] VGA_R;       // VGA Red[9:0]
 output [9:0] VGA_G;      // VGA Green[9:0]
 output [9:0] VGA_B;       // VGA Blue[9:0]
 output [8:0] LEDG;
 output [17:0] LEDR;
 
 
 wire [7:0] x;
 wire [6:0] y;
 
 wire [7:0]x_plot;
 wire [6:0]y_plot;
 
//-----------------------------------------------------------------------------------------------------NEW FOR SHOOTING declarations start
 wire [7:0] shoot_x_plot;
 wire [6:0] shoot_y_plot;
 
 wire [7:0] expl_x_plot;
 wire [6:0] expl_y_plot;
 
 assign expl_x_plot = x_offset + enemy_x_position;
 assign expl_y_plot = y_offset + enemy_y_position;
 
 integer shoot_reached_screen_end;
 integer done_erase_shoot;
 integer done_update_shoot;
 integer done_draw_shoot;
 
 integer bullet_x_position;
 integer bullet_y_position;
 integer bullet_x_position_update; 
 integer bullet_y_position_update;
 
 assign shoot_x_plot = x_offset + bullet_x_position;
 assign shoot_y_plot = y_offset + bullet_y_position;
 
 integer done_draw_explosion;
 
 //----------------------------------------------------------------------------------------------------NEW FOR SHOOTING declarations end
 reg [2:0] color;
 wire [7:0] w_addr;
 wire [2:0] w_color;
 //reg [2:0] erase_color;
 wire writeEn;
 
 // For Erase
 integer erase_done;
 //assign erase_color = 3'b000;
 
 // Movement Directions
 wire left;
 wire right;
 wire up;
 wire down;
 wire enable_move;
 assign left = ~KEY[1];
 assign right = ~KEY[0];
 assign up = ~KEY[2];
 assign down = ~KEY[3];
 assign enable_move = left|right|up|down;
 integer count;
 
 //T flip flop that changes new_clock signal
 reg new_clock; //new clock of spaceship --------------------------------------------SPACESHP MOVEMENT
 wire delay; // new delay of the spaceship is in this wire
 new_clock_delay delaying(delay, CLOCK_50); //spaceship movement
 
 always@(posedge delay)
 begin
 new_clock = new_clock^1;
 end
 
 //T flip flop that changes enemy_delay signal
 reg enemy_clock; //new clock of enemy forming
 wire enemy_delay;// new delay of the enemy being formed is in this wire ------------ENEMY POPPING
 enemy_delay_2_seconds inst1(enemy_delay, CLOCK_50);// enemy popping up
 
 always@(posedge enemy_delay)
 begin
 enemy_clock = enemy_clock^1;
 end
 
 reg enemy_signal;
 
 always@(posedge enemy_clock)
 begin
 enemy_signal <= 1;
 end
 
 //T-flip-flop for enemy movement clock
 reg enemy_move_clock;
 wire enemy_move_delay;
 one_second_clock one_sec(enemy_move_delay, CLOCK_50);
 
 always@(posedge enemy_move_delay)
 begin
 enemy_move_clock <= enemy_move_clock^1;
 end
 
  // To update x and y for input to the vga
 integer x_position;
 integer y_position;
 
 integer x_update_new;
 integer y_update_new;
 integer x_update_old;
 integer y_update_old;
 
 integer update_done;
 integer enemy_update_done;
 integer enemy_update_done2;
 
 assign x_plot = x_offset + x_position;
 assign y_plot = y_offset + y_position; // + 60
 
 
 
 wire resetn;
 assign resetn = 1;
  
 reg [3:0] current_state,next_state;
 
 integer x_offset;
 integer y_offset;
 
 integer done_one_row;
 integer done_one_box;
 
 integer exceeds_x_boundaries;
 integer exceeds_y_boundaries;
 
 integer reseter;
 integer reseter_x;
 integer reseter_y;
 
 integer draw_enemy_x_position;
 integer draw_enemy_y_position;
 integer done_drawing_enemy;
 
 integer temp_hold_x_position;
 integer temp_hold_y_position;
 
 integer x_address_offset;
 integer y_address_offset;
 
 integer idle_count;
 wire draw_enemy;
 
 //For debugging purposes
 assign LEDR[0] = (current_state == START);
 assign LEDR[1] = (current_state == RESET_CLEAR);
 assign LEDR[2] = (current_state == IDLE);
 assign LEDR[3] = (current_state == ERASE);
 assign LEDR[4] = (current_state == UPDATE);
 assign LEDR[5] = (current_state == DRAW_SPACESHIP);
 assign LEDR[6] = (current_state == DRAW_ENEMY);
 assign LEDR[7] = (current_state == GAME_OVER);
 assign LEDR[8] = (current_state == SHOOT);
 assign LEDR[9] = (current_state == ERASE_SHOOT);
 assign LEDR[10] = (current_state == UPDATE_SHOOT);
 assign LEDR[11] = (current_state == DRAW_SHOOT);
 assign LEDR[12] = (current_state == EXPLOSION);
 assign LEDR[13] = (current_state == WAIT_WIN);
 assign LEDR[14] = (current_state == WIN);
 
 assign LEDG[8] = ship_enemy_collision;
 
 wire [6:0]rand_enemy_y; //random number generated for y-coordinate of enemy
 
 // Random number for enemy generation
 random_number test(CLOCK_50, SW[17], rand_enemy_y[6:0]);
 random_number test1(CLOCK_50, SW[17], LEDG[6:0]);
 
//----------------------------------------------------------------------------------------------------------------------NEW
 reg [7:0]x_coord_plot;
 reg [6:0]y_coord_plot;
 
 wire [7:0]enemy_x_plot;
 wire [6:0]enemy_y_plot;
 
 integer update_enemy_x;
 integer update_enemy_x2;
 integer update_enemy_x3;
 integer update_enemy_x4;
 
 integer enemy_erase_done;
 integer enemy_erase_done2;
 
 wire [7:0]enemy_RAM_position;
 wire [7:0]enemy_RAM_position2;
 wire [7:0]enemy_RAM_position3;
 wire [7:0]enemy_RAM_position4;
 integer enemy_x_position;
 integer enemy_y_position;
 
 assign enemy_x_plot = enemy_x_position + x_offset;
 assign enemy_y_plot = enemy_y_position + y_offset;
 
 integer enemy_count; //determines how many emeies on-screen and sets max(4)
 reg enemy_status; //alive or dead
 reg enemy_status2;
 
 wire wren_enemy; //used in update state to write updated xcoordinate to RAM
 wire rden_enemy; //used in erase and draw to read xcoordinate from RAM
 
 assign wren_enemy = (current_state == UPDATE)|(current_state == IDLE);
 assign LEDR[15] = wren_enemy;
 assign rden_enemy = (current_state == ERASE)|(current_state == DRAW_SPACESHIP);
 assign LEDR[16] = rden_enemy;
 
 wire [3:0]enemy1_addr;
 wire [3:0]enemy2_addr;
 wire [3:0]enemy3_addr;
 wire [3:0]enemy4_addr;
 
 assign enemy1_addr = 4'b000;
 assign enemy2_addr = 4'b001;
 assign enemy3_addr = 4'b010;
 assign enemy4_addr = 4'b011;
 
 enemy_ram enemy1(
 .data(update_enemy_x),
 .inclock(CLOCK_50),
 .outclock(CLOCK_50),
 .rdaddress(enemy1_addr),
 .rden(rden_enemy),
 .wraddress(enemy1_addr),
 .wren(wren_enemy),
 .q(enemy_RAM_position));
 
// 
// enemy_ram enemy2(
// .data(update_enemy_x2),
// .inclock(CLOCK_50),
// .outclock(CLOCK_50),
// .rdaddress(enemy2_addr),
// .rden(rden_enemy),
// .wraddress(enemy2_addr),
// .wren(wren_enemy),
// .q(enemy_RAM_position2)); 
 
 
 //----------------------------------------------------------------------------------------------COLlISION
 
 reg ship_enemy_collision; 
 reg bullet_enemy_collision;
 
 integer y_col_count;
 integer x_row_count;
 
 wire [14:0]game_over_addr;
 wire [2:0]game_over_color;
 
 wire [14:0]start_addr;
 wire [2:0]start_color;
 
 wire [7:0]expl_addr;
 wire [2:0]expl_color;
 
 wire[14:0] win_addr;
 wire[2:0] win_color;
 
 integer expl_x_offset;
 integer expl_y_offset;
 
 integer screen_x_offset;
 integer screen_y_offset;
 
 wire restart_game;
 assign restart_game = SW[0];
 
 wire start_game;
 assign start_game = SW[1];
 
 integer explosion_timer;

 integer done_wait_win;
 
 initial begin
 current_state = 4'b000; //3'b100
 next_state = 4'b000;  //3'b000
 count = 0;
 
 idle_count = 0;
 x_offset = 0;
 y_offset = 0;
 x_position = 0;
 y_position = 0;
 done_one_row = 0;
 done_one_box = 0; //to ensure 1 box is drawn
 exceeds_x_boundaries = 0; //for setting boundaries
 exceeds_y_boundaries = 0;
 
 reseter = 0; //for resetting
 reseter_x = 0;
 reseter_y = 0;
  
 draw_enemy_x_position = 0;
 draw_enemy_y_position = 0;
 done_drawing_enemy = 0;
 
 
 temp_hold_x_position = 0;
 temp_hold_y_position = 0;
 
 
 x_address_offset = 0;
 y_address_offset = 0;
 
 erase_done = 0;
 update_done = 0;
 //----------------------------------------------------------------------------------------- NEW 
 enemy_count = 0;
 enemy_status = 1;
 enemy_status2 = 0;
 enemy_x_position = 140;
 enemy_y_position = 60;
 
 update_enemy_x = 120;
 update_enemy_x2 = 120;
 
 enemy_erase_done = 0;
 enemy_erase_done2 = 0;
 
 enemy_update_done = 0;
 enemy_update_done2 = 0;
 
 //collision
 y_col_count = 0;
 x_row_count = 0;
 //ship_enemy_collision = 0;    ---------------------this was the change
 
 screen_x_offset = 0;
 screen_y_offset = 0;
 
 //initial values for shooting --------------------------------------------------------NEW variable initializations FOR SHOOTING
 shoot_reached_screen_end = 0;
 done_erase_shoot = 0;
 done_update_shoot = 0;
 done_draw_shoot = 0;
   
 bullet_x_position = 0;
 bullet_y_position = 0;
 
 
 bullet_x_position_update = 0; 
 bullet_y_position_update = 0;
 //-----------------------------------------------------------------------------------NEW variable initializations FOR SHOOTING
 
 explosion_timer = 0;
 
 done_wait_win = 0;
 
 end
 // Create an Instance of a VGA controller - there can be only one!
 // Define the number of colours as well as the initial background
 // image file (.MIF) for the controller.
 vga_adapter VGA(
   .resetn(resetn),
   .clock(CLOCK_50),
   .colour(color),
   .x(x_coord_plot),//x_plot + draw_enemy_x_position
   .y(y_coord_plot),//y_plot + draw_enemy_y_position
   .plot(writeEn),
   /* Signals for the DAC to drive the monitor. */
   .VGA_R(VGA_R),
   .VGA_G(VGA_G),
   .VGA_B(VGA_B),
   .VGA_HS(VGA_HS),
   .VGA_VS(VGA_VS),
   .VGA_BLANK(VGA_BLANK),
   .VGA_SYNC(VGA_SYNC),
   .VGA_CLK(VGA_CLK)); //vga_adapter module ends here
  defparam VGA.RESOLUTION = "160x120";
  defparam VGA.MONOCHROME = "FALSE";
  defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
 // defparam VGA.BACKGROUND_IMAGE = "display.mif";
   
 // Put your code here. Your code should produce signals x,y,color and writeEn
 // for the VGA controller, in addition to any other functionality your design may require.
 animation anirom (
 .address(w_addr),
 .clock(CLOCK_50),
 .q(w_color));
 
 game_over game_over_rom(
 .address(game_over_addr),
 .clock(CLOCK_50),
 .q(game_over_color));
 
 start_screen restart_rom(
 .address(start_addr),
 .clock(CLOCK_50),
 .q(start_color));
 
 explosion explosion_rom(
	.address(expl_addr),
	.clock(CLOCK_50),
	.q(expl_color));
	
	
you_win winrom(
	.address(win_addr),
	.clock(CLOCK_50),
	.q(win_color));	
 
assign w_addr = (x_offset + x_address_offset) + 15*(y_offset + y_address_offset);
assign game_over_addr = (screen_x_offset) + 160*(screen_y_offset);
assign start_addr = (screen_x_offset) + 160*(screen_y_offset);
assign expl_addr = (x_offset) + 15*(y_offset);
assign win_addr = (screen_x_offset) + 160*(screen_y_offset);

 
 parameter [3:0]  START = 4'b0000, RESET_CLEAR = 4'b0001, IDLE = 4'b0010, ERASE = 4'b0011, UPDATE = 4'b0100, DRAW_SPACESHIP = 4'b0101, DRAW_ENEMY = 4'b0110, 
      GAME_OVER = 4'b0111, SHOOT = 4'b1000, ERASE_SHOOT = 4'b1001, UPDATE_SHOOT = 4'b1010, DRAW_SHOOT = 4'b1011, 
		EXPLOSION = 4'b1100, WAIT_WIN = 4'b1101, WIN = 4'b1110; 
      
      //----------------NEW STATES FOR BULLET ADDED ABOVE
  
 always@(*)
 begin: state_table
  case(current_state)
	
   IDLE: 
  if(ship_enemy_collision == 1)
  next_state = GAME_OVER;
  
 else if(enable_move == 1)
  next_state = ERASE;
  
 else if (SW[5] == 1)
   next_state = SHOOT; 
   
   
   else
  next_state = IDLE;
 
   ERASE:
   if(erase_done == 1)
   begin
  next_state = UPDATE;
   end
   
   else
  next_state = ERASE;
  
 
 UPDATE:
   if(update_done == 1)
   begin
  next_state = DRAW_SPACESHIP;
   end
   
   else
  next_state = UPDATE;
 
   
   DRAW_SPACESHIP: 
   if(done_one_box == 1) //&draw_enemy == 1
   begin
  next_state = DRAW_ENEMY;
   end
  
   else
  next_state = DRAW_SPACESHIP;
   
 DRAW_ENEMY:
   if(done_drawing_enemy == 1)
  begin
   next_state = IDLE;
  end
   else
   next_state = DRAW_ENEMY;
  
 GAME_OVER:
  if(restart_game == 1)
   next_state = START;
	
  else
   next_state = GAME_OVER;
   
 START:
  if(enable_move == 1)
   next_state = RESET_CLEAR;
	
  else
   next_state = START;
  
 RESET_CLEAR:
  if(enable_move == 1)
   next_state = IDLE;
  else
   next_state = RESET_CLEAR;
   
 //------------------------------------------------------------------- NEW STATES FOR SHOOTING start
  
 SHOOT:
	if(bullet_enemy_collision == 1)
		next_state = EXPLOSION;
		
  else if(shoot_reached_screen_end == 1)
   begin
    next_state = IDLE;
   end 
   
  else if (shoot_reached_screen_end == 0)
   begin
    next_state = ERASE_SHOOT;
   end
	
  else
   begin
    next_state = SHOOT;
   end
  
  
 ERASE_SHOOT:
   if(done_erase_shoot == 1)
    begin
     next_state = UPDATE_SHOOT;
    end
    
   else
    next_state = ERASE_SHOOT;
 
 UPDATE_SHOOT:
   if(done_update_shoot == 1)
    begin
     next_state = DRAW_SHOOT;
    end
    
   else
    next_state = UPDATE_SHOOT;
    
 DRAW_SHOOT:
   if(done_draw_shoot == 1)
    begin
     next_state = SHOOT;
    end
   else
    next_state = DRAW_SHOOT;
	 
 EXPLOSION:
	if(done_draw_explosion == 1)
	begin
		next_state = WAIT_WIN;
	end
	else
		next_state = EXPLOSION;
		
 WAIT_WIN:
	if(done_wait_win == 1)
	begin
		next_state = WIN;
	end
	else
		next_state = WAIT_WIN;
	
	
		
 WIN:
	if(restart_game == 1)
	   next_state = START;
  else
		next_state = WIN;
 
      
    //------------------------------------------------------------------- NEW STATES FOR SHOOTING END
  
   
   
   
   default: next_state = IDLE; //default state
    
  endcase
   
 end
 
 always@(posedge new_clock) //spaceship movement speed
  begin: state_FFS
 current_state <= next_state;  
  end
 
  
 assign writeEn = ((current_state == DRAW_SPACESHIP) | (current_state == ERASE) | (current_state ==  DRAW_ENEMY) 
      | (current_state == GAME_OVER) | (current_state == START) | (current_state == RESET_CLEAR) 
      |  (current_state == ERASE_SHOOT) | (current_state == DRAW_SHOOT) | (current_state == EXPLOSION) | (current_state == WIN)); 
       //NEW SHOOTING STATES ADDED IN ABOVE
      
      
 assign LEDR[17] = writeEn;
 
 
 always@(posedge CLOCK_50)
 begin//-----------------------------------------main
  //begin//---------------------------------------------------------------------------1
  if(current_state == IDLE)
  begin
  x_position <= x_position;
  y_position <= y_position;
  
  explosion_timer <= 0;
  done_wait_win <= 0;
  
  x_offset <=0;
  y_offset<=0;
  
  
 bullet_x_position <= x_position + 16; //-----------------------//Newly added  values for SHOOTING
 bullet_y_position <= y_position + 4;
 shoot_reached_screen_end <= 0;
 
 screen_x_offset <=0;
 screen_y_offset <=0;
  
  end
  
  if(current_state == ERASE)
 begin
  color <= 3'b000;
  //begin// erase enemy1
   if(enemy_status == 1)
   begin
    enemy_x_position <= enemy_RAM_position;
    x_coord_plot <= enemy_x_plot;
    y_coord_plot <= enemy_y_plot;
                  if(x_offset<15)
                   x_offset <= x_offset + 1;
                  
                  else if(x_offset==15) //one row drawn
                   begin//---------------------------------------------------------------------3
                    x_offset <= 0;
                    done_one_row <= 1;
                    
                    
                     if(y_offset<9)
                      begin//-------------------------------------------4
                      y_offset <= y_offset + 1; //go to next row
                      end//---------------------------------------------4
                     else if (y_offset == 9) //all rows down, i.e box drawn
                      begin//----------------------------------------------------5
                       enemy_erase_done <= 1;
                       y_offset<=0;
                       x_offset<=0;
                      end//-------------------------------------------------------5
                   end//-----------------------------------------------------------------------3    
   end
  
  begin// erase ship
   x_coord_plot <= x_plot;
   y_coord_plot <= y_plot;
                  if(x_offset<15)
                   x_offset <= x_offset + 1;
                  
                  else if(x_offset==15) //one row drawn
                   begin//---------------------------------------------------------------------3
                    x_offset <= 0;
                    done_one_row <= 1;
                    
                    
                     if(y_offset<9)
                      begin//-------------------------------------------4
                      y_offset <= y_offset + 1; //go to next row
                      end//---------------------------------------------4
                     else if (y_offset == 9) //all rows down, i.e box drawn
                      begin//----------------------------------------------------5
                       erase_done <= 1;
                       y_offset<=0;
                       x_offset<=0;
                      end//-------------------------------------------------------5
                   end//-----------------------------------------------------------------------3
  end
 end
  
  if(current_state == UPDATE)
  begin
 begin// update enemy1
 if(enemy_status == 1)
  begin
  enemy_x_position <= enemy_RAM_position;
  update_enemy_x <= enemy_x_position - 1;
  end
 end
 
  
 begin// update ship
 if(left == 1)
  x_update_new <= x_position - 1;
  
 if(right == 1)
  x_update_new <= x_position + 1;
  
 if(up == 1)
  y_update_new <= y_position + 1;
   
 if(down == 1)
  y_update_new <= y_position - 1;
   
 update_done <= 1; 
 end
  end
  
   if((current_state == DRAW_SPACESHIP)) //& (KEY[0] == 1)) //draw squares
    begin//-----------------------------------------2
  begin// draw ship
    x_coord_plot <= x_plot;
    y_coord_plot <= y_plot;
    
     x_address_offset <= 0;
     y_address_offset <= 0;
  
     color <= w_color;
     //  writeEn <= 1;
     exceeds_x_boundaries <= 0;
     exceeds_x_boundaries <= 0;
     
     x_position <= x_update_new;
     y_position <= y_update_new;
  
                  
                  if(x_offset<15)
                   x_offset <= x_offset + 1;
                  
                  else if(x_offset==15) //one row drawn
                   begin//---------------------------------------------------------------------3
                    x_offset <= 0;
                    done_one_row <= 1;
                    
                    
                     if(y_offset<9)
                      begin//-------------------------------------------4
                      y_offset <= y_offset + 1; //go to next row
                      end//---------------------------------------------4
                     else if (y_offset ==9) //all rows down, i.e box drawn
                      begin//----------------------------------------------------5
                       done_one_box <= 1;
                       y_offset<=0;
                       x_offset<=0;
                      end//-------------------------------------------------------5
                   end//-----------------------------------------------------------------------3
   end// ship
    end//------------------------------------------2
  
  
  if(current_state == DRAW_ENEMY)
  begin
  
    begin// draw enemy1
   enemy_x_position <= enemy_RAM_position;
   x_coord_plot <= enemy_x_plot;
   y_coord_plot <= enemy_y_plot;
   
   if(enemy_status < 1)
   begin
  
   enemy_x_position <= 140; //drawing enemy on VGA to the right
   enemy_y_position<= rand_enemy_y;  //drawing enemy on VGA to the bottom
  
   x_address_offset <= 0;
   y_address_offset <= 9;
     
   color<=w_color;
   if(x_offset<15)
   x_offset <= x_offset + 1;
     
     
                  
                  else if(x_offset==15) //one row drawn
                   begin//---------------------------------------------------------------------3
                    x_offset <= 0;
                    done_one_row <= 1;
                    
                    
                     if(y_offset<9)
                      begin//-------------------------------------------4
                      y_offset <= y_offset + 1; //go to next row
                      end//---------------------------------------------4
                     else if (y_offset ==9) //all rows down, i.e box drawn
                      begin//----------------------------------------------------5
                       y_offset<=0;
                       x_offset<=0;
         done_drawing_enemy <= 1;
         enemy_status <= 1;
         
         
                      end//-------------------------------------------------------5
                   end//-----------------------------------------------------------------------3
   end
   
   else if(enemy_status == 1)
   begin
   x_address_offset <= 0;
   y_address_offset <= 9;
     
   color<=w_color;
   if(x_offset<15)
   x_offset <= x_offset + 1;
     
     
                  
                  else if(x_offset==15) //one row drawn
                   begin//---------------------------------------------------------------------3
                    x_offset <= 0;
                    done_one_row <= 1;
                    
                    
                     if(y_offset<9)
                      begin//-------------------------------------------4
                      y_offset <= y_offset + 1; //go to next row
                      end//---------------------------------------------4
                     else if (y_offset ==9) //all rows down, i.e box drawn
                      begin//----------------------------------------------------5
                       y_offset<=0;
                       x_offset<=0;
         done_drawing_enemy <= 1;
         
         
                      end//-------------------------------------------------------5
                   end//-----------------------------------------------------------------------3   
   end
   
  end// enemy1
 
 
 end
 
  
  if(current_state == GAME_OVER)
  begin // game_over
  x_coord_plot <= screen_x_offset;
  y_coord_plot <= screen_y_offset;
  
  color <= game_over_color;
  
  if(screen_x_offset < 160)
      screen_x_offset <= screen_x_offset + 1;
               
      else if(screen_x_offset == 160) //one row drawn
      begin//---------------------------------------------------------------------3
      screen_x_offset <= 0;
      done_one_row <= 1;
                    
                    
      if(screen_y_offset < 120)
           begin//-------------------------------------------4
           screen_y_offset <= screen_y_offset + 1; //go to next row
           end//---------------------------------------------4
      else if (screen_y_offset == 120) //all rows down, i.e box drawn
           begin//----------------------------------------------------5
         //  done_game_over <= 1;
           screen_y_offset <= 0;
           screen_x_offset <= 0;
           end//-------------------------------------------------------5
      end//-----------------------------------------------------------------------3
  end // game_over
  
  
  if(current_state == START)
  begin // start_screen
  
  x_coord_plot <= screen_x_offset;
  y_coord_plot <= screen_y_offset;
  
  explosion_timer <= 0;
  done_wait_win <= 1;
  
   x_position<=0;
	y_position<=0;
	
   x_offset<=0;
   y_offset<=0;
  
  color <= start_color;
  
  if(screen_x_offset < 160)
      screen_x_offset <= screen_x_offset + 1;
               
      else if(screen_x_offset == 160) //one row drawn
      begin//---------------------------------------------------------------------3
      screen_x_offset <= 0;
      done_one_row <= 1;
                    
                    
      if(screen_y_offset < 120)
           begin//-------------------------------------------4
           screen_y_offset <= screen_y_offset + 1; //go to next row
           end//---------------------------------------------4
      else if (screen_y_offset == 120) //all rows down, i.e box drawn
           begin//----------------------------------------------------5
         //  done_game_over <= 1;
           screen_y_offset <= 0;
           screen_x_offset <= 0;
			  x_position<=0;
			  y_position<=0;
			  x_offset<=0;
			  y_offset<=0;
           end//-------------------------------------------------------5
      end//-----------------------------------------------------------------------3
  
  end // start_screen
  
  
  if(current_state == EXPLOSION)
  
    begin// explosion
    x_coord_plot <= expl_x_plot;
    y_coord_plot <= expl_y_plot;
  
     color <= expl_color;
     //  writeEn <= 1;
  
                  
                  if(x_offset<15)
                   x_offset <= x_offset + 1;
     
     
                  
                  else if(x_offset==15) //one row drawn
                   begin//---------------------------------------------------------------------3
                    x_offset <= 0;
                    done_one_row <= 1;
                    
                    
                     if(y_offset<9)
                      begin//-------------------------------------------4
                      y_offset <= y_offset + 1; //go to next row
                      end//---------------------------------------------4
                     else if (y_offset ==9) //all rows down, i.e box drawn
                      begin//----------------------------------------------------5
                       
                       y_offset<=0;
                       x_offset<=0;
							  
							  done_draw_explosion <= 1;
                      end//-------------------------------------------------------5
                   end//-----------------------------------------------------------------------3
   end// explosion
  
	
	if(current_state == WAIT_WIN)
		begin
			if(explosion_timer == 150_000_000)
				begin
					explosion_timer <= 0;
					done_wait_win <= 1;
				end
				
			else
				explosion_timer <= explosion_timer + 1;
		
		end
	
	if(current_state == WIN)
		begin
			x_coord_plot <= screen_x_offset;
			y_coord_plot <= screen_y_offset;
			
			
			color <= win_color;
			
			
		
			
  if(screen_x_offset < 160)
      screen_x_offset <= screen_x_offset + 1;
               
      else if(screen_x_offset == 160) //one row drawn
      begin//---------------------------------------------------------------------3
      screen_x_offset <= 0;
      done_one_row <= 1;
                    
                    
      if(screen_y_offset < 120)
           begin//-------------------------------------------4
           screen_y_offset <= screen_y_offset + 1; //go to next row
           end//---------------------------------------------4
      else if (screen_y_offset == 120) //all rows down, i.e box drawn
           begin//----------------------------------------------------5
         
           screen_y_offset <= 0;
           screen_x_offset <= 0;
			  
           end//-------------------------------------------------------5
      end//-----------------------------------------------------------------------3
  
  	end

  if(current_state == RESET_CLEAR)
  begin //clear
  x_coord_plot <= screen_x_offset;
  y_coord_plot <= screen_y_offset;
  
  color <= 3'b000;
 // color <= start_color;
  
  if(screen_x_offset < 160)
      screen_x_offset <= screen_x_offset + 1;
               
      else if(screen_x_offset == 160) //one row drawn
      begin//---------------------------------------------------------------------3
      screen_x_offset <= 0;
      done_one_row <= 1;
                    
                    
      if(screen_y_offset < 120)
           begin//-------------------------------------------4
           screen_y_offset <= screen_y_offset + 1; //go to next row
           end//---------------------------------------------4
      else if (screen_y_offset == 120) //all rows down, i.e box drawn
           begin//----------------------------------------------------5
         //  done_game_over <= 1;
           screen_y_offset <= 0;
           screen_x_offset <= 0;
           end//-------------------------------------------------------5
      end//-----------------------------------------------------------------------3
 
     count <= 0;
   
   idle_count <= 0;
   x_offset <= 0;
   y_offset <= 0;
   x_position <= 0;
   y_position <= 0;
   done_one_row <= 0;
   done_one_box <= 0; //to ensure 1 box is drawn
   exceeds_x_boundaries <= 0; //for setting boundaries
   exceeds_y_boundaries <= 0;
   
   reseter <= 0; //for resetting
   reseter_x <= 0;
   reseter_y <= 0;
    
   draw_enemy_x_position <= 0;
   draw_enemy_y_position <= 0;
   done_drawing_enemy <= 0;
   
   
   temp_hold_x_position <= 0;
   temp_hold_y_position <= 0;
   
   
   x_address_offset <= 0;
   y_address_offset <= 0;
   
   erase_done <= 0;
   update_done <= 0;
   //----------------------------------------------------------------------------------------- NEW 
   enemy_count <= 0;
   enemy_status <= 1;
   enemy_status2 <= 0;
   enemy_x_position <= 140;
  // enemy_y_position <= rand_enemy_y;
   enemy_y_position <= 60;
	
   update_enemy_x <= 140;
   update_enemy_x2 <= 120;
   
   enemy_erase_done <= 0;
   enemy_erase_done2 <= 0;
   
   enemy_update_done <= 0;
   enemy_update_done2 <= 0;
   
   //collision
   y_col_count <= 0;
   x_row_count <= 0;
   ship_enemy_collision <= 0;
	bullet_enemy_collision <= 0;
  
  end // clear

  
  //-------------------------------------------------------------------------------------- COLLISION CONDITIONS
  // ship with enemy collisions
  if(x_position + 15 == enemy_x_position)//front collision
  begin
  if(y_col_count < 9)
  begin
  if(((y_position + y_col_count) == enemy_y_position)|((y_position + y_col_count) == enemy_y_position + 9))
  begin
   ship_enemy_collision <= 1;
   y_col_count <= 0;
   x_row_count <= 0;
  end
  y_col_count <= y_col_count + 1;
  end
  if(y_col_count == 9)
  begin
  y_col_count <= 0;
  x_row_count <= 0;
  end
  end
  
  if(x_position == enemy_x_position + 15)//back collision
  begin
  if(y_col_count < 9)
  begin
  if(((y_position + y_col_count) == enemy_y_position)|((y_position + y_col_count) == enemy_y_position + 9))
  begin
   ship_enemy_collision <= 1;
   y_col_count <= 0;
   x_row_count <= 0;
  end
  y_col_count <= y_col_count + 1;
  end
  if(y_col_count == 9)
  begin
  y_col_count <= 0;
  x_row_count <= 0;
  end
  end 
  
  if(y_position == enemy_y_position + 9)
  begin
  if(x_row_count < 15)
  begin
  if(((x_position + x_row_count) == enemy_x_position)|((x_position + x_row_count) == enemy_x_position + 15))
  begin
   ship_enemy_collision <= 1;
   y_col_count <= 0;
   x_row_count <= 0;
  end
  x_row_count <= x_row_count + 1;
  end
  if(x_row_count == 15)
  begin
  y_col_count <= 0;
  x_row_count <= 0;
  end
  end
  
  if(y_position + 9 == enemy_y_position)
  begin
  if(x_row_count < 15)
  begin
  if(((x_position + x_row_count) == enemy_x_position)|((x_position + x_row_count) == enemy_x_position + 15))
  begin
   ship_enemy_collision <= 1;
   y_col_count <= 0;
   x_row_count <= 0;
  end
  x_row_count <= x_row_count + 1;
  end
  if(x_row_count == 15)
  begin
  y_col_count <= 0;
  x_row_count <= 0;
  end
  end
  
  if(bullet_x_position == enemy_x_position)
  begin
	if(y_col_count < 9)
	begin
	if(((bullet_y_position + y_col_count) == enemy_y_position) | (((bullet_y_position + y_col_count) == enemy_y_position + 9)))
	begin
		bullet_enemy_collision <= 1;
		y_col_count <= 0;
		x_row_count <= 0;
	end
	y_col_count <= y_col_count + 1;
	end
	if(y_col_count == 9)
	begin
	  y_col_count <= 0;
	  x_row_count <= 0;
	end
  end
  
  //enemy collision at end of screen
  if(enemy_x_position == 0)
	ship_enemy_collision <= 1;
	
  
  
//---------------------------------------------------------------------------------------NEW SHOOTING STATE DESCRIPTIONS HERE
if(current_state == SHOOT)
  begin//------------------------------------------------------1
  
   if(bullet_x_position == 160)
    begin
     shoot_reached_screen_end <= 1; //reached end of x axis screen
    end
  
  end//--------------------------------------------------------1
  
  
 if(current_state == ERASE_SHOOT)
  begin//-----------------------------------------------------1
  color <= 3'b000;
  x_coord_plot <= shoot_x_plot;
  y_coord_plot <= shoot_y_plot;
  
     if(x_offset<3)//15
                   x_offset <= x_offset + 1;
                  
                  else if(x_offset==3) //15
                   begin//---------------------------------------------------------------------3
                    x_offset <= 0;
        done_erase_shoot <= 1;
                    end//----------------------------------------------------------------------3
                   
  end//-------------------------------------------------------1
 
 
 
 
 
 if(current_state == UPDATE_SHOOT)
  begin//---------------------------------------------------------------------------------------41
   
  bullet_x_position_update <= bullet_x_position + 1;
  bullet_y_position_update <= bullet_y_position;
  
  done_update_shoot <= 1;
   
  end//-------------------------------------------------------------------------------------41
  
  
  
  
 if(current_state == DRAW_SHOOT)
 
   //Draw shoot starts from here
   begin//--------------------------------------------------------52
  
   
  x_coord_plot <= shoot_x_plot;
  y_coord_plot <= shoot_y_plot;
  
  color<= 3'b110;
  
  x_address_offset <= 0;
  y_address_offset <= 0;
  
  bullet_x_position <= bullet_x_position_update;
  bullet_y_position <= bullet_y_position_update;
   
  if(x_offset<2)
                   x_offset <= x_offset + 1;
                  
                  else if(x_offset==2) //one row drawn
                   begin//---------------------------------------------------------------------3
                    x_offset <= 0;
        y_offset <= 0;
        done_draw_shoot <= 1;
        end//----------------------------------------------------------------------3 - new after removing y offset
                    
  end//---------------------------------------------------------52
  
  
  
  
  
 end//----------------------------------main
 
 endmodule
 