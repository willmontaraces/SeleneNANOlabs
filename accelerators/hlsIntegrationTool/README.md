# Steps to integrate a HLS accelerator
1. Use Vitis HLS 2020.2. 
   Check accelerators/hlsIntegrationTool/setenv_2020.2.sh file and modify if necesary.

2. Be sure to enable HLSinf at selene-soc/selene-xilinx-vcu118/config.vhd file
    ```
   constant CFG_HLSINF_EN : integer := 1;
    ```
3. Execute accelerators/hlsIntegrationTool/launch_vcu118_integration_HLSinf.sh file.
    ```
    chmod 755 launch_vcu118_integration_HLSinf.sh
    ./launch_vcu118_integration_HLSinf.sh 1
    ```
4. Follow accelerators/hlsIntegrationTool/launch_vcu118_integration_HLSinf.sh steps when done.
   These steps will be printed once the script finishes.
    
5. At this point, the HLS accelerator is already integrated. To generate a bitfile use Vivado 2020.2 using the selene-soc/selene-xilinx-vcu118/Makefile as usual.
