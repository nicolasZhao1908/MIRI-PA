import random

import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_add_no_Overflow(dut):
    suit = []
    for _ in range(1000):
        suit.append([random.randint(0, 4096), random.randint(0, 4096)])

    for i in range(len(suit)):
        dut.a.value = suit[i][0]
        dut.b.value = suit[i][1]
        dut.sub.value = 0
        await Timer(1, units="ns")

        assert dut.out.value == suit[i][0] + suit[i][1], f"Addition wrong: {suit[i][0]} + {suit[i][1]} = {dut.out.value} | {suit[i][0] + suit[i][1]}"

@cocotb.test()
async def test_sub_no_Overflow(dut):
    suit = []
    for _ in range(1000):
        a = random.randint(0, 4096)
        suit.append([a, random.randint(0, a)])

    for i in range(len(suit)):
        dut.a.value = suit[i][0]
        dut.b.value = suit[i][1]
        dut.sub.value = 1
        await Timer(1, units="ns")

        assert dut.out.value == suit[i][0] - suit[i][1], f"Addition wrong: {suit[i][0]} - {suit[i][1]} = {dut.out.value} | {suit[i][0] - suit[i][1]}"
