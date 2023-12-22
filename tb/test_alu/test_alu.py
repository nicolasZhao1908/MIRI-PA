from brisc_pkg import INSTR_E
import random
import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def adding(dut):
    for instr in ["ADD", "ADDI", "LW", "LB", "SW", "SB"]:
        for i in range(1000):
            dut.instr.value = INSTR_E[instr]
            a = random.randint(0, int("0xFFFFFFFF", 16))
            b = random.randint(0, int("0xFFFFFFFF", 16))
            expected_value = (a + b) % (2**32)
            dut.src1.value = a
            dut.src2.value = b
            await Timer(1, units="ns")
            assert (
                dut.alu_res.value == expected_value
            ), f"Iteration {i}: expected {expected_value} but got {dut.alu_res.value}"


@cocotb.test()
async def adding_signed(dut):
    for instr in ["ADD", "ADDI", "LW", "LB", "SW", "SB"]:
        for i in range(1000):
            dut.instr.value = INSTR_E[instr]
            a = random.randint(0, int("0x7FFFFFFF", 16)) # positive
            b = random.randint(int("0x80000000", 16), int("0xFFFFFFFF", 16)) # negative
            expected_value = (a + b) % (2**32)
            dut.src1.value = a
            dut.src2.value = b
            await Timer(1, units="ns")
            assert (
                dut.alu_res.value == expected_value
            ), f"Iteration {i}: expected {expected_value} but got {dut.alu_res.value}"
        for i in range(1000):
            dut.instr.value = INSTR_E[instr]
            a = random.randint(int("0x80000000", 16), int("0xFFFFFFFF", 16)) # positive
            b = random.randint(int("0x80000000", 16), int("0xFFFFFFFF", 16)) # negative
            expected_value = (a + b) % (2**32)
            dut.src1.value = a
            dut.src2.value = b
            await Timer(1, units="ns")
            assert (
                dut.alu_res.value == expected_value
            ), f"Iteration {i}: expected {expected_value} but got {dut.alu_res.value}"


@cocotb.test()
async def subtracting(dut):
    for instr in ["BEQ", "SUB"]:
        for i in range(1000):
            dut.instr.value = INSTR_E[instr]
            a = random.randint(0, int("0x7FFFFFFF", 16)) # positive
            b = random.randint(0, int("0x7FFFFFFF", 16)) # positive
            expected_value = a - b
            dut.src1.value = a
            dut.src2.value = b
            await Timer(1, units="ns")
            assert twos_comp(dut.alu_res.value,32) == expected_value , f"Iteration {i}: {a} - {b} = {expected_value} != {twos_comp(dut.alu_res.value,32)}"
            if instr == "BEQ" and expected_value == 0:
                assert dut.b_taken.value == 1
            else:
                assert dut.b_taken.value == 0

def twos_comp(val, bits):
    """compute the 2's complement of int value val"""
    if (val & (1 << (bits - 1))) != 0: # if sign bit is set e.g., 8bit: 128-255
        val = val - (1 << bits)        # compute negative value
    return val                         # return positive value as is
