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
	oStartTransmission, 	// Signal asserted to initiate host-to-mouse communication
	
	//j Memory signals
	iSlot0, //asserted when we load slot 0
	iSlot1, //load when we slot 1
	oDatapathSelect
	);
	// Inputs
	input wire iResetn, iClk, iBtnL, iBtnR, iDone, iClear, iMove;
	
	// Output
	output wire [4:0] oState;
	output reg oEnableMouse, oStartTransmission, oDatapathSelect;
	
	// Regs
	reg [4:0] cur_state, nex_state;
	// memory
	input wire iSlot1, iSlot0; 
	// States 
	localparam IDLE            = 5'd0,
				  MOVE 			= 5'd1,
				  WAIT 			= 5'd2,
				  CLEAN 			= 5'd3,
				  DRAW 			= 5'd4,
				  ERASE 			= 5'd5,
				  CLEAR_WAIT 	= 5'd6,
				  CLEAR 			= 5'd7,
				  RESET_MOUSE 	= 5'd8,
				  CHANGE_STATE0 = 5'd9,
				  CHANGE_STATE0_LOAD = 5'd10,
				  CHANGE_STATE1 = 5'd11,
				  CHANGE_STATE1_LOAD = 5'd12,
				  CLEAR_RESET_WAIT0 = 5'd13,
				  CLEAR_RESET_SLOT0 = 5'd14,
				  CLEAR_RESET_WAIT1 = 5'd15,
				  CLEAR_RESET_SLOT1 = 5'd16;
	  
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
						// Order of priority in idle state: load, move, draw, erase, clear
						if (iSlot0) nex_state = CHANGE_STATE0; //j added load states to the top as i think you should prioritize this over mouse when loading
            		else if (iSlot1) nex_state = CHANGE_STATE1;
						else if (iMove) nex_state = MOVE;

						else if (iBtnL) nex_state = DRAW;
						else if (iBtnR) nex_state = ERASE;
						else if (iClear) nex_state = CLEAR_WAIT;
						else nex_state = IDLE;
					end
					
				// These states involved outputting to VGA
				// Change state only when task is completed
				CHANGE_STATE0_LOAD: begin
					if(iDone) begin
						nex_state = IDLE;
					end
					else if (!iDone)begin
						nex_state = CHANGE_STATE0_LOAD;
					end					
				end
				//j memory states
				CHANGE_STATE0: begin 
					if(!iSlot0)begin
						nex_state = CHANGE_STATE0_LOAD;
					end
					else if(iSlot0)begin
						nex_state = CHANGE_STATE0;
						
					end
				end
				CHANGE_STATE1_LOAD: begin
					if(iDone) begin
						nex_state = IDLE;
					end
					else if(!iDone)begin
						nex_state = CHANGE_STATE1_LOAD;
					end
				end
				CHANGE_STATE1: begin
					if(!iSlot1)begin
						nex_state = CHANGE_STATE1_LOAD;
					end
					else if(iSlot1)begin
						nex_state = CHANGE_STATE1;
						
					end
				end
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
						if (iDone) nex_state = IDLE;
						else nex_state = CLEAR;
					end
				// After reset of mouse, always go to IDLE state
				RESET_MOUSE: nex_state = IDLE;
				
				CLEAR_RESET_WAIT0: nex_state = CLEAR_RESET_SLOT0;
				CLEAR_RESET_SLOT0:
					begin
						if (iDone) nex_state = CLEAR_RESET_WAIT1;
						else nex_state = CLEAR_RESET_SLOT0;
					end
				CLEAR_RESET_WAIT1: nex_state = CLEAR_RESET_SLOT1;
				CLEAR_RESET_SLOT1:
					begin
						if (iDone) nex_state = IDLE;
						else nex_state = CLEAR_RESET_SLOT1;
					end
				
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
			oDatapathSelect = 0;

			case (cur_state)				
				// Send signal to disable mouse before clearing screen (currently disabled)
				/*CLEAR_WAIT:
					begin
						oStartTransmission = 1;
						oEnableMouse = 0;
					end
				*/
				// Send signal to enable mouse
				RESET_MOUSE:
					begin
						oStartTransmission = 1;
						oEnableMouse = 1;
					end
				// Datapath to use signals from should be memory datapath
				CHANGE_STATE0: begin
					oDatapathSelect = 1;
				end
				CHANGE_STATE0_LOAD:begin
					 oDatapathSelect = 1;
				end
				CHANGE_STATE1: 
					begin
						oDatapathSelect = 1;
					end
				CHANGE_STATE1_LOAD:
					begin
						oDatapathSelect = 1;
					end
				CLEAR_RESET_WAIT0: oDatapathSelect = 1;
				CLEAR_RESET_WAIT1: oDatapathSelect = 1;
			endcase
		end
		
	// Current state register
	always@(posedge iClk, negedge iResetn)
		begin
			// Maybe change reset to clearing screen
			if(!iResetn) cur_state <=  CLEAR_RESET_WAIT0; // Forces reset on mouse before entering idle state
			else cur_state <= nex_state;
		end
		
	assign oState = cur_state;
endmodule
