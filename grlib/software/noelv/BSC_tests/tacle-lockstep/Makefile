#========================================================================
# UCB VLSI FLOW: Makefile for riscv-bmarks
#-----------------------------------------------------------------------
# Yunsup Lee (yunsup@cs.berkeley.edu)
#

XLEN ?=64
UART ?=1

default: all

src_dir=source


#--------------------------------------------------------------------
# Experiment configuration
# -------------------------------------------------------------------

# This variables can be overwrite when calling the Makefile
# 0 to not activate SafeDE, 1 to activate SafeDE
SafeDE ?=1
# Core that is going to print the results
active_cores ?=2
# number of iterations
iterations ?=100
# Min and max slack for the SafeDE
min_slack ?=20
max_slack ?=1000


#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------

bmarks := $(shell ls source) 

bmarks_riscv=$(addsuffix .riscv,  $(bmarks))

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

RISCV_PREFIX ?= riscv$(XLEN)-unknown-elf-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
RISCV_GCC_OPTS ?= -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O2 -ffast-math -fno-common -fno-builtin-printf -march=rv64ima -mabi=lp64 -DNO_UART_WAIT=$(UART) -DNOSTAT
RISCV_LINK ?= $(RISCV_GCC) -T ../common/test.ld $(incs)
RISCV_LINK_OPTS ?= -static -nostdlib -nostartfiles -lm -lgcc 
RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.data

incs  += -I../uart -I../env -I../common -I../BSC_libraries/PMU -I../BSC_libraries/SafeDE -Iinit_functions $(addprefix -I, $(src_dir)/$(bmarks))

define compile_template
$(1).riscv: $(wildcard $(1)/*) $(wildcard ../common/*) $(wildcard ../uart/*)
	mkdir -p $$@  
	if [ "$(active_cores)" -ge "0" ]; then \
	$$(RISCV_GCC) $$(incs) $$(RISCV_GCC_OPTS) -D__CORE__=1 -D__CORES_NUMBER__=$(active_cores) -D__LOCKSTEP__=$(SafeDE) -D__RESULTS_CORE__=$(results_core) -D__MIN_SLACK__=$(min_slack) -D__MAX_SLACK__=$(max_slack) -D__ITERATIONS__=$(iterations) $$(EXTRA_GCC_OPTS) -o $$@/$(1)-1.riscv $(wildcard $(src_dir)/$(1)/*.c) $(wildcard ../common/*.c) $(wildcard ../uart/*.c) $(wildcard ../BSC_libraries/PMU/*.c) $(wildcard ../BSC_libraries/SafeDE/*.c) $(wildcard ../common/*.S) $$(RISCV_LINK_OPTS) -T ../common/noelv1.ld; \
	fi
	if [ "$(active_cores)" -ge "1" ]; then \
	$$(RISCV_GCC) $$(incs) $$(RISCV_GCC_OPTS) -D__CORE__=2 -D__CORES_NUMBER__=$(active_cores) -D__LOCKSTEP__=$(SafeDE) -D__RESULTS_CORE__=$(results_core) -D__MIN_SLACK__=$(min_slack) -D__MAX_SLACK__=$(max_slack) -D__ITERATIONS__=$(iterations) $$(EXTRA_GCC_OPTS) -o $$@/$(1)-2.riscv $(wildcard $(src_dir)/$(1)/*.c) $(wildcard ../common/*.c) $(wildcard ../uart/*.c) $(wildcard ../BSC_libraries/PMU/*.c) $(wildcard ../BSC_libraries/SafeDE/*.c) $(wildcard ../common/*.S) $$(RISCV_LINK_OPTS) -T ../common/noelv2.ld; \
	fi

endef

$(foreach bmark,$(bmarks),$(eval $(call compile_template,$(bmark))))

#define compile_template
#$(1).riscv: $(wildcard $(1)/*) $(wildcard ../common/*) $(wildcard ../uart/*)
#	j=1 ; \
#	while [ "$$j" -le $(active_cores) ] ; \
#	do \
#	$(RISCV_GCC) $(incs) $$(RISCV_GCC_OPTS) -D__CORE__=$$j -D__MAX_CORES__=4 $$(EXTRA_GCC_OPTS) -o $$@$$j $(wildcard $(1)/*.c) $(wildcard ../common/*.c) $(wildcard ../uart/*.c) $(wildcard ../BSC_libraries/PMU/*.c) $(wildcard ../BSC_libraries/SafeDE/*.c) $(wildcard ../common/*.S) $$(RISCV_LINK_OPTS) -T ../common/noelv$$j.ld ; \
#	j=$$((j + 1)) ; \
#	done
#
#endef

#$(foreach bmark,$(bmarks),$(eval $(call compile_template,$(bmark))))


#------------------------------------------------------------
# Default

all: $(bmarks_riscv)

#------------------------------------------------------------
# Clean up

clean:
	rm -rf *.riscv


# Clean results
clean_results:
	rm -rf results csv_results
