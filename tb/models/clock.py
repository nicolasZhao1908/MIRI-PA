import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


class BRiscClock():
    def __init__(self, clk):
        self.clk = clk
        my_clock = Clock(self.clk, 2, units="ps")
        cocotb.start_soon(my_clock.start(start_high=False))
    async def tick(self):
        await RisingEdge(self.clk)
        