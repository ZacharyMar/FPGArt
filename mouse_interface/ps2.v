`timescale 1 ns / 1 ns

/**************************************************************************************************************
PS2 mouse interface module

Interfaces with PS2 port on FPGA.
Screen is interpreted to be a grid (has discrete locations). Movement data from the mouse is only interpreted by 
direction to determine which direction on the grid should be traversed (absolute xy coordinate is not calculated).

Code based on ps2 mouse interface found here: https://class.ece.uw.edu/271/hauck2/de1/mouse/ps2.v
****************************************************************************************************************/

module ps2
	#(
		parameter SCREEN_WIDTH = 640,
		parameter SCREEN_HEIGHT = 480,
		parameter CELL_TICKS = 15, // Width of each cell in mouse ticks (DPI)
		parameter HYSTERESIS = 5 // Delay or deadzone for mouse movement to register
	)
	(
		start,         // transmit instrucions to device
		send_enable,   // HIGH = command sent is enabling streaming, LOW = command send is disabling streaming
		reset,         // FSM reset signal --> active LOW
		CLOCK_50,      //clock source
		PS2_CLK,       //ps2_clock signal inout
		PS2_DAT,       //ps2_data  signal inout
		button_left,   //left button press display
		button_right,  //right button press display
		button_middle, //middle button press display
		cell_x,         // Unsigned integer for selected cell in x direction
		cell_y,          // Unsigned integer for selected cell in y direction
	);

//=======================================================
//  PARAMETERS
//=======================================================
parameter CELL_DIMENSION = 5; // Each cell is 5 x 5 pixels
// Upperbound of bits accomdates largest dimension
parameter UPPER_BITS = $clog2((SCREEN_WIDTH / CELL_DIMENSION) > (SCREEN_HEIGHT / CELL_DIMENSION)? (SCREEN_WIDTH / CELL_DIMENSION):(SCREEN_HEIGHT / CELL_DIMENSION));
parameter LOWER_BITS = $clog2(CELL_TICKS+HYSTERESIS+256)+1;
parameter THRESHOLD = CELL_TICKS+HYSTERESIS;

//=======================================================
//  PORT declarations
//=======================================================

input start;
input send_enable;
input reset;
input CLOCK_50;  

inout PS2_CLK;
inout PS2_DAT;

output reg button_left;
output reg button_right;
output reg button_middle;
output reg [UPPER_BITS-1:0] cell_x;
output reg [UPPER_BITS-1:0] cell_y;

//instruction define, users can charge the instruction byte here for other purpose according to ps/2 mouse datasheet.
//the MSB is of parity check bit, that's when there are odd number of 1's with data bits, it's value is '0',otherwise it's '1' instead.

parameter enable_byte =9'b011110100; // Host to mouse signal F4 --> enables streaming from mouse
parameter disable_byte = 9'b111110101; // Host to mouse signal F5 --> disables streaming from mouse
parameter reset_byte = 9'b111111111; // Host to mouse signal FF --> resets mouse

//=======================================================
//  REG/WIRE declarations
//=======================================================
reg [1:0] cur_state,nex_state;
reg clk_en,data_en;
reg [3:0] byte_count,delay;
reg [5:0] data_length_count;
reg [7:0] count;
reg [8:0] clk_div;
reg [9:0] data_out_reg;
reg [32:0] shift_reg; // Data read from mouse
reg       leflatch,riglatch,midlatch;
reg       ps2_clk_in,ps2_clk_syn1,ps2_dat_in,ps2_dat_syn1, transmission_active;
wire      clk,ps2_dat_syn0,ps2_clk_syn0,ps2_dat_out,ps2_clk_out,flag;
reg [LOWER_BITS-1:0] x_latch;
reg [LOWER_BITS-1:0] y_latch;
reg [UPPER_BITS-1:0] oX_cell;
reg [UPPER_BITS-1:0] oY_cell;

//=======================================================
//  PARAMETER declarations
//=======================================================
//state define
parameter listen =2'b00,
          pullclk=2'b01,
          pulldat=2'b10,
          trans  =2'b11;
          
//=======================================================
//  Structural coding
//=======================================================          
//clk division, derive a 97.65625KHz clock from the 50MHz source;

always@(posedge CLOCK_50)
	begin
		clk_div <= clk_div+1;
	end
	
assign clk = clk_div[8];
//tristate output control for PS2_DAT and PS2_CLK;
assign PS2_CLK = clk_en?ps2_clk_out:1'bZ;
assign PS2_DAT = data_en?ps2_dat_out:1'bZ;
assign ps2_clk_out = 1'b0;
assign ps2_dat_out = data_out_reg[0];
assign ps2_clk_syn0 = clk_en?1'b1:PS2_CLK;
assign ps2_dat_syn0 = data_en?1'b1:PS2_DAT;
// deal with any issues which may be due to moving between clock domains
reg [9:0] starttimer;
always @(posedge CLOCK_50)
begin
	if(start) starttimer <= 1'b1;
	else if(starttimer) starttimer <= starttimer + 1'b1;
	
	button_left = leflatch;
	button_right = riglatch;
	button_middle = midlatch;
	cell_x = oX_cell;
	cell_y = oY_cell;
end
//multi-clock region simple synchronization
always@(posedge clk)
	begin
		ps2_clk_syn1 <= ps2_clk_syn0;
		ps2_clk_in   <= ps2_clk_syn1;
		ps2_dat_syn1 <= ps2_dat_syn0;
		ps2_dat_in   <= ps2_dat_syn1;
	end
//FSM shift
always@(*)
begin
   case(cur_state)
     listen  :begin
              if (starttimer && (count == 8'b11111111))
                  nex_state = pullclk;
              else
                  nex_state = listen;
                  clk_en = 1'b0;
                  data_en = 1'b0;
              end
     pullclk :begin
              if (delay == 4'b1100)
                  nex_state = pulldat;
              else
                  nex_state = pullclk;
                  clk_en = 1'b1;
                  data_en = 1'b0;
              end
     pulldat :begin
                  nex_state = trans;
                  clk_en = 1'b1;
                  data_en = 1'b1;
              end
     trans   :begin
              if  (byte_count == 4'b1010)
						begin
							transmission_active = 0;
							nex_state = listen;
						end
              else   
						begin
							nex_state = trans;
							transmission_active = 1;
							clk_en = 1'b0;
							data_en = 1'b1;
						end
              end
     default :begin
					   nex_state = listen;
						transmission_active = 0;
					end
   endcase
end
//idle counter
always@(posedge clk)
begin
  if ({ps2_clk_in,ps2_dat_in} == 2'b11)
	begin
		count <= count+1;
    end
  else begin
		count <= 8'd0;
       end
end
//periodically reset data_length_count
assign flag = (count == 8'hff)?1:0;
always@(posedge ps2_clk_in,posedge flag, negedge reset)
begin
	if (!reset) data_length_count <= 6'b000000;
  else if (flag)
     data_length_count <= 6'b000000;
  else
     data_length_count <= data_length_count+1;
end
//latch data from shift_reg;outputs is of 2's complement;
always@(posedge clk, negedge reset)
begin
   if(!reset)
   begin
      leflatch <= 1'b0;
      riglatch <= 1'b0;
      midlatch <= 1'b0;
      x_latch  <= 0;
      y_latch  <= 0;
		// Default cell position is (0,0)
      oX_cell <= 0;
      oY_cell <= 0;
   end
	// Reset on host to mouse data
	else if (transmission_active)
		begin
			leflatch <= 1'b0;
			riglatch <= 1'b0;
			midlatch <= 1'b0;
			x_latch  <= 0;
			y_latch  <= 0;
			// Default cell position is (0,0)
			oX_cell <= 0;
			oY_cell <= 0;
		end
   else if (count == 8'b00011110 && (data_length_count[5] == 1'b1 || data_length_count[4] == 1'b1))
   begin
      leflatch <= shift_reg[1];
      riglatch <= shift_reg[2];
      midlatch <= shift_reg[3];
		// Latch to new calculated cell
      x_latch  <= x_latch+{{(LOWER_BITS-8){shift_reg[19]}},shift_reg[19 : 12]};
      y_latch  <= y_latch+{{(LOWER_BITS-8){shift_reg[30]}},shift_reg[30 : 23]};
   end
	else
	begin
		// Input movement in +x dir
		if($signed(x_latch) >= THRESHOLD)
		begin
			// Set x_latch back one cell
			x_latch <= x_latch - CELL_TICKS;
			// Not at right boundary
			if(oX_cell != (SCREEN_WIDTH / CELL_DIMENSION) - 1)
			begin
				// Increments one cell to right
				oX_cell <= oX_cell + 1'b1;
			end
		end
		// Input movement in -x dir
		else if($signed(x_latch) <= -THRESHOLD)
		begin
			// Set x_latch back one cell
			x_latch <= x_latch + CELL_TICKS;
			// Not at left boundary
			if(oX_cell != 0)
			begin
				// Increment one cell to left
				oX_cell <= oX_cell - 1'b1;
			end
		end
		
		// Input movement in +y dir
		if($signed(y_latch) >= THRESHOLD)
		begin
			// set y_latch back one cell
			y_latch <= y_latch - CELL_TICKS;
			// Not at top boundary
			if(oY_cell != 0)
			begin
				// Increment cell down
				oY_cell <= oY_cell - 1'b1; 
			end
		end
		// Input movement in -y dir
		else if($signed(y_latch) <= -THRESHOLD)
		begin
			// set y_latch back one cell
			y_latch <= y_latch + CELL_TICKS;
			// Not at bottom boundary
			if(oY_cell != (SCREEN_HEIGHT / CELL_DIMENSION) - 1)
			begin
				// Increment cell up
				oY_cell <= oY_cell + 1'b1; 
			end
		end
		
	end
end

//pull ps2_clk low for 100us before transmit starts;
always@(posedge clk)
begin
  if (cur_state == pullclk)
     delay <= delay+1;
  else
     delay <= 4'b0000;
end
//transmit data to ps2 device
always@(negedge ps2_clk_in)
begin
  if (cur_state == trans)
     data_out_reg <= {1'b0,data_out_reg[9:1]};
  else
	  // Load command to be sent to device into register
	  if (send_enable) data_out_reg <= {enable_byte,1'b0}; // send_enable HIGH = command to stream
	  else data_out_reg <= {disable_byte,1'b0}; // send_enable LOW = command to disable streaming
end
//transmit byte length counter
always@(negedge ps2_clk_in)
begin
  if (cur_state == trans)
     byte_count <= byte_count+1;
  else
     byte_count <= 4'b0000;
end
//receive data from ps2 device;
always@(negedge ps2_clk_in)
begin
  if (cur_state == listen)
     shift_reg <= {ps2_dat_in,shift_reg[32:1]};
end
//FSM movement
always@(posedge clk,negedge reset)
begin
  if (!reset)
     cur_state <= pullclk;
  else
     cur_state <= nex_state;
end
endmodule
