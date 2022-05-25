open_run synth_1 -name synth_1

if {[llength [get_cells {cpu/core0/gpp0/noelv0/cpuloop[0].core}]] > 0 } {
    create_pblock {pblock_cpuloop[0].core}
    add_cells_to_pblock [get_pblocks {pblock_cpuloop[0].core}] [get_cells -quiet [list {cpu/core0/gpp0/noelv0/cpuloop[0].core}]]
    resize_pblock [get_pblocks {pblock_cpuloop[0].core}] -add {SLICE_X3Y302:SLICE_X141Y359}
    resize_pblock [get_pblocks {pblock_cpuloop[0].core}] -add {DSP48E2_X1Y122:DSP48E2_X15Y143}
    resize_pblock [get_pblocks {pblock_cpuloop[0].core}] -add {LAGUNA_X0Y244:LAGUNA_X19Y359}
    resize_pblock [get_pblocks {pblock_cpuloop[0].core}] -add {RAMB18_X0Y122:RAMB18_X9Y143}
    resize_pblock [get_pblocks {pblock_cpuloop[0].core}] -add {RAMB36_X0Y61:RAMB36_X9Y71}
    resize_pblock [get_pblocks {pblock_cpuloop[0].core}] -add {URAM288_X0Y84:URAM288_X3Y95}
    set_property EXCLUDE_PLACEMENT 1 [get_pblocks {pblock_cpuloop[0].core}]
} else {
    puts "Floorplan: Core[0] not present in the SoC"
}


if {[llength [get_cells {cpu/core0/gpp0/noelv0/cpuloop[1].core}]] > 0 } {
    create_pblock {pblock_cpuloop[1].core}
    add_cells_to_pblock [get_pblocks {pblock_cpuloop[1].core}] [get_cells -quiet [list {cpu/core0/gpp0/noelv0/cpuloop[1].core}]]
    resize_pblock [get_pblocks {pblock_cpuloop[1].core}] -add {SLICE_X3Y363:SLICE_X141Y417}
    resize_pblock [get_pblocks {pblock_cpuloop[1].core}] -add {DSP48E2_X1Y146:DSP48E2_X15Y165}
    resize_pblock [get_pblocks {pblock_cpuloop[1].core}] -add {RAMB18_X0Y146:RAMB18_X9Y165}
    resize_pblock [get_pblocks {pblock_cpuloop[1].core}] -add {RAMB36_X0Y73:RAMB36_X9Y82}
    resize_pblock [get_pblocks {pblock_cpuloop[1].core}] -add {URAM288_X0Y100:URAM288_X3Y107}
    set_property EXCLUDE_PLACEMENT 1 [get_pblocks {pblock_cpuloop[1].core}]
} else {
    puts "Floorplan: Core[1] not present in the SoC"
}


if {[llength [get_cells {cpu/core0/gpp0/noelv0/cpuloop[2].core}]] > 0 } {
    create_pblock {pblock_cpuloop[2].core}
    add_cells_to_pblock [get_pblocks {pblock_cpuloop[2].core}] [get_cells -quiet [list {cpu/core0/gpp0/noelv0/cpuloop[2].core}]]
    resize_pblock [get_pblocks {pblock_cpuloop[2].core}] -add {SLICE_X3Y422:SLICE_X141Y478}
    resize_pblock [get_pblocks {pblock_cpuloop[2].core}] -add {DSP48E2_X1Y170:DSP48E2_X15Y189}
    resize_pblock [get_pblocks {pblock_cpuloop[2].core}] -add {RAMB18_X0Y170:RAMB18_X9Y189}
    resize_pblock [get_pblocks {pblock_cpuloop[2].core}] -add {RAMB36_X0Y85:RAMB36_X9Y94}
    resize_pblock [get_pblocks {pblock_cpuloop[2].core}] -add {URAM288_X0Y116:URAM288_X3Y123}
    set_property EXCLUDE_PLACEMENT 1 [get_pblocks {pblock_cpuloop[2].core}]
} else {
    puts "Floorplan: Core[2] not present in the SoC"
}


if {[llength [get_cells {cpu/core0/gpp0/noelv0/cpuloop[3].core}]] > 0 } {
    create_pblock {pblock_cpuloop[3].core}
    add_cells_to_pblock [get_pblocks {pblock_cpuloop[3].core}] [get_cells -quiet [list {cpu/core0/gpp0/noelv0/cpuloop[3].core}]]
    resize_pblock [get_pblocks {pblock_cpuloop[3].core}] -add {SLICE_X3Y482:SLICE_X141Y538}
    resize_pblock [get_pblocks {pblock_cpuloop[3].core}] -add {DSP48E2_X1Y194:DSP48E2_X15Y213}
    resize_pblock [get_pblocks {pblock_cpuloop[3].core}] -add {RAMB18_X0Y194:RAMB18_X9Y213}
    resize_pblock [get_pblocks {pblock_cpuloop[3].core}] -add {RAMB36_X0Y97:RAMB36_X9Y106}
    resize_pblock [get_pblocks {pblock_cpuloop[3].core}] -add {URAM288_X0Y132:URAM288_X3Y139}
    set_property EXCLUDE_PLACEMENT 1 [get_pblocks {pblock_cpuloop[3].core}]
} else {
    puts "Floorplan: Core[3] not present in the SoC"
}


if {[llength [get_cells {cpu/core0/gpp0/noelv0/cpuloop[4].core}]] > 0 } {
    create_pblock {pblock_cpuloop[4].core}
    add_cells_to_pblock [get_pblocks {pblock_cpuloop[4].core}] [get_cells -quiet [list {cpu/core0/gpp0/noelv0/cpuloop[4].core}]]
    resize_pblock [get_pblocks {pblock_cpuloop[4].core}] -add {SLICE_X2Y603:SLICE_X141Y657}
    resize_pblock [get_pblocks {pblock_cpuloop[4].core}] -add {DSP48E2_X1Y242:DSP48E2_X15Y261}
    resize_pblock [get_pblocks {pblock_cpuloop[4].core}] -add {RAMB18_X0Y242:RAMB18_X9Y261}
    resize_pblock [get_pblocks {pblock_cpuloop[4].core}] -add {RAMB36_X0Y121:RAMB36_X9Y130}
    resize_pblock [get_pblocks {pblock_cpuloop[4].core}] -add {URAM288_X0Y164:URAM288_X3Y171}
} else {
    puts "Floorplan: Core[4] not present in the SoC"
}


if {[llength [get_cells {cpu/core0/gpp0/noelv0/cpuloop[5].core}]] > 0 } {
    create_pblock {pblock_cpuloop[5].core}
    add_cells_to_pblock [get_pblocks {pblock_cpuloop[5].core}] [get_cells -quiet [list {cpu/core0/gpp0/noelv0/cpuloop[5].core}]]
    resize_pblock [get_pblocks {pblock_cpuloop[5].core}] -add {SLICE_X2Y662:SLICE_X141Y718}
    resize_pblock [get_pblocks {pblock_cpuloop[5].core}] -add {DSP48E2_X1Y266:DSP48E2_X15Y285}
    resize_pblock [get_pblocks {pblock_cpuloop[5].core}] -add {RAMB18_X0Y266:RAMB18_X9Y285}
    resize_pblock [get_pblocks {pblock_cpuloop[5].core}] -add {RAMB36_X0Y133:RAMB36_X9Y142}
    resize_pblock [get_pblocks {pblock_cpuloop[5].core}] -add {URAM288_X0Y180:URAM288_X3Y187}
} else {
    puts "Floorplan: Core[5] not present in the SoC"
}


if {[llength [get_cells {cpu/core0/FFI_GEN.FFICORE}]] > 0 } {
    create_pblock pblock_FFI_GEN.FFICORE
    add_cells_to_pblock [get_pblocks pblock_FFI_GEN.FFICORE] [get_cells -quiet [list cpu/core0/FFI_GEN.FFICORE]]
    resize_pblock [get_pblocks pblock_FFI_GEN.FFICORE] -add {SLICE_X153Y61:SLICE_X161Y238}
    resize_pblock [get_pblocks pblock_FFI_GEN.FFICORE] -add {RAMB18_X10Y26:RAMB18_X11Y93}
    resize_pblock [get_pblocks pblock_FFI_GEN.FFICORE] -add {RAMB36_X10Y13:RAMB36_X11Y46}

    set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
    set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
    set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
    connect_debug_port dbg_hub/clk [get_nets clk]
} else {
    puts "Floorplan: FFICORE not present in the SoC"
}


set projpath [get_property DIRECTORY [current_project]] 
file mkdir $projpath/noelv-xilinx-vcu118.srcs/constrs_1/new
close [ open $projpath/noelv-xilinx-vcu118.srcs/constrs_1/new/floorplan.xdc w ]
add_files -fileset constrs_1 $projpath/noelv-xilinx-vcu118.srcs/constrs_1/new/floorplan.xdc
set_property target_constrs_file $projpath/noelv-xilinx-vcu118.srcs/constrs_1/new/floorplan.xdc [current_fileset -constrset]
save_constraints -force
set_property used_in_synthesis false [get_files  $projpath/noelv-xilinx-vcu118.srcs/constrs_1/new/floorplan.xdc]
set_property used_in_implementation true [get_files  $projpath/noelv-xilinx-vcu118.srcs/constrs_1/new/floorplan.xdc]
close_design
