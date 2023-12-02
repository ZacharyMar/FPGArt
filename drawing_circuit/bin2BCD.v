`timescale 1 ns / 1 ns

/* Implementation of the double dabble algorithm to convert BIN to BCD
	Used to convert the cell locations from the mouse to decimal values to display on 7seg display
 */

module bin2BCD(iX_cell, iY_cell, oBCDX, oBCDY);
	input [7:0] iX_cell, iY_cell;
	output reg [11:0] oBCDX, oBCDY;
	
	// Counters
	integer i, j;
	
	// Change in x position
	always@(iX_cell)
		begin
			// Initialize output to zero
			oBCDX = 0;
			
			// Double Dabble algo
			// Iterate for each bit in input
			for (i=0; i<8; i=i+1) begin
				// Add 3 to nibble if value is greater than or equal to 5
				if (oBCDX[3:0] > 4) oBCDX[3:0] = oBCDX[3:0] + 3;
				if (oBCDX[7:4] > 4) oBCDX[7:4] = oBCDX[7:4] + 3;
				if (oBCDX[11:8] > 4) oBCDX[11:8] = oBCDX[11:8] + 3;
				// Left shift values in output and shift in bit from input
				oBCDX = {oBCDX[10:0], iX_cell[7-i]};
			end
		end
		
	// Change in y position
	always@(iY_cell)
		begin
			// Initialize with zeros
			oBCDY = 0;
			
			// Double dabble algo (same as above)
			for (j=0; j<8; j=j+1) begin
				if (oBCDY[3:0] > 4) oBCDY[3:0] = oBCDY[3:0] + 3;
				if (oBCDY[7:4] > 4) oBCDY[7:4] = oBCDY[7:4] + 3;
				if (oBCDY[11:8] > 4) oBCDY[11:8] = oBCDY[11:8] + 3;
				oBCDY = {oBCDY[10:0], iY_cell[7-j]};
			end
		end
	
endmodule
