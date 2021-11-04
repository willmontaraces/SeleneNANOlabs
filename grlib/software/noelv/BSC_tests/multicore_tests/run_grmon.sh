grmon_script=run.grmon
export MULTICORE_BENCHMARK=$1
grmon -digilent -u -v -jtagcable 2 -jtagcfg /home/osala/repos/selene-hardware/selene-soc/selene-xilinx-vcu118/conf_file.txt -c $grmon_script
