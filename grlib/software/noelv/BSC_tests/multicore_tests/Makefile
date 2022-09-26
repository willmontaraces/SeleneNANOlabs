#========================================================================
# UCB VLSI FLOW: Makefile for riscv-bmarks
#-----------------------------------------------------------------------
# Yunsup Lee (yunsup@cs.berkeley.edu)
#

XLEN ?= 64
UART ?= 1

cores_number=2

default: all

src_dir=source


#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------

bmarks := 	mp_hello \
    	  	lockstep \
	  	  	binarysearch_sync \
	  	  	ubench_sync \
	  		ubench_binarysearch \
          	ubenchmarks_singlecore \
			ubenchmarks_dualcore
#Broken tests
	# l1miss_severals \
	# mccu_experiment
	# mccu_tests 

bmarks_riscv=$(addsuffix .riscv,  $(bmarks))
#--
# Chech for drivers
#--
ifeq ($(PMU_DRIVER),)
PMU_DRIVER := ./../BSC_libraries/safeSU/6-core
$(warning Undefined envar PMU_DRIVER, fallback to default path)
endif

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

RISCV_PREFIX ?= riscv64-unknown-elf-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
RISCV_GCC_OPTS ?= -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O2 -ffast-math -fno-common -fno-builtin-printf -march=rv64ima -mabi=lp64 -DNO_UART_WAIT=$(UART) -DNOSTAT
RISCV_LINK ?= $(RISCV_GCC) -T ../common/test.ld $(incs)
RISCV_LINK_OPTS ?= -static -nostdlib -nostartfiles -lm -lgcc 
RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.data

incs  += -I../uart -I../env -I../common -I$(PMU_DRIVER)  -I../BSC_libraries/SafeDE $(addprefix -I, $(src_dir)/$(bmarks))

define compile_template
$(1).riscv: $(wildcard $(1)/*) $(wildcard ../common/*) $(wildcard ../uart/*)
	mkdir -p $$@  
	if [ "$(cores_number)" -ge "1" ]; then \
	$$(RISCV_GCC) $$(incs) $$(RISCV_GCC_OPTS) -D__CORE__=1 -D__MAX_CORES__=$(cores_number) $$(EXTRA_GCC_OPTS) -o $$@/$(1)-1.riscv $(wildcard $(src_dir)/$(1)/*.c) $(wildcard ../common/*.c) $(wildcard ../uart/*.c) $(wildcard $(PMU_DRIVER)/*.c) $(wildcard ../BSC_libraries/SafeDE/*.c) $(wildcard ../common/*.S) $$(RISCV_LINK_OPTS) -T ../common/noelv1.ld; \
	fi
	if [ "$(cores_number)" -ge "2" ]; then \
	$$(RISCV_GCC) $$(incs) $$(RISCV_GCC_OPTS) -D__CORE__=2 -D__MAX_CORES__=$(cores_number) $$(EXTRA_GCC_OPTS) -o $$@/$(1)-2.riscv $(wildcard $(src_dir)/$(1)/*.c) $(wildcard ../common/*.c) $(wildcard ../uart/*.c) $(wildcard $(PMU_DRIVER)/*.c) $(wildcard ../BSC_libraries/SafeDE/*.c) $(wildcard ../common/*.S) $$(RISCV_LINK_OPTS) -T ../common/noelv2.ld; \
	fi
	#if [ "$(cores_number)" -ge "3" ]; then \
	$$(RISCV_GCC) $$(incs) $$(RISCV_GCC_OPTS) -D__CORE__=3 -D__MAX_CORES__=$(cores_number) $$(EXTRA_GCC_OPTS) -o $$@/$(1)-3.riscv $(wildcard $(src_dir)/$(1)/*.c) $(wildcard ../common/*.c) $(wildcard ../uart/*.c) $(wildcard $(PMU_DRIVER)/*.c) $(wildcard ../BSC_libraries/SafeDE/*.c) $(wildcard ../common/*.S) $$(RISCV_LINK_OPTS) -T ../common/noelv3.ld; \
	fi
	#if [ "$(cores_number)" -ge "4" ]; then \
	$$(RISCV_GCC) $$(incs) $$(RISCV_GCC_OPTS) -D__CORE__=4 -D__MAX_CORES__=$(cores_number) $$(EXTRA_GCC_OPTS) -o $$@/$(1)-4.riscv $(wildcard $(src_dir)/$(1)/*.c) $(wildcard ../common/*.c) $(wildcard ../uart/*.c) $(wildcard $(PMU_DRIVER)/*.c) $(wildcard ../BSC_libraries/SafeDE/*.c) $(wildcard ../common/*.S) $$(RISCV_LINK_OPTS) -T ../common/noelv4.ld; \
	fi

endef

$(foreach bmark,$(bmarks),$(eval $(call compile_template,$(bmark))))

#------------------------------------------------------------
# Default

all: $(bmarks_riscv)

#------------------------------------------------------------
# Clean up

clean:
	rm -rf *.riscv
