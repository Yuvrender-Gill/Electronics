vlib work

vlog -timescale 1ns/1ps slow_counter.v

vsim slow_counter

log {/*}

add wave {/*}


force {SW[9]} 1
force {SW[0]} 1
force {SW[1]} 0
force {SW[2]} 1 0, 1 20
force {SW[3]} 0
force {CLOCK_50} 0 0, 1 10 -repeat 20
run 400ns