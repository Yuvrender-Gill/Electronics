# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all verilog modules in mux.v to working dir;
# could also have multiple verilog files.
vlog morsecode.v

# Load simulation using mux as the top level simulation module.
vsim MorseCode

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}


force {SW[0]} 0


force {SW[1]} 1

force {SW[2]} 0
force {KEY[0]} 1 0, 0 5
force {KEY[1]} 1 10, 0 13

force {CLOCK_50} 0 0 ns, 1 1 ns -r 2
run 100ns

force {SW[0]} 0


force {SW[1]} 1

force {SW[2]} 0
force {KEY[1]} 1 110, 0 111
run 100ns