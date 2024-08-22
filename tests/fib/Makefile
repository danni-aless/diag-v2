.phony: clean all

CC = riscv64-unknown-elf-gcc
OBJCOPY = riscv64-unknown-elf-objcopy
CCFLAGS = -march=rv64i -mabi=lp64 -Tlink.ld -static -nostdlib -nostartfiles
OBJFLAGS = -O binary

SRCS = $(wildcard *.c)
TESTS = $(patsubst %.c,%.mem,$(SRCS))
DMEMS = $(patsubst %.c,%_data.mem,$(SRCS))

all: $(TESTS) $(DMEMS)

%_data.mem: %.bin
	hexdump -v -e '/8 "%016x\n"' $< > $@

%.mem: %.bin
	hexdump -v -e '/4 "%08x\n"' $< > $@

%.bin: %.elf
	$(OBJCOPY) $(OBJFLAGS) $< $@

%.elf: %.c
	$(CC) $(CCFLAGS) start.S $< -o $@

clean:
	rm -f *.mem *.bin *.elf
