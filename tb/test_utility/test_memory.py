import random

from bRISC.tb.simulatedBlocks.memory import Memory
from math import ceil

import cocotb
from cocotb.triggers import Timer

LD = "LD"
ST = "ST"


@cocotb.test()
async def test_defined_suit(dut):
    suit = [
        [ST, 0, 5],
        [LD, 0]
    ]
    await test_suit(dut, suit)


@cocotb.test()
async def test_random_suit(dut):
    suit = []

    for i in range(128):
        suit.append([ST, i, 0])

    for _ in range(10000):
        if random.randint(0, 1) == 0:
            suit.append([LD, random.randint(0, 127)])
        else:
            suit.append([ST, random.randint(0, 127), random.randint(0, 10000)])

    await test_suit(dut, suit)


async def test_suit(dut, suit):
    mem = Memory()
    for i in range(len(suit)):

        dut.req.value = 1
        dut.store.value = suit[i][0] == ST
        dut.address.value = suit[i][1]
        dut.evict_data.value = 15 if len(suit[i]) == 2 else suit[i][2]

        for _ in range(5):
            dut.clk.value = 0
            await Timer(1, units="ns")
            dut.clk.value = 1
            await Timer(1, units="ns")

        if suit[i][0] == ST:
            mem.store(suit[i][1], suit[i][2])

        if suit[i][0] == LD:
            assert dut.response_valid.value == 1, "response should be rdy!"
            memres = mem.load_bin_str(suit[i][1])
            assert str(dut.fill_data.value) == memres, f"Loaded data off: \n{dut.fill_data.value} \n{memres} [REAL]"
        else:
            assert dut.response_valid.value == 0, "there should be no valid response!"




# VERILOG_SOURCES += $(PWD)/rtl/utility/memory.sv
#
#
# # TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
# TOPLEVEL = memory
#
# # MODULE is the basename of the Python test file
# MODULE = tb.test_utility.test_memory
