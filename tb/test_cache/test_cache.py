import cocotb
from clock import BRiscClock


@cocotb.test()
async def test_hit(dut):
    clk = BRiscClock(dut.clk)
    dut.reset.value = 0
    await clk.tick()
    dut.reset.value = 1
    dut.addr = 0x0000_0000
    dut.addr = 0x0000_0000
    dut.addr = 0x0000_0004
    dut.addr = 0x0000_0008
    dut.addr = 0x0000_000C
    dut.addr = 0x0000_0010
    await clk.tick()
    return


@cocotb.test()
async def test_miss():
    return
