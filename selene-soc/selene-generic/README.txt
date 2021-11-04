SELENE Generic Design 
----------------------------------------------------------
This design is not tailored for a specific board

----------------------------------------------------------
The design has been tested with the following tools:

Mentor Modelsim 10.6a
Vivado 2018.1
----------------------------------------------------------
To simulate using Modelsim use the make targets:

  make map_xilinx_7series_lib
  make sim
  make sim-launch

----------------------------------------------------------
Synthesys is tailored for Xilinx Vivado 2018.1
   make vivado
   or
 make vivado-launch

----------------------------------------------------------
Important note:
The bitstream for this design is generated with unspecified pin location.
Do not use the bitstream to program an FPGA.

