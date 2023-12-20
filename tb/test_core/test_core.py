import cocotb
from cocotb.triggers import Timer

# if cocotb.simulator.is_running():
#     from brisc_pkg import ITYPE

@cocotb.test()
async def printProcedure(dut):
    print("Hi")
    print("Thats me!")
    print("You may wonder how i got into this situation:")
    print("It all began in the PA class...")