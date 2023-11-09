import cocotb
from cocotb.triggers import Timer

#async def tick(dut):
#    dut.clk.value = 0
#    await Timer(1, units="ns")
#    dut.clk.value = 1
#    await Timer(1, units="ns")

@cocotb.test()
async def is_valid(dut):
    dut.instr.value = int('0x00000013',16)
    assert dut.is_valid.value == 1, "is_valid is not 1!"

@cocotb.test()
async def not_valid(dut):
    dut.instr.value = int('0x0000ffff',16)
    assert dut.is_valid.value == 0, "is_valid is not 0!"
