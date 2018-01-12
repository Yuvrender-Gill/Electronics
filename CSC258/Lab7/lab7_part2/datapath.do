vlib work

vlog -timescale 1ns/1ns VGA.v

vsim datapath

log {/*}

add wave {/*}

force {clk} 0 0,1 5 -r 10
force {resetn} 1 
force {ld_x} 1
force {ld_y} 1 
force {ld_c} 1 
force {coordinate_in} 7'b00000010
force {color_in} 3'b010 
run 300ns