############################################################
## This file is generated automatically by Vitis HLS.
## Please DO NOT edit it.
## Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
############################################################

open_project HLSinf
set_top k_conv2D
add_files ../src/add.cpp -cflags "-D [lindex $argv 2]"
add_files ../src/add_data.cpp -cflags "-D [lindex $argv 2]"
add_files ../src/stm.cpp -cflags "-D [lindex $argv 2]"
add_files ../src/conv2D.h -cflags "-D [lindex $argv 2]"
add_files ../src/cvt.cpp -cflags "-D [lindex $argv 2]"
add_files ../src/direct_convolution.cpp -cflags "-D [lindex $argv 2]"
add_files ../src/dws_convolution.cpp -cflags "-D [lindex $argv 2]"
add_files ../src/join_split.cpp -cflags "-D [lindex $argv 2]"
add_files ../src/k_conv2D.cpp -cflags "-D [lindex $argv 2]"
add_files ../src/mul.cpp -cflags "-D [lindex $argv 2]"
add_files ../src/padding.cpp -cflags "-D [lindex $argv 2]"
add_files ../src/pooling.cpp -cflags "-D [lindex $argv 2]"
add_files ../src/read.cpp -cflags "-D [lindex $argv 2]"
add_files ../src/relu.cpp -cflags "-D [lindex $argv 2]"
add_files ../src/serialization.cpp -cflags "-D [lindex $argv 2]"
add_files ../src/winograd_convolution.cpp -cflags "-D [lindex $argv 2]"
add_files ../src/write.cpp -cflags "-D [lindex $argv 2]"
add_files ../src/batch_normalization.cpp -cflags "-D [lindex $argv 2]"
add_files -tb ../src/data_test.cpp -cflags "-D [lindex $argv 2] -Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"
add_files -tb ../src/test_arguments.cpp -cflags "-D [lindex $argv 2] -Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"
add_files -tb ../src/test_buffers.cpp -cflags "-D [lindex $argv 2] -Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"
add_files -tb ../src/test_check.cpp -cflags "-D [lindex $argv 2] -Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"
add_files -tb ../src/test_conv2D.cpp -cflags "-D [lindex $argv 2] -Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"
add_files -tb ../src/test_conv2D.h -cflags "-D [lindex $argv 2] -Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"
add_files -tb ../src/test_cpu.cpp -cflags "-D [lindex $argv 2] -Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"
add_files -tb ../src/test_file.cpp -cflags "-D [lindex $argv 2] -Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"
add_files -tb ../src/test_kernel.cpp -cflags "-D [lindex $argv 2] -Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"
add_files -tb ../src/test_print.cpp -cflags "-D [lindex $argv 2] -Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"
open_solution "[lindex $argv 2]" -flow_target vitis
set_part {xcvu9p-flga2104-2L-e}
create_clock -period 3.33 -name default
config_interface -default_slave_interface s_axilite -m_axi_alignment_byte_size 64 -m_axi_latency 64 -m_axi_max_widen_bitwidth 512 -m_axi_offset slave
config_rtl -register_reset_num 3
csynth_design
export_design -format ip_catalog
exit
