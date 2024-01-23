# BRISC

Basic RISC-V pipelined processor core developed for the final project of
Processor Architecture course at UPC, with the following requirements:

- Multicycle pipeline.
- Instruction and data caches.
- Unified memory.
- Store buffer.
- Reorder buffer.
- Full bypassing.
- Virtual memory.
- Exception and interruption handling.

## Supported instructions

- Arithmetic: ADD, ADDI, OR, AND, SUB, MUL, AUIPC (needed for la)
- Conditional branch: BEQ
- Unconditional jump: JAL 
- Memory: SB, SW, LB, LW

## Quickstart

```bash
# Available programs are: buffer_sum, memcpy, matmul
PROG=<program_name> make sim
make waves
```

## Create tests hex memory file

Requires [riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)
to be installed.

```bash
# Available targets are: buffer_sum, memcpy, matmul
make -C <program_name>
```

## Running testbench

```bash
 # Install dependencies
pip install -r requirements.txt
# Run a test
make -C tb/<test_directory>
# Or run all tests
make
```
