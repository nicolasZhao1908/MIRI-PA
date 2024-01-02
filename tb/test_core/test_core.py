import cocotb
from clock import BRiscClock
from instr import add, addi

# if cocotb.simulator.is_running():
#     from brisc_pkg import ITYPE

FILENAME = "program.txt"


@cocotb.test()
async def test_raw(dut):
    clock = BRiscClock(dut.clk)
    dut.reset.value = 1
    print(dut.pc_F.value)
    await clock.tick()
    dut.reset.value = 0
    ticks = 0
    print("============")
    print("Testing RAW:")
    print("============")
    print()
    print("ADDI x1, x0, 6")
    print("ADDI x3, x0, 5")
    print("ADD x1, x2, x3")
    print("ADD x3, x1, x2")
    print("ADD x3, x1, x2")
    print()
    with open(FILENAME, "w", encoding="utf8") as f:
        # f.write(addi(0b00001, 0b00010, 0b000000000110))
        # f.write(addi(0b00001, 0b00010, 0b000000000111))
        # f.write(add(0b00001, 0b00010, 0b00011))
        # f.write(add(0b00011, 0b00001, 0b00010))
        # f.write(add(0b00011, 0b00001, 0b00010))
        f.write(addi(1, 0, 6))
        f.write(addi(3, 0, 5))
        f.write(add(1, 2, 3))
        f.write(add(3, 1, 2))
        f.write(add(3, 1, 2))
    while ticks < 100:
        await clock.tick()
        ticks += 1
