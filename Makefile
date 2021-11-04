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