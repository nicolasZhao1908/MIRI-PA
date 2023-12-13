import cocotb
from cocotb.triggers import Timer

# if cocotb.simulator.is_running():
#     from brisc_pkg import ITYPE

@cocotb.test()
async def is_add(dut):
    dut.instr.value = 0b0000000_00001_00001_000_00001_0110011
    await Timer(1, units="ns")
    assert dut.rs1.value == 0b00001
    assert dut.rs2.value == 0b00001
    assert dut.rd.value == 0b00001
    assert dut.i_valid.value == 0b1
    assert dut.out_instr.value == 0b00100

@cocotb.test()
async def is_xor(dut):
    dut.instr.value = 0b0000000_00001_00001_100_00001_0110011
    await Timer(1, units="ns")
    assert dut.rs1.value == 0b00001
    assert dut.rs2.value == 0b00001
    assert dut.rd.value == 0b00001
    assert dut.i_valid.value == 0b1
    assert dut.out_instr.value == 0b00111

@cocotb.test()
async def is_and(dut):
    dut.instr.value = 0b0000000_00001_00001_111_00001_0110011
    await Timer(1, units="ns")
    assert dut.rs1.value == 0b00001
    assert dut.rs2.value == 0b00001
    assert dut.rd.value == 0b00001
    assert dut.i_valid.value == 0b1
    assert dut.out_instr.value == 0b00101

@cocotb.test()
async def is_or(dut):
    dut.instr.value = 0b0000000_00001_00001_110_00001_0110011
    await Timer(1, units="ns")
    assert dut.rs1.value == 0b00001
    assert dut.rs2.value == 0b00001
    assert dut.rd.value == 0b00001
    assert dut.i_valid.value == 0b1
    assert dut.out_instr.value == 0b00110


@cocotb.test()
async def is_sub(dut):
    dut.instr.value = 0b0100000_00001_00001_000_00001_0110011
    await Timer(1, units="ns")
    assert dut.rs1.value == 0b00001
    assert dut.rs2.value == 0b00001
    assert dut.rd.value == 0b00001
    assert dut.i_valid.value == 0b1
    assert dut.out_instr.value == 0b00011


@cocotb.test()
async def is_mul(dut):
    dut.instr.value = 0b0000001_00001_00001_000_00001_0110011
    await Timer(1, units="ns")
    assert dut.rs1.value == 0b00001
    assert dut.rs2.value == 0b00001
    assert dut.rd.value == 0b00001
    assert dut.i_valid.value == 0b1
    assert dut.out_instr.value == 0b01000

@cocotb.test()
async def is_lb(dut):
    dut.instr.value = 0b010000000001_00001_000_00001_0000011
    await Timer(1, units="ns")
    assert dut.rs1.value == 0b00001
    assert dut.imm.value == 0b010000000001
    assert dut.rd.value == 0b00001
    assert dut.i_valid.value == 0b1
    assert dut.out_instr.value == 0b00001


@cocotb.test()
async def is_lw(dut):
    dut.instr.value = 0b010000000001_00001_010_00001_0000011
    await Timer(1, units="ns")
    assert dut.rs1.value == 0b00001
    assert dut.imm.value == 0b010000000001
    assert dut.rd.value == 0b00001
    assert dut.i_valid.value == 0b1
    assert dut.out_instr.value == 0b00000


@cocotb.test()
async def is_sb(dut):
    dut.instr.value = 0b0000001_00001_00001_000_00001_0100011
    await Timer(1, units="ns")
    assert dut.rs1.value == 0b00001
    assert dut.rs2.value == 0b00001
    assert dut.imm.value == 0b000000100001
    assert dut.i_valid.value == 0b1
    assert dut.out_instr.value == 0b01010


@cocotb.test()
async def is_sw(dut):
    dut.instr.value = 0b0000001_00001_00001_010_00001_0100011
    await Timer(1, units="ns")
    assert dut.rs1.value == 0b00001
    assert dut.rs2.value == 0b00001
    assert dut.imm.value == 0b000000100001
    assert dut.i_valid.value == 0b1
    assert dut.out_instr.value == 0b01001

@cocotb.test()
async def is_beq(dut):
    dut.instr.value = 0b1100000_00001_00001_000_00001_1100011
    await Timer(1, units="ns")
    assert dut.rs1.value == 0b00001
    assert dut.rs2.value == 0b00001
    assert dut.imm.value == 0b1111_1111_1111_1111_111_1_1_100000_00000
    assert dut.i_valid.value == 0b1
    assert dut.out_instr.value == 0b01011

@cocotb.test()
async def is_jal(dut):
    dut.instr.value = 0b11000000000100001010_00001_1101111
    await Timer(1, units="ns")
    assert dut.rs1.value == 0b00001
    assert dut.imm.value == 0b1111_1111_111_1_00001010_1_10000000000
    assert dut.i_valid.value == 0b1
    assert dut.out_instr.value == 0b01100

@cocotb.test()
async def is_addi(dut):
    dut.instr.value = 0b11000000000100001010_00001_0010011
    await Timer(1, units="ns")
    assert dut.rs1.value == 0b00001
    assert dut.imm.value == 0b1111_1111_111_1_00001010_1_10000000000
    assert dut.i_valid.value == 0b1
    assert dut.out_instr.value == 0b00010

@cocotb.test()
async def is_invalid(dut):
    dut.instr.value = 0x0000_0000
    await Timer(1, units="ns")
    assert dut.i_valid.value == 0b0
