from clock import BRiscClock
import cocotb


@cocotb.test()
async def test_response_delay(dut):
    clock = BRiscClock(dut.clk)
    total_cycles = 20
    req = 1
    addr = 0x0000_0000
    expected_resp = 0b1
    expected_data = 0x00500113
    dut.req.value = req
    dut.addr.value = addr

    print(f"Setting req={req} and addr={addr}")
    await clock.tick()

    for i in range(1, total_cycles + 1):
        await clock.tick()
        print(f"clock cycle {i}: {dut.data.value} {dut.resp.value} {expected_data} {expected_resp}")
        if i == total_cycles:
            assert (
                dut.data.value == expected_data
            ), f"after {total_cycles} clock cycles the expected data {expected_data} was not returned"
            assert(
                dut.resp.value == expected_resp
            ), f"after {total_cycles} clock cycles the expected response {expected_resp} was not returned"
        else:
            assert (
                dut.data.value != expected_data
            ), f"at clock cycle {i} the expected data {expected_data} was returned early"
            assert (
                dut.resp.value != expected_resp
            ), f"at clock cycle {i} the expected response {expected_resp} was returned early"
    # await RisingEdge(dut.clk)
    # print(f"RESET: {dut.data.value} {dut.resp.value}")
    # assert dut.data.value == 0x0000_0000, "data was not reseted after response"
    # assert dut.resp.value == 0b0, "response was not resetted after response"
