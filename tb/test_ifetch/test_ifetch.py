import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


async def resp_delay(clk):
    await RisingEdge(clk)
    await RisingEdge(clk)
    await RisingEdge(clk)
    await RisingEdge(clk)
    await RisingEdge(clk)


async def req_delay(clk):
    await RisingEdge(clk)
    await RisingEdge(clk)
    await RisingEdge(clk)
    await RisingEdge(clk)
    await RisingEdge(clk)


@cocotb.test()
async def test_next_pc(dut):
    clock = Clock(dut.clk, 5, units="ns")
    cocotb.start_soon(clock.start(start_high=False))
    boot_addr = 0x1000
    offset = 0

    # Reset
    dut.reset.value = 0b1
    await RisingEdge(dut.clk)
    dut.reset.value = 0b0

    for i in range(1,1001):
        expected_curr = boot_addr + offset
        expected_next = boot_addr + offset + 4
        await RisingEdge(dut.clk)
        assert (
            dut.pc_curr.value == boot_addr + offset
        ), f"failed at clock {i}: {expected_curr=} got {dut.pc_curr.value}"
        assert (
            dut.pc_next.value == boot_addr + offset + 4
        ), f"failed at clock {i}: {expected_next=} got {dut.pc_next.value}"
        offset += 4


@cocotb.test()
async def test_b_taken(dut):
    clock = Clock(dut.clk, 5, units="ns")
    cocotb.start_soon(clock.start(start_high=False))
    # Reset
    dut.reset.value = 0b1
    await RisingEdge(dut.clk)
    dut.reset.value = 0b0

    for i in range(1,1001):
        b_target = random.randrange(int("0x1000", 16), int("0x1FFFF", 16), 4)
        b_taken = random.randint(0, 1)
        dut.b_taken.value = b_taken
        dut.b_target.value = b_target
        await RisingEdge(dut.clk)
        expected_next = b_target if b_taken else dut.pc_curr.value + 4
        assert (
            dut.pc_next.value == expected_next
        ), f"at clock cycle {i}: {b_taken=} and {b_target=}, next PC should be {expected_next} but got {dut.pc_next.value}"

    return

# @cocotb.test()
# async def test_stall(dut):
#     return
