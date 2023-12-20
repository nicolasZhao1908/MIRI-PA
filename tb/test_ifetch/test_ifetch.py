from clock import BRiscClock
import random
import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_next_pc(dut):
    clock =  BRiscClock(dut.clk)
    boot_addr = 0x1000
    offset = 0

    # Reset
    dut.reset.value = 0b1
    await clock.tick()
    dut.reset.value = 0b0

    for i in range(1,1001):
        expected_curr = boot_addr + offset
        expected_next = boot_addr + offset + 4
        await clock.tick()
        assert (
            dut.pc_curr.value == boot_addr + offset
        ), f"failed at clock {i}: {expected_curr=} got {dut.pc_curr.value}"
        assert (
            dut.pc_next.value == boot_addr + offset + 4
        ), f"failed at clock {i}: {expected_next=} got {dut.pc_next.value}"
        offset += 4


@cocotb.test()
async def test_b_taken(dut):
    clock =  BRiscClock(dut.clk)
    # Reset
    dut.reset.value = 0b1
    await clock.tick()
    dut.reset.value = 0b0

    for i in range(1,1001):
        b_target = random.randrange(int("0x1000", 16), int("0x1FFFF", 16), 4)
        b_taken = random.randint(0, 1)
        dut.b_taken.value = b_taken
        dut.b_target.value = b_target
        await clock.tick()
        expected_next = b_target if b_taken else dut.pc_curr.value + 4
        assert (
            dut.pc_next.value == expected_next
        ), f"at clock cycle {i}: {b_taken=} and {b_target=}, next PC should be {expected_next} but got {dut.pc_next.value}"

    return


@cocotb.test()
async def test_read_instr_from_mem(dut):
    mem = []

    num = 0
    n = 10000

    for i in range(n):
        line = num
        num += 1
        line += num * (2**32)
        num += 1
        line += num * (2**64)
        num += 1
        line += num * (2**96)
        num += 1
        print(bin(line))
        # line = [0] * 128
        # line[0:32] = [1 if (num & (0b1 << i)) > 0 else 0 for i in range(32)]
        # num = num + 1
        # line[32:64] = [1 if (num & (0b1 << i)) > 0 else 0 for i in range(32)]
        # num = num + 1
        # line[64:96] = [1 if (num & (0b1 << i)) > 0 else 0 for i in range(32)]
        # num = num + 1
        # line[96:128] = [1 if (num & (0b1 << i)) > 0 else 0 for i in range(32)]
        # num = num + 1
        mem.append(line)
    dut.reset.value = 1
    dut.b_taken.value = 0

    dut.clk.value = 0
    await Timer(1, units="ns")
    dut.clk.value = 1
    await Timer(1, units="ns")

    dut.reset.value = 0

    num = 0
    for i in range(n):

        if (dut.req_to_arbiter.value):
            print(f"MEM ADDR LOADED: {dut.req_addr_to_mem.value} {int(str(dut.req_addr_to_mem.value), 2)}")
            addr_int = f"{str(dut.req_addr_to_mem.value)}"
            addr_int = int(addr_int, 2)
            dut.fill_data_from_mem.value = mem[(addr_int - 4096) // 16]
            print(f"MEM FILL ({(addr_int - 4096) // 16}) {dut.fill_data_from_mem.value}")
            dut.fill_data_from_mem_valid.value = 1
        else:
            dut.fill_data_from_mem_valid.value = 0

        dut.arbiter_grant.value = dut.req_to_arbiter.value
        dut.stall_fetch.value = dut.stall.value # stalls when cache miss

        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")

        print(f"Current PC: {dut.pc_curr.value}")
        print(f"PC Update: {dut.pc_update.value}")
        print(f"Current instruction: {dut.instr.value}")
        print(f"Cache hit: {dut.cache_hit.value}")
        print(dut.cache.cacheUnit.set.value)
        
        print("------------")

        if dut.stall.value == 0:
            assert num == int(str(dut.instr.value), 2), f"WRONG Instruction code\n{int(str(dut.instr.value), 2)} != {num}"                           
            num += 1



# @cocotb.test()
# async def test_stall(dut):
#     return
        