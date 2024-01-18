LD = linker.ld
CC = riscv64-unknown-linux-gnu-gcc 
CFLAGS = -static -nostdlib -nostartfiles -march=rv32im -O0 -mabi=ilp32
OBJCPY = riscv64-unknown-linux-gnu-objcopy
OBJDMP = riscv64-unknown-linux-gnu-objdump
OBJCPY_FLAGS = -O verilog --verilog-data-width=4
OBJDMP_FLAGS = -d
XCPT = xcpt.S
MEMHEX = mem.hex

TARGETS = memcpy \
		buffer_sum \
		matmul

buffer_sum: buffer_sum.elf
	$(OBJCPY) $(OBJCPY_FLAGS) $< $(MEMHEX)

adding: adding.elf
	$(OBJCPY) $(OBJCPY_FLAGS) $< $(MEMHEX)

memcpy: memcpy.elf
	$(OBJCPY) $(OBJCPY_FLAGS) $< $(MEMHEX)

matmul: matmul.elf
	$(OBJCPY) $(OBJCPY_FLAGS) $< $(MEMHEX)

# Create .elf from .S
%.elf: %.S
	$(CC) ${CFLAGS} -T ${LD} $< $(XCPT) -o $@

clean:
	rm -f *.elf *.hex 

.PHONY: clean adding memcpy buffer_sum matmul 
