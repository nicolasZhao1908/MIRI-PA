import cocotb
from clock import BRiscClock


@cocotb.test()
async def test_buffer_sum(dut):
    i = 0
    clk = BRiscClock(dut.clk)
    dut.reset.value = 1
    await clk.tick()
    dut.reset.value = 0
    await clk.tick()
    while i < 3000:
        await clk.tick()
        i += 1
    return


@cocotb.test()
async def test_memcpy(dut):
    return


@cocotb.test()
async def test_matmul(dut):
    return
