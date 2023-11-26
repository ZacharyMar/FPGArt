`timescale 1 ns / 1ns

module drawingControlPath(
	iResetn, 				// FSM reset
	iClk, 					// Source clock
	iBtnL, 					// Asserted if LMB pressed
	iBtnR, 					// Asserted if RMB pressed
	iDone, 					// Signal from datapath indicating process is complete
	iClear, 					// Signal from user to clear screen
	iMove, 					// Signal from datapath indicating mouse movement detected
	oState, 					// Output current state
	oEnableMouse, 			// Signal asserted to enable (1) or disable (0) mouse streaming
	oStartTransmission 	// Signal asserted to initiate host-to-mouse communication
	);
	// Inputs
	input wire iResetn, iClk, iBtnL, iBtnR, iDone, iClear, iMove;
	
	// Output
	output wire [3:0] oState;
	output reg oEnableMouse, oStartTransmission;
	
	// Regs
	reg [3:0] cur_state, nex_state;
	
	// States
	localparam IDLE 			= 4'd0,
				  MOVE 			= 4'd1,
				  WAIT 			= 4'd2,
				  CLEAN 			= 4'd3,
				  DRAW 			= 4'd4,
				  ERASE 			= 4'd5,
				  CLEAR_WAIT 	= 4'd6,
				  CLEAR 			= 4'd7,
				  RESET_MOUSE 	= 4'd8;
	  
   // Steps to trigger enable/disable of mouse:
	// 1. Have a buffer state before the state you want the mouse enabled/disabled
	// 2. In the buffer state, set the transmission signal high and the according command
	// 3. Transition to the desired state. In the state, set the transmission signal low.
				  
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
						else if (iClear) nex_state = CLEAR_WAIT;
						else nex_state = IDLE;
					end
					
				// These states involved outputting to VGA
				// Change state only when task is completed
				MOVE:
					begin
						if (iDone) nex_state = WAIT;
						else nex_state = MOVE;
					end
				// State for setting delay of animation (can delay to be in sync with monitor
				WAIT: nex_state = CLEAN;
				// Cleans the previous fragments from animation	
				CLEAN:
					begin
						if (iDone) nex_state = IDLE;
						else nex_state = CLEAN;
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
				
				// Wait for release of key to clear
				CLEAR_WAIT:
					begin
						if (!iClear) nex_state = CLEAR;
						else nex_state = CLEAR_WAIT;
					end
				CLEAR:
					begin
						if (iDone) nex_state = RESET_MOUSE;
						else nex_state = CLEAR;
					end
					
				// After reset of mouse, always go to IDLE state
				RESET_MOUSE: nex_state = IDLE;
				
				// Should default to idle state
				default: nex_state = IDLE;
			endcase
		end
		
	// Output signal logic
	always@(*)
		begin
			// Default signal values
			oStartTransmission = 0;
			oEnableMouse = 1;
			
			case (cur_state)				
				// Send signal to disable mouse before clearing screen
				CLEAR_WAIT:
					begin
						oStartTransmission = 1;
						oEnableMouse = 0;
					end
				// Send signal to enable mouse
				RESET_MOUSE:
					begin
						oStartTransmission = 1;
						oEnableMouse = 1;
					end
			endcase
		end
		
	// Current state register
	always@(posedge iClk, negedge iResetn)
		begin
			// Maybe change reset to clearing screen
			if(!iResetn) cur_state <= RESET_MOUSE; // Forces reset on mouse before entering idle state
			else cur_state <= nex_state;
		end
		
	assign oState = cur_state;
endmodule
