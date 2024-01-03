# BRISC

Basic RISC-V pipelined processor core developed for the final project of
Processor Architecture course at UPC, with the following requirements:

- 6-stage pipeline.
- Supports ADD, ADDI, SUB, LW, LB, SW, SB, BEQ, AUIPC, JAL, MUL instructions
- Store buffer.
- Reorder buffer.
- Instruction and data cache.
- Full bypassing.
- Virtual memory.
- Exception and interruption handling.

## Create tests hex memory file

Requires both [elf2hex](https://github.com/sifive/elf2hex) and
[riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)
to be installed.

```bash
cd tests
make
```

## Running testbench

```bash
pip install -r requirements.txt # Install dependencies
make
```
