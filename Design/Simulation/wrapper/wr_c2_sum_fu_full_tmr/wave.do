onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /wr_c2_sum_fu_full_tmr_tb/tb_clk
add wave -noupdate /wr_c2_sum_fu_full_tmr_tb/tb_arstn
add wave -noupdate /wr_c2_sum_fu_full_tmr_tb/tb_in_a
add wave -noupdate /wr_c2_sum_fu_full_tmr_tb/tb_valid_a
add wave -noupdate /wr_c2_sum_fu_full_tmr_tb/tb_in_b
add wave -noupdate /wr_c2_sum_fu_full_tmr_tb/tb_valid_b
add wave -noupdate /wr_c2_sum_fu_full_tmr_tb/tb_ready_downs
add wave -noupdate /wr_c2_sum_fu_full_tmr_tb/tb_conf_wd
add wave -noupdate /wr_c2_sum_fu_full_tmr_tb/tb_ready_a
add wave -noupdate /wr_c2_sum_fu_full_tmr_tb/tb_ready_b
add wave -noupdate /wr_c2_sum_fu_full_tmr_tb/tb_out_data
add wave -noupdate /wr_c2_sum_fu_full_tmr_tb/tb_out_valid
add wave -noupdate /wr_c2_sum_fu_full_tmr_tb/tb_testing
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1049482 ps} 0}
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
