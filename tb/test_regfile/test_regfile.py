import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


@cocotb.test()
async def test_write_read(dut):
    clock = Clock(dut.clk, 2, units="ps")
    cocotb.start_soon(clock.start(start_high=False))
    for i in range(100):
        expected_value = random.randint(0, int("0xFFFFFFFF", 16))
        dut.write_data.value = expected_value
        write_addr = random.randint(1, 31)
        dut.rd_addr.value = write_addr
        dut.enable.value = random.randint(0, 1)
        await RisingEdge(dut.clk)
        # write performed
        dut.rs1_addr.value = write_addr
        dut.rs2_addr.value = write_addr
        await RisingEdge(dut.clk)
        # read performed
        if dut.enable.value == 1:
            assert (
                dut.rs1_data.value == expected_value
            ), f"read value in iteration {i} was {dut.rs1.data.value}, expected {expected_value}"
            assert (
                dut.rs2_data.value == expected_value
            ), f"read value in iteration {i} was {dut.rs2.data.value}, expected {expected_value}"
