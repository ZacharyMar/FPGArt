vlib work
vlog drawingControlPath.v drawingDataPath.v drawingCircuit.v
vsim -G SCREEN_WIDTH=10 -G SCREEN_HEIGHT=10 drawingCircuit

log {/*}
add wave {/*}

force {iClk} 1 0ns, 0 {5ns} -r 10ns
run 10ns

force {iResetn} 0
force {iClear} 0
force {iColour} 3'b111
force {iX_cell} 0
force {iY_cell} 0
force {iLeftbtn} 0
force {iRightbtn} 0
run 10ns

# Idle
force {iResetn} 1
run 20ns

# Move mouse to (1, 0)
force {iX_cell} 'd1
run 540ns

# Draw at (1,0) in red
force {iColour} 3'b100
force {iLeftbtn} 1
run 130ns

# Move to (1, 1) while holding LMB
# Should move cursor first, then draw in cell
force {iY_cell} 'd1
run 670ns

# Release LMB and move back to (1, 0)
force {iLeftbtn} 0
force {iY_cell} 'd0
run 540ns

# Erase at (1, 0)
force {iRightbtn} 1
run 130ns

# Move to (1, 1) while holding RMB
# Should move cursor, then erase in cell
force {iY_cell} 'd1
run 670ns

# Idle
force {iRightbtn} 0
run 10ns

# Move to (0, 1) and draw in green
force {iX_cell} 'd0
force {iColour} 3'b010
force {iLeftbtn} 1
run 670ns

# Idle
force {iLeftbtn} 0
run 70ns

# Clear
force {iClear} 1
run 10ns

force {iClear} 0
run 1030ns

# Move to (0, 0)
force {iY_cell} 'd0
run 600ns

# Clear
force {iClear} 1
run 10ns

force {iClear} 0
run 1050ns