# AXI NOC
For the NOC we are currently using the [pulp-platform xbar](https://github.com/pulp-platform/axi), this module is written on system verilog and the rest of our design is written on vhdl, so some considerations need to be made.
Due to circular dependencies and vhdl-verilog language mixing there are some duplicate configuration parameters for the XBAR that only manifest on synthesis.
Those configuration parameters are located on [`selene-hardware/interconnect/libnoc/libnoc_pkg`](libnoc/libnoc_pkg) and [`selene-hardware/interconnect/wrapper/axi_xbar_typedef_pkg.svc`](wrapper/axi_xbar_typedef_pkg.svc)
