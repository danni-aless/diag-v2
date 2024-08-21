.phony: clean all

CC = riscv64-unknown-elf-gcc
OBJCOPY = riscv64-unknown-elf-objcopy
CCFLAGS = -march=rv64i -mabi=lp64 -Tlink.ld -static -nostdlib -nostartfiles
OBJFLAGS = -O binary

SRCS = $(wildcard *.S)
TESTS = $(patsubst %.S,%.mem,$(SRCS))
DMEMS = $(patsubst %.S,%_data.mem,$(SRCS))

all: $(TESTS) $(DMEMS)

%_data.mem: %.bin
	hexdump -v -e '/8 "%016x\n"' $< > $@

%.mem: %.bin
	hexdump -v -e '/4 "%08x\n"' $< > $@

%.bin: %.elf
	$(OBJCOPY) $(OBJFLAGS) $< $@

%.elf: %.S
	$(CC) $(CCFLAGS) $< -o $@

clean:
	rm -f *.mem *.bin *.elf
