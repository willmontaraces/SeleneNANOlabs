# selene-hardware
This repository holds the SELENE hardware platform.

Remember to clone this repository recursively, as interconnect/axi and interconnect/common\_cells are submodules.
To simulate the SoC and/or generate the SELENE plaftorm for the VCU118 follow the instructions at **selene-soc/selene-xilinx-vcu118/README.txt**

The directories are organized as follows:

| Path | Description |
| ------ | ----------| 
|grlib | GRLIB IP core library |
|grlib/bin | GRLIB infrastructure |
|grlib/boards | Board description files |
|grlib/designs | Template designs |
|grlib/doc | GRLIB documentation |
|grlib/lib | GRLIB IP core RTL code |
|grlib/software | NOEL-V example software |
|selene-soc | SELENE SoC directory |
|selene-soc/rtl | Design files common to all FPGAs |
|selene-soc/selene-generic | Generic template design |
|selene-soc/selene-xilinx-vcu118 | Template design tailored for VCU118 |
|accelerators | Colection of tested HLS generated IP cores |
|safety | Safety related IP cores |
|interconnect | Interconnect submodules and bridging logic |

This project was inititiated in the context of the European Union’s Horizon 2020 SELENE project under grant agreement no. 871467 and is currently updated and maintained in the context of the Chips Joint Undertaking project ISOLDE with grant no. 101112274