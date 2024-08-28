#=======================================================================
# Makefile for riscv-tests/isa
#-----------------------------------------------------------------------

XLEN ?= 64

src_dir := .

include $(src_dir)/rv64ui/Makefrag

default: all

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

RISCV_PREFIX ?= riscv$(XLEN)-unknown-elf-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
RISCV_GCC_OPTS ?= -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data
RISCV_OBJCOPY ?= $(RISCV_PREFIX)objcopy -O binary

vpath %.S $(src_dir)

#------------------------------------------------------------
# Build assembly tests

%_data.mem: %.bin
	hexdump -v -e '/8 "%016x\n"' $< > $@

%.mem: %.bin
	hexdump -v -e '/4 "%08x\n"' $< > $@

%.bin: %.elf
	$(RISCV_OBJCOPY) $< $@

%.dump: %.elf
	$(RISCV_OBJDUMP) $< > $@

%.elf: rv64ui/%.S
	$(RISCV_GCC) -march=rv64i -mabi=lp64 $(RISCV_GCC_OPTS) -I$(src_dir)/../env/p -I$(src_dir)/macros/scalar -T$(src_dir)/../env/p/link.ld $< -o $@

.PHONY: clean all

tests_dump = $(addsuffix .dump, $(tests))

tests_mem = $(addsuffix .mem, $(tests))

tests_data = $(addsuffix _data.mem, $(tests))

junk += $(tests_dump) $(tests_mem) $(tests_data)

#------------------------------------------------------------
# Default

all: $(tests_mem) $(tests_data)

#------------------------------------------------------------
# Clean up

clean:
	rm -rf $(junk)
