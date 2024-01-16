import random

import cocotb
from clock import BRiscClock


def debug(dut):
    debug_vars = {
        "read_ptr_q": dut.read_ptr_q.value,
        "read_ptr_n": dut.read_ptr_n.value,
        "write_ptr_q": dut.write_ptr_q.value,
        "write_ptr_n": dut.write_ptr_n.value,
        "entries_q": dut.entries_q.value,
        "entries_n": dut.entries_n.value,
        "flush_q": dut.flush_q.value,
        "flush_n": dut.flush_n.value,
        "cnt_q": dut.cnt_q.value,
        "cnt_n": dut.cnt_n.value,
        "read_data_out": dut.read_data_out.value,
        "read_addr_out": dut.read_addr_out.value,
        "read_valid_out": dut.read_valid_out.value,
        "data_size_out": dut.data_size_out.value,
    }

    dut._log.info(debug_vars)


async def init_clk(dut):
    clk = BRiscClock(dut.clk)
    dut.reset.value = 1
    await clk.tick()
    dut.reset.value = 0
    return clk


@cocotb.test()
async def test_properties(dut):
    i = 0
    clk = BRiscClock(dut.clk)
    dut.reset.value = 1
    await clk.tick()
    dut.reset.value = 0
    dut._log.info("[INFO] Initialize and reset model")
    while i < 1000:
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
        dut._log.info(
            f"[INFO] {i}\t{dut.enable.value}\t{dut.stb_ctrl_in.value}"
        )
        assert (
            not(dut.can_store.value and dut.flush_q.value)
        ), "[ERROR] Cannot write and flush at the same time"
        i += 1
        await clk.tick()
        assert (
           int(dut.cnt_q.value) <= 4
        ), "[ERROR] Num entries cannot be larger than 4"


# @cocotb.test()
# async def test_insert(dut):
#     clk = await init_clk(dut)
#     dut.enable.value = 1
#     dut.stb_ctrl_in.value = 0
#     dut.write_data_in.value = 100
#     dut.data_size_in.value = 1
#     dut.addr_in.value = 1
#     await clk.tick()
#     dut.write_data_in.value = 200
#     dut.data_size_in.value = 1
#     dut.addr_in.value = 2
#     await clk.tick()
#     dut.write_data_in.value = 300
#     dut.data_size_in.value = 1
#     dut.addr_in.value = 3
#     await clk.tick()
#     dut.write_data_in.value = 400
#     dut.data_size_in.value = 1
#     dut.addr_in.value = 3
#     await clk.tick()
#     debug(dut)

# @cocotb.test()
# async def test_flush(dut):
#     clk = await init_clk(dut)
#     dut.enable.value = 1
#     dut.stb_ctrl_in.value = 0
#     dut.write_data_in.value = 100
#     dut.data_size_in.value = 1
#     dut.addr_in.value = 1
#     await clk.tick()
#     dut.write_data_in.value = 200
#     dut.data_size_in.value = 0
#     dut.addr_in.value = 2
#     await clk.tick()
#     dut.write_data_in.value = 300
#     dut.data_size_in.value = 0
#     dut.addr_in.value = 3
#     await clk.tick()
#     debug(dut)
#     await clk.tick()
#     debug(dut)
#     await clk.tick()
#     debug(dut)
#     await clk.tick()
#     debug(dut)
#     await clk.tick()
#     debug(dut)

# @cocotb.test()
# async def test_stall_flush(dut):
#     clk = await init_clk(dut)
#     dut.enable.value = 1
#     dut.stb_ctrl_in.value = 0
#     dut.write_data_in.value = 100
#     dut.data_size_in.value = 1
#     dut.addr_in.value = 1
#     await clk.tick()
#     dut.write_data_in.value = 200
#     dut.data_size_in.value = 0
#     dut.addr_in.value = 2
#     await clk.tick()
#     dut.write_data_in.value = 300
#     dut.data_size_in.value = 0
#     dut.addr_in.value = 3
#     await clk.tick()
#     dut.write_data_in.value = 400
#     dut.data_size_in.value = 0
#     dut.addr_in.value = 3
#     dut.enable.value = 0
#     await clk.tick()
#     await clk.tick()
#     await clk.tick()
#     await clk.tick()
#     await clk.tick()
#     debug(dut)
#     dut.enable.value = 0
#     await clk.tick()
#     await clk.tick()
#     await clk.tick()
#     await clk.tick()
#     await clk.tick()
#     debug(dut)


# @cocotb.test()
# async def test_read_most_recent(dut):
#     clk = await init_clk(dut)
#     dut.enable.value = 1
#     dut.stb_ctrl_in.value = 0
#     dut.write_data_in.value = 1
#     dut.data_size_in.value = 1
#     dut.addr_in.value = 1
#     await clk.tick()
#     dut.write_data_in.value = 2
#     dut.data_size_in.value = 1
#     await clk.tick()
#     dut.write_data_in.value = 3
#     dut.data_size_in.value = 1
#     await clk.tick()
#     dut.stb_ctrl_in.value = 1
#     await clk.tick()
#     debug(dut)
