# How to adapt an accelerator

To adapt an accelerator currently it has to have a axi-lite slave control port to interface with the processor. This port is only for configuration and control signaling.
Then the accelerator can have N AXI master ports that interface with memory across the crossbar. It needs to be noted that the examples provided only have one master port to interface with memory, but configuring the crossbar more ports can be had.

# Integrating a Xilinx RTL kernel

Xilinx RTL kernels and HLS accelerators implement the AXI4 lite and AXI4 interface.
They generally have one AXI4 lite slave control connection and one or various AXI4 master connections.

Currently there is only support for one accelerator concurrently, the ability to customize this will be added on further iterations. Also currently the crossbar and processor only implement AXI3, so some conversions need to be made as can be seen on our accelerator examples.

## Components

### Control signals
The AXI4 lite connection is currently connected to the AHB bus of the NOEL-V System. 

To see how it is connected and an example go to  [`selene-hardware/selene-soc/rtl/selene_core.vhd`](../selene-soc/rtl/selene_core.vhd). This AXI lite control interface can be addressed by the CPU at the address provided by the Plug&Play interface. 
The current configuration is an address space of 256 bytes on `0xfffc0010` .
To modify this configuration access go to [`selene-hardware/selene-soc/rtl/gpp_sys.vhd`](../selene-soc/rtl/gpp_sys.vhd) and modify the `ahb2axi` component following the [Grlib manual - Section 5.3](https://www.gaisler.com/products/grlib/grlib.pdf).

### Accelerator adaptation
To adapt a Xilinx RTL kernel as an accelerator we need two files:
- A vhdl package where we define intermediate types and two components ([Example](rtl_vadd/librtlacc.vhd)):
	* The description of the accelerator top level module on vhdl
	* The description of the vhdl top level module of our accelerator, it is recommended to follow the generic and port scheme presented on [`selene-hardware/accelerators/rtl_vadd/librtlacc.vhd`](rtl_vadd/librtlacc.vhd):`rtl_add` to ease module interchangeability.
- A vhdl module that instantiates the system verilog top module and translates it's signals to the grlib axi vhdl types. ([Example](rtl_vadd/rtl_add.vhd))

## Accelerator instantiation
To instantiate an accelerator replace the one currently instantiated on [`selene-hardware/selene-soc/rtl/selene_core.vhd`](../selene-soc/rtl/selene_core.vhd) with yours. If you followed the previous advice the interface should be identical and no further changes will be needed.

## Accelerator software interfacing
Currently we only support accelerator interfacing on bare metal mode.
You can see examples of accelerator software interfacing on:
- [`selene-hardware/accelerators/rtl_vadd/software`](rtl_vadd/software)
- [`selene-hardware/accelerators/SystolicArray-AXI/software`](SystolicArray-axi/software)

You can find the address offset of the control signals for each configurable parameter on `<Kernel_name>_rtl_control_s_axi.v`.
The base address of this module is that of your accelerator control interface, as described on the __Control signals__ section.
Once the accelerator is configured you can assert the __ap\_start__ signal and wait for an __ap\_done__ pulse by polling.

# Integrating a Vitis HLS kernel

Vitis HLS kernels implement the AXI4 lite and AXI4 interface.
We have designed an integration tool to automatically do the following steps:
- Vitis HLS kernel export
- Accelerator adaptation
- Accelerator instanciation

We can easily integrate these by using the hlsIntegrationTool as decribed in [`selene-hardware/accelerators/hlsIntegrationTool/README.md`](hlsIntegrationTool/README.md).

