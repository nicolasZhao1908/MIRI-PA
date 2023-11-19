import cocotb
from cocotb.triggers import Timer

#async def tick(dut):
#    dut.clk.value = 0
#    await Timer(1, units="ns")
#    dut.clk.value = 1
#    await Timer(1, units="ns")

@cocotb.test()
async def test_ff_complete(dut):
    in_val = [0, 0, 0, 0, 1, 1, 1, 1]
    enable = [0, 0, 1, 1, 0, 0, 1, 1]
    reset  = [0, 1, 0, 1, 0, 1, 0, 1]

    result = [0, 0, 0, 0, 0, 0, 1, 0]
    for cycle in range(len(result)):
        dut.enable.value = enable[cycle]
        dut.reset.value = reset[cycle]
        dut.inp.value = in_val[cycle]

        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")
        assert dut.out.value[0] == result[cycle], f"Wrong result: In {in_val[cycle]}, enable {enable[cycle]}, reset {reset[cycle]}"

        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")
        assert dut.out.value[0] == result[cycle], f"Consitency Problem: In {in_val[cycle]}, enable {enable[cycle]}, reset {reset[cycle]}"
