# Steps to generate a bitfile with HLSinf accelerator
1. Use Vivado and Vitis HLS 2020.2:
	```
    export XILINX=/opt/Xilinx/Vivado/2020.2/ids_lite/ISE/
	source /opt/Xilinx/Vivado/2020.2/settings64.sh
	source /opt/xilinx/xrt/setup.sh
	export XILINX_VIVADO=/opt/Xilinx/Vivado/2020.2
	export XILINX_XRT=/opt/xilinx/xrt
	export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu
	```
2. Be sure to enable HLSinf at selene-soc/selene-xilinx-vcu118/config.vhd file
    ```
	constant CFG_HLSINF_EN : integer := 1;
    ```
3. Generate a bitfile as usual using the selene-soc/selene-xilinx-vcu118/Makefile
