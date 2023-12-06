import cocotb
from cocotb.triggers import Timer

if cocotb.simulator.is_running():
    from brisc_pkg import ITYPE

@cocotb.test()
async def is_itype(dut):
    dut.instr.value = int('0x00000003',16)
    await Timer(1, units="ns")
    print(f"instr: {dut.instr.value}, itype: {dut.itype.value}")
    assert dut.itype.value == ITYPE["I"], "itype is not I type"

@cocotb.test()
async def is_rtype(dut):
    dut.instr.value = int('0x00000033',16)
    await Timer(1, units="ns")
    print(f"instr: {dut.instr.value}, itype: {dut.itype.value}")
    assert dut.itype.value == ITYPE["R"], "itype is not R type"

@cocotb.test()
async def is_stype(dut):
    dut.instr.value = int('0x00000023',16)
    await Timer(1, units="ns")
    print(f"instr: {dut.instr.value}, itype: {dut.itype.value}")
    assert dut.itype.value == ITYPE["S"], "itype is not S type"

@cocotb.test()
async def is_btype(dut):
    dut.instr.value = int('0x00000063',16)
    await Timer(1, units="ns")
    print(f"instr: {dut.instr.value}, itype: {dut.itype.value}")
    assert dut.itype.value == ITYPE["B"], "itype is not B type"

@cocotb.test()
async def is_invalidtype(dut):
    dut.instr.value = int('0x00000000',16)
    await Timer(1, units="ns")
    print(f"instr: {dut.instr.value}, itype: {dut.itype.value}")
    assert dut.itype.value == ITYPE["INVALID"], "itype is not INVALID type"
