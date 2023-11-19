import random

import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_defined_suit(dut):
    suit = [
        getTestLine(1, 0, 0, 0),  # 0
        getTestLine(1, 1, 0, 0),
        getTestLine(1, 2, 0, 0),
        getTestLine(1, 3, 0, 0),  # invalidate Cache

        getTestLine(0, 0, 0),  # 4
        getTestLine(1, 0, 5),  # 5
        getTestLine(0, 0, 0),
        getTestLine(1, 1, 1),
        getTestLine(1, 2, 2),
        getTestLine(1, 3, 6),
        getTestLine(0, 0, 0),  # 10
        getTestLine(0, 1, 0),
        getTestLine(0, 2, 0),
        getTestLine(0, 3, 0),
        getTestLine(0, 5, 0),
        getTestLine(0, 6, 0),  # 15
        getTestLine(0, 7, 0),
        getTestLine(0, 8, 0),
        getTestLine(1, 8, 12),
        getTestLine(1, 9, 51),
        getTestLine(1, 10, 213),
        getTestLine(1, 11, 24),  # 20
        getTestLine(0, 0, 0),
        getTestLine(0, 1, 0),  # 22
        getTestLine(0, 2, 0),
        getTestLine(0, 3, 0),
        getTestLine(0, 5, 0),  # 25
        getTestLine(0, 6, 0),
        getTestLine(0, 7, 0),
        getTestLine(0, 8, 0),  # 29
    ]
    await test_cache(dut, suit)


@cocotb.test()
async def test_random_suit(dut):
    suit = [
        getTestLine(1, 0, 0, 0),  # 0
        getTestLine(1, 1, 0, 0),
        getTestLine(1, 2, 0, 0),
        getTestLine(1, 3, 0, 0),  # invalidate Cache
    ]

    for _ in range(10000):
        suit.append(getTestLine(random.randint(0, 1), random.randint(0, 20), random.randint(0, 4096 * 2)))

    await test_cache(dut, suit)


async def test_cache(dut, suit):
    cache = Cache(2)
    for i in range(len(suit)):
        dut.read_write.value = suit[i][0]
        dut.inp.value = suit[i][1]
        dut.data_in.value = suit[i][2]
        dut.valid_in = suit[i][3]

        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")

        print(f"suit: {suit[i]}")

        # print(f"Write in: {dut.read_write.value}")
        # print(f"Cache Valid out: {dut.valid_from_lines_out.value}")
        # print(f"Write enebles out: {dut.write_enables_out.value}")
        # print(f"Write data out: {dut.data_out.value}")
        # print(f"Input data in: {dut.inp.value}")
        # print(f"Set data out: {dut.set_out.value}")
        # print(f"Tag out: {dut.tag_out.value}")
        if suit[i][0] == 1:
            if suit[i][3] == 1:
                cache.put(suit[i][1], suit[i][2])
        else:
            hit, data = cache.read(suit[i][1])
            assert hit == dut.hit.value, f"Hit malfunctioning: Cycle: {i}. Correct: {hit}, got {dut.hit.value}"
            if hit:
                assert data == int(str(dut.data_out.value),
                                   2), f"Data inconsistent: {int(str(dut.data_out.value), 2)} orig {dut.data_out.value} expected {data} in cycle{i}"


def getTestLine(write, inp, data, valid_in=1):
    return [write, inp, data, valid_in]


def swap_endian(n, width=32):
    b = '{:0{width}b}'.format(n, width=width)
    return int(b[::-1], 2)


class Cache:
    def __init__(self, set_bits):
        self.set_bits = set_bits
        self.lines = [[0, 0, 0] for _ in range(2 ** set_bits)]
        self.set_mask = ((0b1 << set_bits) - 1)

    def put(self, inp, data):
        set = inp & self.set_mask
        self.lines[set][0] = True
        self.lines[set][1] = inp
        self.lines[set][2] = data

    def read(self, inp):
        set = inp & self.set_mask
        hit = self.lines[set][0] and self.lines[set][1] == inp
        return hit, self.lines[set][2]


############ MAKE FILES DATA ############
# VERILOG_SOURCES += $(PWD)/rtl/utility/fully_associative_cache.sv
#
#
# # TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
# TOPLEVEL = fully_associative_cache
#
# # MODULE is the basename of the Python test file
# MODULE = tb.test_utility.test_fully_associative_cache