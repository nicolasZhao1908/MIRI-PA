import random

import cocotb
from cocotb.triggers import Timer
from memory import Memory

@cocotb.test()
async def test_defined_suit(dut):
    suit = [
        getTestLine(1, 0, 0, 1, 0),  # 0
        getTestLine(1, 1 * 4, 0, 1, 0),
        getTestLine(1, 2 * 4, 0, 1, 0),
        getTestLine(1, 3 * 4, 0, 1, 0),  # invalidate Cache

        getTestLine(0, 4 * 0, 0, 0),  # 4
        getTestLine(1, 4 * 0, 5, 0),  # 5
        getTestLine(0, 4 * 0, 0, 0),
        getTestLine(1, 4 * 1, 1, 0),
        getTestLine(1, 4 * 2, 2, 0),
        getTestLine(1, 4 * 3, 6, 0),
        getTestLine(0, 4 * 0, 0, 0),  # 10
        getTestLine(0, 4 * 1, 0, 0),
        getTestLine(0, 4 * 2, 0, 0),
        getTestLine(0, 4 * 3, 0, 0),
        getTestLine(0, 4 * 5, 0, 0),
        getTestLine(0, 4 * 6, 0, 0),  # 15
        getTestLine(0, 4 * 7, 0, 0),
        getTestLine(0, 4 * 8, 0, 0),
        getTestLine(1, 4 * 8, 12, 0),
        getTestLine(1, 4 * 9, 51, 0),
        getTestLine(1, 4 * 10, 213, 0),
        getTestLine(1, 4 * 11, 24, 0),  # 20
        getTestLine(0, 4 * 0, 0, 0),
        getTestLine(0, 4 * 1, 0, 0),  # 22
        getTestLine(0, 4 * 2, 0, 0),
        getTestLine(0, 4 * 3, 0, 0),
        getTestLine(0, 4 * 5, 0, 0),  # 25
        getTestLine(0, 4 * 6, 0, 0),
        getTestLine(0, 4 * 7, 0, 0),
        getTestLine(0, 4 * 8, 0, 0),  # 29
    ]
    await test_cache(dut, suit)

@cocotb.test()
async def test_random_suit(dut):
    suit = [
        getTestLine(1, 0, 0, 1, 0),  # 0
        getTestLine(1, 1, 0, 1, 0),
        getTestLine(1, 2, 0, 1, 0),
        getTestLine(1, 3, 0, 1, 0),  # invalidate Cache
    ]

    for i in range(128):
        suit.append(getTestLine(1, i, 0, 1))

    for _ in range(10000):
        if (random.randint(0, 1) == 0):
            suit.append(getTestLine(random.randint(0, 1), random.randint(0, 20 * 4), random.randint(0, 255), 0))
        else:
            suit.append(getTestLine(random.randint(0, 1), random.randint(0, 20) * 4, random.randint(0, 4096 * 2), 1))

    await test_cache(dut, suit)

async def wait_cycle(dut):
    dut.clk.value = 0
    await Timer(1, units="ns")
    dut.clk.value = 1
    await Timer(1, units="ns")

async def test_cache(dut, suit):
    mem = Memory()
    for i in range(len(suit)):
        dut.store.value = suit[i][0]
        dut.addr.value = suit[i][1]
        dut.data_in.value = suit[i][2]
        dut.word.value = suit[i][3]
        #dut.valid_in = suit[i][4]

        print(f"suit: {suit[i]}")

        if suit[i][0] == 1:
            await wait_cycle(dut)
            print("Waited 1 cycle")
            # print(f"Send to Mem: {dut.sendD.value}")
            # print(f"Enables: {[dut.enables.value[i] for i in range(512)]}")
            if suit[i][4] == 1:
                mem.store(suit[i][1], suit[i][2], suit[i][3])

        else:
            if (suit[i][3] == 0):
                real_data = mem.load_ONLY_ONE_BYTE(suit[i][1])
            else:
                real_data = mem.load_ONLY_ONE_WORD(suit[i][1])

            rtl_hit = False
            for wait in range(10):
                await wait_cycle(dut)
                print("Waited 1 cycle")

                rtl_hit = dut.hit.value
                if rtl_hit:
                    break
            
            # print(f"Cacheline: {dut.data_out_cache_unit_o.value}")
            # print(f"Word: {dut.word_out_out.value}")
            assert rtl_hit, "Cache hit guaranteed after time!"

            assert real_data == int(str(dut.data_out.value),
                                   2), f"Data inconsistent: {int(str(dut.data_out.value), 2)} orig {dut.data_out.value} expected {real_data} in cycle{i}"
        
        # print(f"Data: {[dut.data_out_out.value[i] for i in range(12)]}")


def getTestLine(write, inp, data, word, valid_in = 1):
    return [write, inp, data, word, valid_in]


def swap_endian(n, width=32):
    b = '{:0{width}b}'.format(n, width=width)
    return int(b[::-1], 2)

# VERILOG_SOURCES += $(PWD)/rtl/cache/dcache.sv
#
# #SIM_ARGS = -Wno{MODDUP}
#
# # TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
# TOPLEVEL = dcache_mem_testonly
#
# # MODULE is the basename of the Python test file
# MODULE = tb.test_cache.test_dcache
