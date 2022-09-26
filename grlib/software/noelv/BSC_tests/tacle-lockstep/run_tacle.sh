#!/bin/bash


#syntax:
#./run_tacles.sh tacle_name iterations active_cores lokcstep min_slack max_slack 


# iterations:   number of execution of each test 
# active_cores: 1 or 2 cores executing the tacle-benches
# lockstep:     1 to use lockstep, 0 not to use it
# min_slack:    minimum slack in the lockstep
# max_slack:    maximum slack in the lockstep


MULTICORE_BENCHMARK=$1

iterations=$2
iterations_default=10

active_cores=$3
active_cores_default=2

lockstep=$4
lockstep_default=1

min_slack=$5
min_slack_default=20

max_slack=$6
max_slack_default=50

if [ -z "$iterations" ]; then
    iterations=$iterations_default
    active_cores=$active_cores_default
    lockstep=$lockstep_default
    min_slack=$min_slack_default
    max_slack=$max_slack_default
fi

echo "Tacle name: $MULTICORE_BENCHMARK"
echo "iterations=$iterations active_cores=$active_cores lockstep=$lockstep min_slack=$min_slack max_slack=$max_slack" 

#Clean binaries and compile new ones. Some arguments are passed to the makefile and the makefile passes them to the C code to configure
#different experiments
make clean
make $MULTICORE_BENCHMARK.riscv iterations=$iterations active_cores=$active_cores lockstep=$lockstep min_slack=$min_slack max_slack=$max_slack 

#We export the name of the benchmark to a environment variable because later the GRMON TLC script will use this variable
export MULTICORE_BENCHMARK

#LOCK the FPGA
/mnt/caos_hw/Programs/fpga_script/hardware_resources.sh fbasjalo vcu118 LOCK
if [ $? -eq 1 ]; then exit 1; fi

#We define the grmon script we are going to execute when we run grmon and we launch grmon
grmon_script=grmon_scripts/active_cores_$active_cores.grmon
grmon -digilent -u -v -jtagcable 2 -c $grmon_script

#UNLOCK the FPGA
/mnt/caos_hw/Programs/fpga_script/hardware_resources.sh fbasjalo vcu118 UNLOCK

