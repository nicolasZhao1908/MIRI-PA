import random

import cocotb
from clock import BRiscClock


@cocotb.test()
async def test_store(dut):
    clock = BRiscClock(dut.clk)
    dut.reset.value = 0
    dut.stall_in.value = 0
    dut.result_WB_in.value = 1000
    dut.wb_rd_in.value = 0b00010

    await clock.tick()

    dut.result_WB_in.value = 100
    dut.wb_rd_in.value = 0b00011

    await clock.tick()

    dut.instr_in.value = create_store(0b00010, 0b00000, 0b1010, "w")

    await clock.tick()

    assert dut.src1.value == 0
    assert dut.rs2_data_out.value == 1000

    dut.instr_in.value = create_store(0b00011, 0b00010, 0b1010, "w")

    await clock.tick()

    assert dut.src1.value == 1000
    assert dut.rs2_data_out.value == 100


@cocotb.test()
async def test_alu(dut):
    clock = BRiscClock(dut.clk)
    dut.reset.value = 0
    dut.stall_in.value = 0
    dut.result_WB_in.value = 1
    dut.rd_WB_in.value = 0b00010

    await clock.tick()

    dut.result_WB_in.value = 2
    dut.wb_rd_in.value = 0b00011

    await clock.tick()
    dut.instr_in.value = create_add(0b00011, 0b00010, 0b11111)
    await clock.tick()

    assert dut.src1.value == 1
    assert dut.src2.value == 2


@cocotb.test()
async def test_imm(dut):
    clock = BRiscClock(dut.clk)
    dut.reset.value = 0
    dut.stall_in.value = 0
    dut.result_WB_in.value = 100
    dut.wb_rd_in.value = 0b00011

    await clock.tick()

    dut.instr_in.value = create_load(0b00011, 0b00010, 1000, "w")
    await clock.tick()

    assert dut.rd_out.value == 0b00010
    assert dut.src1.value == 100
    assert dut.src2.value == 1000


@cocotb.test()
async def test_jump(dut):
    clock = BRiscClock(dut.clk)
    dut.reset.value = 0
    dut.stall_in.value = 0
    await clock.tick()

    dut.instr_in.value = create_jump(1000)
    await clock.tick()

    assert dut.instr_out.value == 0b01100


def create_jump(imm):
    opcode = 0b1101111

    imm_field = imm & 0b11111111000000000000
    imm_field = imm_field | ((imm & 0b100000000000) << 8)
    imm_field = imm_field | ((imm & 0b11111111110) << 9)
    imm_field = imm_field | ((imm & 0b100000000000000000000) << 19)

    instr = (0b00000 << 7) | opcode
    instr = (imm_field << 12) | instr

    return instr


def create_load(rs1, rd, imm, size):
    opcode = 0b0000011

    sizes = {
        "b": 0b000,
        "h": 0b001,
        "w": 0b010,
    }

    funct3 = sizes[size]  # store word

    instr = (rd << 7) | opcode
    instr = (funct3 << 12) | instr
    instr = (rs1 << 15) | instr  # rs1
    instr = (imm << 20) | instr  # rs2

    return instr


def create_add(rs2, rs1, rd):
    opcode = 0b0110011
    funct3 = 0b000
    funct7 = 0b0100000

    instr = (rd << 7) | opcode
    instr = (funct3 << 12) | instr
    instr = (rs1 << 15) | instr  # rs1
    instr = (rs2 << 20) | instr  # rs2
    instr = (funct7 << 25) | instr

    return instr


def create_store(rs2, rs1, offset, size):
    opcode = 0b0100011
    lower_offset = offset & 0b11111
    upper_offset = offset & 0b111111100000

    sizes = {
        "b": 0b000,
        "h": 0b001,
        "w": 0b010,
    }

    funct3 = sizes[size]  # store word

    instr = (lower_offset << 7) | opcode
    instr = (funct3 << 12) | instr
    instr = (rs1 << 15) | instr  # rs1
    instr = (rs2 << 20) | instr  # rs2
    instr = (upper_offset << 25) | instr

    return instr
