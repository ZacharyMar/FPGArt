# FPGArt
### Created by Zachary Mar and James Zhang
Drawing tool for the DE1-SoC FPGA created using Verilog. The canvas is displayed via VGA port and is 320px by 240px with 9-bit colour. Users use a PS2 Mouse to interface with the program. Right clicking draws in the selected colour and left clicking erases. Colours are selected by using the on board switches. The keys on the board are used to select the save slot the user is drawing to. The program supports up to two separate save slots.

## Demo Video
Watch the demo video on Youtube!

[![Watch the video](https://img.youtube.com/vi/P_KntpUst0I/default.jpg)](https://youtu.be/P_KntpUst0I)

## Try it Yourself
Installation instructions:
1. Download project from Github.
2. Open Quartus Prime and create a new project.
3. Add all the project files to the project.
4. Set the top-level module to FPGArt.v
5. Add the DE1_SoC.qsf file to assignments.
6. Compile the project and program the DE1-SoC board

Once programmed, FPGArt should be ready to use. Always begin by resetting the program by pressing KEY0.

Program I/O:
- KEY0: Reset the program (Will erase both save slots!)
- KEY1: Select save slot 0
- KEY2: Select save slot 1
- KEY4: Clear current save slot
- SW[9:7]: Intensity of red
- SW[6:4]: Intensity of green
- SW[3:1]: Intensity of blue
- 7-Segment Display: Shows the (x,y) position of the cursor in decimal
- PS2 Mouse: Left click to draw in select colour. Right click to erase.

## Module Descriptions

The following are key modules in this program. Given is a brief description and port connections to these modules (if applicable). Excluded are modules used to connect these modules together including mux and other logic circuits.

<ins>Quick Links:</ins>
- [PS2 Mouse Interface](#ps2-mouse-interface)
- [Central FSM](#central-fsm)
- [Drawing Datapath](#drawing-datapath)
- [VGA Adapter](#vga-adapter)
- [7 Segment Display](#7-segment-display)
- [Memory Interface](#memory-interface)
- [Memory Read/Write Datapath](#memory-read/write-datapath)

### PS2 Mouse Interface

Responsible for getting input from mouse and translating it to useable data in the datapath and FSM. Streams the mouse button click data and mouse movement data.


<ins>Input parameters:</ins>
- SCREEN_WIDTH: length of screen in the horizontal direction in pixels
- SCREEN_HEIGHT: length of screen in the vertical direction in pixels
- CELL_TICKS: number of mouse ticks required to span each cell (adjustable to change mouse sensitivity)
- HYSTERESIS: Used to calculate deadzone/threshold of mouse movement (i.e minimum amount of movement required to be taken as valid input)

<ins>Port declarations:</ins>

**Input:**
- start: singal asserted to initiate host to mouse communication
- send_enable: signal asserted to disable (0) or enable (1) mouse streaming
- reset: FSM reset signal
- CLOCK_50: DE1-SoC board clock (50Mhz)

**Inout (used for communication between host and mouse):**
- PS2_CLK: DE1-SoC PS2 clock signal
- PS2_DAT: DE1-SoC PS2 data signal

**Output:**
- button_left: indicates if left button is pushed (1) or not (0)
- button_right: indicates if right button is pushed (1) or not (0)
- button_middle: indicates if middle button is pushed (1) or not (0)
- cell_x: unsigned integer value representing selected cell in the x direction
- cell_y: unsigned integer value representing selected cell in the y direction

### Central FSM

Responsible for determining correct datapath signals to be used (i.e chooses which signals are valid from either drawing datapath or memory datapath). Also determines what processes should take place in the program at any given time.

<ins>Port Declarations:</ins>

**Input:**
- iResetn: active low reset signal for FSM
- iClk: source clock from DE1-SoC
- iBtnL: input from mouse module whether LMB is pressed
- iBtnR: input from mosue module whether RMB is pressed
- iDone: signal asserted from datapath when process is completed
- iClear: input from user to clear the screen (intended to be a key press on DE1-SoC)
- iMove: signal asserted from datapath when movement of mouse is detected
- iSlot0: signal asserted when loading data from save slot 0
- iSlot1: signal asserted when loading data from save slot 1

**Output:**
- oState: output signal indicating current state
- oEnableMouse: signal asserted to enable (1) or disable (0) mouse streaming
- oStartTransmission: signal asserted to initiate host-to-mouse communication
- oDatapathSelect: lets program know to use drawing datapath signals (0) or memory datapath signals (1)

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
- CHANGE_STATE0 (9): State entered when iSlot0 signal asserted. Program remains idle until iSlot0 is deasserted.
- CHANGE_STATE0_LOAD (10): State entered from (9) after iSlot0 is deasserted. Displays slot 0 from BRAM to VGA. Changes the chip select to write/read from slot 0.
- CHANGE_STATE1 (11): State entered when iSlot1 signal asserted. Program remains idle until iSlot1 is deasserted.
- CHANGE_STATE1_LOAD (12): State entered from (11) after iSlot1 is deasserted. Displays slot 1 from BRAM to VGA. Changes the chip select to write/read from slot 1.
- RESET STATES (13-16): States entered after iResetn signal deasserted. Clears both save slots and resets mouse. Transitions to (0) after resetting process finished.

**NOTE:** Priority of entering states from IDLE are as follows: CHANGE_STATE0, CHANGE_STATE1, MOVE, DRAW, ERASE, CLEAR_WAIT (i.e if multiple inputs are asserted at the same time, priority is given to state first in the list)

### Drawing Datapath

Used to assert signals when in a drawing state. Responsible for simutaneously generating output signals to VGA adapter to correctly draw what the user expects, and write to select memory slot.

<ins>Input Parameters:</ins>
- SCREEN_WIDTH: width of display monitor in pixels
- SCREEN_HEIGHT: height of display monitor in pixels

<ins>Port Declarations:</ins>

**Inputs:**
- iResetn: active low reset signal used to set default values
- iClk: source clock from DE1-SoC
- iX_cell: location of cell in the x direction, inputted from mouse module
- iY_cell: location of cell in the y direction, inputted from mouse module
- iColour: colour inputted from user
- iState: current state inputted from the FSM

**Outputs:**
- oX_pixel: location of pixel to draw in the x direction, outputted to VGA adapter
- oY_pixel: location of pixel to draw in the y direction, outputted to VGA adapter
- oDone: signal asserted when process is completed, outputted to FSM
- oColour: colour to draw in, outputted to VGA adapter
- oMove: signal asserted when mouse movement detected, outputted to FSM
- oPlot: signal asserted to draw to monitor, outputted to VGA adapter
- oAddress: calculated memory address of the current pixel being drawn to
- oWren: write enable signal to memory slot

### VGA Adapter

Modified VGA Adapter modules provided by the University of Toronto. Modified version allows for larger range of colour display and screen dimensions.

### 7 Segment Display

Included modules are the BIN2BCD converter and hex decoder. Responsible for converting given binary data on cursor position to decimal and displaying it for the user on the 7 segment displays.
Utilizes the double dapple algorithm to convert the x and y positions of the mouse cursor to binary coded decimal (BCD). The BCD data is then fed into the hex decoder where it correctly asserts the values to hex displays to the user.

### Memory Interface
Responsible for controlling access and the reading and writing to on-board BRAM memory, while interfacing directly with the ram datapath and indirectly with the drawing controlpath. Two total frame buffers are used (one for each save slot), each corresponding to its block of BRAM indexed by iChipSelect.

<ins>Port Declarations:</ins>

**Inputs:**
- iResetn: active low reset signal used to set default values
- iClk: source clock from DE1-SoC
- iChipSelect: input from memory datapath that specifies BRAM block to read/write to
- iData: input colour data to be written to memory
- iAddress: input address in memory to write to, directly indexed via x and y coordinates. 
- iWren: write enable signal asserted by drawing datapath when the current display is to be saved to memory

**Outputs:**
 - oQ: output bus storing colour information specified by input signals
   
### Memory Read/Write Datapath
Responsible for interfacing with the ram controller module and VGA adapter module to write a frame buffer from memory to the display, and from the display back to memory (save and load). 

<ins>Input Parameters:</ins>
- SCREEN_WIDTH: width of display monitor in pixels
- SCREEN_HEIGHT: height of display monitor in pixels

<ins>Port Declarations:</ins>

**Inputs:**
- iResetn: active low reset signal used to set default values
- iClk: source clock from DE1-SoC
- iState: current state inputted from the FSM
- iQ_ram: data read from memory specified at port oAddress inputted into the datapath

**Outputs:**
- ox: horizontal x location of pixel to draw from memory, outputted to VGA adapter
- oy: vertical y location of pixel to draw from memory, outputted to VGA adapter
- oDone: signal asserted when process is completed, outputted to FSM
- oAddress_ram: address passed to memory controller to specify read/write location
- oChipSelect: ChipSelect signal passed in to memory controller specifying which frame buffer (BRAM block) to perform write/read operations on
- oColour: 9 bit colour bus outputted to VGA controller read from memory
- oPlot: signal asserted to draw to monitor, outputted to VGA adapter
