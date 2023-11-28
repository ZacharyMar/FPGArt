`timescale 1 ns / 1ns

/* Top level module for FPGArt program
	Program created for use on the DE1-SoC board
 */

module FPGArt(
	CLOCK_50,		// 50Mhz source clock
	KEY,				// KEY[0] for reset, KEY[3] for clear
	SW,				// Switches used for colour selection
	
	// PS2 ports used for mouse interface
	PS2_CLK,			
	PS2_DAT,
	
	// Hex displays used to output cursor position
	HEX0,				
	HEX1,
	HEX2,
	HEX3,
	
	// VGA ports
	VGA_CLK,
	VGA_HS,							
	VGA_VS,							
	VGA_BLANK_N,						
	VGA_SYNC_N,						
	VGA_R,   						
	VGA_G,	 						
	VGA_B  
);
	// Change screen size to 640x480 when memory installed
	parameter SCREEN_WIDTH = 320;
	parameter SCREEN_HEIGHT = 240;
	
	// Inputs
	input CLOCK_50;
	input [3:0] KEY;
	
	// Inouts
	inout PS2_CLK, PS2_DAT;
	
	// Outputs
	output [6:0] HEX0, HEX1, HEX2, HEX3;
	
	// VGA ports
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	// Wires
	wire left_btn, right_btn, mid_btn; // Button pushes from mosue
	// Position from mouse
	wire [7:0] cell_x;
	wire [7:0] cell_y;
	// Host-to-mouse signals
	wire mouseTransmission, mouseEnable;
	
	// X and Y pixel to draw at
	wire [$clog(SCREEN_WIDTH):0] x_pixel;
	wire [$clog(SCREEN_HEIGHT):0] y_pixel;
	// Colour to display
	wire [2:0] colour;
	// Enable plotting to monitor
	wire plot_en;
	
	
	// VGA adapter instance
	vga_adapter VGA(
			.resetn(KEY[0]),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x_pixel),
			.y(y_pixel),
			.plot(plot_en),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240"; // Change resolution parameter to 640x480 when memory installed
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1; // Change bits for colour to 3 when memory installed 
		defparam VGA.BACKGROUND_IMAGE = "background320x240.mif"; // Change to MIF file for 640x480 when memory installed
		
	// Mouse instance
	ps2 #(.SCREEN_WIDTH(SCREEN_WIDTH), .SCREEN_HEIGHT(SCREEN_HEIGHT)) MOUSE(
		.start(mouseTransmission),
		.send_enable(mouseEnable),
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
	
	// Drawing circuit instance
	drawingCircuit #(.SCREEN_WIDTH(SCREEN_WIDTH), .SCREEN_HEIGHT(SCREEN_HEIGHT)) DRAW_CIRCUIT(
		.iResetn(KEY[0]),
		.iClk(CLOCK_50),
		.iClear(~KEY[3]),
		.iColour(SW[9:7]),
		.iX_cell(cell_x),
		.iY_cell(cell_y),
		.iLeftbtn(left_btn),
		.iRightbtn(right_btn),
		.oStartTransmission(mouseTransmission),
		.oMouseEnable(mouseEnable),
		.oX_pixel(x_pixel),
		.oY_pixel(y_pixel),
		.oColour(colour),
		.oPlot(plot_en)
	);
	
	// Hex decoder instance
	hexDecoder HEX_DECODER(
		.x_pos(cell_x),
		.y_pox(cell_y),
		.hex_0(HEX0),
		.hex_1(HEX1),
		.hex_2(HEX2),
		.hex_3(HEX3)
	);

endmodule