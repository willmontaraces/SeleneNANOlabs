# Steps to integrate a HLS accelerator
1. Use Vitis HLS 2020.2. 
   Check accelerators/hlsIntegrationTool/setenv_2020.2.sh file and modify if necesary.

2. Set accelerators/hlsIntegrationTool/launch_vcu118_integration.sh file internal variables lines 7-25.
    
3. Execute accelerators/hlsIntegrationTool/launch_vcu118_integration.sh file.
    ```
    chmod 755 launch_vcu118_integration.sh
    ./launch_vcu118_integration.sh
    ```
4. Follow accelerators/hlsIntegrationTool/launch_vcu118_integration.sh steps when done.
   These steps will be printed once the script finishes.
    
5. At this point, the HLS accelerator is already integrated. To generate a bitfile use Vivado 2020.2:
	```
    export XILINX=/opt/Xilinx/Vivado/2020.2/ids_lite/ISE/
	. /opt/Xilinx/Vivado/2020.2/settings64.sh
	``` 