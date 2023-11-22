`timescale 1 ns / 1 ns

module drawingDataPath
	#(
		parameter SCREEN_WIDTH = 640,
		parameter SCREEN_HEIGHT = 480
	)
	(iResetn, iClk, iX_cell, iY_cell, iColour, iState, oX_pixel, oY_pixel, oDone, oColour, oMove, oPlot);
	parameter CELL_DIMENSION = 5;
	parameter UPPER_BITS = $clog2((SCREEN_WIDTH / CELL_DIMENSION) > (SCREEN_HEIGHT / CELL_DIMENSION)? (SCREEN_WIDTH / CELL_DIMENSION):(SCREEN_HEIGHT / CELL_DIMENSION));
	
	// Inputs
	input wire iResetn, iClk;
	// States: IDLE - 0, MOVE - 1, WAIT - 2, CLEAN - 3, DRAW - 4, ERASE - 5, CLEAR - 6
	input wire [2:0] iState;
	input wire [UPPER_BITS-1:0] iX_cell, iY_cell;
	// For now take 3 bit colour
	input wire [2:0] iColour;
	
	// Outputs
	output reg [$clog2(SCREEN_WIDTH > SCREEN_HEIGHT ? SCREEN_WIDTH:SCREEN_HEIGHT):0] oX_pixel, oY_pixel;
	output reg oDone, oMove, oPlot;
	output wire [2:0] oColour;
	
	// Regs
	// Counters used to fill in cell
	reg [1:0] x_count, y_count;
	// Counters used for clearing the screen
	reg [$clog2(SCREEN_WIDTH > SCREEN_HEIGHT ? SCREEN_WIDTH:SCREEN_HEIGHT):0] x_clear_count, y_clear_count;
	// Stores initial x and y pixel when user wants to draw or erase
	reg [$clog2(SCREEN_WIDTH > SCREEN_HEIGHT ? SCREEN_WIDTH:SCREEN_HEIGHT):0] x_init_pixel, y_init_pixel;
	// Stores position of cell at last clock cycle
	reg [UPPER_BITS-1:0] prev_x_cell, prev_y_cell;
	// Counter used for drawing
	reg [2:0] x_border_count, y_border_count;
	
	
	always@(posedge iClk, negedge iResetn)
		begin
			if(!iResetn)
				begin
					ox_pixel <= 0;
					oy_pixel <= 0;
					oDone <= 0;
					// Default colour is white
					oColour <= 3'b111;
					x_count <= 0;
					y_count <= 0;
					x_clear_count <= 0;
					y_clear_count <= 0;
					x_init_pixel <= 0;
					y_init_pixel <= 0;
					prev_x_cell <= 0;
					prev_y_cell <= 0;
					x_border_count <= 0;
					y_border_count <= 0;
					oPlot <= 0;
				end
				
			else
				begin
					// Check if there is movement
					if (prev_x_cell != iX_cell || prev_y_cell != iY_cell)
						begin
							// Do not override this information when entering states to animate cursor
							if (iState != 3'd1 && iState != 3'd2 && iState != 3'd3)
								begin
									oMove <= 1;
									x_init_pixel <= iX_cell*5;
									y_init_pixel <= iY_cell*5;
									x_border_count <= 0;
									y_border_count <= 0;
									// Border is yellow
									oColour <= 3'b110;
								end
						end
					else omove <= 0;
					
					// Handle each state
					// Idle state
					if (iState == 3'd0) oDone <= 0;
					// Move state
					else if (iState == 3'd1)
						begin
							// Use counters to draw new outline
							oX_pixel <= x_init_pixel + x_border_count;
							oY_pixel <= y_init_pixel + y_border_count;
							
							
							// Only plot if pixel is on border
							if (x_border_count == 3'd0 || x_border_count == 3'd4 || y_border_count == 3'd0 || y_border_count == 3'd4) oPlot <= 1;
							else oPlot <= 0;
							
							// Increment counters
							if (y_border_count == 3'd4)
								begin
									oDone <= 1;
									// Reset counts for clean state to use
									x_border_count <= 0;
									y_border_count <= 0;
								end
							else if (x_border_count == 3'd4) 
								begin
									x_border_count <= 0;
									y_border_count <= y_border_count + 1;
								end
							else x_border_count <= x_border_count + 1;
						end
					
					// Wait State
					else if (iState == 3'd2)
						begin
							// Add delay here if needed
							oDone <= 0;
							// Set colour for clean state to grid colour - black for now
							oColour <= 3'b000 
						end
						
					// Clean state
					else if (iState == 3'd3)
						begin
							// Use prev measurement
							oX_pixel <= (prev_x_cell*5) + x_border_count;
							oY_pixel <= (prev_y_cell*5) + y_border_count;
							
							// Only plot if pixel is on border
							if (x_border_count == 3'd0 || x_border_count == 3'd4 || y_border_count == 3'd0 || y_border_count == 3'd4) oPlot <= 1;
							else oPlot <= 0;
							
							// Increment counters
							if (y_border_count == 3'd4)
								begin
									oDone <= 1;
									// Reset counts
									x_border_count <= 0;
									y_border_count <= 0;
									// Set prev position equal to current position
									prev_x_cell <= iX_cell;
									prev_y_cell <=iY_cell;
								end
							else if (x_border_count == 3'd4) 
								begin
									x_border_count <= 0;
									y_border_count <= y_border_count + 1;
								end
							else x_border_count <= x_border_count + 1;
						end
					
					// Draw state
					else if (iState == 3'd4)
					
					// Erase state
					else if (iState == 3'd5)
					
					// Clear state
					else if (iState == 3'd6)
				end
		end

endmodule