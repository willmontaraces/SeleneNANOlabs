proc import_acc {} {
	set vc ""

	if {[file exists "../../grlib/boards/xilinx-vcu118-xcvu9p/acc"]} {
		set k_conv2D_ip_list [glob -directory "../../grlib/boards/xilinx-vcu118-xcvu9p/acc" -- "*.xci"]
		foreach k_conv2D_ip $k_conv2D_ip_list {
			set k_conv2D_ip_basename [file rootname [file tail $k_conv2D_ip]]
			if { [file exists "vivado/$k_conv2D_ip_basename.xci"] == 0} {         
				file copy $k_conv2D_ip "vivado/"
				append vc "\nset_property target_language verilog \[current_project\]"
				append vc "\nimport_ip -files vivado/$k_conv2D_ip_basename.xci -name $k_conv2D_ip_basename"
				append vc "\nupgrade_ip \[get_ips $k_conv2D_ip_basename\]"
				append vc "\ngenerate_target  all \[get_files ./vivado/noelv-xilinx-vcu118/noelv-xilinx-vcu118.srcs/sources_1/ip/$k_conv2D_ip_basename/$k_conv2D_ip_basename.xci\] -force "
			}
		}
	} else {
		append vc "\n\n#WARNING: No ACC IP list was found\n\n"
	}

	set f [open vivado/selene_soc_vivado.tcl a]
	puts $f $vc
	close $f
}

import_acc
return


	
