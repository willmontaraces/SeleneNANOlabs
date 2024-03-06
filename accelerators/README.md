
# How to adapt an accelerator

To adapt an accelerator currently it has to have a axi-lite slave control port to interface with the processor. This port is only for configuration and control signaling.
Then the accelerator can have N AXI master ports that interface with memory across the crossbar. It needs to be noted that the examples provided only have one master port to interface with memory, but configuring the crossbar more ports can be had.

# Integrating a Xilinx RTL kernel

Xilinx RTL kernels and HLS accelerators implement the AXI4 lite and AXI4 interface.
They generally have one AXI4 lite slave control connection and one or various AXI4 master connections.

Currently there is only support for one accelerator concurrently, the ability to customize this will be added on further iterations. Also currently the crossbar and processor only implement AXI3, so some conversions need to be made as can be seen on our accelerator examples.

## Components
#### Anatomy of a Xilinx HLS accelerator
A xilinx HLS accelerator has a structure like what can be seen in [krnl_vadd_rtl.v](../accelerators/rtl_vadd/krnl_vadd_rtl.v), with AXI_lite control logic and AXI4 memory interface. The control logic is interfaced as memory mapped with the AXI_lite interface as described in  [krnl_vadd_rtl_control_s_axi.v](../accelerators/rtl_vadd/krnl_vadd_rtl_control_s_axi.v).

### Accelerator adaptation
To adapt a Xilinx RTL kernel as an accelerator we need to create a Verilog to VHDL conversion, this conversion involves two files:
- A VHDL package where we define the following:
	- The declaration of new intermediate wrapped datatypes to convert the unwrapped VHDL AXI signals into wrapped signals.
	* The description of the accelerator top level module on VHDL: this description should mimic the description given by the Verilog compiled code. [librtlacc](../accelerators/rtl_vadd/librtlacc.vhd)
	* The description of the new VHDL top level module of our accelerator. This is the component that will be instantiated by the rest of the system and should have it's AXI signals wrapped into the GAISLER signal types as presented in [librtlacc](../accelerators/rtl_vadd/librtlacc.vhd) to ease module interchangeability.
- A vhdl module that instantiates the raw system verilog top module and translates it's signals to the grlib axi vhdl types as presented in [rtl_add](rtl_vadd/rtl_add.vhd)

### Control signals
Xilinx HLS generated accelerators manage control signals via AXI_lite in an interface such as seen in [krnl_vadd_rtl_control_s_axi.v](../rtl_vadd/krnl_vadd_rtl_control_s_axi.v) in a memmory mapped manner.

The HLS accelerator control signals are connected in [selene_core.vhd](../selene-soc/rtl/selene_core.vhd) via the AXI_lite crossbar from the pulp library. To add a new accelerator you need to modify the number of target ports and the mapping of the axi_lite crossbar instance.
To modify this instance first you need to increase the number of target ports of the crossbar in [config.vhd](../selene-soc/selene-xilinx-vcu118/config.vhd) and add the new accelerator to the address map of the xbar_lite on [xbar_lite_wrapper](..//interconnect/wrapper/xbar_lite_wrapper.sv).

If the crossbar mapping has reached the full capacity, you need to increase the crossbar's address mapping via the AHB to AXI_lite bridge Plug&Play interface. The current configuration is an address space of 256 bytes on `0xfffc0010` . To modify this configuration access go to [`selene-hardware/selene-soc/rtl/gpp_sys.vhd`](../selene-soc/rtl/gpp_sys.vhd) and modify the `ahb2axi` component following the [Grlib manual - Section 5.3](https://www.gaisler.com/products/grlib/grlib.pdf).

### Data signals
The HLS generated accelerator will have it's data signals as AXI4 initiator interfaces that should be connected as initiators to our memory crossbar. To do so one must instantiate the accelerator on [`selene-hardware/selene-soc/rtl/selene_core.vhd`](../selene-soc/rtl/selene_core.vhd) and attach it's AXI4 outputs to the input vector of the crossbar `initiator_aximo` and `initiator_aximo`. These inputs should be correctly dimmensioned if the `CFG_AXI_N_INITIATORS` is set to the desired number of AXI4 master interfaces of the system.

If the HLS generated accelerator AXI4 data signals are of a width that is different than the default 128 bit width one must instantiate AXI4 width converters. To do so, we provide a simple operation mode. The top-level component of your accelerator should instantiate all AXI4 signals to the `AXI4wide_mosi_type` and `AXIwide_somi_type` types, thus overdimensioning all AXI4 signals to 512 bit wide signals but only populating the lower n bits of those signals. Then, on `selene_core.vhd` those signals need to be fed into instances of the `axi_dw_wrapper` component. This component takes a generic `AXISlvPortDataWidth` of the original data width of the signal (that should be present in the lower n bits of the AXI4wide signal) and converts it into `AXIMstPortDataWidth` that should be 128 for this platform. This 128 bit AXI_mosi and somi types are then fed into the `initiator_aximi` and `initiator_aximo` vectors.

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
