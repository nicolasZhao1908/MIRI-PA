import random

import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_ff_complete(dut):
    in_val = [0, 0, 0, 0, 1, 1, 1, 1]
    enable = [0, 0, 1, 1, 0, 0, 1, 1]
    reset  = [0, 1, 0, 1, 0, 1, 0, 1]

    result = [0, 0, 0, 0, 0, 0, 1, 0]

    for i in range(8, 10000):
        in_val.append(random.randint(0, 1))
        enable.append(random.randint(0, 1))
        reset.append(0)

        if (enable[i]):
            result.append(in_val[i])
        else:
            result.append(result[i - 1])

    for cycle in range(len(result)):
        dut.enable.value = enable[cycle]
        dut.reset.value = reset[cycle]
        dut.inp.value = in_val[cycle]

        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")
        assert dut.out.value[0] == result[cycle], f"Wrong result: In {in_val[cycle]}, enable {enable[cycle]}, reset {reset[cycle]}"

        assert dut.out.value[0] == result[cycle], f"Consitency Problem: In {in_val[cycle]}, enable {enable[cycle]}, reset {reset[cycle]}"
