/* This module converts a user specified coordinates into a memory address.
 * The output of the module depends on the resolution set by the user.
 */
module vga_address_translator(x, y, mem_address);

	parameter RESOLUTION = "640x480";
	/* Set this parameter to "160x120" or "320x240". It will cause the VGA adapter to draw each dot on
	 * the screen by using a block of 4x4 pixels ("160x120" resolution) or 2x2 pixels ("320x240" resolution).
	 * It effectively reduces the screen resolution to an integer fraction of 640x480. It was necessary
	 * to reduce the resolution for the Video Memory to fit within the on-chip memory limits.
	 */

	input [((RESOLUTION == "640x480") ? (9) : (8)):0] x; 
	input [((RESOLUTION == "640x480") ? (8) : (7)):0] y;	
	output reg [((RESOLUTION == "640x480") ? (18) : (16)):0] mem_address;
	
	/* The basic formula is address = y*WIDTH + x;
	 * For 320x240 resolution we can write 320 as (256 + 64). Memory address becomes
	 * (y*256) + (y*64) + x;
	 * This simplifies multiplication a simple shift and add operation.
	 * A leading 0 bit is added to each operand to ensure that they are treated as unsigned
	 * inputs. By default the use a '+' operator will generate a signed adder.
	 * Write 640 as (512 + 128). (y*512) + (y*128) + x
	 */
	wire [16:0] res_320x240 = ({1'b0, y, 8'd0} + {1'b0, y, 6'd0} + {1'b0, x});
	wire [18:0] res_640x480 = ({1'b0, y, 9'd0} + {1'b0, y, 7'd0} + {1'b0, x});
	
	always @(*)
	begin
		if (RESOLUTION == "640x480")
			mem_address = res_640x480;
		else
			mem_address = res_320x240;
	end
endmodule
