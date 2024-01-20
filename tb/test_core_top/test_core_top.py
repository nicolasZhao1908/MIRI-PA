import cocotb
from clock import BRiscClock


@cocotb.test()
async def test_core(dut):
    i = 0
    clk = BRiscClock(dut.clk)
    dut.reset.value = 1
    await clk.tick()
    dut.reset.value = 0
    await clk.tick()
    while i < 2500:
        await clk.tick()
        i += 1
    return
