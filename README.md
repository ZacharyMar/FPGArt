# FPGArt
### Created by Zachary Mar and James Zhang
Drawing tool for the DE1-SoC FPGA and VGA output created using Verilog. The program is designed for a 640 x 480 display. The canvas is divded into a grid of 5px by 5px cells. Users use a PS2 Mouse to interface with the program. Right clicking draws in the selected colour and left clicking erases. Program allows users to save screen captures to off chip memory and load screen captures saved in memory.

## Outline
#### PS2 Mouse Interface
##### VERIFIED WORKING IN LAB
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
TODO:
- ~Create state diagram/table~
- ~Determine signals handled in each state~
- Create FSM module
- Simulate module

#### Drawing Datapath
TODO:
- ~Create schematic~
- Create module
- Indicator for current mouse location?
- Simulate module
- Integrate with drawing FSM for high level module

#### VGA Adapter
TODO:
- Modify provided VGA adapter to handle inputs provided by top level drawing module
- Simulate in lab

#### Memory Interface

#### Memory Read/Write FSM

#### Memory Read/Write Datapath
