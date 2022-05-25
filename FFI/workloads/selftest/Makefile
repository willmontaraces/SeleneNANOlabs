CC           = riscv-gaisler-elf-gcc
CFLAGS       = -g -O2 -qbsp=2020q4  -march=rv64imafd -mabi=lp64d



#workloads = 1_matmult 2_dijkstra 3_aes 4_crc 5_qsort 6_binarysearch 7_fir
workloads = 1_matmult 2_dijkstra 4_crc 5_qsort 6_binarysearch 7_fir


top = top_multicore.c


help:
	@echo -e 'Target workloads:'
	@echo -e '\n1) matmult : matrix multiplicaton adapted from Mibench-automotive \n\t\t(signed integer, multiplicaiton with accumulation, nested loops) '
	@echo -e '\n2) aes     : AES-256 encryption adapted from Tiny-AES library (https://github.com/kokke/tiny-AES-c)\n\t\tcomplex well-stuctured code'
	@echo -e '\n3) dijkstra: finding shortest paths on the graph, two versions:\n\t\t3.1)adapted from Mibench-networking (with mallocs)\n\t\t3.2)custom version (static allocation only)'
	@echo -e '\n4) crc     : cyclic redundancy check from Malardalen WCET benchmark'
	@echo -e '\n5) qsortv1 : quick sort (floating point) adapted from Malardalen WCET benchmark (qsort-exam)'
	@echo -e '\n5) qsortv2 : quick sort (floating point) based on stdlib'
	@echo -e '\n6) bs      : binary search (array of 20 key-value structures)\n\t\theavily reworked version of bs from Malardalen WCET benchmark\n\t\trecursive function calls, nested loops'
	@echo -e '\n7) fir     : finite impulse response filter adapted from Malardalen WCET benchmark without major modifications'
	

all: $(workloads)

$(workloads):%:%.c
	$(CC) $(CFLAGS) $(top) $< -o kernel_$@.out
	#riscv-gaisler-elf-objcopy -O srec kernel_$@.out tmp_$@.srec	
	#tclsh /home2/tuil/selene-hardware/grlib/bin/padsrec.tcl <tmp_$@.srec >workload_$@.srec
	#rm tmp_$@.srec	
	#gcc top_host.c $< -o host_$@.elf	
	
	
	
clean:
	rm -f *.OBJ *.LST *.o *.gch *.out *.hex *.map *.elf *.a *.srec


