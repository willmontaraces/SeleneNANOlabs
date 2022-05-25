

ifeq ("$(GRLIB)","")
GRLIB=../../../../grlib
endif

RTL=../rtl
CLEAN=soft-clean

############  Board Setup  ########################

### Xilinx Vivado device and board setup
DESIGN=selene-generic

TECHNOLOGY=virtexup
PART=xcvu9p
PACKAGE=flga2104
SPEED=2l-e
DEVICE=$(PART)-$(PACKAGE)-$(SPEED)
XDC=xilinx-vcu118-xcvu9p.xdc
GRLIB_CONFIG=grlib_config.vhd

#CONFIG_GRETH_ENABLE=y
CONFIG_MIG_7SERIES=y
CONFIG_MIG_7SERIES_MODEL=y
############  Project  ########################

### Simulation Options ###
# Design Top Level
TOP=selene_soc

# Simulation top level
SIMTOP=testbench

# Uncomment for Modelsim or change to specify your simulator
GRLIB_SIMULATOR=ModelSim

# Options used during compilation
VCOMOPT=-explicit -O0

# GRLIB Options
VSIMOPT= -gdisas=1 -L secureip -L unisims_ver

# GRETH options
#ifeq ($(CONFIG_GRETH_ENABLE),y)
#VSIMOPT+= -L gig_ethernet_pcs_pma_v16_1_1
#endif


ifeq ($(CONFIG_MIG_7SERIES),y)
VSIMOPT+= -t 1ps -novopt
#VSIMOPT+= -t 1ps
ifndef CONFIG_MIG_7SERIES_MODEL
VSIMOPT+= -gUSE_MIG_INTERFACE_MODEL=false
ASIMOPT+= -gUSE_MIG_INTERFACE_MODEL=false
else
VSIMOPT+= -gUSE_MIG_INTERFACE_MODEL=true -t ps
ASIMOPT+= -gUSE_MIG_INTERFACE_MODEL=true -t ps
endif
endif


ifeq ($(CONFIG_MIG_7SERIES),y)
VIVADO_MIG_AXI=1
AXI_128=1
endif
VIVADO_IMPL_STRATEGY = Performance_SpreadSLLs

# Simulator switches
ifeq ("$(GRLIB_SIMULATOR)","ALDEC")
VSIMOPT+= +access +w -voptargs="+acc" +notimingchecks
else
VSIMOPT+=-novopt +notimingchecks
#VSIMOPT+= +notimingchecks -voptargs="+acc -nowarn 1" 
endif

GRLIB_XILINX_SOURCE_MGMT_MODE=DisplayOnly

# Remove collision check in UNSIM library
VSIMOPT+= -GSIM_COLLISION_CHECK="GENERATE_X_ONLY"
ASIMOPT+= -GSIM_COLLISION_CHECK="GENERATE_X_ONLY"

# Simulation scripts
VSIMOPT+= -do $(GRLIB)/bin/runvsim.do
ASIMDO = run -all

# Toplevel
VSIMOPT+= $(SIMTOP)

### End of Simulation Options ###

### Synthesize Options ###

### End of Synthesize Options ###

### Testbench, design and libraries to compile and not to compile

VHDLSYNFILES= 	config.vhd $(RTL)/ahbrom.vhd $(RTL)/io_sys.vhd $(RTL)/mem_sys.vhd $(RTL)/gpp_sys.vhd  $(RTL)/ddr4ram.vhd\
		 $(RTL)/ahb2axi_mig4_7series.vhd $(RTL)/selene_core.vhd $(RTL)/pads.vhd selene_soc.vhd  $(MEMTECH)


VHDLSIMFILES= testbench.vhd 

TECHLIBS = unisim
SKIP_SIM_TECHLIBS = 1

LIBSKIP = pci pci/pcif core1553bbc core1553brm srio core1553brt idt gr1553 corePCIF \
	tmtc openchip ihp spw gsi cypress hynix eth ge_1000baseX \
	spansion secureip usb ddr grdmac mmuconfig fmf esa micron spfi
DIRSKIP = b1553 pci gr1553b/core pci/pcif leon2 leon2ft srio idt crypto satcan pci ambatest \
	spacewire ascs slink irqmp grdmac grrm nand leon3v3 leon5 leon5v0 hcan can greth \
	pwm gr1553b iommu ac97 secureip mmuiface clk2x i2c spi canfd leon4v0 spacefibre ftaddr 
DIRADD = noelv noelvv0 riscv plic noelvsubsys

FILESKIP = grcan.vhd ddr2.v mobile_ddr.v adapters/sgmii.vhd iu4.vhd

include $(GRLIB)/bin/Makefile
include $(GRLIB)/software/noelv/Makefile

OBJCOPY_OPTS = --srec-len=16 --srec-forceS3
### Software ###
XLEN = 64
#EXTRA_PROM = --reverse-bytes=8
UART = 0

##################  project specific targets ##########################

### Simulation ###
#### Synthesis ###

cp-mig-files: scripts
	@echo "!!!!! Overwriting board mig files with local files"
	cp axi_128/mig.xci vivado/mig.xci
	cp axi_128/mig_cdc.xci vivado/mig_cdc.xci
	cp axi_128/axi_pipe.xci vivado/axi_pipe.xci

vivado-launch: cp-mig-files

vivado: cp-mig-files
