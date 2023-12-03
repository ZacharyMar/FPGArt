vlib work
vlog integratedCircuit.v drawingControlPath.v drawingDataPath.v ramDatapath.v
vsim -G SCREEN_WIDTH=10 -G SCREEN_HEIGHT=10 integratedCircuit

log {/*}
add wave {/*}

force {iClk} 1 0ns, 0 {5ns} -r 10ns
run 10ns

# Initialize
force {iResetn} 0
force {iClear} 0
force {iSlot0} 0
force {iSlot1} 0
force {iColour} 3'b111
force {iQ_r} 3'b000
force {iX_cell} 0
force {iY_cell} 0
force {iBtnL} 0
force {iBtnR} 0
run 10ns

# After reset, go to clear
force {iResetn} 1
run 1030ns

# Move to (1, 0)
force {iX_cell} 'd1
run 10ns

# oMove should be asserted
run 270ns

# oDone asserted
run 10ns

# Clean state
run 270ns

# Back to idle
run 20ns

# Draw in red
force {iColour} 3'b100
force {iBtnL} 1
run 130ns

# Move mouse while drawing to (1,1)
force {iY_cell} 'd1
run 780ns

# Release LMB and move back to (1, 0)
force {iBtnL} 0
force {iY_cell} 'd0
run 540ns

# Erase at (1, 0)
force {iBtnR} 1
run 130ns

# Move to (1, 1) while holding RMB
# Should move cursor, then erase in cell
force {iY_cell} 'd1
run 670ns

# Idle
force {iBtnR} 0
run 10ns

# Move to (0, 1) and draw in green
force {iX_cell} 'd0
force {iColour} 3'b010
force {iBtnL} 1
run 670ns

# Idle
force {iBtnL} 0
run 70ns

# Change to slot 1
force {iSlot1} 1
force {iQ_r} 3'b100
run 10ns

force {iSlot1} 0
run 2100ns

# Draw to (0, 0) in slot 1
force {iBtnL} 1
force {iColour} 3'b011
run 120ns

force {iBtnL} 0
run 10ns

# Switch save slot
force {iSlot0} 1
run 10ns

force {iSlot0} 0
run 2100ns

# should expect to see green at (0,1)

# Clear
force {iClear} 1
run 10ns

force {iClear} 0
run 1030ns


