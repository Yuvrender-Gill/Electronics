vlib work

vlog -timescale 1ns/1ps clkrcounter.v

vsim clkrcounter

log {/*}

add wave {/*}


force {SW[9]} 0
force {SW[0]} 0
force {SW[1]} 0
force {SW[2]} 0 0, 1 20
force {SW[3]} 1
force {CLOCK_50} 0 0, 1 10 -repeat 20
run 400ns