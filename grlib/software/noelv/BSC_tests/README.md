## Tests for NoelV processor

There are two different folders with different test sources: *multicore_tests*, and *tests_for_simulation*.

##### Define your hardware
To let the recipes know what driver is required for the PMU/safeSU it is
required to define the env variable PMU_DRIVER and the path of the driver.
eg: 
    export PMU_DRIVER=$GRLIB/software/noelv/BSC_tests/BSC_libraries/safeSU/4-core
    export PMU_DRIVER=$GRLIB/software/noelv/BSC_tests/BSC_libraries/safeSU/6-core
##### tests_for_simulation

This folder contains only tests for simulation. To generate the binaries, you should execute **make #name of the test#.riscv**. If you want to compile all the tests at once, you should execute **make all**. Also, to compile one of the tests and start a simulation with QuestaSim, the script *compile_for_simulation* can be executed from *grlib/designs/noelv-xilinx-kcu105:* **./compile_for_simulation #name of the test#**.

##### multicore_tests

To compile any of the tests in sources folder you should do **make #name of the test#.riscv**. If you want to compile all the tests at once, you should execute **make all**. If you want to run one of the tests with GRMON, you should call the script **./run_grmon #name of the test#** if the test is not compiled it will be automatically compiled. You optionally can add as a parameter a "1" if you want to use one core instead of two **./run_grmon #name of the test# 1**.

