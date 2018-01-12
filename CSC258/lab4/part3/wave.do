onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand /shiftregister/SW
add wave -noupdate -expand /shiftregister/KEY
add wave -noupdate -expand /shiftregister/LEDR
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {166 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 140
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {76 ns}
