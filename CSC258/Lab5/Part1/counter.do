vlib work

vlog -timescale 1ns/1ns Counter_8_bit.v

vsim Counter_8_bit

log {/*}

add wave {/*}

force {enable} 1

force {clk} 0 0, 1 10 -r 20

force {clear_b} 1 0, 0 5, 1 10

run 2000 ns