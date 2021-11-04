# launch this script with SYNTHESIS as it's argument for sinthetizable code
# launch this script with SIMULATION as it's argument for simulation code
PATH_TO_INTERCONNECT=../../interconnect/

NUMBER_INITIATORS=$(grep CFG_AXI_N_INITIATORS config.vhd | tr -dc '0-9')


cpp -P -D $1 ${PATH_TO_INTERCONNECT}libnoc/libnoc.vhc ${PATH_TO_INTERCONNECT}libnoc/libnoc.vhd
cpp -C -P -D $1 -D CFG_AXI_N_INITIATORS="${NUMBER_INITIATORS}" ${PATH_TO_INTERCONNECT}wrapper/axi_xbar_typedef_pkg.svc ${PATH_TO_INTERCONNECT}wrapper/axi_xbar_typedef_pkg.sv
cpp -P -D $1 -D CFG_AXI_N_INITIATORS="${NUMBER_INITIATORS}" ${PATH_TO_INTERCONNECT}libnoc/libnoc_pkg/libnoc_pkg.vhc ${PATH_TO_INTERCONNECT}libnoc/libnoc_pkg/libnoc_pkg.vhd


if [ $1 = SYNTHESIS ]
then
  ln -sf ../../common_cells/include/common_cells ${PATH_TO_INTERCONNECT}axi/src
  ln -sf ../include/axi ${PATH_TO_INTERCONNECT}axi/src
fi
