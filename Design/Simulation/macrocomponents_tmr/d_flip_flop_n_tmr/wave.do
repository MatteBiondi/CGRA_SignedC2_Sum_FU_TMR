onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /d_flip_flop_n_tmr_tb/clk_tb
add wave -noupdate /d_flip_flop_n_tmr_tb/arstn_tb
add wave -noupdate /d_flip_flop_n_tmr_tb/en_tb
add wave -noupdate -radix decimal /d_flip_flop_n_tmr_tb/d_tb
add wave -noupdate -radix decimal /d_flip_flop_n_tmr_tb/q_tb
add wave -noupdate -radix decimal -childformat {{/d_flip_flop_n_tmr_tb/DUT/internal_q(0) -radix decimal} {/d_flip_flop_n_tmr_tb/DUT/internal_q(1) -radix decimal} {/d_flip_flop_n_tmr_tb/DUT/internal_q(2) -radix decimal}} -expand -subitemconfig {/d_flip_flop_n_tmr_tb/DUT/internal_q(0) {-radix decimal} /d_flip_flop_n_tmr_tb/DUT/internal_q(1) {-radix decimal} /d_flip_flop_n_tmr_tb/DUT/internal_q(2) {-radix decimal}} /d_flip_flop_n_tmr_tb/DUT/internal_q
add wave -noupdate /d_flip_flop_n_tmr_tb/testing
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1165034 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {0 ps} {2205 ns}
