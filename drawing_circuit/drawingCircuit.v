`timescale 1 ns / 1 ns

module drawingCircuit #(parameter SCREEN_WIDTH = 320,parameter SCREEN_HEIGHT = 240)(
    iClk,
    iResetn,
    iBtnL,
    iBtnR,
    iClear,
    iSlot0,
    iSlot1,
    iX_cell,
    iY_cell,
    iColour,
    oColour,
    oX_pixel,
    oY_pixel,
    oStartTransmission,
    oEnableMouse,
    oPlot,
    oChipSelect
	);
    parameter CELL_DIMENSION = 5;
	 parameter UPPER_BITS = $clog2((SCREEN_WIDTH / CELL_DIMENSION) > (SCREEN_HEIGHT / CELL_DIMENSION)? (SCREEN_WIDTH / CELL_DIMENSION):(SCREEN_HEIGHT / CELL_DIMENSION));
    //block inputs
    input wire iClk, iResetn, iBtnL, iBtnR, iClear, iSlot0, iSlot1;
    input wire [UPPER_BITS-1:0] iX_cell, iY_cell; //xy from mouse (represents position on smaller drawing grid (32 x 24 on 160 x 120 display))
    input wire [8:0] iColour; //colour data from switch input
    //block outputs
    output wire [8:0] oColour; //also known as data to ram, used for VGA and data into ram controller
    output wire [$clog2(SCREEN_WIDTH):0] oX_pixel; //xy to VGA
	 output wire [$clog2(SCREEN_HEIGHT):0] oY_pixel;
    output wire oPlot;
    output wire oStartTransmission;
    output wire oEnableMouse;
    output wire oChipSelect;

    
    //inner wires to memory controller module
    wire ChipSelect, wren;
	 wire [8:0] q;
    wire [16:0] address;
    assign oChipSelect = ChipSelect;
	integratedCircuit #(.SCREEN_WIDTH(SCREEN_WIDTH), .SCREEN_HEIGHT(SCREEN_HEIGHT)) INTEGRATED_CIRCUIT(
	 .iClk(iClk),
    .iResetn(iResetn),
    .iBtnL(iBtnL),
    .iBtnR(iBtnR),
    .iClear(iClear),
    .iSlot0(iSlot0),
    .iSlot1(iSlot1),
    .iX_cell(iX_cell),
    .iY_cell(iY_cell),
    .iQ_r(q),
    .iColour(iColour),
    .oAddress(address),
    .oWren_d(wren),
    .oColour(oColour),
    .oX_pixel(oX_pixel),
    .oY_pixel(oY_pixel),
    .oChipSelect(ChipSelect),
    .oStartTransmission(oStartTransmission),
    .oEnableMouse(oEnableMouse),
	 .oPlot(oPlot)
	);

	memory_controller MEMORY_CONTROLLER(
	 .iResetn(iResetn),
	 .iClk(iClk), 
    .iData(oColour), 
    .iAddress(address), 
    .iWren(wren), 
    .iChipSelect(ChipSelect), 
    .oQ(q)
	);
	

endmodule
