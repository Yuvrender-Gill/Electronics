vlib work

vlog -timescale 1ns/1ns morseencoder.v

vsim morseencoder

log {/*}

add wave {/*}



force {SW[2: 0]} 2#110

force {KEY[1]} 1 0, 1 20

force {CLOCK_50} 0 0, 1 10 -r 20

force {KEY[0]} 0 0, 0 1, 0 2

run 1800ns