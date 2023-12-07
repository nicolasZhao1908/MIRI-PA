import pprint
import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_ram(dut):
    await Timer(1, units="ns")
    pprint.pprint(dut.ram.value)
    pprint.pprint(dut.data.value)