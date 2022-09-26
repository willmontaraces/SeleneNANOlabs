#!/bin/bash

results_folder=results
grmon_folder=grmon_scripts
MULTICORE_BENCHMARK=$1
#if active_cores is not specified, then active_cores will be set to its default value
active_cores_default=2
active_cores=$2

if [ -z "$active_cores" ] 
then
    active_cores=$active_cores_default
elif  [ 2 -eq $active_cores ] 
then
    echo The number of processors is less than $active_cores
    exit 1
fi
    
#depending of the number of active cores, a different grmon script will be executed
grmon_script=$grmon_folder/active_cores_$active_cores.grmon


#checks if the binary of the test that it is going to be executed exists and 
#if not, it is generated with the Makefile
if ! [ -d "$MULTICORE_BENCHMARK.riscv" ]; then
   make $MULTICORE_BENCHMARK.riscv
fi

export MULTICORE_BENCHMARK
mkdir -p $results_folder
#grmon -digilent -u -v -abaud  115200 -log $results_folder/$MULTICORE_BENCHMARK-$active_cores-cores -c $grmon_script
grmon -digilent -u -v -jtagcable 2 -log $results_folder/$MULTICORE_BENCHMARK-$active_cores-cores -c $grmon_script

