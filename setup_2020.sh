echo "launch this script as . setup.sh"
## THIS SCRIPT SHOULD BE LAUNCHED ON THE selene-hardware directory ##
export GRLIB=$PWD/grlib
RESULT="Script execution succesful"


HOSTNAME=$(hostname)
CURRENT_HOST="fractal"

#If we are not currently on the peak8 machine some tuning is needed, warn the user
if [[ "$HOSTNAME" != "$CURRENT_HOST" ]]; then
	echo "WARNING: This script has some machine-dependant instructions that should be tuned for each machine, please change the variables accourdingly"
	RESULT="Script execution not succesful, please follow the instructions shown on screen"
else	
	# Vivado 2018.1 is recomended, but we use 2018.2 instead as it is the version currently installed on our system
	# THIS WILL ONLY WORK ON THE PEAK8 MACHINE
	export XILINX=/opt/Xilinx/Vivado/2020.2/ids_lite/ISE/


	# this should be your vivado 2018.1 configuration script, on our system it is located on the following path
	# THIS WILL ONLY WORK ON THE PEAK8 MACHINE
	. /opt/Xilinx/Vivado/2020.2/settings64.sh 
fi

#Adding Questasim to the path
export PATH=/opt/questasim/bin/:$PATH

#UPV licensing server
export LM_LICENSE_FILE=1717@lic-mentor.upv.es:2100@lic-xilinx.upv.es:29000@158.42.250.86

#Enviorenment variable necessary
export GRLIB_SIMULATOR=Questa

#NCC
export PATH=$PATH:/opt/ncc-1.0.0-gcc/bin 
#export PATH=/opt/grmon-pro-3.2.13/linux/bin64:$PATH

SELENE_HARDWARE=${PWD}
if [[ "$SELENE_HARDWARE" == *selene-hardware ]] 
then
	export GRLIB=$SELENE_HARDWARE/grlib 
	export PATH=$SELENE_HARDWARE/grlib/software/noelv/riscv-gnu-toolchain/bin:$PATH
else
	echo "ERROR: Please locate this script on the selene repository root folder named selene-hardware"
	RESULT="Script execution not succesful, please follow the instructions shown on screen"
fi

echo $RESULT
