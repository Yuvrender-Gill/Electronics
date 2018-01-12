vlib work

vlog -timescale 1ns/1ns VGA.v

vsim control

log {/*}

add wave {/*}

force {go} 1 0, 0 10 -r 40
force {resetn} 0 0,1 100
force {clk} 0 0,1 5 -r 10
force {draw} 1 0, 0 10 -r 160
run 500ns