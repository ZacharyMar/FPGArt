`timescale 1 ns / 1ns

module hexDecoder(
	// X cell position in decimal digits
	x_ones,
	x_tens,
	//x_huns,
	// Y cell position in decimal digits
	y_ones,
	y_tens,
	// Hex display
	hex_0,
	hex_1,
	hex_3,
	hex_4,
	//hex_5
);	
	input wire [3:0] x_ones, x_tens, y_ones, y_tens; // , x_huns
	output reg [6:0] hex_0, hex_1, hex_3, hex_4;// hex_5;

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
	
	// Output position to hex
	// HEX5, HEX4, HEX3 are x position
	// HEX1 and HEX0 are y position
	// (x2 x1 x0, y1 y0)
	always@(*)
		begin
			case (x_ones)
				4'd0: hex_3 = HEX_0;
				4'd1: hex_3 = HEX_1;
				4'd2: hex_3 = HEX_2;
				4'd3: hex_3 = HEX_3;
				4'd4: hex_3 = HEX_4;
				4'd5: hex_3 = HEX_5;
				4'd6: hex_3 = HEX_6;
				4'd7: hex_3 = HEX_7;
				4'd8: hex_3 = HEX_8;
				4'd9: hex_3 = HEX_9;
				default: hex_3 = dash;
			endcase
		end
		
	always@(*)
		begin
			case (x_tens)
				4'd0: hex_4 = HEX_0;
				4'd1: hex_4 = HEX_1;
				4'd2: hex_4 = HEX_2;
				4'd3: hex_4 = HEX_3;
				4'd4: hex_4 = HEX_4;
				4'd5: hex_4 = HEX_5;
				4'd6: hex_4 = HEX_6;
				4'd7: hex_4 = HEX_7;
				4'd8: hex_4 = HEX_8;
				4'd9: hex_4 = HEX_9;
				default: hex_4 = dash;
			endcase
		end
		
	/*	
	always@(*)
		begin
			case (x_huns)
				4'd0: hex_5 = HEX_0;
				4'd1: hex_5 = HEX_1;
				4'd2: hex_5 = HEX_2;
				4'd3: hex_5 = HEX_3;
				4'd4: hex_5 = HEX_4;
				4'd5: hex_5 = HEX_5;
				4'd6: hex_5 = HEX_6;
				4'd7: hex_5 = HEX_7;
				4'd8: hex_5 = HEX_8;
				4'd9: hex_5 = HEX_9;
				default: hex_5 = dash;
			endcase
		end
	*/	
		
	always@(*)
		begin
			case (y_ones)
				4'd0: hex_0 = HEX_0;
				4'd1: hex_0 = HEX_1;
				4'd2: hex_0 = HEX_2;
				4'd3: hex_0 = HEX_3;
				4'd4: hex_0 = HEX_4;
				4'd5: hex_0 = HEX_5;
				4'd6: hex_0 = HEX_6;
				4'd7: hex_0 = HEX_7;
				4'd8: hex_0 = HEX_8;
				4'd9: hex_0 = HEX_9;
				default: hex_0 = dash;
			endcase
		end
	
	always@(*)
		begin
			case (y_tens)
				4'd0: hex_1 = HEX_0;
				4'd1: hex_1 = HEX_1;
				4'd2: hex_1 = HEX_2;
				4'd3: hex_1 = HEX_3;
				4'd4: hex_1 = HEX_4;
				4'd5: hex_1 = HEX_5;
				4'd6: hex_1 = HEX_6;
				4'd7: hex_1 = HEX_7;
				4'd8: hex_1 = HEX_8;
				4'd9: hex_1 = HEX_9;
				default: hex_1 = dash;
			endcase
		end
	
	
endmodule
