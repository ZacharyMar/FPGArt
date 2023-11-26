# FPGArt
### Created by Zachary Mar and James Zhang
Drawing tool for the DE1-SoC FPGA and VGA output created using Verilog. The program is designed for a 640 x 480 display. The canvas is divded into a grid of 5px by 5px cells. Users use a PS2 Mouse to interface with the program. Right clicking draws in the selected colour and left clicking erases. Program allows users to save screen captures to off chip memory and load screen captures saved in memory.

## Outline
#### PS2 Mouse Interface
✅VERIFIED WORKING IN LAB✅

Responsible for getting input from mouse and translating it to useable data in the datapath and FSM.

<ins>Input parameters:</ins>
- SCREEN_WIDTH: length of screen in the horizontal direction in pixels
- SCREEN_HEIGHT: length of screen in the vertical direction in pixels
- CELL_TICKS: number of mouse ticks required to span each cell (adjustable to change mouse sensitivity)
- HYSTERESIS: Used to calculate deadzone/threshold of mouse movement (i.e minimum amount of movement required to be taken as valid input)

<ins>Port declarations:</ins>

Input:
- start: singal asserted to initiate host to mouse communication
- send_enable: signal asserted to disable (0) or enable (1) mouse streaming
- reset: FSM reset signal
- CLOCK_50: DE1-SoC board clock (50Mhz)

Inout (used for communication between host and mouse):
- PS2_CLK: DE1-SoC PS2 clock signal
- PS2_DAT: DE1-SoC PS2 data signal

Output:
- button_left: indicates if left button is pushed (1) or not (0)
- button_right: indicates if right button is pushed (1) or not (0)
- button_middle: indicates if middle button is pushed (1) or not (0)
- cell_x: unsigned integer value representing selected cell in the x direction
- cell_y: unsigned integer value representing selected cell in the y direction

#### Drawing FSM
🟢WORKING SIMULATION

Responsible for controling the data used to draw to the output monitor and enabling mouse streaming.

<ins>Port Declarations:</ins>

Input:
- iResetn: active low reset signal for FSM
- iClk: source clock from DE1-SoC
- iBtnL: input from mouse module whether LMB is pressed
- iBtnR: input from mosue module whether RMB is pressed
- iDone: signal asserted from datapath when process is completed
- iClear: input from user to clear the screen (intended to be a key press on DE1-SoC)
- iMove: signal asserted from datapath when movement of mouse is detected

Output:
- oState: output signal indicating current state
- oEnableMouse: signal asserted to enable (1) or disable (0) mouse streaming
- oStartTransmission: signal asserted to initiate host-to-mouse communication

<ins>States</ins>
- IDLE (0): Central state. Listens for inputs into FSM to transition states.
- MOVE (1): State entered from IDLE when iMove signal asserted. Draws outline of selected cell in new position.
- WAIT (2): State entered from MOVE when iDone signal asserted. Acts as a delay between drawing and erasing cell outline.
- CLEAN (3): State entered from WAIT after delay. Erases the previously drawn location of the cell outline.
- DRAW (4): State entered from IDLE when iBtnL signal asserted. Fills in selected cell with selected colour.
- ERASE (5): State entered from IDLE when iBtnR signal asserted. Fills in selected cell with white.
- CLEAR_WAIT (6): State entered from IDLE when iClear is asserted. Acts as buffer state waiting for iClear to be de-asserted before clearing. Disables mouse.
- CLEAR (7): State entered from CLEAR_WAIT after iClear is de-asserted. Redraws the whole screen to be the default (blank cells with outlines).
- RESET_MOUSE (8): Buffer state that sends enable signal to mouse. Should be used after state where mouse is disabled. Transitions to IDLE.

NOTE: Priority of entering states from IDLE are as follows: MOVE, DRAW, ERASE, CLEAR_WAIT (i.e if multiple inputs are asserted at the same time, priority is given to state first in the list)

#### Drawing Datapath
🟢WORKING SIMULATION

Responsible for generating output signals to VGA adapter to correctly draw what the user expects.

<ins>Input Parameters:</ins>
- SCREEN_WIDTH: width of display monitor in pixels
- SCREEN_HEIGHT: height of display monitor in pixels

<ins>Port Declarations:</ins>

Inputs:
- iResetn: active low reset signal used to set default values
- iClk: source clock from DE1-SoC
- iX_cell: location of cell in the x direction, inputted from mouse module
- iY_cell: location of cell in the y direction, inputted from mouse module
- iColour: colour inputted from user
- iState: current state inputted from the FSM

Outputs:
- oX_pixel: location of pixel to draw in the x direction, outputted to VGA adapter
- oY_pixel: location of pixel to draw in the y direction, outputted to VGA adapter
- oDone: signal asserted when process is completed, outputted to FSM
- oColour: colour to draw in, outputted to VGA adapter
- oMove: signal asserted when mouse movement detected, outputted to FSM
- oPlot: signal asserted to draw to monitor, outputted to VGA adapter

#### Drawing Circuit
🟢WORKING SIMULATION

Top level module that allows other modules to interface with the drawing FSM + datapath.

<ins>Input Parameters:</ins>
- SCREEN_WIDTH: width of display monitor in pixels
- SCREEN_HEIGHT: height of display monitor in pixels

<ins>Port Declarations:</ins>

Inputs:
- iResetn: Global reset signal
- iClk: Source clock from DE!-SoC
- iClear: Signal asserted to begin clearing the screen
- iColour: Input from the user to select colour to draw in
- iX_cell: X coordinate of the current cell from the mouse
- iY_cell: Y coordinate of the current cell from the mouse
- iLeftbtn: Signal asserted when LMB pressed
- iRightbtn: Signal asserted when RMB pressed

Outputs:
- oStartTransmission: Signal asserted to initiate host-to-mouse communication
- oMouseEnable: Signal asserted/de-asserted to send the enable/disable streaming command the mouse
- oX_pixel: X coordinate of the pixel to draw at
- oY_pixel: Y coordinate of the pixel to draw at
- oColour: Colour to draw in
- oPlot: Asserted/De-asserted to enable/disable drawing to monitor

The drawing circuit is connected to the PS2 Mouse Interface and the VGA adapater. This module is responsible for all logic regarding drawing functionality and generating data used to draw to the monitor.

#### VGA Adapter
TODO:
- Connect to drawing circuit and configure inputs to match ports
- Modify to allow for larger colour range (bonus)
- Modify to allow for larger screen size display (640 x 480)
- Modify to allow for loading "saves" from off chip memory
- Simulate in lab

#### Memory Interface

#### Memory Read/Write FSM

#### Memory Read/Write Datapath
