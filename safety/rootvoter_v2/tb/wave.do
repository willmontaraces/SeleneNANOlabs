onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /RVC_test/dif/NSETS
add wave -noupdate -radix hexadecimal /RVC_test/dif/state_internal
add wave -noupdate -radix hexadecimal /RVC_test/dif/cfg
add wave -noupdate /RVC_test/RVC_inst/config_ok
add wave -noupdate -radix hexadecimal /RVC_test/dif/clk
add wave -noupdate -radix hexadecimal /RVC_test/dif/reset
add wave -noupdate /RVC_test/RVC_inst/C0/cnt
add wave -noupdate /RVC_test/RVC_inst/counter_expired
add wave -noupdate /RVC_test/RVC_inst/all_datasets_loaded
add wave -noupdate /RVC_test/RVC_inst/dataset_cnt
add wave -noupdate -radix hexadecimal -childformat {{{/RVC_test/dif/sets[0]} -radix hexadecimal} {{/RVC_test/dif/sets[1]} -radix hexadecimal} {{/RVC_test/dif/sets[2]} -radix hexadecimal} {{/RVC_test/dif/sets[3]} -radix hexadecimal} {{/RVC_test/dif/sets[4]} -radix hexadecimal} {{/RVC_test/dif/sets[5]} -radix hexadecimal} {{/RVC_test/dif/sets[6]} -radix hexadecimal}} -expand -subitemconfig {{/RVC_test/dif/sets[0]} {-height 15 -radix hexadecimal} {/RVC_test/dif/sets[1]} {-height 15 -radix hexadecimal} {/RVC_test/dif/sets[2]} {-height 15 -radix hexadecimal} {/RVC_test/dif/sets[3]} {-height 15 -radix hexadecimal} {/RVC_test/dif/sets[4]} {-height 15 -radix hexadecimal} {/RVC_test/dif/sets[5]} {-height 15 -radix hexadecimal} {/RVC_test/dif/sets[6]} {-height 15 -radix hexadecimal}} /RVC_test/dif/sets
add wave -noupdate -radix hexadecimal -childformat {{{/RVC_test/dif/valid[6]} -radix hexadecimal} {{/RVC_test/dif/valid[5]} -radix hexadecimal} {{/RVC_test/dif/valid[4]} -radix hexadecimal} {{/RVC_test/dif/valid[3]} -radix hexadecimal} {{/RVC_test/dif/valid[2]} -radix hexadecimal} {{/RVC_test/dif/valid[1]} -radix hexadecimal} {{/RVC_test/dif/valid[0]} -radix hexadecimal}} -expand -subitemconfig {{/RVC_test/dif/valid[6]} {-height 15 -radix hexadecimal} {/RVC_test/dif/valid[5]} {-height 15 -radix hexadecimal} {/RVC_test/dif/valid[4]} {-height 15 -radix hexadecimal} {/RVC_test/dif/valid[3]} {-height 15 -radix hexadecimal} {/RVC_test/dif/valid[2]} {-height 15 -radix hexadecimal} {/RVC_test/dif/valid[1]} {-height 15 -radix hexadecimal} {/RVC_test/dif/valid[0]} {-height 15 -radix hexadecimal}} /RVC_test/dif/valid
add wave -noupdate -radix hexadecimal -childformat {{{/RVC_test/dif/match_cnt[0]} -radix hexadecimal} {{/RVC_test/dif/match_cnt[1]} -radix hexadecimal} {{/RVC_test/dif/match_cnt[2]} -radix hexadecimal} {{/RVC_test/dif/match_cnt[3]} -radix hexadecimal} {{/RVC_test/dif/match_cnt[4]} -radix hexadecimal} {{/RVC_test/dif/match_cnt[5]} -radix hexadecimal} {{/RVC_test/dif/match_cnt[6]} -radix hexadecimal}} -expand -subitemconfig {{/RVC_test/dif/match_cnt[0]} {-height 15 -radix hexadecimal} {/RVC_test/dif/match_cnt[1]} {-height 15 -radix hexadecimal} {/RVC_test/dif/match_cnt[2]} {-height 15 -radix hexadecimal} {/RVC_test/dif/match_cnt[3]} {-height 15 -radix hexadecimal} {/RVC_test/dif/match_cnt[4]} {-height 15 -radix hexadecimal} {/RVC_test/dif/match_cnt[5]} {-height 15 -radix hexadecimal} {/RVC_test/dif/match_cnt[6]} {-height 15 -radix hexadecimal}} /RVC_test/dif/match_cnt
add wave -noupdate -radix hexadecimal /RVC_test/dif/match_vector
add wave -noupdate -radix hexadecimal -childformat {{{/RVC_test/dif/status[14]} -radix hexadecimal} {{/RVC_test/dif/status[13]} -radix hexadecimal} {{/RVC_test/dif/status[12]} -radix hexadecimal} {{/RVC_test/dif/status[11]} -radix hexadecimal} {{/RVC_test/dif/status[10]} -radix hexadecimal} {{/RVC_test/dif/status[9]} -radix hexadecimal} {{/RVC_test/dif/status[8]} -radix hexadecimal} {{/RVC_test/dif/status[7]} -radix hexadecimal} {{/RVC_test/dif/status[6]} -radix hexadecimal} {{/RVC_test/dif/status[5]} -radix hexadecimal} {{/RVC_test/dif/status[4]} -radix hexadecimal} {{/RVC_test/dif/status[3]} -radix hexadecimal} {{/RVC_test/dif/status[2]} -radix hexadecimal} {{/RVC_test/dif/status[1]} -radix hexadecimal} {{/RVC_test/dif/status[0]} -radix hexadecimal}} -expand -subitemconfig {{/RVC_test/dif/status[14]} {-height 15 -radix hexadecimal} {/RVC_test/dif/status[13]} {-height 15 -radix hexadecimal} {/RVC_test/dif/status[12]} {-height 15 -radix hexadecimal} {/RVC_test/dif/status[11]} {-height 15 -radix hexadecimal} {/RVC_test/dif/status[10]} {-height 15 -radix hexadecimal} {/RVC_test/dif/status[9]} {-height 15 -radix hexadecimal} {/RVC_test/dif/status[8]} {-height 15 -radix hexadecimal} {/RVC_test/dif/status[7]} {-height 15 -radix hexadecimal} {/RVC_test/dif/status[6]} {-height 15 -radix hexadecimal} {/RVC_test/dif/status[5]} {-height 15 -radix hexadecimal} {/RVC_test/dif/status[4]} {-height 15 -radix hexadecimal} {/RVC_test/dif/status[3]} {-height 15 -radix hexadecimal} {/RVC_test/dif/status[2]} {-height 15 -radix hexadecimal} {/RVC_test/dif/status[1]} {-height 15 -radix hexadecimal} {/RVC_test/dif/status[0]} {-height 15 -radix hexadecimal}} /RVC_test/dif/status
add wave -noupdate /RVC_test/RVC_inst/state_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6096 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 236
configure wave -valuecolwidth 157
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
WaveRestoreZoom {0 ns} {1226 ns}
