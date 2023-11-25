vlib work
vlog drawingControlPath.v
vsim drawingControlPath

log {/*}
add wave {/*}

force {iClk} 1 0ns, 0 {5ns} -r 10ns
run 10ns

force {iResetn} 0
force {iBtnL} 0
force {iBtnR} 0
force {iDone} 0
force {iClear} 0
force {iMove} 0
run 10ns

# Idle
force {iResetn} 1
run 10ns

# Movement
force {iMove} 1
run 10ns

# Wait
force {iDone} 1
force {iMove} 0
run 10ns

# In clean state
force {iDone} 0
run 20ns

force {iDone} 1
run 10ns

# Draw
force {iDone} 0
force {iBtnL} 1
run 10ns

force {iBtnL} 0
run 20ns

force {iDone} 1
run 10ns

# Erase state
force {iDone} 0
force {iBtnR} 1
run 10ns

force {iBtnR} 0
run 20ns

force {iDone} 1
run 10ns

# Start clear
force {iDone} 0
force {iClear} 1
run 20ns

# Clear initiates after release
force {iClear} 0
run 20ns

force {iDone} 1
run 10ns

force {iDone} 0
run 10ns
