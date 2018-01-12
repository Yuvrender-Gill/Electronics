vlib work

vlog -timescale 1ns/1ns part2.v

vsim control

log {/*}

add wave {/*}

force {ld} 0 0, 1 40, 0 60
force {reset_n} 0 0, 1 20
force {clk} 0 0, 1 10 -r 20
force {start} 0 0, 1 80, 0 0 100

run 500ns