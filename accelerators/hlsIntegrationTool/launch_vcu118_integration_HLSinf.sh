#!/bin/bash

usage() {   echo "Usage: ./launch_vcu118_integration_HLSinf.sh <DEBUG>"
      echo
      1>&2; exit 1;
    }

# exit when any command fails
set -e

# Debug mode by default, all prints are set
DEBUG=$1

if [ -z "$1" ]; then
  DEBUG=1
fi
# Implementation name i.e. conv
imple_name=conv
# Top file module name i.e. k_conv2D
top_name=k_conv2D
# Main selene project folder i.e. selene-hardware
selene_project_base_dir=${PWD}/../../

#Main hls accelerator folder name i.e. HLSinf
hls_folder_name=accelerators/HLSinf
hls_folder_base_dir=${selene_project_base_dir}$hls_folder_name

# This folder normally contains a file called ".project" i.e. project/HLSinf
hls_project_base_dir=project/HLSinf
# Folder where other solutions are allocated
hls_project_solutions_dir=${hls_folder_base_dir}/${hls_project_base_dir}
hls_project_scripts_dir=${hls_folder_base_dir}/scripts

if [ $DEBUG -ne "1"  ]; then
    exec > /dev/null
fi

cd $selene_project_base_dir
# git clone https://github.com/PEAK-UPV/HLSinf.git $hls_folder_base_dir
cd $hls_folder_base_dir
# git checkout develop
# git checkout 57291dd84be2c5c264fd96e7a91dd287dac5ffce

CHECK=$(ls | grep -w "scripts" | wc -l)
if [ $CHECK -ne "1"  ]; then
    git submodule update --init --recursive
fi


CHECK=$(ls | grep -w "pyscript2.py" | wc -l)
if [ $CHECK -ne "0"  ]; then
    rm pyscript2.py
fi
touch src/conv2D_out.h
cat << EOF > pyscript2.py
#!/usr/bin/python
import sys

hls_folder_base_dir = sys.argv[1]

with open(str(hls_folder_base_dir) + '/src/conv2D_out.h', 'w') as filename_out:  # Outfile name changed
    with open(str(hls_folder_base_dir) + '/src/conv2D.h', 'r') as filename_in:
        Lines = filename_in.readlines()
        for line in Lines:
            if(line.startswith("#define HLSINF_1_15")):
                newlines = ('//#define HLSINF_1_15\n')
                filename_out.write(newlines)
            elif(line.startswith("//#define HLSINF_1_0")):
                newlines = ('#define HLSINF_1_0  // U200, 4x4,  FP32:             DIRECT_CONV, RELU, STM, CLIPPING,        POOLING, BN, ADD, UPSIZE\n')
                filename_out.write(newlines)
            else:
                filename_out.write(line)
    filename_in.close()
filename_out.close()
EOF

chmod 755 pyscript2.py
./pyscript2.py ${hls_folder_base_dir}
rm pyscript2.py
rm src/conv2D.h
mv src/conv2D_out.h src/conv2D.h

touch scripts/vcu118_csynth.tcl
CHECK=$(ls | grep -w "pyscript2.py" | wc -l)
if [ $CHECK -ne "0"  ]; then
    rm pyscript2.py
fi
cat << EOF > pyscript2.py
#!/usr/bin/python
import sys

hls_project_scripts_dir = sys.argv[1]

with open(str(hls_project_scripts_dir) + '/vcu118_csynth.tcl', 'w') as filename_out:  # Outfile name changed
    newlines = ('open_project HLSinf\n'
                'set_top k_conv2D\n'
                'add_files ../src/add.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files ../src/add_data.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files ../src/stm.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files ../src/conv2D.h -cflags "-D [lindex \$argv 2]"\n'
                'add_files ../src/cvt.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files ../src/direct_convolution.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files ../src/dws_convolution.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files ../src/join_split.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files ../src/k_conv2D.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files ../src/mul.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files ../src/padding.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files ../src/pooling.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files ../src/read.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files ../src/relu.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files ../src/serialization.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files ../src/winograd_convolution.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files ../src/write.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files ../src/batch_normalization.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files -tb ../src/data_test.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files -tb ../src/test_arguments.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files -tb ../src/test_buffers.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files -tb ../src/test_check.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files -tb ../src/test_conv2D.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files -tb ../src/test_conv2D.h -cflags "-D [lindex \$argv 2]"\n'
                'add_files -tb ../src/test_cpu.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files -tb ../src/test_file.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files -tb ../src/test_kernel.cpp -cflags "-D [lindex \$argv 2]"\n'
                'add_files -tb ../src/test_print.cpp -cflags "-D [lindex \$argv 2]"\n'
                'open_solution "[lindex \$argv 2]" -flow_target vitis\n'
                'set_part {xcvu9p-flga2104-2L-e}\n'
                'create_clock -period 3.33 -name default\n'
                'config_interface -default_slave_interface s_axilite -m_axi_alignment_byte_size 64 -m_axi_latency 64 -m_axi_max_widen_bitwidth 512 -m_axi_offset slave\n'
                'config_rtl -register_reset_num 3\n'
                '# source "./HLSinf/vcu118/directives.tcl"\n'
                '# csim_design -O -setup\n'
                'csynth_design\n'
                '# cosim_design -wave_debug -trace_level all\n'
                'export_design -rtl verilog -format ip_catalog\n'
                'exit\n')
    filename_out.write(newlines)
filename_out.close()
EOF

chmod 755 pyscript2.py
./pyscript2.py ${hls_project_scripts_dir}
rm pyscript2.py

cd $hls_project_solutions_dir
CHECK=$(ls | grep -w "vcu118" | wc -l)
if [ $CHECK -ne "1"  ]; then
    cd $hls_folder_base_dir
    chmod +x scripts/setenv_2020.2.sh
    source scripts/setenv_2020.2.sh
    cd project
    vitis_hls -f ../scripts/vcu118_csynth.tcl HLSINF_1_0
    cd $hls_project_solutions_dir
    mkdir vcu118
    cp -a HLSINF_1_0/. vcu118/.
fi


CHECK=$(ls | grep -w "vcu118_export$" | wc -l)
if [ $CHECK -ne "1"  ]; then
    mkdir vcu118_export
    unzip -d ./vcu118_export/ ./vcu118/impl/export.zip
fi

#Copy needed files in selene-hardware project
cd $selene_project_base_dir/accelerators
touch dirs2.txt

CHECK=$(ls | grep -w "pyscript2.py" | wc -l)
if [ $CHECK -ne "0"  ]; then
    rm pyscript2.py
fi
cat << EOF > pyscript2.py
#!/usr/bin/python
import sys

imple_name = sys.argv[1]
done = 0

with open('dirs2.txt', 'w') as filename_out:  # Outfile name changed
    with open('dirs.txt', 'r') as filename_in:
        Lines = filename_in.readlines()
        for line in Lines:
            if(line.startswith(str(imple_name))):
                filename_out.write(line)
                done = 1
            else:
                filename_out.write(line)
        if(done==0):
            newlines = (str(imple_name)+'/src\n'
                        +str(imple_name)+'/src/libraries\n')
            filename_out.write(newlines)
    filename_in.close()
filename_out.close()
EOF
chmod 755 pyscript2.py
./pyscript2.py ${imple_name}
rm dirs.txt
mv dirs2.txt dirs.txt
rm pyscript2.py


CHECK=$(find ./${imple_name}/ | grep -w "./${imple_name}" | wc -l)
if [ $CHECK -ne "0"  ]; then
    cd ${imple_name}
    CHECK=$(ls | grep -w "src" | wc -l)
    if [ $CHECK -ne "0"  ]; then
        rm -r ./src
    fi
    cd ..
else
    mkdir $selene_project_base_dir/accelerators/${imple_name}
fi
mkdir $selene_project_base_dir/accelerators/${imple_name}/src
mkdir $selene_project_base_dir/accelerators/${imple_name}/src/libraries
cd $selene_project_base_dir/accelerators/${imple_name}/src
cp -a $hls_project_solutions_dir/vcu118_export/hdl/verilog/. .
find *.v > vlogsyn.txt
touch vlogsyn.txt
touch vhdlsyn.txt
echo "${imple_name}_pkg.vhd" >> vhdlsyn.txt
echo "${imple_name}_kernel.vhd" >> vhdlsyn.txt

#Copy *.tcl files from verilog folder
CHECK=$(ls $hls_project_solutions_dir/vcu118/impl/verilog | grep '.tcl$' | wc -l)
if [ $CHECK -ne "0"  ]; then
    cp $hls_project_solutions_dir/vcu118/impl/verilog/*.tcl .
fi

#Copy *.vhd files corresponding to ip cores from vhdl folder
cd libraries
CHECK=$(find $hls_project_solutions_dir/vcu118_export/hdl/vhdl | grep "dsp" | wc -l)
if [ $CHECK -ne "0"  ]; then
    find $hls_project_solutions_dir/vcu118_export/hdl/vhdl/ | grep "dsp" | xargs cp -t .
    find *.vhd > vhdlsyn.txt
fi

#Copy IP-cores
cd $selene_project_base_dir/grlib/boards/xilinx-vcu118-xcvu9p/
CHECK=$(ls | grep -w "acc" | wc -l)
if [ $CHECK -ne "0"  ]; then
    rm -r acc
fi
mkdir acc
cd acc
CHECK=$(find $hls_project_solutions_dir/vcu118/impl/ip | grep ./tmp.srcs | wc -l)
if [ $CHECK -ne "0"  ]; then
    cp $hls_project_solutions_dir/vcu118/impl/ip/tmp.srcs/sources_1/ip/*/* .
else
    cd ..
    rm -r acc
fi

#Copy software driver files
cd $selene_project_base_dir/accelerators/${imple_name}
CHECK=$(ls | grep -w "software$" | wc -l)
if [ $CHECK -ne "1"  ]; then
    mkdir software
fi
cd software
CHECK=$(ls | grep -w "k_conv2D_v1_0$" | wc -l)
if [ $CHECK -ne "0"  ]; then
    rm -r k_conv2D_v1_0
fi
mkdir k_conv2D_v1_0
mkdir k_conv2D_v1_0/src 
cd k_conv2D_v1_0/src
cp $hls_project_solutions_dir/vcu118_export/drivers/k_conv2D_v1_0/src/xk_conv2d.c .
cp $hls_project_solutions_dir/vcu118_export/drivers/k_conv2D_v1_0/src/xk_conv2d.h .
cp $hls_project_solutions_dir/vcu118_export/drivers/k_conv2D_v1_0/src/xk_conv2d_hw.h .

#Generate instance wrapper with python script
cd $selene_project_base_dir/accelerators/${imple_name}/src
touch ${imple_name}_pkg.vhd
touch ${imple_name}_kernel.vhd
touch ../../../selene-soc/rtl/selene_core2.vhd

CHECK=$(ls | grep -w "pyscript2.py" | wc -l)
if [ $CHECK -ne "0"  ]; then
    rm pyscript2.py
fi
cat << EOF > pyscript2.py
#!/usr/bin/python
import sys

print '\n\nStarting python parser to generate instance wrapper'

imple_name = sys.argv[1]
top_name = sys.argv[2]
max_ports = 16
interrupt = 0
usingGMEM0 = 0
placeHolder_written = 0
placeHolder_finished = 0

print 'Get number of ports and number of with for every port variable'
print '\n'
port_list = []
tupla_data = (0,0)
tupla_addr = (0,0)
tupla_id = (0,0)
tupla = (0,0,0)

print 'Format of port_list'
print 'Index order'
print "     Port [0]:    GMEM[PORT_ID, DATA_WIDTH, ADDR_WIDTH, ID_WIDTH]"
print "     Port [1-X]:  GMEMX[PORT_ID, GMEMDATA_WIDTH, ADDR_WIDTH, ID_WIDTH]"
print "     Port [last]: CONTROL[PORT_ID, DATA_WIDTH, ADDR_WIDTH, ID_WIDTH]"
print '\n'

print 'Getting information from '+str(top_name) + '.v file'
with open(str(top_name) + '.v', 'r') as filename_in:
    Lines = filename_in.readlines()
    for line in Lines:
        # Get GMEM0 port status
        if(line.startswith("parameter    C_M_AXI_GMEM0_DATA_WIDTH")):
            usingGMEM0 = 1
        # Get with values for GMEM port
        if(line.startswith("parameter    C_M_AXI_GMEM_DATA_WIDTH") or line.startswith("parameter    C_M_AXI_GMEM0_DATA_WIDTH")):
            tupla_data = line.split(" = ")
            tupla_data[0] = tupla_data[0].strip("parameter ")
            tupla_data[1] = tupla_data[1].strip(";\n")
        elif(line.startswith("parameter    C_M_AXI_GMEM_ADDR_WIDTH") or line.startswith("parameter    C_M_AXI_GMEM0_ADDR_WIDTH")):
            tupla_addr = line.split(" = ")
            tupla_addr[0] = tupla_addr[0].strip("parameter ")
            tupla_addr[1] = tupla_addr[1].strip(";\n")
        elif(line.startswith("parameter    C_M_AXI_GMEM_ID_WIDTH") or line.startswith("parameter    C_M_AXI_GMEM0_ID_WIDTH")):
            tupla_id = line.split(" = ")
            tupla_id[0] = tupla_id[0].strip("parameter ")
            tupla_id[1] = tupla_id[1].strip(";\n")
    tupla = (0, tupla_data[1],tupla_addr[1],tupla_id[1])
    port_list.append(tupla)

    for i in range(1, max_ports):
        found = False
        for line in Lines:
            # Get with values for the rest of GMEM ports
            if(line.startswith('parameter    C_M_AXI_GMEM' + str(i) + '_DATA_WIDTH')):
                tupla_data = line.split(" = ")
                tupla_data[0] = tupla_data[0].strip("parameter ")
                tupla_data[1] = tupla_data[1].strip(";\n")
                found = True
            elif(line.startswith('parameter    C_M_AXI_GMEM' + str(i) + '_ADDR_WIDTH')):
                tupla_addr = line.split(" = ")
                tupla_addr[0] = tupla_addr[0].strip("parameter ")
                tupla_addr[1] = tupla_addr[1].strip(";\n")
            elif(line.startswith('parameter    C_M_AXI_GMEM' + str(i) + '_ID_WIDTH')):
                tupla_id = line.split(" = ")
                tupla_id[0] = tupla_id[0].strip("parameter ")
                tupla_id[1] = tupla_id[1].strip(";\n")
        if (found): 
            tupla = (i, tupla_data[1],tupla_addr[1],tupla_id[1])
            port_list.append(tupla)

    num_ports = len(port_list)
    for line in Lines:
        # Get control port with values
        if(line.startswith("parameter    C_S_AXI_CONTROL_DATA_WIDTH")):
            tupla_data = line.split(" = ")
            tupla_data[0] = tupla_data[0].strip("parameter ")
            tupla_data[1] = tupla_data[1].strip(";\n")
        elif(line.startswith("parameter    C_S_AXI_CONTROL_ADDR_WIDTH")):
            tupla_addr = line.split(" = ")
            tupla_addr[0] = tupla_addr[0].strip("parameter ")
            tupla_addr[1] = tupla_addr[1].strip(";\n")
    tupla = (num_ports+1,tupla_data[1],tupla_addr[1],tupla_id[1])
    port_list.append(tupla)

    for line in Lines:
        # Get interrput port status
        if(line.startswith("output   interrupt;")):
            interrupt = 1
        # Get GMEM0 port status
        if(line.startswith("parameter    C_M_AXI_GMEM0_DATA_WIDTH")):
            usingGMEM0 = 1
filename_in.close()

print 'Number of ports:', num_ports
print 'Interrupt port:', interrupt
print 'Using GMEM0 :', usingGMEM0
print 'port_list:\n'
for i in range(num_ports+1):
    print "Port ",i,": ",port_list[i]
print '\n'


print 'Opening the template file to create the pkg.vhd file'
with open(str(imple_name) + '_pkg.vhd', 'w') as filename_out:  # Outfile name changed
    with open('../../templates/template_pkg.vhd', 'r') as filename_in:
        Lines = filename_in.readlines()
        for line in Lines:
            if(line.startswith("--INSERT constants")):
                if(usingGMEM0==1):
                    newlines = ('  constant C_S_AXI_CONTROL_ADDR_WIDTH  : integer := '+port_list[num_ports][2]+';\n'
                               '  constant C_S_AXI_CONTROL_DATA_WIDTH  : integer := '+port_list[num_ports][1]+';\n'
                               '  constant C_M_AXI_GMEM0_ID_WIDTH     : integer := '+port_list[0][3]+';\n'
                               '  constant C_M_AXI_GMEM0_ADDR_WIDTH   : integer := '+port_list[0][2]+';\n'
                               '  constant C_M_AXI_GMEM0_DATA_WIDTH   : integer := '+port_list[0][1]+';\n')
                else:
                    newlines = ('  constant C_S_AXI_CONTROL_ADDR_WIDTH  : integer := '+port_list[num_ports][2]+';\n'
                               '  constant C_S_AXI_CONTROL_DATA_WIDTH  : integer := '+port_list[num_ports][1]+';\n'
                               '  constant C_M_AXI_GMEM_ID_WIDTH     : integer := '+port_list[0][3]+';\n'
                               '  constant C_M_AXI_GMEM_ADDR_WIDTH   : integer := '+port_list[0][2]+';\n'
                               '  constant C_M_AXI_GMEM_DATA_WIDTH   : integer := '+port_list[0][1]+';\n')
                filename_out.write(newlines)
                for i in range(1, num_ports):
                    newlines = ('  constant C_M_AXI_GMEM'+str(port_list[i][0])+'_ID_WIDTH     : integer := '+port_list[i][3]+';\n'
                                '  constant C_M_AXI_GMEM'+str(port_list[i][0])+'_ADDR_WIDTH   : integer := '+port_list[i][2]+';\n'
                                '  constant C_M_AXI_GMEM'+str(port_list[i][0])+'_DATA_WIDTH   : integer := '+port_list[i][1]+';\n')
                    filename_out.write(newlines)
            elif(line.startswith("--INSERT template_kernel in out ports")):
                for i in range(0, num_ports):
                    if ((i == 0) and (usingGMEM0==0)):
                        index = str('')
                        indexSlash = str('')
                    else :
                        index = str(port_list[i][0])
                        indexSlash = '_'+str(port_list[i][0])
                    newlines = ('      axi_to_mem'+str(indexSlash)+':     out axi4wide_mosi_type;\n'
                                '      axi_from_mem'+str(indexSlash)+':   in  axiwide_somi_type;\n')
                    filename_out.write(newlines)
            elif(line.startswith("--INSERT component definition")):
                newlines = ('  component '+str(top_name)+' \n')
                filename_out.write(newlines)
            elif(line.startswith("--INSERT component id_width and data_width parameters")):
                if(usingGMEM0==1):
                    if (num_ports == 1):
                        newlines = ('      C_M_AXI_GMEM0_ID_WIDTH      : integer := C_M_AXI_GMEM0_ID_WIDTH\n')
                    else :
                        newlines = ('      C_M_AXI_GMEM0_ID_WIDTH      : integer := C_M_AXI_GMEM0_ID_WIDTH;\n')
                    filename_out.write(newlines)
                else:
                    if (num_ports == 1):
                        newlines = ('      C_M_AXI_GMEM_ID_WIDTH      : integer := C_M_AXI_GMEM_ID_WIDTH\n')
                    else :
                        newlines = ('      C_M_AXI_GMEM_ID_WIDTH      : integer := C_M_AXI_GMEM_ID_WIDTH;\n')
                    filename_out.write(newlines)
                for i in range(1, num_ports):
                    newlines = ('      C_M_AXI_GMEM'+str(port_list[i][0])+'_ID_WIDTH     : integer := C_M_AXI_GMEM'+str(port_list[i][0])+'_ID_WIDTH;\n')
                    filename_out.write(newlines)
                for i in range(1, num_ports):
                    if (i == num_ports-1):
                        newlines = ('      C_M_AXI_GMEM'+str(port_list[i][0])+'_DATA_WIDTH     : integer := C_M_AXI_GMEM'+str(port_list[i][0])+'_DATA_WIDTH\n')
                    else :
                        newlines = ('      C_M_AXI_GMEM'+str(port_list[i][0])+'_DATA_WIDTH     : integer := C_M_AXI_GMEM'+str(port_list[i][0])+'_DATA_WIDTH;\n')
                    filename_out.write(newlines)
            elif(line.startswith("--INSERT component port fields definition")):
                if(usingGMEM0==1):
                    for i in range(0, num_ports):
                        newlines = ('      m_axi_gmem'+str(port_list[i][0])+'_AWVALID          : out std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWREADY          : in std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWADDR           : out std_logic_vector(C_M_AXI_GMEM'+str(port_list[i][0])+'_ADDR_WIDTH-1 downto 0);       \n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWID             : out std_logic_vector(C_M_AXI_GMEM'+str(port_list[i][0])+'_ID_WIDTH-1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWLEN            : out std_logic_vector(7 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWSIZE           : out std_logic_vector(2 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWBURST         : out std_logic_vector (1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWLOCK :         out std_logic_vector (1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWCACHE :        out std_logic_vector (3 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWPROT :         out std_logic_vector (2 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWQOS :          out std_logic_vector (3 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWREGION :       out std_logic_vector (3 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWUSER :         out std_logic_vector (0 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_WVALID :         out std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_WREADY :         in  std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_WDATA :          out std_logic_vector (C_M_AXI_GMEM'+str(port_list[i][0])+'_DATA_WIDTH-1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_WSTRB :          out std_logic_vector (C_M_AXI_GMEM'+str(port_list[i][0])+'_DATA_WIDTH/8-1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_WLAST :          out std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_WID :            out std_logic_vector (C_M_AXI_GMEM'+str(port_list[i][0])+'_ID_WIDTH -1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_WUSER :          out std_logic_vector (0 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARVALID :        out std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARREADY :        in  std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARADDR :         out std_logic_vector (C_M_AXI_GMEM'+str(port_list[i][0])+'_ADDR_WIDTH-1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARID :           out std_logic_vector (C_M_AXI_GMEM'+str(port_list[i][0])+'_ID_WIDTH-1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARLEN :          out std_logic_vector (7 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARSIZE :         out std_logic_vector (2 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARBURST :        out std_logic_vector (1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARLOCK :         out std_logic_vector (1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARCACHE :        out std_logic_vector (3 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARPROT :         out std_logic_vector (2 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARQOS :          out std_logic_vector (3 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARREGION :       out std_logic_vector (3 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARUSER :         out std_logic_vector (0 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_RVALID :         in  std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_RREADY :         out std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_RDATA :          in  std_logic_vector (C_M_AXI_GMEM'+str(port_list[i][0])+'_DATA_WIDTH - 1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_RLAST :          in  std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_RID :            in  std_logic_vector (C_M_AXI_GMEM'+str(port_list[i][0])+'_ID_WIDTH - 1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_RUSER :          in  std_logic_vector (0 downto 0); \n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_RRESP :          in  std_logic_vector (1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_BVALID :         in  std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_BREADY :         out std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_BRESP :          in  std_logic_vector (1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_BID :            in  std_logic_vector (C_M_AXI_GMEM'+str(port_list[i][0])+'_ID_WIDTH - 1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_BUSER :          in  std_logic_vector (0 downto 0);\n\n')
                        filename_out.write(newlines)
                else:
                    newlines = ('      m_axi_gmem_AWVALID          : out std_logic;\n'
                                    '      m_axi_gmem_AWREADY          : in std_logic;\n'
                                    '      m_axi_gmem_AWADDR           : out std_logic_vector(C_M_AXI_GMEM_ADDR_WIDTH-1 downto 0);       \n'
                                    '      m_axi_gmem_AWID             : out std_logic_vector(C_M_AXI_GMEM_ID_WIDTH-1 downto 0);\n'
                                    '      m_axi_gmem_AWLEN            : out std_logic_vector(7 downto 0);\n'
                                    '      m_axi_gmem_AWSIZE           : out std_logic_vector(2 downto 0);\n'
                                    '      m_axi_gmem_AWBURST         : out std_logic_vector (1 downto 0);\n'
                                    '      m_axi_gmem_AWLOCK :         out std_logic_vector (1 downto 0);\n'
                                    '      m_axi_gmem_AWCACHE :        out std_logic_vector (3 downto 0);\n'
                                    '      m_axi_gmem_AWPROT :         out std_logic_vector (2 downto 0);\n'
                                    '      m_axi_gmem_AWQOS :          out std_logic_vector (3 downto 0);\n'
                                    '      m_axi_gmem_AWREGION :       out std_logic_vector (3 downto 0);\n'
                                    '      m_axi_gmem_AWUSER :         out std_logic_vector (0 downto 0);\n'
                                    '      m_axi_gmem_WVALID :         out std_logic;\n'
                                    '      m_axi_gmem_WREADY :         in  std_logic;\n'
                                    '      m_axi_gmem_WDATA :          out std_logic_vector (C_M_AXI_GMEM_DATA_WIDTH-1 downto 0);\n'
                                    '      m_axi_gmem_WSTRB :          out std_logic_vector (C_M_AXI_GMEM_DATA_WIDTH/8-1 downto 0);\n'
                                    '      m_axi_gmem_WLAST :          out std_logic;\n'
                                    '      m_axi_gmem_WID :            out std_logic_vector (C_M_AXI_GMEM_ID_WIDTH -1 downto 0);\n'
                                    '      m_axi_gmem_WUSER :          out std_logic_vector (0 downto 0);\n'
                                    '      m_axi_gmem_ARVALID :        out std_logic;\n'
                                    '      m_axi_gmem_ARREADY :        in  std_logic;\n'
                                    '      m_axi_gmem_ARADDR :         out std_logic_vector (C_M_AXI_GMEM_ADDR_WIDTH-1 downto 0);\n'
                                    '      m_axi_gmem_ARID :           out std_logic_vector (C_M_AXI_GMEM_ID_WIDTH-1 downto 0);\n'
                                    '      m_axi_gmem_ARLEN :          out std_logic_vector (7 downto 0);\n'
                                    '      m_axi_gmem_ARSIZE :         out std_logic_vector (2 downto 0);\n'
                                    '      m_axi_gmem_ARBURST :        out std_logic_vector (1 downto 0);\n'
                                    '      m_axi_gmem_ARLOCK :         out std_logic_vector (1 downto 0);\n'
                                    '      m_axi_gmem_ARCACHE :        out std_logic_vector (3 downto 0);\n'
                                    '      m_axi_gmem_ARPROT :         out std_logic_vector (2 downto 0);\n'
                                    '      m_axi_gmem_ARQOS :          out std_logic_vector (3 downto 0);\n'
                                    '      m_axi_gmem_ARREGION :       out std_logic_vector (3 downto 0);\n'
                                    '      m_axi_gmem_ARUSER :         out std_logic_vector (0 downto 0);\n'
                                    '      m_axi_gmem_RVALID :         in  std_logic;\n'
                                    '      m_axi_gmem_RREADY :         out std_logic;\n'
                                    '      m_axi_gmem_RDATA :          in  std_logic_vector (C_M_AXI_GMEM_DATA_WIDTH - 1 downto 0);\n'
                                    '      m_axi_gmem_RLAST :          in  std_logic;\n'
                                    '      m_axi_gmem_RID :            in  std_logic_vector (C_M_AXI_GMEM_ID_WIDTH - 1 downto 0);\n'
                                    '      m_axi_gmem_RUSER :          in  std_logic_vector (0 downto 0); \n'
                                    '      m_axi_gmem_RRESP :          in  std_logic_vector (1 downto 0);\n'
                                    '      m_axi_gmem_BVALID :         in  std_logic;\n'
                                    '      m_axi_gmem_BREADY :         out std_logic;\n'
                                    '      m_axi_gmem_BRESP :          in  std_logic_vector (1 downto 0);\n'
                                    '      m_axi_gmem_BID :            in  std_logic_vector (C_M_AXI_GMEM_ID_WIDTH - 1 downto 0);\n'
                                    '      m_axi_gmem_BUSER :          in  std_logic_vector (0 downto 0);\n\n')
                    filename_out.write(newlines)
                    for i in range(1, num_ports):
                        newlines = ('      m_axi_gmem'+str(port_list[i][0])+'_AWVALID          : out std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWREADY          : in std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWADDR           : out std_logic_vector(C_M_AXI_GMEM'+str(port_list[i][0])+'_ADDR_WIDTH-1 downto 0);       \n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWID             : out std_logic_vector(C_M_AXI_GMEM'+str(port_list[i][0])+'_ID_WIDTH-1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWLEN            : out std_logic_vector(7 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWSIZE           : out std_logic_vector(2 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWBURST         : out std_logic_vector (1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWLOCK :         out std_logic_vector (1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWCACHE :        out std_logic_vector (3 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWPROT :         out std_logic_vector (2 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWQOS :          out std_logic_vector (3 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWREGION :       out std_logic_vector (3 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_AWUSER :         out std_logic_vector (0 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_WVALID :         out std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_WREADY :         in  std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_WDATA :          out std_logic_vector (C_M_AXI_GMEM'+str(port_list[i][0])+'_DATA_WIDTH-1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_WSTRB :          out std_logic_vector (C_M_AXI_GMEM'+str(port_list[i][0])+'_DATA_WIDTH/8-1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_WLAST :          out std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_WID :            out std_logic_vector (C_M_AXI_GMEM'+str(port_list[i][0])+'_ID_WIDTH -1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_WUSER :          out std_logic_vector (0 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARVALID :        out std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARREADY :        in  std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARADDR :         out std_logic_vector (C_M_AXI_GMEM'+str(port_list[i][0])+'_ADDR_WIDTH-1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARID :           out std_logic_vector (C_M_AXI_GMEM'+str(port_list[i][0])+'_ID_WIDTH-1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARLEN :          out std_logic_vector (7 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARSIZE :         out std_logic_vector (2 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARBURST :        out std_logic_vector (1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARLOCK :         out std_logic_vector (1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARCACHE :        out std_logic_vector (3 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARPROT :         out std_logic_vector (2 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARQOS :          out std_logic_vector (3 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARREGION :       out std_logic_vector (3 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_ARUSER :         out std_logic_vector (0 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_RVALID :         in  std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_RREADY :         out std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_RDATA :          in  std_logic_vector (C_M_AXI_GMEM'+str(port_list[i][0])+'_DATA_WIDTH - 1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_RLAST :          in  std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_RID :            in  std_logic_vector (C_M_AXI_GMEM'+str(port_list[i][0])+'_ID_WIDTH - 1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_RUSER :          in  std_logic_vector (0 downto 0); \n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_RRESP :          in  std_logic_vector (1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_BVALID :         in  std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_BREADY :         out std_logic;\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_BRESP :          in  std_logic_vector (1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_BID :            in  std_logic_vector (C_M_AXI_GMEM'+str(port_list[i][0])+'_ID_WIDTH - 1 downto 0);\n'
                                    '      m_axi_gmem'+str(port_list[i][0])+'_BUSER :          in  std_logic_vector (0 downto 0);\n\n')
                        filename_out.write(newlines)
            elif(line.startswith("--INSERT component last port fields and interrupt port")):
                if(interrupt==1):
                    newlines = ('      s_axi_control_BRESP: out std_logic_vector(1 downto 0);\n'
                                '      interrupt: out std_logic\n')
                else:
                    newlines = ('      s_axi_control_BRESP: out std_logic_vector(1 downto 0)\n')
                filename_out.write(newlines)
            elif "template" in line:
                newlines = line.replace("template", str(imple_name))
                filename_out.write(newlines)
            else:
                filename_out.write(line)
    filename_in.close()
filename_out.close()


print 'Opening the template file to create the kernel.vhd file'
with open(str(imple_name) + '_kernel.vhd', 'w') as filename_out:  # Outfile name changed
    with open('../../templates/template_kernel.vhd', 'r') as filename_in:
        Lines = filename_in.readlines()
        for line in Lines:
            if(line.startswith("--INSERT template_kernel in out ports")):
                for i in range(0, num_ports):
                    if ((i == 0) and (usingGMEM0==0)):
                        index = str('')
                        indexSlash = str('')
                    else :
                        index = str(port_list[i][0])
                        indexSlash = '_'+str(port_list[i][0])
                    newlines = ('      axi_to_mem'+str(indexSlash)+':     out axi4wide_mosi_type;\n'
                                '      axi_from_mem'+str(indexSlash)+':   in  axiwide_somi_type;\n')
                    filename_out.write(newlines)
            elif(line.startswith("--INSERT signal definitions")):
                for i in range(0, num_ports):
                    if ((i == 0) and (usingGMEM0==0)):
                        index = str('')
                        indexSlash = str('')
                    else :
                        index = str(port_list[i][0])
                        indexSlash = '_'+str(port_list[i][0])
                    newlines = ('signal acc_mst_in'+str(indexSlash)+':  axi_acc_mst_in;\n'
                                'signal acc_mst_out'+str(indexSlash)+': axi_acc_mst_out;\n\n')
                    filename_out.write(newlines)
            elif(line.startswith("--INSERT aux_axi_addr definitions")):
                for i in range(0, num_ports):
                    if ((i == 0) and (usingGMEM0==0)):
                        index = str('')
                        indexSlash = str('')
                    else :
                        index = str(port_list[i][0])
                        indexSlash = '_'+str(port_list[i][0])
                    newlines = ('signal aux'+str(indexSlash)+'_axi_awaddr:    std_logic_vector(C_M_AXI_GMEM'+str(index)+'_ADDR_WIDTH-1 downto 0);\n'
                                'signal aux'+str(indexSlash)+'_axi_araddr:    std_logic_vector(C_M_AXI_GMEM'+str(index)+'_ADDR_WIDTH-1 downto 0);\n\n')
                    filename_out.write(newlines)
            elif(line.startswith("--INSERT AXI IN/OUT interfaces")):
                for i in range(0, num_ports):
                    if ((i == 0) and (usingGMEM0==0)):
                        index = str('')
                        indexSlash = str('')
                    else :
                        index = str(port_list[i][0])
                        indexSlash = '_'+str(port_list[i][0])
                    newlines = ('-- mst'+str(index)+' AXI4 interface OUT\n'
                                '  axi_to_mem'+str(indexSlash)+'.aw.valid  <= acc_mst_out'+str(indexSlash)+'.m00_axi_awvalid; \n'
                                '  axi_to_mem'+str(indexSlash)+'.aw.addr   <= acc_mst_out'+str(indexSlash)+'.m00_axi_awaddr(C_M_AXI_CURRENT_GMEM_ADDR_WIDTH-1 downto 0);\n'
                                '  axi_to_mem'+str(indexSlash)+'.aw.len    <= acc_mst_out'+str(indexSlash)+'.m00_axi_awlen;\n'
                                '  axi_to_mem'+str(indexSlash)+'.aw.id     <= acc_mst_out'+str(indexSlash)+'.m00_axi_awid;\n'
                                '  axi_to_mem'+str(indexSlash)+'.aw.size   <= acc_mst_out'+str(indexSlash)+'.m00_axi_awsize; --log2(data width in bytes)\n'
                                '  axi_to_mem'+str(indexSlash)+'.aw.burst  <= acc_mst_out'+str(indexSlash)+'.m00_axi_awburst; \n'
                                '  axi_to_mem'+str(indexSlash)+'.aw.lock   <= acc_mst_out'+str(indexSlash)+'.m00_axi_awlock(0);\n'
                                '  axi_to_mem'+str(indexSlash)+'.aw.cache  <= acc_mst_out'+str(indexSlash)+'.m00_axi_awcache;\n'
                                '  axi_to_mem'+str(indexSlash)+'.aw.prot   <= acc_mst_out'+str(indexSlash)+'.m00_axi_awprot;\n'
                                ' \n'
                                '  axi_to_mem'+str(indexSlash)+'.w.valid   <= acc_mst_out'+str(indexSlash)+'.m00_axi_wvalid;\n')
                    filename_out.write(newlines)
                    # if (port_list[i][1] == '128'):
                    #     newlines = ('  axi_to_mem'+str(indexSlash)+'.w.data(C_M_AXI_GMEM'+str(index)+'_DATA_WIDTH-1 downto 0)    <= acc_mst_out'+str(indexSlash)+'.m00_axi_wdata; \n'
                    #                 '  axi_to_mem'+str(indexSlash)+'.w.strb(C_M_AXI_GMEM'+str(index)+'_DATA_WIDTH/8-1 downto 0)    <= acc_mst_out'+str(indexSlash)+'.m00_axi_wstrb; \n')
                    # else :
                    newlines = ('  axi_to_mem'+str(indexSlash)+'.w.data(C_M_AXI_GMEM'+str(index)+'_DATA_WIDTH-1 downto 0)    <= acc_mst_out'+str(indexSlash)+'.m00_axi_wdata(C_M_AXI_GMEM'+str(index)+'_DATA_WIDTH-1 downto 0); \n'
                                '  axi_to_mem'+str(indexSlash)+'.w.strb(C_M_AXI_GMEM'+str(index)+'_DATA_WIDTH/8-1 downto 0)    <= acc_mst_out'+str(indexSlash)+'.m00_axi_wstrb(C_M_AXI_GMEM'+str(index)+'_DATA_WIDTH/8-1 downto 0);\n')
                    filename_out.write(newlines)
                    newlines = ('  axi_to_mem'+str(indexSlash)+'.w.last    <= acc_mst_out'+str(indexSlash)+'.m00_axi_wlast; \n'
                                '  axi_to_mem'+str(indexSlash)+'.b.ready   <= acc_mst_out'+str(indexSlash)+'.m00_axi_bready;\n'
                                '  axi_to_mem'+str(indexSlash)+'.ar.valid <= acc_mst_out'+str(indexSlash)+'.m00_axi_arvalid;\n'
                                '  axi_to_mem'+str(indexSlash)+'.ar.addr  <= acc_mst_out'+str(indexSlash)+'.m00_axi_araddr(C_M_AXI_CURRENT_GMEM_ADDR_WIDTH-1 downto 0);\n'
                                '  axi_to_mem'+str(indexSlash)+'.ar.len   <= acc_mst_out'+str(indexSlash)+'.m00_axi_arlen;\n'
                                '  axi_to_mem'+str(indexSlash)+'.ar.id    <= acc_mst_out'+str(indexSlash)+'.m00_axi_arid;\n'
                                '  axi_to_mem'+str(indexSlash)+'.ar.size  <= acc_mst_out'+str(indexSlash)+'.m00_axi_arsize;\n'
                                '  axi_to_mem'+str(indexSlash)+'.ar.burst <= acc_mst_out'+str(indexSlash)+'.m00_axi_arburst;\n'
                                '  axi_to_mem'+str(indexSlash)+'.ar.lock  <= acc_mst_out'+str(indexSlash)+'.m00_axi_arlock(0);\n'
                                '  axi_to_mem'+str(indexSlash)+'.ar.cache <= acc_mst_out'+str(indexSlash)+'.m00_axi_arcache;\n'
                                '  axi_to_mem'+str(indexSlash)+'.ar.prot  <= acc_mst_out'+str(indexSlash)+'.m00_axi_arprot;\n'
                                '  axi_to_mem'+str(indexSlash)+'.r.ready  <= acc_mst_out'+str(indexSlash)+'.m00_axi_rready;\n'
                                ' \n'
                                '  axi_to_mem'+str(indexSlash)+'.aw.qos   <= (others => \'0\');\n'
                                '  axi_to_mem'+str(indexSlash)+'.ar.qos   <= (others => \'0\');\n'
                                ' \n'
                                ' -- mst'+str(index)+' AXI4 interface IN\n'
                                '  acc_mst_in'+str(indexSlash)+'.m00_axi_awready <= axi_from_mem'+str(indexSlash)+'.aw.ready;\n'
                                '  acc_mst_in'+str(indexSlash)+'.m00_axi_wready  <= axi_from_mem'+str(indexSlash)+'.w.ready;\n'
                                '  acc_mst_in'+str(indexSlash)+'.m00_axi_bvalid  <= axi_from_mem'+str(indexSlash)+'.b.valid;\n'
                                '  acc_mst_in'+str(indexSlash)+'.m00_axi_bresp   <= axi_from_mem'+str(indexSlash)+'.b.resp;\n'
                                '  acc_mst_in'+str(indexSlash)+'.m00_axi_bid     <= axi_from_mem'+str(indexSlash)+'.b.id;\n'
                                '  acc_mst_in'+str(indexSlash)+'.m00_axi_arready <= axi_from_mem'+str(indexSlash)+'.ar.ready;\n'
                                '  acc_mst_in'+str(indexSlash)+'.m00_axi_rvalid  <= axi_from_mem'+str(indexSlash)+'.r.valid;\n')
                    filename_out.write(newlines)
                    # if (port_list[i][1] == '128'):
                    #     newlines = ('  acc_mst_in'+str(indexSlash)+'.m00_axi_rdata   <= axi_from_mem'+str(indexSlash)+'.r.data(C_M_AXI_GMEM'+str(index)+'_DATA_WIDTH-1 downto 0);\n')
                    # else :
                    newlines = ('  acc_mst_in'+str(indexSlash)+'.m00_axi_rdata(C_M_AXI_GMEM'+str(index)+'_DATA_WIDTH-1 downto 0)   <= axi_from_mem'+str(indexSlash)+'.r.data(C_M_AXI_GMEM'+str(index)+'_DATA_WIDTH-1 downto 0);\n')
                    filename_out.write(newlines)
                    newlines = ('  acc_mst_in'+str(indexSlash)+'.m00_axi_rlast   <= axi_from_mem'+str(indexSlash)+'.r.last;\n'
                                '  acc_mst_in'+str(indexSlash)+'.m00_axi_rid     <= axi_from_mem'+str(indexSlash)+'.r.id;\n'
                                '  acc_mst_in'+str(indexSlash)+'.m00_axi_rresp   <= axi_from_mem'+str(indexSlash)+'.r.resp;\n'
                                ' \n'
                                ' \n')
                    filename_out.write(newlines)
            elif(line.startswith("--INSERT aux_axi_addr connections")):
                for i in range(0, num_ports):
                    if ((i == 0) and (usingGMEM0==0)):
                        index = str('')
                        indexSlash = str('')
                    else :
                        index = str(port_list[i][0])
                        indexSlash = '_'+str(port_list[i][0])
                    newlines = ('acc_mst_out'+str(indexSlash)+'.m00_axi_awaddr(C_M_AXI_CURRENT_GMEM_ADDR_WIDTH-1 downto 0) <= aux'+str(indexSlash)+'_axi_awaddr(C_M_AXI_CURRENT_GMEM_ADDR_WIDTH-1 downto 0);\n'
                                'acc_mst_out'+str(indexSlash)+'.m00_axi_araddr(C_M_AXI_CURRENT_GMEM_ADDR_WIDTH-1 downto 0) <= aux'+str(indexSlash)+'_axi_araddr(C_M_AXI_CURRENT_GMEM_ADDR_WIDTH-1 downto 0);\n\n')
                    filename_out.write(newlines)
            elif(line.startswith("--INSERT acc_inst")):
                newlines = ('acc_inst : '+str(top_name)+'\n')
                filename_out.write(newlines)
            elif(line.startswith("--INSERT component id_width and data_width parameters")):
                if(usingGMEM0==1):
                    if (num_ports == 1):
                        newlines = ('    C_M_AXI_GMEM0_ID_WIDTH      => C_M_AXI_GMEM0_ID_WIDTH\n')
                    else :
                        newlines = ('    C_M_AXI_GMEM0_ID_WIDTH      => C_M_AXI_GMEM0_ID_WIDTH,\n')
                    filename_out.write(newlines)
                else:
                    if (num_ports == 1):
                        newlines = ('    C_M_AXI_GMEM_ID_WIDTH      => C_M_AXI_GMEM_ID_WIDTH\n')
                    else :
                        newlines = ('    C_M_AXI_GMEM_ID_WIDTH      => C_M_AXI_GMEM_ID_WIDTH,\n')
                    filename_out.write(newlines)
                for i in range(1, num_ports):
                    newlines = ('    C_M_AXI_GMEM'+str(port_list[i][0])+'_ID_WIDTH     => C_M_AXI_GMEM'+str(port_list[i][0])+'_ID_WIDTH,\n')
                    filename_out.write(newlines)
                for i in range(1, num_ports):
                    if (i == num_ports-1):
                        newlines = ('    C_M_AXI_GMEM'+str(port_list[i][0])+'_DATA_WIDTH   => C_M_AXI_GMEM'+str(port_list[i][0])+'_DATA_WIDTH\n')
                    else :
                        newlines = ('    C_M_AXI_GMEM'+str(port_list[i][0])+'_DATA_WIDTH   => C_M_AXI_GMEM'+str(port_list[i][0])+'_DATA_WIDTH,\n')
                    filename_out.write(newlines)
            elif(line.startswith("--INSERT component port fields definition")):
                for i in range(0, num_ports):
                    if ((i == 0) and (usingGMEM0==0)):
                        index = str('')
                        indexSlash = str('')
                    else :
                        index = str(port_list[i][0])
                        indexSlash = '_'+str(port_list[i][0])
                    newlines = ('    --m_axi_gmem'+str(index)+'\n'
                                '    m_axi_gmem'+str(index)+'_AWVALID   => acc_mst_out'+str(indexSlash)+'.m00_axi_awvalid,\n'
                                '    m_axi_gmem'+str(index)+'_AWREADY   => acc_mst_in'+str(indexSlash)+'.m00_axi_awready,\n'
                                '    m_axi_gmem'+str(index)+'_AWADDR    => aux'+str(indexSlash)+'_axi_awaddr,\n'
                                '    m_axi_gmem'+str(index)+'_AWID      => acc_mst_out'+str(indexSlash)+'.m00_axi_awid(C_M_AXI_GMEM'+str(index)+'_ID_WIDTH-1 downto 0), \n'
                                '    m_axi_gmem'+str(index)+'_AWLEN     => acc_mst_out'+str(indexSlash)+'.m00_axi_awlen,\n'
                                '    m_axi_gmem'+str(index)+'_AWSIZE    => acc_mst_out'+str(indexSlash)+'.m00_axi_awsize, \n'
                                '    m_axi_gmem'+str(index)+'_AWBURST   => acc_mst_out'+str(indexSlash)+'.m00_axi_awburst, \n'
                                '    m_axi_gmem'+str(index)+'_AWLOCK    => acc_mst_out'+str(indexSlash)+'.m00_axi_awlock, \n'
                                '    m_axi_gmem'+str(index)+'_AWCACHE   => acc_mst_out'+str(indexSlash)+'.m00_axi_awcache, \n'
                                '    m_axi_gmem'+str(index)+'_AWPROT    => acc_mst_out'+str(indexSlash)+'.m00_axi_awprot, \n'
                                '    m_axi_gmem'+str(index)+'_AWQOS     => acc_mst_out'+str(indexSlash)+'.m00_axi_awqos,      --not used\n'
                                '    m_axi_gmem'+str(index)+'_AWREGION  => acc_mst_out'+str(indexSlash)+'.m00_axi_awregion, --not used\n'
                                '    m_axi_gmem'+str(index)+'_AWUSER    => open,\n'
                                '    m_axi_gmem'+str(index)+'_WVALID    => acc_mst_out'+str(indexSlash)+'.m00_axi_wvalid,\n'
                                '    m_axi_gmem'+str(index)+'_WREADY    => acc_mst_in'+str(indexSlash)+'.m00_axi_wready,\n'
                                '    m_axi_gmem'+str(index)+'_WDATA     => acc_mst_out'+str(indexSlash)+'.m00_axi_wdata(C_M_AXI_GMEM'+str(index)+'_DATA_WIDTH-1 downto 0),\n'
                                '    m_axi_gmem'+str(index)+'_WSTRB     => acc_mst_out'+str(indexSlash)+'.m00_axi_wstrb(C_M_AXI_GMEM'+str(index)+'_DATA_WIDTH/8-1 downto 0),\n'
                                '    m_axi_gmem'+str(index)+'_WID       => open,\n'
                                '    m_axi_gmem'+str(index)+'_WUSER     => open,\n'
                                '    m_axi_gmem'+str(index)+'_WLAST     => acc_mst_out'+str(indexSlash)+'.m00_axi_wlast,\n'
                                '    m_axi_gmem'+str(index)+'_ARVALID   => acc_mst_out'+str(indexSlash)+'.m00_axi_arvalid, \n'
                                '    m_axi_gmem'+str(index)+'_ARREADY   => acc_mst_in'+str(indexSlash)+'.m00_axi_arready,\n'
                                '    m_axi_gmem'+str(index)+'_ARADDR    => aux'+str(indexSlash)+'_axi_araddr,\n'
                                '    m_axi_gmem'+str(index)+'_ARID      => acc_mst_out'+str(indexSlash)+'.m00_axi_arid(C_M_AXI_GMEM'+str(index)+'_ID_WIDTH-1 downto 0), \n'
                                '    m_axi_gmem'+str(index)+'_ARLEN     => acc_mst_out'+str(indexSlash)+'.m00_axi_arlen,\n'
                                '    m_axi_gmem'+str(index)+'_ARSIZE    => acc_mst_out'+str(indexSlash)+'.m00_axi_arsize, \n'
                                '    m_axi_gmem'+str(index)+'_ARBURST   => acc_mst_out'+str(indexSlash)+'.m00_axi_arburst,  \n'
                                '    m_axi_gmem'+str(index)+'_ARLOCK    => acc_mst_out'+str(indexSlash)+'.m00_axi_arlock, \n'
                                '    m_axi_gmem'+str(index)+'_ARCACHE   => acc_mst_out'+str(indexSlash)+'.m00_axi_arcache, \n'
                                '    m_axi_gmem'+str(index)+'_ARPROT    => acc_mst_out'+str(indexSlash)+'.m00_axi_arprot,  \n'
                                '    m_axi_gmem'+str(index)+'_ARQOS     => acc_mst_out'+str(indexSlash)+'.m00_axi_arqos, \n'
                                '    m_axi_gmem'+str(index)+'_ARREGION  => acc_mst_out'+str(indexSlash)+'.m00_axi_arregion, \n'
                                '    m_axi_gmem'+str(index)+'_ARUSER    => open,\n'
                                '    m_axi_gmem'+str(index)+'_RVALID    => acc_mst_in'+str(indexSlash)+'.m00_axi_rvalid,\n'
                                '    m_axi_gmem'+str(index)+'_RREADY    => acc_mst_out'+str(indexSlash)+'.m00_axi_rready,\n'
                                '    m_axi_gmem'+str(index)+'_RDATA     => acc_mst_in'+str(indexSlash)+'.m00_axi_rdata(C_M_AXI_GMEM'+str(index)+'_DATA_WIDTH-1 downto 0),\n'
                                '    m_axi_gmem'+str(index)+'_RLAST     => acc_mst_in'+str(indexSlash)+'.m00_axi_rlast,\n'
                                '    m_axi_gmem'+str(index)+'_RUSER     => "0",\n'
                                '    m_axi_gmem'+str(index)+'_RID       => acc_mst_in'+str(indexSlash)+'.m00_axi_rid(C_M_AXI_GMEM'+str(index)+'_ID_WIDTH-1 downto 0),  \n'
                                '    m_axi_gmem'+str(index)+'_RRESP     => acc_mst_in'+str(indexSlash)+'.m00_axi_rresp, \n'
                                '    m_axi_gmem'+str(index)+'_BVALID    => acc_mst_in'+str(indexSlash)+'.m00_axi_bvalid,\n'
                                '    m_axi_gmem'+str(index)+'_BREADY    => acc_mst_out'+str(indexSlash)+'.m00_axi_bready,\n'
                                '    m_axi_gmem'+str(index)+'_BRESP     => acc_mst_in'+str(indexSlash)+'.m00_axi_bresp, \n'
                                '    m_axi_gmem'+str(index)+'_BID       => acc_mst_in'+str(indexSlash)+'.m00_axi_bid(C_M_AXI_GMEM'+str(index)+'_ID_WIDTH-1 downto 0), \n'
                                '    m_axi_gmem'+str(index)+'_BUSER     => "0",\n\n')
                    filename_out.write(newlines)
            elif(line.startswith("--INSERT component last port fields and interrupt port")):
                if(interrupt==1):
                    newlines = ('    s_axi_control_BRESP   => acc_slv_out.s_axi_control_bresp,\n'
                                '    interrupt             => interrupt\n')
                else:
                    newlines = ('    s_axi_control_BRESP   => acc_slv_out.s_axi_control_bresp\n')
                filename_out.write(newlines)
            elif "template" in line:
                newlines = line.replace("template", str(imple_name))
                filename_out.write(newlines)
            else:
                filename_out.write(line)
    filename_in.close()
filename_out.close()

print 'Writting acc instance at selene-soc/rtl/selene_core.vhd file'
with open('../../../selene-soc/rtl/selene_core2.vhd', 'w') as filename_out:  # Outfile name changed
    with open('../../../selene-soc/rtl/selene_core.vhd', 'r') as filename_in:
        Lines = filename_in.readlines()
        for line in Lines:
            if(line.startswith("--use accelerators.conv_pkg.all;")):
                newlines = ('use accelerators.conv_pkg.all;\n')
                filename_out.write(newlines)
            elif(line.startswith("--library accelerators;")):
                newlines = ('library accelerators;\n')
                filename_out.write(newlines)

            elif(line.startswith("--PLACE HOLDER, PLEASE DO NOT REMOVE COMMENTS")):
                filename_out.write(line)
                newlines = ('--PLEASE DO NOT ADD MORE CODE BETWEEN THIS, ADD AFTHER OR BEFORE PLACE HOLDER\n'
                            '     HLSinf_en : if (CFG_HLSINF_EN = 1 and CFG_IN_SYNTHESIS) generate \n'
                            '     --Rtl accelerator '+str(imple_name)+' created by vivado HLS\n'
                            '     axi_acc_'+str(imple_name)+'_instance : '+str(imple_name)+'_kernel \n'
                            '       port map (\n'
                            '         clk                 => clkm,\n'
                            '         rst_n               => acc_rst_n,\n'
                            '         axi_control_in      => accel_l_aximo(0), --address is\n'
                            '         axi_control_out     => accel_l_aximi(0),\n')
                filename_out.write(newlines)

                for i in range(0, num_ports):
                    if ((i == 0) and (usingGMEM0==0)):
                        index = str('')
                        indexSlash = str('')
                    else :
                        index = str(port_list[i][0])
                        indexSlash = '_'+str(port_list[i][0])
                    newlines = ('         axi_to_mem'+str(indexSlash)+'          => acc_mem_aximo_wide('+str(i)+'),\n'
                                '         axi_from_mem'+str(indexSlash)+'        => acc_mem_aximi_wide('+str(i)+'),\n')
                    filename_out.write(newlines)
                
                newlines = ('         interrupt           => acc_interrupt  \n'
                            '       );\n')
                filename_out.write(newlines)

                for i in range(0, num_ports):
                    newlines = ('     width_converter_'+str(imple_name)+'_mem'+str(port_list[i][0])+': axi_dw_wrapper \n'
                                '      generic map(\n'
                                '        AxiMaxReads =>    1,     \n'
                                '        AxiSlvPortDataWidth => '+str(port_list[i][1])+',\n'
                                '        AxiMstPortDataWidth => AXIDW\n'
                                '      )\n'
                                '      port map (\n'
                                '        clk               => clkm, \n'
                                '        rst               => rstn, \n'
                                '        axi_component_in  => acc_mem_aximo_wide('+str(i)+'),\n'
                                '        axi_component_out => acc_mem_aximi_wide('+str(i)+'),\n'
                                '        axi_from_noc      => acc_mem_aximi('+str(i)+'),\n'
                                '        axi_to_noc        => acc_mem_aximo('+str(i)+')\n'
                                '     );\n'
                                ' \n')
                    filename_out.write(newlines)

                for i in range(0, num_ports):
                    newlines = ('      acc_mem_aximi('+str(i)+')      <= initiator_aximi('+str(i+1)+'); \n'
                                '      initiator_aximo('+str(i+1)+') <= acc_mem_aximo('+str(i)+');\n'
                                ' \n')
                    filename_out.write(newlines)

                newlines = ('      end generate;\n'
                            '--PLEASE DO NOT ADD MORE CODE BETWEEN THIS, ADD AFTHER OR BEFORE PLACE HOLDER\n')
                filename_out.write(newlines)
                placeHolder_written = 1

            if(line.startswith("--END PLACE HOLDER, PLEASE DO NOT REMOVE COMMENTS")):
                filename_out.write(line)
                placeHolder_finished = 1

            elif(placeHolder_written==0 and placeHolder_finished==0):
                filename_out.write(line)

            elif(placeHolder_written==1 and placeHolder_finished==1):
                filename_out.write(line)
            
        if(placeHolder_written==1 and placeHolder_finished==1):
            print '\nACC INSTANCE DONE! at selene-soc/rtl/selene_core.vhd file'
            print 'PLEASE CHECK the following changes:'
            print ''
            # print '     1) Add the acc pkg at instance at the begining of selene-soc/rtl/selene_core.vhd file:' 
            # print '         \"use accelerators.'+str(imple_name)+'_pkg.all;\"'
            # print '     2) Uncomment the following line at selene-soc/rtl/selene_core.vhd file:'
            # print '         \"signal acc_mem_aximo_wide : axi4wide_mosi_vector_type(0 to CFG_AXI_N_ACCELERATOR_PORTS-1);\"'
            # print '     3) Uncomment the following line at selene-soc/rtl/selene_core.vhd file:'
            # print '         \"signal acc_mem_aximi_wide : axiwide_somi_vector_type(0 to CFG_AXI_N_ACCELERATOR_PORTS-1);\"'
            print '     1) Check the acc instance at selene-soc/rtl/selene_core.vhd file.'
            print '     2) Modify the following line at selene-soc/selene-xilinx-vcu118/config.vhd file:'
            print '         \"constant CFG_AXI_N_ACCELERATOR_PORTS : integer := CFG_AXI_N_ACCELERATORS + '+str(num_ports-1)+';\"'
            print '     3) Modify the following line at selene-soc/selene-xilinx-vcu118/config.vhd file:'
            print '         \"constant CFG_AXI_N_INITIATORS : integer := '+str(num_ports+1)+';\"'
        else:
            print '\nERROR! ACC INSTANCE PLACE HOLDER NOT FOUND, PLEASE CHECK selene-soc/rtl/selene_core.vhd file'
            print 'PLACE HOLDER IS BETWEEN THE FOLLOWING LINES:'
            print '      \"--PLACE HOLDER, PLEASE DO NOT REMOVE COMMENTS\"'  
            print '      \"--END PLACE HOLDER, PLEASE DO NOT REMOVE COMMENTS\"'
    filename_in.close()
filename_out.close()

EOF

chmod 755 pyscript2.py
./pyscript2.py ${imple_name} ${top_name}
rm pyscript2.py
cd $selene_project_base_dir/selene-soc/rtl
rm selene_core.vhd
mv selene_core2.vhd selene_core.vhd

# # Assign the filename
# filename="scr/conv2D.h"

# # Take the search string
# read -p "#define HLSINF_1_15" search

# # Take the replace string
# read -p "#define HLSINF_1_15" replace

# if [[ $search != "" && $replace != "" ]]; then
# sed -i "s/$search/$replace/" $filename
# fi
