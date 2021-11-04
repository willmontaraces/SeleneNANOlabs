---------------------------------------------------
-------------- The SELENE SoC FPGA DESIGN ---------
---------------------------------------------------

The folders are organized in the following way:
   - rtl -> files common to the designs for all the different FPGAs/Boards.
   - selene-generic -> design not tailored for any specific FPGA
   - selene-xilinx-vcu118 -> Basic template design tailored for VCU118

Each design directory contains a top-level file that instantiates
the pads.vhd from the rtl/ directory.
Each design directory has its own version of the config.vhd file.

---------------------------------------------------

In order to build or simulate a design is necessary to set and export the environment variable GRLIB:

  export GRLIB=*path to GRLIB library folder*

