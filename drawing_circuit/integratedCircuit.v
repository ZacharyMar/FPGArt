`timescale 1 ns / 1ns

module integratedCircuit #(parameter SCREEN_WIDTH = 160,parameter SCREEN_HEIGHT = 120)(
	 iClk,						// Source clock
	 iResetn,					// FSM reset signal
	 iBtnL,						// Asserted when LMB clicked
	 iBtnR,						// Asserted when RMB clicked
	 iClear,						// Asserted when user wants to clear screen
	 iSlot0,						// Asserted when user wants to write to save slot 0
	 iSlot1,						// Asserted when user wants to write to save slot 1
	 iX_cell,					// Current x cell position of cursor
	 iY_cell,					// Current y cell position of cursor
	 iQ_r,						// Colour data from memory
	 iColour,					// User input of selected colour
	 oAddress,					// Address to write/read from in memory
	 oWren_d,					// Enables (1) writing to memory or only allows read access (0) from memory
	 oColour,					// Colour to draw to VGA
	 oX_pixel,					// Pixel x coordinate to draw to VGA
	 oY_pixel,					// Pixel y coordinate to draw to VGA
	 oChipSelect,				// Outputted to memory controller to select which block of memory to interface with
	 oStartTransmission,		// Asserted to start host-to-mouse communication
	 oEnableMouse,				// Asserted to enable (1) or disable (0) mouse streaming
	 oPlot,						// Asserted to allow for drawing to display
	 oTestState
	 );

	 parameter CELL_DIMENSION = 5;
	 parameter UPPER_BITS = $clog2((SCREEN_WIDTH / CELL_DIMENSION) > (SCREEN_HEIGHT / CELL_DIMENSION)? (SCREEN_WIDTH / CELL_DIMENSION):(SCREEN_HEIGHT / CELL_DIMENSION)); //bit count of drawing grid (where each cell in the drawing grid = 5x5 block on display)
	 
	 //block inputs
	 input wire iClk, iResetn, iBtnL, iBtnR, iClear, iSlot0, iSlot1;
	 input wire [UPPER_BITS-1:0] iX_cell, iY_cell; 
	 input wire [2:0] iQ_r; 
	 input wire [2:0] iColour; 
	 
	 //block outputs
	 output reg [14:0] oAddress; 
	 output wire oWren_d; 
	 output reg [2:0] oColour; 
	 output reg [$clog2(SCREEN_WIDTH):0] oX_pixel; 
	 output reg [$clog2(SCREEN_HEIGHT):0] oY_pixel;
	 output reg oPlot;
	 output wire oChipSelect; 
	 output wire oStartTransmission;
	 output wire oEnableMouse;
	 output wire [3:0] oTestState;
	 
	 //internal wires and mux selectors
	 wire [3:0] state;
	 wire move;
	 
	 // Selector bit used to determine which datapath outputs are valid
	 // 1 - ram datapath outputs should be used
	 // 0 - drawing datapath outputs should be used
	 wire datapath_select; 
	 
	 // The following wires store the shared outputs of the datapaths
	 //done selector 
	 wire done_ram, done_draw;
	 
	 //address selector mux
	 wire [14:0] address_ram, address_draw;
	 
	 //VGA selector mux
	 wire [$clog2(SCREEN_WIDTH):0] x_draw, x_ram;
	 wire [$clog2(SCREEN_HEIGHT):0] y_draw, y_ram;
	 wire plot_draw, plot_ram;
	 wire [2:0] colour_draw, colour_ram;
		 
	 // Circuit outputs based on mux
	 always@(*)
		begin
			if (datapath_select)
				begin
					oAddress = address_ram;
					oX_pixel = x_ram;
					oY_pixel = y_ram;
					oPlot = plot_ram;
					oColour = colour_ram;
				end
			else
				begin
					oAddress = address_draw;
					oX_pixel = x_draw;
					oY_pixel = y_draw;
					oPlot = plot_draw;
					oColour = colour_draw;
				end
		end
		
	assign oTestState = state;
	
	 drawingControlPath cr0(
		.iResetn(iResetn), 				
		.iClk(iClk), 				
		.iBtnL(iBtnL), 					
		.iBtnR(iBtnR), 					
		.iDone(datapath_select? done_ram : done_draw), 					
		.iClear(iClear), 					
		.iMove(move), 					
		.oState(state), 					
		.oEnableMouse(oEnableMouse), 			
		.oStartTransmission(oStartTransmission),
		.iSlot0(iSlot0), 
		.iSlot1(iSlot1),
		.oDatapathSelect(datapath_select)
	 );
		
	 drawingDataPath #(.SCREEN_WIDTH(SCREEN_WIDTH), .SCREEN_HEIGHT(SCREEN_HEIGHT)) d0(
		.iResetn(iResetn), 	
		.iClk(iClk), 		
		.iX_cell(iX_cell), 	
		.iY_cell(iY_cell), 	
		.iColour(iColour), 	
		.iState(state), 		
		.oX_pixel(x_draw),	
		.oY_pixel(y_draw), 	
		.oDone(done_draw), 	 	
		.oColour(colour_draw),  	
		.oMove(move), 	 	
		.oPlot(plot_draw),    	
		.oAddress(address_draw), 
		.oWren(oWren_d) 
	);
			
	 ramDatapath #(.SCREEN_WIDTH(SCREEN_WIDTH), .SCREEN_HEIGHT(SCREEN_HEIGHT)) r0(
		 .iClk(iClk),
		 .iReset(iResetn),
		 .iState(state),
		 .oDone(done_ram),
		 .iQ_ram(iQ_r),
		 .oAddress_ram(address_ram),
		 .oColour(colour_ram),
		 .oPlot(plot_ram),
		 .ox(x_ram),
		 .oy(y_ram),
		 .oChipSelect(oChipSelect)
	 );

endmodule
