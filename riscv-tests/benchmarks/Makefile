#=======================================================================
# UCB VLSI FLOW: Makefile for riscv-bmarks
#-----------------------------------------------------------------------
# Yunsup Lee (yunsup@cs.berkeley.edu)
#

XLEN ?= 64

ifeq ($(XLEN),32)
ABI ?= ilp32
endif
ifeq ($(XLEN),64)
ABI ?= lp64
endif

default: all

src_dir = .

#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------

bmarks = \
	median \
	qsort \
	rsort \
	towers \
	vvadd \
	memcpy \
	multiply \
	dhrystone \
	fib

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

RISCV_PREFIX ?= riscv$(XLEN)-unknown-elf-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
RISCV_GCC_OPTS ?= -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O2 -ffast-math -fno-common -fno-builtin-printf -fno-tree-loop-distribute-patterns -march=rv$(XLEN)i_zicsr -mabi=$(ABI)
RISCV_LINK_OPTS ?= -static -nostdlib -nostartfiles -lm -lgcc -T $(src_dir)/common/test.ld
RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data
RISCV_OBJCOPY ?= $(RISCV_PREFIX)objcopy -O binary

incs  += -I$(src_dir)/../env -I$(src_dir)/common

vpath %.S $(src_dir)

#------------------------------------------------------------
# Build benchmarks

%_data.mem: %.bin
	hexdump -v -e '/8 "%016x\n"' $< > $@

%.mem: %.bin
	hexdump -v -e '/4 "%08x\n"' $< > $@

%.bin: %.elf
	$(RISCV_OBJCOPY) $< $@

%.dump: %.elf
	$(RISCV_OBJDUMP) $< > $@

%.elf: $(wildcard $(src_dir)/%/*) $(wildcard $(src_dir)/common/*)
	$(RISCV_GCC) $(incs) $(RISCV_GCC_OPTS) -o $@ $(wildcard $(src_dir)/$*/*.c) $(wildcard $(src_dir)/$*/*.S) $(wildcard $(src_dir)/common/*.c) $(wildcard $(src_dir)/common/*.S) $(RISCV_LINK_OPTS)

.PHONY: clean all

bmarks_dump = $(addsuffix .dump, $(bmarks))

bmarks_mem = $(addsuffix .mem, $(bmarks))

bmarks_data = $(addsuffix _data.mem, $(bmarks))

junk += $(bmarks_dump) $(bmarks_mem) $(bmarks_data)

#------------------------------------------------------------
# Default

all: $(bmarks_mem) $(bmarks_data)

#------------------------------------------------------------
# Clean up

clean:
	rm -rf $(junk)
