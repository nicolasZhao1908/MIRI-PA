import random
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
    mem = SimulatedMemory()
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


class SimulatedMemory:
    def __init__(self, fill_data_width=128, spaces=128, cell_width=32):
        self.fill_data_width = fill_data_width
        self.size = spaces
        self.mem = [0] * spaces
        self.cell_width = cell_width
        self.cells_per_line = fill_data_width // cell_width

    def store(self, addr, data):
        self.mem[addr] = data;

    def load(self, addr):
        line_start = (addr // self.cells_per_line) * self.cells_per_line

        result = []
        for i in range(self.cells_per_line):
            result.append(self.mem[line_start + i])
        return result

    def load_bin_str(self, addr):
        arr = self.load(addr)
        res = ""
        formatS = f":0{self.cell_width}b"
        formatS = "{" + formatS + "}"
        for i in range(self.cells_per_line):
            binS = formatS.format(arr[i])
            res = f"{binS}{res}"

        return res
