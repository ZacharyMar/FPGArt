`timescale 1 ns / 1 ns

module drawingDataPath
	#(
	parameter SCREEN_WIDTH = 160,
	parameter SCREEN_HEIGHT = 120
	)
	(
	iResetn, 	// Reset datapath to initial values
	iClk, 		// clock source
	iX_cell, 	// Input of current x cell position from mouse
	iY_cell, 	// Input of current y cell position from mouse
	iColour, 	// Input of colour from user
	iState, 		// Current state from FSM
	oX_pixel,	// x pixel output to VGA
	oY_pixel, 	// y pixel output to VGA
	oDone, 	 	// Signal asserted when counter related processes are done
	oColour,  	// Colour output to VGA
	oMove, 	 	// Signal asserted when mouse movement is detected
	oPlot,    	// Signal output to VGA to draw to monitor
	//j memory outputs
	oAddress, //data write address
    oWren, //data write enable
	);
	parameter CELL_DIMENSION = 5;
	parameter UPPER_BITS = $clog2((SCREEN_WIDTH / CELL_DIMENSION) > (SCREEN_HEIGHT / CELL_DIMENSION)? (SCREEN_WIDTH / CELL_DIMENSION):(SCREEN_HEIGHT / CELL_DIMENSION));
	
	// Inputs
	input wire iResetn, iClk;
	// States: IDLE - 0, MOVE - 1, WAIT - 2, CLEAN - 3, DRAW - 4, ERASE - 5, CLEAR_WAIT - 6, CLEAR - 7, RESET_MOUSE - 8
	input wire [3:0] iState;
	input wire [UPPER_BITS-1:0] iX_cell, iY_cell;
	// For now take 3 bit colour
	input wire [2:0] iColour;
	
	// Outputs
	output reg [$clog2(SCREEN_WIDTH):0] oX_pixel;
	output reg [$clog2(SCREEN_HEIGHT):0] oY_pixel;
	output reg oDone, oMove, oPlot;
	output reg [2:0] oColour; //wire output to input of data in ram modules
	//j memory inputs/outputs
	output reg[14:0] oAddress;
	output reg oWren;
	
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
	// Flag used to indicate first loop iteration
	reg initialize;
	
	
	always@(posedge iClk, negedge iResetn)
		begin
			if(!iResetn)
				begin
					oX_pixel <= 0;
					oY_pixel <= 0;
					oDone <= 0;
					oMove <= 0;
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
					initialize <= 1;
					oPlot <= 0;
					oWren <= 0;
					oAddress <= 0;
				end
				
			else
				begin					
					// Check whether mouse movement was made -- asynchronous to state
					if (prev_x_cell != iX_cell || prev_y_cell != iY_cell)
						// Assert transition to move state
						begin
							oMove <= 1;
						end
					// Prev and current position match
					else 
						begin
							oMove <= 0;
						end
					
					// Handle each state
					// Idle state - central state
					if (iState == 4'd0)
						// Reset signals
						begin
							oDone <= 0;
							oPlot <= 0;
							initialize <= 1;
							oWren <= 0;
						end
					// Move state
					else if (iState == 4'd1 && !oDone)
						begin
							// First loop iterarion - initialize values
							if (initialize)
								begin
									if (iColour == 3'b000) oColour <= 3'b110;
									else oColour <= iColour;
									x_init_pixel <= iX_cell*5;
									y_init_pixel <= iY_cell*5;
									x_border_count <= 0;
									y_border_count <= 0;
									initialize <= 0;
								end
							// Not first loop, draw to screen
							else
								begin
									// Use counters to draw new outline
									oX_pixel <= x_init_pixel + x_border_count;
									oY_pixel <= y_init_pixel + y_border_count;

									
									// Only plot if pixel is on border
									if (x_border_count == 3'd0 || x_border_count == 3'd4 || y_border_count == 3'd0 || y_border_count == 3'd4) oPlot <= 1;
									else oPlot <= 0;
									
									// Increment counters
									if (y_border_count == 3'd4 && x_border_count == 3'd4)
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
						end
					
					// Wait State
					else if (iState == 4'd2)
						begin
							// Add delay here if needed
							//******* Unsure if the animation is smooth until in-lab. Concern: adding delay to smooth animation causes lots of input lag!
							oDone <= 0;
							oPlot <= 0;
							// Make sure clean state has initialization cycle
							initialize <= 1;
							// Set colour for clean state to grid colour - black for now
							oColour <= 3'b000; 
						end
						
					// Clean state
					else if (iState == 4'd3 && !oDone)
						begin
							// First loop - initialize values
							if (initialize)
								begin
									// Set initial pixel to draw from prev value
									x_init_pixel <= prev_x_cell*5;
									y_init_pixel <= prev_y_cell*5;
									// Update prev to current
									prev_x_cell <= iX_cell;
									prev_y_cell <= iY_cell;
									initialize <= 0;
								end
							else
								begin
									// Use prev measurement
									oX_pixel <= x_init_pixel + x_border_count;
									oY_pixel <= y_init_pixel + y_border_count;

									// Only plot if pixel is on border
									if (x_border_count == 3'd0 || x_border_count == 3'd4 || y_border_count == 3'd0 || y_border_count == 3'd4) oPlot <= 1;
									else oPlot <= 0;
									
									
									// Increment counters
									if (y_border_count == 3'd4 && x_border_count == 3'd4)
										begin
											oDone <= 1;
											// Reset counts
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
						end
					
					// Draw state
					else if (iState == 4'd4 && !oDone)
						begin
							// First loop
							if (initialize)
								begin
									// Set current pixel to top left of draw zone of cell
									x_init_pixel <= iX_cell*5 + 1;
									y_init_pixel <= iY_cell*5 + 1;
									initialize <= 0;
									// Colour outputted is what user selected
									oColour <= iColour;
								end
							else
								begin
									// Draw each pixel
									oPlot <= 1;
									oWren <= 1;
									// Send pixel to draw
									oX_pixel <= x_init_pixel + x_count;
									oY_pixel <= y_init_pixel + y_count; 								
									oAddress <= ({1'b0, y_init_pixel + y_count, 7'd0} + {1'b0, y_init_pixel + y_count, 5'd0} + {1'b0, x_init_pixel + x_count});
									// Increment counters
									if (y_count == 2'd2 && x_count == 2'd2)
										begin
											oDone <= 1;
											y_count <= 0;
											x_count <= 0;
										end
									else if (x_count == 2'd2)
										begin
											x_count <= 0;
											y_count <= y_count + 1;
										end
									else x_count <= x_count + 1;
								end
						end
					
					// Erase state - handled the same as draw except colour is white
					else if (iState == 4'd5 && !oDone)
						begin
							// First loop
							if (initialize)
								begin
									// Set current pixel to top left of draw zone of cell
									x_init_pixel <= iX_cell*5 + 1;
									y_init_pixel <= iY_cell*5 + 1;
									initialize <= 0;
									// Colour is white to erase
									oColour <= 3'b111;
								end
							else
								begin
									// Draw each pixel
									oPlot <= 1;
									oWren <= 1;
									// Send pixel to draw
									oX_pixel <= x_init_pixel + x_count;
									oY_pixel <= y_init_pixel + y_count;
									oAddress <= ({1'b0, y_init_pixel + y_count, 7'd0} + {1'b0, y_init_pixel + y_count, 5'd0} + {1'b0, x_init_pixel + x_count});
									// Increment counters
									if (y_count == 2'd2 && x_count == 2'd2)
										begin
											oDone <= 1;
											y_count <= 0;
											x_count <= 0;
										end
									else if (x_count == 2'd2)
										begin
											x_count <= 0;
											y_count <= y_count + 1;
										end
									else x_count <= x_count + 1;
								end
						end
					
					// Clear state
					else if (iState == 4'd7 && !oDone)
						begin
							oX_pixel <= x_clear_count;
							oY_pixel <= y_clear_count;
							oPlot <= 1;
							oWren <= 1;
							oAddress <= ({1'b0, y_clear_count, 7'd0} + {1'b0, y_clear_count, 5'd0} + {1'b0, x_clear_count});
							// Colour is black on gridlines - coordinate has 0, 4, 5 or 9 in one's digit
							if (x_clear_count % 10 == 0 || x_clear_count % 10 == 4 || x_clear_count % 10 == 5 || x_clear_count % 10 == 9 || y_clear_count % 10 == 0 || y_clear_count % 10 == 4 || y_clear_count % 10 == 5 || y_clear_count % 10 == 9)
								 begin
									oColour <= 3'b000;
								 end
							 // Draw white everywhere else
							 else oColour <= 3'b111;
							 
							 // Increment counters
							 if (y_clear_count == (SCREEN_HEIGHT - 1) && x_clear_count == (SCREEN_WIDTH - 1))
								begin
									oDone <= 1;
									y_clear_count <= 0;
									x_clear_count <= 0;
								end
							else if (x_clear_count == SCREEN_WIDTH - 1)
								begin
									x_clear_count <= 0;
									y_clear_count <= y_clear_count + 1;
								end
							else x_clear_count <= x_clear_count + 1;
						end
				end
		end

endmodule
