`timescale 1 ns / 1 ns

module drawingCircuit
	#(
	parameter SCREEN_WIDTH = 640,
	parameter SCREEN_HEIGHT = 480
	)
	(
	iResetn, 			  // Reset signal for drawing circuit
	iClk,    			  // Clock source
	iClear,				  // Signal asserted to clear screen
	iColour,				  // Colour input from user
	iX_cell,				  // X location of cell from mouse
	iY_cell,				  // Y location of cell from mouse
	iLeftbtn,			  // Signal asserted when LMB pressed
	iRightbtn,			  // Signal asserted when RMB pressed
	oStartTransmission, // Signal asserted to initiate host-to-mouse communication
	oMouseEnable,		  // Signal asserted or deasserted to send command to enable/disable mouse streaming
	oX_pixel,			  // Output to VGA for x pixel coordinate
	oY_pixel,			  // Output to VGA for y pixel coordinate
	oColour,				  // Output to VGA for colour to draw in
	oPlot					  // Signal asserted to enable VGA to display to monitor
	);
	parameter CELL_DIMENSION = 5;
	parameter UPPER_BITS = $clog2((SCREEN_WIDTH / CELL_DIMENSION) > (SCREEN_HEIGHT / CELL_DIMENSION)? (SCREEN_WIDTH / CELL_DIMENSION):(SCREEN_HEIGHT / CELL_DIMENSION));
	
	
	// Inputs
	input wire iResetn, iClk, iClear, iLeftbtn, iRightbtn;
	input wire [2:0] iColour;
	input wire [UPPER_BITS-1:0] iX_cell, iY_cell;
	
	// Outputs
	output wire oStartTransmission, oMouseEnable, oPlot;
	output wire [$clog2(SCREEN_WIDTH):0] oX_pixel;
	output wire [$clog2(SCREEN_HEIGHT):0] oY_pixel;
	output wire [2:0] oColour;
	
	// Wires
	wire move; 			// Asserted when mouse movement detected
	wire done; 			// Asserted when process in datapath is finished
	wire [3:0] state; // Carries current state information to datapath
	
	// Instantiate FSM
	drawingControlPath c0 (
		.iResetn(iResetn),
		.iClk(iClk),
		.iBtnL(iLeftbtn),
		.iBtnR(iRightbtn),
		.iDone(done),
		.iClear(iClear),
		.iMove(move),
		.oState(state),
		.oEnableMouse(oMouseEnable),
		.oStartTransmission(oStartTransmission)
	);
	
	// Instantiate datapath
	drawingDataPath #(.SCREEN_WIDTH(SCREEN_WIDTH), .SCREEN_HEIGHT(SCREEN_HEIGHT)) d0 (
		.iResetn(iResetn),
		.iClk(iClk),
		.iX_cell(iX_cell),
		.iY_cell(iY_cell),
		.iColour(iColour),
		.iState(state),
		.oX_pixel(oX_pixel),
		.oY_pixel(oY_pixel),
		.oDone(done),
		.oColour(oColour),
		.oMove(move),
		.oPlot(oPlot)
	);
	
endmodule