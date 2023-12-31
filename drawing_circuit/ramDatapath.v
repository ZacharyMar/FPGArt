`timescale 1 ns / 1 ns
module ramDatapath
    #(
	parameter SCREEN_WIDTH = 320,
	parameter SCREEN_HEIGHT = 240
	)
    (
    iClk,
    iReset,
    iState,
    oDone,
    iQ_ram,
    oAddress_ram,
    oColour,
    oPlot,
    ox,
    oy,
    oChipSelect
);
input wire iClk, iReset;
input wire [4:0] iState;

//output to fsm
output reg oDone, oChipSelect;

//data read signals for first buffer
input wire [8:0] iQ_ram;
output reg [16:0] oAddress_ram;
//removed wren as the controlpath and memory controller's chipselect and datapath select signals should handle when we are reading from memory

//output to VGA
output reg [8:0] oColour;
output reg oPlot;
output reg [$clog2(SCREEN_WIDTH > SCREEN_HEIGHT ? SCREEN_WIDTH:SCREEN_HEIGHT):0] ox, oy;

//internal wires
reg [$clog2(SCREEN_WIDTH > SCREEN_HEIGHT ? SCREEN_WIDTH:SCREEN_HEIGHT):0] x_count, y_count;
reg load_mem, start_load;

//relevant memory states
localparam  IDLE = 5'd0,
            CHANGE_STATE0 = 5'd9,
            CHANGE_STATE0_LOAD = 5'd10,
            CHANGE_STATE1 = 5'd11,
            CHANGE_STATE1_LOAD = 5'd12,
				CLEAR_RESET_WAIT0 = 5'd13,
				CLEAR_RESET_SLOT0 = 5'd14,
				CLEAR_RESET_WAIT1 = 5'd15,
				CLEAR_RESET_SLOT1 = 5'd16;
				
always@ (posedge iClk, negedge iReset) begin
    if(!iReset) begin
        x_count <= 0;
        y_count <= 0;
        load_mem <= 0;
		  oAddress_ram <= 0;
        oDone <= 0;
        ox <= 0;
        oy <= 0;
        oColour <= 9'b111111111;
        oPlot <= 0;
        start_load <= 0;
        oChipSelect <= 0;
    end
    else begin
	 
        // load from memory state 1
        if(iState == CHANGE_STATE1_LOAD && !oDone) begin
            if(start_load)begin //if we just started to load from memory then reset the counts
                x_count <= 0;
                y_count <= 0;
                start_load <= 0;
                load_mem <= 1;
            end
            else if(load_mem)begin //to load a pixel from memory, pass address into BRAM module 1
                load_mem <= 0;
                oAddress_ram <= ({1'b0, y_count, 8'd0} + {1'b0, y_count, 6'd0} + {1'b0, x_count});
            end
            else if(!load_mem)begin //to draw, enable plot and load the x, y, and c registers
					  oColour <= iQ_ram;
					  ox <= x_count-1;
					  oy <= y_count;
					  oPlot <= 1;
                if(y_count == SCREEN_HEIGHT-1 && x_count == SCREEN_WIDTH -1)begin //if we are at the bottom right pixel then we are Done drawing the frame
                    oDone <= 1; 
                    x_count <= 0;
                    y_count <= 0;
                end
                else if(x_count == SCREEN_WIDTH-1)begin //finished drawing row
                    y_count <= y_count+1;
                    x_count <= 0;
                    load_mem <= 1; 
                end
                else begin //increment x counter (somewhere in the middle of the screen)
                    x_count <= x_count+1;
                    load_mem <= 1;
                end
            end
        end
        else if(iState == CHANGE_STATE1) begin
            start_load <= 1;
            oChipSelect <= 1;
            oDone <= 0;
        end
         // load from memory state 0
        else if(iState == CHANGE_STATE0_LOAD && !oDone) begin
            if(start_load)begin //if we just started to load from memory then reset the counts
                x_count <= 0;
                y_count <= 0;
                start_load <= 0;
                load_mem <= 1;
            end
            else if(load_mem)begin //to load a pixel from memory, pass address into BRAM module 0
                load_mem <= 0;
                oAddress_ram <= ({1'b0, y_count, 8'd0} + {1'b0, y_count, 6'd0} + {1'b0, x_count});
            end
            else if(!load_mem)begin //to draw, enable plot and load the x, y, and c registers
                oColour <= iQ_ram;
                ox <= x_count-1;
                oy <= y_count;  
					 oPlot  <= 1;
                if(y_count == SCREEN_HEIGHT-1 && x_count == SCREEN_WIDTH -1)begin 
                    oDone <= 1; //if we are at the bottom right pixel then we are Done drawing the frame
                    x_count <= 0;
                    y_count <= 0;
                    //hacckasnu
                end
                else if(x_count == SCREEN_WIDTH-1)begin //finished drawing row
                    y_count <= y_count+1;
                    x_count <= 0;
                    load_mem <= 1; 
                end
                else begin //increment x counter (somewhere in the middle of the screen)
                    x_count <= x_count+1;
                    load_mem <= 1;
                end
            end
        end
        else if(iState == CHANGE_STATE0) begin
            start_load <= 1;
            oChipSelect <= 0;
            oDone <= 0;
        end
		  
		  else if (iState == CLEAR_RESET_WAIT0) oChipSelect <= 0;
		  
		  else if (iState == CLEAR_RESET_WAIT1) oChipSelect <= 1;
		  
		  // Default case should set plot to 0
		  else
				begin
					oPlot <= 0;
					oDone <= 0;
					start_load <= 1;
				end
    end
end
        

endmodule
