import cocotb
from clock import BRiscClock


@cocotb.test()
async def test_readmemh(dut):
    clk = BRiscClock(dut.clk)
    dut.req.value = 1
    dut.req_address.value = 0
    dut.req_evict_data.value = 0xFFFF_FFFF
    dut.req_store.value = 1
    i = 0
    while i < 10:
        await clk.tick()
        i += 1
    i = 0
    dut.req.value = 1
    dut.req_address.value = 0
    dut.req_evict_data.value = 0xFFFF_FFFF
    dut.req_store.value = 0
    while i < 10:
        await clk.tick()
        i += 1
