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

## Create tests hex memory file

Requires [riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)
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

## References

- [CVA6](https://github.com/openhwgroup/cva6)
    - [MMU code](https://github.com/openhwgroup/cva6/blob/284200dfc94c0f3fd94f13145dee37bdec68bd57/core/mmu_sv32/cva6_mmu_sv32.sv)
    - [MMU docs](https://docs.openhwgroup.org/projects/cva6-user-manual/03_cva6_design/ex_stage.html#memory-management-unit-mmu-par-mmu)
    - [TLB code](https://github.com/openhwgroup/cva6/blob/37427a75a91e0313c0c1a5667ca6e29c9e3088c7/core/mmu_sv32/cva6_tlb_sv32.sv)
    - [TLB docs](https://docs.openhwgroup.org/projects/cva6-user-manual/04_cv32a6_design/source/cv32a6_execute.html#translation-lookaside-buffer)
    - [PTW code](https://github.com/openhwgroup/cva6/blob/284200dfc94c0f3fd94f13145dee37bdec68bd57/core/mmu_sv32/cva6_ptw_sv32.sv)
    - [PTW docs](https://docs.openhwgroup.org/projects/cva6-user-manual/04_cv32a6_design/source/cv32a6_execute.html#page-table-walker)
    - [CSRs](https://docs.openhwgroup.org/projects/cva6-user-manual/01_cva6_user/CV32A6_Control_Status_Registers.html)
- [VM](https://github.com/sifferman/labs-with-cva6/blob/main/labs/vm.md)
- [VM blog](https://danielmangum.com/posts/risc-v-bytes-privilege-levels/)
- [ysyx (Chinese)](https://ysyx.oscc.cc/docs/)
