#!/bin/bash
export XLEN=64
cp $1.riscv/$1-1.riscv /home/develop/selene-hardware/grlib/software/noelv/systest.riscv
cd /home/develop/selene-hardware/grlib/software/noelv
make ram.srec
mv ram.srec /home/develop/selene-hardware/selene-soc/selene-xilinx-vcu118
cd /home/develop/selene-hardware/grlib/software/noelv/BSC_tests/multicore_tests
