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
async def test_comperator_random(dut):
    for cycle in range(ROUNDS):
        inp_1 = random.randint(0, 1)
        inp_2 = random.randint(0, 1)

        dut.inp_1.value = inp_1
        dut.inp_2.value = inp_2

        # dut.clk.value = 0
        # await Timer(1, units="ns")
        # dut.clk.value = 1
        await Timer(1, units="ns")

        assert dut.is_equal.value == (inp_1 == inp_2), f"Comperator not working: {inp_1} and {inp_2}"

