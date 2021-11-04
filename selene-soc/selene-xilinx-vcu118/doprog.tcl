###############################################################################
#  This file was developed as part of H2020 SELENE project.
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
###############################################################################
if {2019.2 <= [version -short]} {
	# exact version Vivado unclear
	open_hw_manager
} {
	open_hw
}

connect_hw_server {*}[switch [info hostname] md1pw58c {
	# Konrad Schwarz, Siemens DE
	list -url md1pw58c:3121
} konservendose {
	# Konrad Schwarz, Siemens DE
	list -url konservendose:3121
}
# other cases/machines go in line above
]

current_hw_target [get_hw_targets]
open_hw_target

# Program and Refresh the Device
current_hw_device [lindex [get_hw_devices] 0]
refresh_hw_device -update_hw_probes false [current_hw_device]
set_property PROGRAM.FILE bitfiles/selene_soc.bit [current_hw_device]

program_hw_devices [current_hw_device]
refresh_hw_device [current_hw_device]

close_hw_target
disconnect_hw_server

if {2019.2 <= [version -short]} {
	# exact version Vivado unclear
	close_hw_manager
} {
	close_hw
}

exit
