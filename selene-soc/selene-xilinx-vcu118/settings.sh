case $(uname -n) in
md1pw58c)	# Konrad Schwarz, Siemens DE
	export VIVADO_LAB=vivado_lab
	if ! command -v $VIVADO_LAB > /dev/null
	then . /cygdrive/c/Programs/Xilinx/Vivado_Lab/2020.1/settings64.sh
	fi
	if ! command -v grmon
	then PATH=$PATH:\
/cygdrive/c/Programs/grmon-pro-gui-64-3.2.8.2/grmon-pro-3.2.8/windows/bin64
	fi
	;;

konservendose)	# Konrad Schwarz, Siemens DE
	export VIVADO_LAB=vivado_lab
	if ! command -v $VIVADO_LAB > /dev/null
	then . /usr/local/tools/Xilinx/Vivado_Lab/2020.2/settings64.sh
	fi
	if ! command -v grmon
	then PATH=$PATH:/usr/local/tools/grmon-pro-3.2.8/linux/bin64
	fi
	;;

*)	printf >&2 'Extend "%s" for your machine "%s"!' "$0" "$(uname -n)"
	return 1
esac
