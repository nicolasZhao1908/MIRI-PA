import random

import cocotb
from clock import BRiscClock


@cocotb.test()
async def test_write_read(dut):
    clock = BRiscClock(dut.clk)
    for i in range(100):
        expected_value = random.randint(0, int("0xFFFFFFFF", 16))
        dut.write_data.value = expected_value
        write_addr = random.randint(1, 31)
        dut.rd_addr.value = write_addr
        dut.enable.value = random.randint(0, 1)
        await clock.tick()
        # write performed
        dut.rs1_addr.value = write_addr
        dut.rs2_addr.value = write_addr
        await clock.tick()
        # read performed
        if dut.enable.value == 1:
            assert (
                dut.rs1_data.value == expected_value
            ), f"read value in iteration {i} was {dut.rs1.data.value}, expected {expected_value}"
            assert (
                dut.rs2_data.value == expected_value
            ), f"read value in iteration {i} was {dut.rs2.data.value}, expected {expected_value}"


@cocotb.test()
async def test_write_to_r0(dut):
    clock = BRiscClock(dut.clk)
    for i in range(100):
        expected_value = random.randint(0, int("0xFFFFFFFF", 16))
        dut.write_data.value = expected_value
        write_addr = 0
        dut.rd_addr.value = write_addr
        dut.enable.value = 1
        await clock.tick()
        # write performed
        dut.rs1_addr.value = write_addr
        dut.rs2_addr.value = write_addr
        await clock.tick()
        # read performed
        if dut.enable.value == 1:
            assert (
                dut.rs1_data.value == 0
            ), f"read value in iteration {i} was {dut.rs1.data.value}, expected 0"
            assert (
                dut.rs2_data.value == 0
            ), f"read value in iteration {i} was {dut.rs2.data.value}, expected 0"
