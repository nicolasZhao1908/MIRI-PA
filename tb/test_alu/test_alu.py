import cocotb
from cocotb.triggers import Timer

# if cocotb.simulator.is_running():
#     from brisc_pkg import ITYPE

@cocotb.test()
async def adding(dut):
    dut.instr.value = 0b0000000_00001_00001_000_00001_0110011
    await Timer(1, units="ns")

@cocotb.test()
async def subtracting(dut):
    dut.instr.value = 0b0000000_00001_00001_000_00001_0110011
    await Timer(1, units="ns")