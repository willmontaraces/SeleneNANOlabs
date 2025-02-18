
file=main

all: elf srec

elf:
	riscv-gaisler-elf-gcc -g -O3 -I . -march=rv64imafd -fno-inline-small-functions $(file).c  -o $(file).elf

srec: elf
	riscv-gaisler-elf-objcopy -O srec $(file).elf temp.srec 
	tclsh $(GRLIB)/bin/padsrec.tcl <temp.srec >hello.srec
	rm temp.srec


clean:
	rm $(file).elf
	rm hello.srec

move:
	mv hello.srec $(GRLIB)/../selene-soc/selene-xilinx-vcu118/hello.srec