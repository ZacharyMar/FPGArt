# FPGArt
### Created by Zachary Mar and James Zhang
Drawing tool for the DE1-SoC FPGA and VGA output created using Verilog. Users use a PS2 Mouse to interface with the program. Right clicking draws in the selected colour and left clicking erases. Program allows users to save screen captures to off chip memory and load screen captures saved in memory.

## Outline
#### PS2 Mouse Interface
TODO:
- Research using PS2 mouse interface
- Create mouse interface module
- Determine how the position signals will be sent to datapath
- Determine button press to change FSM state
- Simulate module
- In lab testing

#### Drawing FSM
TODO:
- Create state diagram/table
- Determine signals handled in each state
- Create FSM module
- Simulate module

#### Drawing Datapath
TODO:
- Create schematic
- Create module
- Bound cursor to screen dimensions
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
