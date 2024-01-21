import os

import cocotb
from clock import BRiscClock


async def check_success(dut, test):
    match test:
        case "matmul":
            return dut.mem.datas_q.value[4110] != 24
        case "buffer_sum":
            return dut.mem.datas_q.value[4096] != 128
        case "memcpy":
            return dut.mem.datas_q.value[4223] != 5
    return True


@cocotb.test()
async def test_core(dut):
    clk = BRiscClock(dut.clk)
    dut.reset.value = 1
    await clk.tick()
    dut.reset.value = 0
    i = 1
    await clk.tick()
    test = os.environ.get("PROG")
    while i < 5000 and await check_success(dut, test):
        await clk.tick()
        i += 1
    dut._log.info("##################################################################")
    dut._log.info(f"[PERFORMANCE] {i} total cycles for {test} test")
    dut._log.info("##################################################################")
    return
