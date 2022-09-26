#!/bin/bash

#To use this script the name of the test has to be the first argument. The second argument
#is to execute Questa with the GUI or in batch mode. The third argument indicates the number
#of binaries that we want to transform to srec format and concatenate. 
#If you want to modify the number of binaries generated the Makefile and linker scripts should 
#be modified as well.
#A folder with the name of the tests and its source code must be in the folder sources.
#Example "./compile_and_simulate_2cores bitcount g" The g is to open the GUI. If the g
#is not added Questa will be executed in batch mode.

gui_flag=g
cores_number=$3

#The third argument is here override. Comment this line if you want to modify the number of cores 
#changing the argument when calling the script
cores_number=2

#It cleans the previous binaries and compiles new ones
make clean
make $1.riscv

echo $n
#This loop generates and concatenates all the srec files generated from the binaries
for (( n=1; n<=$cores_number; n++ ))
do  
    riscv64-unknown-elf-objcopy -O srec $1.riscv/$1-$n.riscv ram_temp2.srec   #It transforms the binary to a srec format
    #riscv64-unknown-elf-objcopy -O srec $1.riscv/$1-$n.riscv ram_temp1.srec
    #tclsh $GRLIB/bin/padsrec.tcl <ram_temp1.srec > ram_temp2.srec   ## This script may be executed. So far it fails if we execute it. 
                                                                     ##It may have to be with the compiler we use which it is not Gaisler's one
    cat ram_temp2.srec >> ram.srec  #Concatenate srec files into a single srec file
done
mv ram.srec $GRLIB/../selene-soc/selene-xilinx-vcu118/hello.srec
rm ram_temp1.srec
rm ram_temp2.srec


cd $GRLIB/../selene-soc/selene-xilinx-vcu118

#Launch Questa
echo $2
make selene-sim
if [ "$2" = "$gui_flag" ]
then 
    #make selene-sim
    make sim-launch
else
    make vsim-run
fi

#Clean binaries
cd $GRLIB/software/noelv/BSC_tests/lockstep_simulation_benchmarks
make clean
