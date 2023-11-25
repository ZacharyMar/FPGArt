vlib work
vlog drawingDataPath.v
vsim -G SCREEN_WIDTH=10 -G SCREEN_HEIGHT=10 drawingDataPath

log {/*}
add wave {/*}

force {iClk} 1 0ns, 0 {5ns} -r 10ns
run 10ns

# Initialize
force {iResetn} 0
force {iX_cell} 0
force {iY_cell} 0
force {iColour} 3'b100
force {iState} 0
run 10ns

# Move position (1,0)
force {iResetn} 1
force {iX_cell} 'd1
run 10ns

# oMove should be asserted
force {iState} 3'd1
run 260ns

# oDone asserted
force {iState} 3'd2
run 10ns

# Clean state
force {iState} 3'd3
run 260ns

# Back to idle
force {iState} 0
run 20ns

# Draw state
force {iState} 3'd4
run 100ns

force {iState} 0
run 10ns

# Erase
force {iState} 3'd5
run 100ns

force {iState} 0
force {iColour} 3'b110
run 20ns

# Move
force {iY_cell} 'd1
run 10ns

force {iState} 3'd1
run 260ns

force {iState} 3'd2
run 10ns

force {iState} 3'd3
run 260ns

force {iState} 3'd0
run 10ns

# Clear
force {iState} 3'd7
run 1010ns

force {iState} 3'd0
run 10ns
