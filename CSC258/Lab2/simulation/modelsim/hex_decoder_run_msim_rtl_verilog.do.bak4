transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/h/u11/c6/01/gillyuv2/CSC258/Lab2 {/h/u11/c6/01/gillyuv2/CSC258/Lab2/hex_decoder.v}

vlog -vlog01compat -work work +incdir+/h/u11/c6/01/gillyuv2/CSC258/Lab2 {/h/u11/c6/01/gillyuv2/CSC258/Lab2/hex_decoder.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  hex_decoder

add wave *
view structure
view signals
run -all
