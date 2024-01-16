import random

import cocotb
from clock import BRiscClock
from cocotb.binary import BinaryValue

NUM_ENTRIES = 4


@cocotb.test()
async def test_properties(dut):
    i = 0
    clk = BRiscClock(dut.clk)
    dut.reset.value = 1
    await clk.tick()
    dut.reset.value = 0
    dut._log.info("[INFO] Initialize and reset model")
    while i < 10000:
        dut.enable.value = random.randint(0, 1)
        # 0 store, 1 load

        stb_ctrl_in = random.randint(0, 1)
        write_data_in = random.randint(0, 0xFFFF_FFFE)
        data_size_in = random.randint(0, 1)
        addr_in = random.randint(0, 0xFFFF_FFFE)

        dut.stb_ctrl_in.value = stb_ctrl_in
        dut.write_data_in.value = write_data_in
        dut.data_size_in.value = data_size_in
        dut.addr_in.value = addr_in
        i += 1
        await clk.tick()
        assert int(dut.cnt_q.value) <= 4, "[ERROR] Num entries cannot be larger than 4"
        read_ptr = int(dut.read_ptr_q.value)
        write_ptr = int(dut.write_ptr_q.value)
        if int(dut.cnt_q.value) > 0:
            assert (
                dut.entries_q.value[read_ptr][0] == 1
            ), "[ERROR] Entry pointed by the read pointer should be valid! (if NUM_ENTRY > 0)"
            for idx in range(NUM_ENTRIES):
                if not idx in range(read_ptr, write_ptr) and read_ptr != write_ptr:
                    assert (
                        dut.entries_q.value[idx][0] != 1
                    ), f"[ERROR] Entry NOT between read and write pointer should be NOT be valid!{dut.entries_q.value},{read_ptr},{write_ptr}"
