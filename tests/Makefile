LD = linker.ld
CC = riscv64-unknown-linux-gnu-gcc 
CFLAGS = -static -nostdlib -nostartfiles -march=rv32im -O0 -mabi=ilp32
OBJCPY = riscv64-unknown-linux-gnu-objcopy
OBJCPY_FLAGS = -O verilog --verilog-data-width=4
XCPT = xcpt.S
# ELF2HEX = riscv64-unknown-elf-elf2hex 
# ELF2HEX_FLAGS =  --bit-width 32

TARGETS = adding \
	    buffer_sum \
	    memcpy 

all: $(TARGETS)

adding: adding.elf
	$(OBJCPY) $(OBJCPY_FLAGS) $< mem.hex

memcpy: memcpy.elf
	$(OBJCPY) $(OBJCPY_FLAGS) $< mem.hex

buffer_sum: buffer_sum.elf
	$(OBJCPY) $(OBJCPY_FLAGS) $< mem.hex

# Create .elf from .S
%.elf: %.S
	$(CC) ${CFLAGS} -T ${LD} $< -o $@

# Create hex memory file
# %.hex: %.elf
# 	$(ELF2HEX) $(ELF2HEX_FLAGS) --input $< --output $@

clean:
	rm -f *.elf *.hex 

.PHONY: clean all $(TARGETS)
