RID := $(shell /bin/bash -c "openssl rand -hex 8")
linting_verilator_BSC:
	# This is a real example, once the PMU module is uploaded to the
	# repository, next 2 lines shhould be uncomented
	#bash ./ci-scripts/linting_verilator_BSC.sh
	#exit $?	
	exit 0

build:
	bash ./ci-scripts/build.sh
	exit $?

simulation_GLOBAL:
	bash ./ci-scripts/simulation_GLOBAL.sh
	exit $?

# This is an example of an individual simulation
#simulation_GLOBAL:
#	bash ./ci-scripts/simulation_INDV1.sh
#	exit $?

bitstream_generation:
	bash ./ci-scripts/bitstream_generation.sh
	exit $?

BSC_tests_software:
	bash ./ci-scripts/BSC_tests_software.sh
	exit $?

load_bitstream: 
	#Load bitstream to FPGA and configure ethernet 
	# ONLY SUPPORTED ON CAOS17 server 
	bash ./ci-scripts/request_fpga.sh $(RID)
	vivado -mode tcl -source ci-scripts/load_bitstream.tcl
	sleep 60
	grmon -u -v -digilent -jtagcable 2 -c ./ci-scripts/eth.tcl || bash /mnt/caos_hw/Programs/fpga_script/hardware_resources.sh gitlab-ci-$(RID) vcu118 UNLOCK
	sleep 60
	bash /mnt/caos_hw/Programs/fpga_script/hardware_resources.sh gitlab-ci-$(RID) vcu118 UNLOCK
	exit $?

attach_board:
	# Attach to board, capture output and check if connected to vcu118 
	# ONLY SUPPORTED ON CAOS17 server 
	bash ./ci-scripts/request_fpga.sh $(RID)
	touch attach_board.log 
	grmon -u -v -digilent -jtagcable 2 -c ci-scripts/info_sys.grmon | tee attach_board.log; cat attach_board.log | grep "Cobham Gaisler  NOEL-V RISC-V Processor" \
	|| bash /mnt/caos_hw/Programs/fpga_script/hardware_resources.sh gitlab-ci-$(RID) vcu118 UNLOCK
	bash /mnt/caos_hw/Programs/fpga_script/hardware_resources.sh gitlab-ci-$(RID) vcu118 UNLOCK
	exit $?
    
load_binary: 
	# Attach to board, Load C test, capture output check result
	# ONLY SUPPORTED ON CAOS17 server 
	bash ./ci-scripts/request_fpga.sh $(RID)
	touch load_binary.log 
	grmon -u -v -digilent -jtagcable 2  -c ci-scripts/c_test.grmon | tee load_binary.log; cat load_binary.log | grep "world" \
	|| bash /mnt/caos_hw/Programs/fpga_script/hardware_resources.sh gitlab-ci-$(RID) vcu118 UNLOCK
	bash /mnt/caos_hw/Programs/fpga_script/hardware_resources.sh gitlab-ci-$(RID) vcu118 UNLOCK
	exit $?
