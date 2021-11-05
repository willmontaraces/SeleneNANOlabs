vlog -quiet -mixedsvvh -sv -work work ../hw/CompareUnit.sv
vlog -quiet -mixedsvvh -sv -work work ../hw/Counter.sv
vlog -quiet -mixedsvvh -sv -work work ../hw/RVCell.sv
vlog -quiet -mixedsvvh -sv -work work ./test_CompareUnit.sv
vlog -quiet -mixedsvvh -sv -work work ./test_RVCell.sv
vsim -voptargs="+acc" work.RVC_test
do wave.do
run 1ms
