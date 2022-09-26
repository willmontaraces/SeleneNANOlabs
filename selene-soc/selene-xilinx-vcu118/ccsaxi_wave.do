onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/ahbmi
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/ahbsi_hmaster
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/axi_contention
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/BASE_BASIC
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/BASE_CCS_AHB
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/BASE_CCS_AXI_R
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/BASE_CCS_AXI_W
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/ccs_contention
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/ccs_latency
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/clk
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/cpu_ahb_access
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/cpus_ahbmo
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/dcache_miss
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/DCL2_ACCESS_EVENT
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/dcl2_events
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/DCL2_HIT_EVENT
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/DCL2_MISS_EVENT
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/END_BASIC
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/END_CCS_AHB
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/END_CCS_AXI_R
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/END_CCS_AXI_W
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/latency_cause_state
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/latency_state
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/mem_sniff_coreID_read_pending_o
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/mem_sniff_coreID_read_serving_o
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/mem_sniff_coreID_write_pending_o
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/mem_sniff_coreID_write_serving_o
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/n_latency_cause_state
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/n_latency_state
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/naxi_ccs
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/naxi_deep
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/ncpu
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/nout
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/pmu_events
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/pmu_input
add wave -noupdate -itemcolor Gold /testbench/cpu/cpu/core0/gpp0/gen_safeSU/ahb_latency_and_contention_inst/rstn
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/acc_ahbso
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/acc_interrupt
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/ahbmi
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/ahbmo
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/ahbmstart
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/ahbsi
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/ahbso
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/ahbsstart_gpp
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/ahbsstart_mem
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/apbi
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/apbo
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/apbstart_gpp
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/apbstart_mem
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/axi_contention
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/ccs_contention
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/ccs_latency
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/clkin
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/clkm
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/cpu0errn
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/cpus_ahbmo
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/dbgmi
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/dbgmo
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/disas
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/dsubreak
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/dsuen
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/fabtech
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/freeze
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/hq_mccu
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/hsidx_accel
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/hsidx_ahbrep
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/hsidx_ahbrom
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/hsidx_l2c
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/hsidx_pmu
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/io_ahbmi
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/io_ahbmo
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/io_ahbsi
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/io_ahbso
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/io_ahbsov_pnp
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/io_apbi
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/io_apbo
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/io_dbgmi
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/io_dbgmo
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/latency_cause_state
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/latency_state
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/mem_ahbsi
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/mem_ahbso
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/mem_apbi
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/mem_apbo
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/mem_aximi
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/mem_aximo
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/mem_sniff_coreID_read_pending_o
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/mem_sniff_coreID_read_serving_o
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/mem_sniff_coreID_write_pending_o
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/mem_sniff_coreID_write_serving_o
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/memtech
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/migmodel
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/n_latency_cause_state
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/n_latency_state
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/ncpu
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/ndbgmst
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/nev
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/nextapb
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/nextmst
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/nextslv
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/one_hmaster
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/pmu_events
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/pmue
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/rstn
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/simulation
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/u1i
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/u1o
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/uarti
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/uarto
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/vcc
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/xbar_l_aximi
add wave -noupdate -itemcolor {Green Yellow} /testbench/cpu/cpu/core0/gpp0/xbar_l_aximo
add wave -noupdate -itemcolor Cyan /testbench/cpu/cpu/core0/mem_sniff_coreID_read_pending_intg
add wave -noupdate -itemcolor Cyan /testbench/cpu/cpu/core0/mem_sniff_coreID_read_pending_intm
add wave -noupdate -itemcolor Cyan /testbench/cpu/cpu/core0/mem_sniff_coreID_read_pending_o
add wave -noupdate -itemcolor Cyan /testbench/cpu/cpu/core0/mem_sniff_coreID_read_serving_intg
add wave -noupdate -itemcolor Cyan /testbench/cpu/cpu/core0/mem_sniff_coreID_read_serving_intm
add wave -noupdate -itemcolor Cyan /testbench/cpu/cpu/core0/mem_sniff_coreID_read_serving_o
add wave -noupdate -itemcolor Cyan /testbench/cpu/cpu/core0/mem_sniff_coreID_write_pending_intg
add wave -noupdate -itemcolor Cyan /testbench/cpu/cpu/core0/mem_sniff_coreID_write_pending_intm
add wave -noupdate -itemcolor Cyan /testbench/cpu/cpu/core0/mem_sniff_coreID_write_pending_o
add wave -noupdate -itemcolor Cyan /testbench/cpu/cpu/core0/mem_sniff_coreID_write_serving_intg
add wave -noupdate -itemcolor Cyan /testbench/cpu/cpu/core0/mem_sniff_coreID_write_serving_intm
add wave -noupdate -itemcolor Cyan /testbench/cpu/cpu/core0/mem_sniff_coreID_write_serving_o
add wave -noupdate -itemcolor Magenta /testbench/cpu/cpu/core0/mem0/clkm0_mem_sniff
add wave -noupdate -itemcolor Magenta /testbench/cpu/cpu/core0/mem0/clkm1_mem_sniff
add wave -noupdate -itemcolor Magenta /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read
add wave -noupdate -itemcolor Magenta /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read_pending
add wave -noupdate -itemcolor Magenta -subitemconfig {/testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read_pending_o(15) {-itemcolor Magenta} /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read_pending_o(14) {-itemcolor Magenta} /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read_pending_o(13) {-itemcolor Magenta} /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read_pending_o(12) {-itemcolor Magenta} /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read_pending_o(11) {-itemcolor Magenta} /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read_pending_o(10) {-itemcolor Magenta} /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read_pending_o(9) {-itemcolor Magenta} /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read_pending_o(8) {-itemcolor Magenta} /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read_pending_o(7) {-itemcolor Magenta} /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read_pending_o(6) {-itemcolor Magenta} /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read_pending_o(5) {-itemcolor Magenta} /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read_pending_o(4) {-itemcolor Magenta} /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read_pending_o(3) {-itemcolor Magenta} /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read_pending_o(2) {-itemcolor Magenta} /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read_pending_o(1) {-itemcolor Magenta} /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read_pending_o(0) {-itemcolor Magenta}} /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read_pending_o
add wave -noupdate -itemcolor Magenta /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read_serving_o
add wave -noupdate -itemcolor Magenta /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_write_pending_o
add wave -noupdate -itemcolor Magenta /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_write_serving_o
add wave -noupdate -itemcolor Magenta /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_read_serving
add wave -noupdate -itemcolor Magenta /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_write
add wave -noupdate -itemcolor Magenta /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_write_pending
add wave -noupdate -itemcolor Magenta /testbench/cpu/cpu/core0/mem0/mem_sniff_coreID_write_serving
add wave -noupdate -itemcolor Magenta /testbench/cpu/cpu/core0/mem0/mem_sniff_read
add wave -noupdate -itemcolor Magenta /testbench/cpu/cpu/core0/mem0/mem_sniff_write
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {160931864 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 605
configure wave -valuecolwidth 318
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
configure wave -timelineunits sec
update
WaveRestoreZoom {0 ps} {953783250 ps}
