LD = linker.ld
CC = riscv64-unknown-linux-gnu-gcc 
CFLAGS = -static -nostdlib -nostartfiles -march=rv32im -O0 -mabi=ilp32
OBJCPY = riscv64-unknown-linux-gnu-objcopy
OBJCPY_FLAGS = -O verilog --verilog-data-width=4
XCPT = xcpt.S
# ELF2HEX = riscv64-unknown-elf-elf2hex 
# ELF2HEX_FLAGS =  --bit-width 32

TARGETS = adding.hex \
	    buffer_sum.hex \
	    mem_copy.hex 

all: $(TARGETS)

# Create hex memory file
# %.hex: %.elf
# 	$(ELF2HEX) $(ELF2HEX_FLAGS) --input $< --output $@

%.hex: %.elf
	$(OBJCPY) $(OBJCPY_FLAGS) $< $@

# Create .elf from .S
%.elf: %.S
	$(CC) ${CFLAGS} -T ${LD} $< -o $@


clean:
	rm -f *.elf *.hex 

.PHONY: clean all
