onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ripple_carry_adder_tmr_tb/clk_tb
add wave -noupdate /ripple_carry_adder_tmr_tb/a_tb
add wave -noupdate /ripple_carry_adder_tmr_tb/b_tb
add wave -noupdate /ripple_carry_adder_tmr_tb/cin_tb
add wave -noupdate /ripple_carry_adder_tmr_tb/s_tb
add wave -noupdate /ripple_carry_adder_tmr_tb/of_tb
add wave -noupdate -expand /ripple_carry_adder_tmr_tb/DUT/internal_s
add wave -noupdate /ripple_carry_adder_tmr_tb/DUT/rca_majority_res
add wave -noupdate /ripple_carry_adder_tmr_tb/testing
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1680 ns}
