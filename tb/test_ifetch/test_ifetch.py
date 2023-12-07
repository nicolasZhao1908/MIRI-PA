import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge 

async def resp_delay(clk):
    await(RisingEdge(clk))
    await(RisingEdge(clk))
    await(RisingEdge(clk))
    await(RisingEdge(clk))
    await(RisingEdge(clk))

async def req_delay(clk):
    await(RisingEdge(clk))
    await(RisingEdge(clk))
    await(RisingEdge(clk))
    await(RisingEdge(clk))
    await(RisingEdge(clk))

@cocotb.test()
async def test_next_pc(dut):
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start(start_high=False))
    # dut.b_taken.value = 0b0
    # dut.b_addr.value = 0x2000

    # Reset
    dut.rst.value = 0b1
    await RisingEdge(dut.clk)
    dut.rst.value = 0b0

    #fetching first instruction

    # sends request to imem and takes 5 cycles
    await req_delay(dut.clk)
    print(hex(dut.pc_curr.value), hex(dut.pc_next.value))
    print(hex(dut.instr.value))
    # imem responds after 5 cycles
    await resp_delay(dut.clk)
    print(hex(dut.pc_curr.value), hex(dut.pc_next.value))
    print(hex(dut.instr.value))

    # fetching second instruction

    # sends request to imem and takes 5 cycles
    await req_delay(dut.clk)
    print(hex(dut.pc_curr.value), hex(dut.pc_next.value))
    print(hex(dut.instr.value))
    # imem responds after 5 cycles
    await resp_delay(dut.clk)
    print(hex(dut.pc_curr.value), hex(dut.pc_next.value))
    print(hex(dut.instr.value))

    # sends request to imem and takes 5 cycles
    await req_delay(dut.clk)
    print(hex(dut.pc_curr.value), hex(dut.pc_next.value))
    print(hex(dut.instr.value))
    # imem responds after 5 cycles
    await resp_delay(dut.clk)
    print(hex(dut.pc_curr.value), hex(dut.pc_next.value))
    print(hex(dut.instr.value))

    # sends request to imem and takes 5 cycles
    await req_delay(dut.clk)
    print(hex(dut.pc_curr.value), hex(dut.pc_next.value))
    print(hex(dut.instr.value))
    # imem responds after 5 cycles
    await resp_delay(dut.clk)
    print(hex(dut.pc_curr.value), hex(dut.pc_next.value))
    print(hex(dut.instr.value))

    # sends request to imem and takes 5 cycles
    await req_delay(dut.clk)
    print(hex(dut.pc_curr.value), hex(dut.pc_next.value))
    print(hex(dut.instr.value))
    # imem responds after 5 cycles
    await resp_delay(dut.clk)
    print(hex(dut.pc_curr.value), hex(dut.pc_next.value))
    print(hex(dut.instr.value))

    # sends request to imem and takes 5 cycles
    await req_delay(dut.clk)
    print(hex(dut.pc_curr.value), hex(dut.pc_next.value))
    print(hex(dut.instr.value))
    # imem responds after 5 cycles
    await resp_delay(dut.clk)
    print(hex(dut.pc_curr.value), hex(dut.pc_next.value))
    print(hex(dut.instr.value))

    # sends request to imem and takes 5 cycles
    await req_delay(dut.clk)
    print(hex(dut.pc_curr.value), hex(dut.pc_next.value))
    print(hex(dut.instr.value))
    # imem responds after 5 cycles
    await resp_delay(dut.clk)
    print(hex(dut.pc_curr.value), hex(dut.pc_next.value))
    print(hex(dut.instr.value))

# @cocotb.test()
# async def test_take_branch(dut):
#     return

# @cocotb.test()
# async def test_stall(dut):
#     return
