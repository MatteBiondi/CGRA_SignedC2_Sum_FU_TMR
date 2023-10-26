onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/clk_tb
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/arstn_tb
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/in_a
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/valid_a
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/in_b
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/valid_b
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/ready_downs
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/conf_wd
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/ready_a
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/ready_b
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/out_data
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/out_valid
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/testing
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/DUT/int_data_from_fifo1
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/DUT/int_data_from_fifo2
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/DUT/int_payload_from_fifo1_to_rca
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/DUT/int_payload_from_fifo2_to_rca
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/DUT/int_flag_from_fifo1_to_flag_slc
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/DUT/int_flag_from_fifo2_to_flag_slc
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/DUT/int_flag_from_flag_gen_to_flag_slc
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/DUT/int_valid_from_fifo1
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/DUT/int_valid_from_fifo2
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/DUT/int_valid_to_out_reg
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/DUT/int_flag_from_flag_slc_to_out_reg
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/DUT/int_of_from_rca_to_flag_gen
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/DUT/int_sum_from_rca
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/DUT/int_data_to_out_reg
add wave -noupdate -height 25 /c2_sum_fu_full_tmr_tb/DUT/int_data_from_out_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {850000 ps} 0}
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
