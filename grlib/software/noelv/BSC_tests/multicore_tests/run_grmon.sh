#usage ./run_grmon.sh benchmark_name number_cores
grmon_script=run.grmon
export MULTICORE_BENCHMARK=$1
export MULTICORE_BENCHMARK_NC=$2
grmon -digilent -u -v -jtagcable 2 -c $grmon_script
