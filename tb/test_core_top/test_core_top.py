import subprocess

import cocotb
from clock import BRiscClock


@cocotb.test()
async def test_buffer_sum(dut):
    # subprocess.run(["make", "-C", "../../tests", "buffer_sum"])
    i = 0
    clk = BRiscClock(dut.clk)
    while i < 500:
        await clk.tick()
        i += 1
    return


@cocotb.test()
async def test_memcpy(dut):
    return


@cocotb.test()
async def test_matmul(dut):
    return
