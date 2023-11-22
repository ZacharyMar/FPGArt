`timescale 1 ns / 1ns

module drawingControlPath(iResetn, iClk, iBtnL, iBtnR, iDone, iClear, iMove, oState);
	// Inputs
	input wire iResetn, iClk, iBtnL, iBtnR, iDone, iClear, iMove;
	
	// Output
	output wire [2:0] oState;
	
	// Regs
	reg [2:0] cur_state, nex_state;
	
	// States
	localparam IDLE = 3'd0,
				  MOVE = 3'd1,
				  WAIT = 3'd2,
				  CLEAN = 3'd3,
				  DRAW = 3'd4,
				  ERASE = 3'd5,
				  CLEAR = 3'd6;
				  
	// Next state logic
	always@(*)
		begin: state_table
			case (cur_state)
				IDLE: 
					begin
						// Order of priority in idle state: move, draw, erase, clear
						if (iMove) nex_state = MOVE;
						else if (iBtnL) nex_state = DRAW;
						else if (iBtnR) nex_state = ERASE;
						else if (iClear) nex_state = CLEAR;
						else nex_state = IDLE;
					end
					
				// These states involved outputting to VGA
				// Change state only when task is completed
				MOVE:
					begin
						if (iDone) nex_state = WAIT;
						else nex_state = MOVE;
					end
				DRAW:
					begin
						if (iDone) nex_state = IDLE;
						else nex_state = DRAW;
					end
				ERASE:
					begin
						if (iDone) nex_state = IDLE;
						else nex_state = ERASE;
					end
				CLEAR:
					begin
						if (iDone) nex_state = IDLE;
						else nex_state = CLEAR;
					end
				// State for setting delay of animation (can delay to be in sync with monitor
				WAIT: nex_state = CLEAN;
				// Cleans the previous fragments from animation	
				CLEAN:
					begin
						if (iDone) nex_state = IDLE;
						else nex_state = CLEAN;
					end
				// Should default to idle state
				default: nex_state = IDLE;
			endcase
		end
		
	// Output signal logic
	// Might add signal to disable mouse data streaming
		
	// Current state register
	always@(posedge iClk, negedge iResetn)
		begin
			// Maybe change reset to clearing screen
			if(!iResetn) cur_state <= IDLE;
			else cur_state <= nex_state;
		end
		
	assign oState = cur_state;
endmodule