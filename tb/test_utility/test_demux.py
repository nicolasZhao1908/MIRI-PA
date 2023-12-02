import random

import cocotb
from cocotb.triggers import Timer

#async def tick(dut):
#    dut.clk.value = 0
#    await Timer(1, units="ns")
#    dut.clk.value = 1
#    await Timer(1, units="ns")

ROUNDS = 100
@cocotb.test()
async def test_demux(dut):
    for i in range(128):

        dut.inp.value = 1
        dut.control.value = i

        # dut.clk.value = 0
        # await Timer(1, units="ns")
        # dut.clk.value = 1
        await Timer(1, units="ns")

        print(f"dmux: {dut.out.value}")
        print(f"i: {dut.out.value[i]}")

        #assert dut.is_equal.value[i] == 1, f"Demux is shit"

