CC           = riscv-gaisler-elf-gcc
CFLAGS       = -g -O2 -qbsp=2020q4  -march=rv64imafd -mabi=lp64d




singlecore:
	$(CC) $(CFLAGS) RootVoter.c testapp.c -o obj_$@.out
	riscv-gaisler-elf-objcopy -O srec obj_$@.out tmp_$@.srec	
	tclsh ../../grlib/bin/padsrec.tcl <tmp_$@.srec >hello_singlecore.srec
	rm tmp_$@.srec	

multicore:
	$(CC) $(CFLAGS) RootVoter.c top_multicore.c kernel_1.c -o obj_$@.out
	riscv-gaisler-elf-objcopy -O srec obj_$@.out tmp_$@.srec	
	tclsh ../../grlib/bin/padsrec.tcl <tmp_$@.srec >hello_multicore.srec
	rm tmp_$@.srec	
	
	
all: singlecore multicore
	
clean:
	rm -f *.OBJ *.LST *.o *.gch *.out *.hex *.map *.elf *.a *.srec *.s


