## TACLe Benchmarks for RISC-V using Gaisler tools

This folder contains the C code of some TACLe benchmarks ported to the RISC-V architecture as well as all the necessary scripts to compile the benchmarks and simulate/execute them.

Next all the folders and its contents are explained in detail:

**BSC_libraries:** It contains bare metal drivers to manage the SafeSU (PMU)[^*] and SafeDE (light lockstep) hardware peripherals. The drivers contain functions to perform all the actions that the hardware IP modules offer. 



**common:** [^**] It contains several files

* **crt.S:** It contains assembly code that is executed after the boot-loader and before the TACLe benchmark or the C code we want to execute

* **noelv.ld:** This files are the linker scripts that the makefile uses to compile the benchmarks.  There are four of them (noelv1.ld - noelv4.ld) one per core. If you want to employ more cores during the execution you should add more linker scripts. The linker scripts define two key parameters, the starting address of the compiled binary and the stack pointer[^***] address. If we want to load the same binary in different address spaces for different cores, an offset has to be applied between different linker scripts starting addresses.
* **syscalls.c:** It contains the definition of the bare metal system calls like for example the *hadle_trap* function in charge of handling the exceptions. The *thread_entry* function must be override for multi-thread executions (more than one core). Otherwise only one core will be allowed to make progress.



**uart:** It contains the C files defining the functions to control the UART hardware. It is important to match the definition of the UART base address in the C code with the physical address of the UART. Otherwise the UART will not work.



**lockstep_simulation_benchmarks:** It contains several files to perform the simulation. To do so we have to compile the C code, transform the binaries to the srec format and copy the srec file to the top of the design. You can add your own benchmarks adding in the source folder another folder named as the benchmark and containing the benchmark C files. Next we explain each folder and file more in detail:

* **common:** It contains the same files as in the *common* folder used for FPGA execution. In this case, the crt.S folder includes a modification that force each core to jump to its start address defined in the linker script. This also can be done changing the PC of the cores in the testbench by writing the appropriate registers of the debug module.

* **source**: It contains the C code of the benchmarks that we want to simulate. 
* **Makefile**: It contains the recipes to compile the benchmarks. This makefile does not use the RISC-V compiler developed by GAISLER and that could produce some issues during the simulation like some invalid instruction exceptions. 
* **compile_and_simulate.sh:** This scripts needs some arguments explained inside. One of them is the name of the test we want to execute. The name has to match with the name of the folder containing the test inside the source folder. The script compiles the code using the Makefile and converts all the binaries to a srec format. Finally it concatenates all the srec files into a single file which is copied to the top of the design as hello.srec (the name defined in the VHDL testbench).



**tacle-lockstep:** It contains some TACLe benchmarks that use SafeDE.  It also contains all the necessary scripts to compile the benchmarks and execute them in the FPGA using GRMON. You can add your own benchmarks adding a folder with the name of the benchmark and with the C files in the folder sources:

* **source:** It contains the C code of the benchmarks.
* **init_functions**: It defines some functions that are executed before and after executing the section of code that needs lockstepped execution (the TACLe benchmarks in this case)
* **Makefile:** It compiles the C code to generate the binaries that are loaded into the FPGA.
* **run_tacle.sh:** This bash script needs several arguments when it is called. These arguments are passed to the Makefile. The Makefile passes those parameters to the C code as defines to perform different experiments depending on their values. The script compiles the binaries and launches GRMON running a GRMON script found inside the *grmon_scripts* folder. This script can be easily adapted to any benchmark.
* **run_experiments:** It is a script to automatically launch several lockstep experiments and gather their results converting them to csv format using the script *results2csv.sh*.
* **grmon_scripts:** It contains the GRMON scripts that are used to activate the cores, load the binaries and control the execution.



**multicore_tests:** It contains a structure similar to *tacle-lockstep* folder with several different benchmarks and tests. The scripts could be obsolete. 



[^*]: SafeSU bare metal driver is an old version.  It could be not compatible with the last versions of the hardware.
[^**]: The files located here are used by the makefile used to compile binaries that are executed in the FPGA. For simulation, the folder common is replicated since some changes are applied to its files.
[^ *** ]: Stack pointer is not needed for this executions and hence it is not define in the linker scripts. However it could be necessary for some experiments. In those cases add this code in the linker script:

  . = 0x01fffff;
  .stack ():{
     . = ALIGN(0x10);
  }
