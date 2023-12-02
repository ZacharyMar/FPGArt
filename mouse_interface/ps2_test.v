`timescale 1 ns / 1 ns

module ps2_test 
	#(
		parameter SCREEN_WIDTH = 640,
		parameter SCREEN_HEIGHT = 480,
		parameter CELL_TICKS = 15, // Width of each cell in mouse ticks (DPI)
		parameter HYSTERESIS = 5 // Delay or deadzone for mouse movement to registed
	)
	(
		CLOCK_50,
		PS2_CLK,
		PS2_DAT,
		KEY,
		SW,
		HEX0,
		HEX1,
		HEX2,
		HEX3,
		HEX4,
		HEX5
	);
	
	input CLOCK_50; 
	input [9:0] SW; // Enable mouse
	input [1:0] KEY; // Reset - KEY[0], start - KEY[1]
	inout PS2_CLK, PS2_DAT;
	output reg [6:0] HEX0;
	output reg [6:0] HEX1;
	output reg [6:0] HEX2;
	output reg [6:0] HEX3;
	output reg [6:0] HEX4;
	output reg [6:0] HEX5;
	
	wire left_btn, right_btn, mid_btn;
	wire [7:0] cell_x;
	wire [7:0] cell_y;
	
	 
	// setting to create HEX value on display
	 
	parameter HEX_0 = 7'b1000000;		// zero
	parameter HEX_1 = 7'b1111001;		// one
	parameter HEX_2 = 7'b0100100;		// two
	parameter HEX_3 = 7'b0110000;		// three
	parameter HEX_4 = 7'b0011001;		// four
	parameter HEX_5 = 7'b0010010;		// five
	parameter HEX_6 = 7'b0000010;		// six
	parameter HEX_7 = 7'b1111000;		// seven
	parameter HEX_8 = 7'b0000000;		// eight
	parameter HEX_9 = 7'b0011000;		// nine
	parameter HEX_10 = 7'b0001000;		// ten
	parameter HEX_11 = 7'b0000011;		// eleven
	parameter HEX_12 = 7'b1000110;		// twelve
	parameter HEX_13 = 7'b0100001;		// thirteen
	parameter HEX_14 = 7'b0000110;		// fourteen
	parameter HEX_15 = 7'b0001110;		// fifteen
	parameter zero   = 7'b1111111;		// all off	
	parameter right = 7'b0101111;      // right button push
	parameter left = 7'b1000111;			// left button push
	parameter middle = 7'b0101011;		// middle button push and letter n
	parameter dash = 7'b0111111; 		// dash (no button push)
	
	// Institate mouse controller
	ps2 u0 (
		.start(~KEY[1]),
		.send_enable(SW[0]),
		.reset(KEY[0]),
		.CLOCK_50(CLOCK_50),
		.PS2_CLK(PS2_CLK),
		.PS2_DAT(PS2_DAT),
		.button_left(left_btn),
		.button_right(right_btn),
		.button_middle(mid_btn),
		.cell_x(cell_x),
		.cell_y(cell_y)
	);
	
	// Use hex to display cell position and button press
	always@(*)
		begin
			// Output to check if mouse buttons correctly being read
			if (left_btn) HEX5 = left;
			else HEX5 = dash;
			if (right_btn) HEX4 = right;
			else HEX4 = dash;			
		end
	
	// Output position to hex
	// HEX3 and HEX2 are x position
	// HEX1 and HEX0 are y position
	// (x1 x0, y1 y0)
	always@(*)
		begin
			case (cell_x[3:0])
				4'd0: HEX2 = HEX_0;
				4'd1: HEX2 = HEX_1;
				4'd2: HEX2 = HEX_2;
				4'd3: HEX2 = HEX_3;
				4'd4: HEX2 = HEX_4;
				4'd5: HEX2 = HEX_5;
				4'd6: HEX2 = HEX_6;
				4'd7: HEX2 = HEX_7;
				4'd8: HEX2 = HEX_8;
				4'd9: HEX2 = HEX_9;
				4'd10: HEX2 = HEX_10;
				4'd11: HEX2 = HEX_11;
				4'd12: HEX2 = HEX_12;
				4'd13: HEX2 = HEX_13;
				4'd14: HEX2 = HEX_14;
				4'd15: HEX2 = HEX_15;
			endcase
		end
		
	always@(*)
		begin
			case (cell_x[7:4])
				4'd0: HEX3 = HEX_0;
				4'd1: HEX3 = HEX_1;
				4'd2: HEX3 = HEX_2;
				4'd3: HEX3 = HEX_3;
				4'd4: HEX3 = HEX_4;
				4'd5: HEX3 = HEX_5;
				4'd6: HEX3 = HEX_6;
				4'd7: HEX3 = HEX_7;
				4'd8: HEX3 = HEX_8;
				4'd9: HEX3 = HEX_9;
				4'd10: HEX3 = HEX_10;
				4'd11: HEX3 = HEX_11;
				4'd12: HEX3 = HEX_12;
				4'd13: HEX3 = HEX_13;
				4'd14: HEX3 = HEX_14;
				4'd15: HEX3 = HEX_15;
			endcase
		end
		
	always@(*)
		begin
			case (cell_y[3:0])
				4'd0: HEX0 = HEX_0;
				4'd1: HEX0 = HEX_1;
				4'd2: HEX0 = HEX_2;
				4'd3: HEX0 = HEX_3;
				4'd4: HEX0 = HEX_4;
				4'd5: HEX0 = HEX_5;
				4'd6: HEX0 = HEX_6;
				4'd7: HEX0 = HEX_7;
				4'd8: HEX0 = HEX_8;
				4'd9: HEX0 = HEX_9;
				4'd10: HEX0 = HEX_10;
				4'd11: HEX0 = HEX_11;
				4'd12: HEX0 = HEX_12;
				4'd13: HEX0 = HEX_13;
				4'd14: HEX0 = HEX_14;
				4'd15: HEX0 = HEX_15;
			endcase
		end
	
	always@(*)
		begin
			case (cell_y[7:4])
				4'd0: HEX1 = HEX_0;
				4'd1: HEX1 = HEX_1;
				4'd2: HEX1 = HEX_2;
				4'd3: HEX1 = HEX_3;
				4'd4: HEX1 = HEX_4;
				4'd5: HEX1 = HEX_5;
				4'd6: HEX1 = HEX_6;
				4'd7: HEX1 = HEX_7;
				4'd8: HEX1 = HEX_8;
				4'd9: HEX1 = HEX_9;
				4'd10: HEX1 = HEX_10;
				4'd11: HEX1 = HEX_11;
				4'd12: HEX1 = HEX_12;
				4'd13: HEX1 = HEX_13;
				4'd14: HEX1 = HEX_14;
				4'd15: HEX1 = HEX_15;
			endcase
		end

endmodule