import random
from math import ceil

import cocotb
from cocotb.triggers import Timer
from memory import Memory

LD = 0
ST = 1


#@cocotb.test()
async def test_defined_suit(dut):
    suit = [
        [ST, 0, 5],
        [LD, 0]
    ]
    await test_suit(dut, suit)


#@cocotb.test()
async def test_random_suit(dut):
    suit = []

    for i in range(128):
        suit.append([ST, i, True])
    # suit = [[1, 15, 8106], [-3, 34, 5765], [1, 8, 3528], [-1, 41, 701], [0, 18, 1785], [-2, 1, 1162], [0, 38, 238], [1, 21, 4423], [1, 29, 5010], [1, 29, 1645], [1, 24, 8128], [0, 23, 3970]]
    for _ in range(10000):
        if random.randint(0, 1) == 0:
            suit.append([LD, random.randint(0, 10) * 4, False])
        else:
            suit.append([ST, random.randint(0, 10) * 4, False])

    await test_suit(dut, suit)


async def test_suit(dut, suit):
    mem = Memory()
    for i in range(len(suit)):

        dut.req.value = suit[i][0] >= 0
        dut.store.value = suit[i][0] == ST if suit[i][0] >= 0 else 0
        dut.address.value = suit[i][1]
        dut.evict_data.value = 15 if len(suit[i]) == 2 else suit[i][2]

        print(f"Suit: {suit[i]} [{i}]")
        
        if suit[i][0] == ST or suit[i][0] < 0:
            dut.clk.value = 0
            await Timer(1, units="ns")
            dut.clk.value = 1
            await Timer(1, units="ns")

            # print(f"Enables: {dut.enables_o.value}")
            # print(f"Evict D: {dut.evictD.value}")
        else:
            for _ in range(5):
                dut.clk.value = 0
                await Timer(1, units="ns")
                dut.clk.value = 1
                await Timer(1, units="ns")

                # print("-----------------------")
                # for x in range(6):
                #     print(f"Cables[{x}]: {dut.cabels[x]}")

        if suit[i][0] == ST:
            mem.store(suit[i][1], suit[i][2], suit[i][3])

        if suit[i][0] == LD:
            assert dut.response_valid.value == 1, "response should be rdy!"
            memres = mem.load_bin_str(suit[i][1])
            assert str(dut.fill_data.value) == memres, f"Loaded data off: \n{dut.fill_data.value} \n{memres} [REAL]"

            dut.clk.value = 0
            await Timer(1, units="ns")
            dut.clk.value = 1
            await Timer(1, units="ns")
        else:
            assert dut.response_valid.value == 0, "there should be no valid response!"




# VERILOG_SOURCES += $(PWD)/rtl/utility/memory.sv


# # TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
# TOPLEVEL = memory

# # MODULE is the basename of the Python test file
# MODULE = tb.test_utility.test_memory
