import random

import cocotb
from cocotb.triggers import Timer
from memory import Memory

@cocotb.test()
async def test_with_random_suit(dut):
    # n = 100000
    n = 10000

    suit1 = create_random_suit(n, 0)
    suit2 = create_random_suit(n, 1)

    # suit1[0] = [-1, 8, 2**24-1]
    # suit2[0] = [-1, 0, 0]

    # for i in range(n):
    #     suit2[i][0] = -1

    # suit1[4] = [0, 8, 999]
    #
    # suit2[0][0] = -1
    # suit2[1][0] = -1
    # suit2[2][0] = 0
    # suit2[2][1] = 80

    # for i in range(9):
    #     suit1[i][0] = 1
    #     suit1[i][1] = i

    index1 = 0
    index2 = 0

    executed = []

    m = Memory()

    for i in range(n * 3):
        dut.enable_1.value = suit1[index1][0] >= 0
        dut.store_1.value = suit1[index1][0] if suit1[index1][0] >= 0 else 0
        dut.addr_1.value = suit1[index1][1]
        dut.data_in_1.value = suit1[index1][2]

        dut.enable_2.value = suit2[index2][0] >= 0
        dut.store_2.value = suit2[index2][0] if suit2[index2][0] >= 0 else 0
        dut.addr_2.value = suit2[index2][1]
        dut.data_in_2.value = suit2[index2][2]


        dut.clk.value = 0
        await Timer(1, units="ns")



        oi1 = index1
        oi2 = index2

        print(f"Iterations: i1: {oi1} {suit1[oi1]} {dut.hit_1.value} i2: {oi2} {suit2[oi2]} {dut.hit_2.value}")
        # print(f"R1 G1 R2 G2: {dut.rg_out.value} CLK 0")
        # print(f"RQ_Mem V_Mem: {dut.mem_resp.value}")
        # print(f"Arb to Mem: {int(str(dut.arb2mem.value), 2)} F: {dut.mem2arb.value}")
        # print(f"Arb to Mem Addr: {int(str(dut.arb2memAddr.value), 2)} ST: {dut.arb2memStr.value}")
        # print(f"Evict: {dut.evict_data_out.value}")
        # for i2 in range(9):
        #     print(f"data[{i2}] = {dut.data_out_out.value[i2]}")
        # # print(f"Mem out inst: {dut.mem_oi.value}")
        #
        # print(f"Enables_out: {dut.enables_out.value}")
        # # print(f"CTR A: {dut.controlAddr.value} ST&REQ: {dut.strAndReq.value}")
        # # print(f"{executed}")
        print("---------------------")
        dut.clk.value = 1
        await Timer(1, units="ns")
        # print(f"Iterations: i1: {oi1} {suit1[oi1]} {dut.hit_1.value} i2: {oi2} {suit2[oi2]} {dut.hit_2.value}")
        # print(f"R1 G1 R2 G2: {dut.rg_out.value}  CLK 1")
        # print(f"RQ_Mem V_Mem: {dut.mem_resp.value}")
        # print(f"Arb to Mem: {int(str(dut.arb2mem.value), 2)} F: {dut.mem2arb.value}")
        # print(f"Arb to Mem Addr: {int(str(dut.arb2memAddr.value), 2)} ST: {dut.arb2memStr.value}")
        # print(f"Evict: {dut.evict_data_out.value}")
        # for i2 in range(9):
        #     print(f"data[{i2}] = {dut.data_out_out.value[i2]}")
        # # print(f"Mem out inst: {dut.mem_oi.value}")
        #
        # print(f"Enables_out: {dut.enables_out.value}")
        # print("----------------------------------")


        if dut.hit_1.value or suit1[index1][0] < 0:
            if suit1[index1][0] == 0 and dut.hit_1.value:
                py_data = m.load_ONLY_ONE(suit1[index1][1])
                assert py_data == int(str(dut.data_out_1.value),
                                        2), f"Data inconsistent: {int(str(dut.data_out_1.value), 2)} orig {dut.data_out_1.value} expected {py_data} in cycle{i} {suit1[index1]}"
                executed.append(suit1[index1])
                index1 = (index1 + 1) % n
            elif suit1[index1][0] == 1 and dut.hit_1.value:
                m.store(suit1[index1][1], suit1[index1][2])
                executed.append(suit1[index1])
                # print("STORED! 1")
                #
                # print("P2")
                # print(f"Iterations: i1: {oi1} {suit1[oi1]} {dut.hit_1.value} i2: {oi2} {suit2[oi2]} {dut.hit_2.value}")
                # print(f"R1 G1 R2 G2: {dut.rg_out.value}")
                # print(f"RQ_Mem V_Mem: {dut.mem_resp.value}")
                # print(f"Arb to Mem: {int(str(dut.arb2mem.value), 2)} F: {dut.mem2arb.value}")
                # print(f"Arb to Mem Addr: {int(str(dut.arb2memAddr.value), 2)} ST: {dut.arb2memStr.value}")
                # print(f"Evict: {dut.evict_data_out.value}")
                # for i2 in range(9):
                #     print(f"data[{i2}] = {dut.data_out_out.value[i2]}")
                # py_data = m.load_ONLY_ONE(suit1[index1][1])
                # assert py_data == int(str(dut.data_out_1.value),
                #                       2), f"Data inconsistent: {int(str(dut.data_out_1.value), 2)} orig {dut.data_out_1.value} expected {py_data} in cycle{i} {suit1[index1]}"

                index1 = (index1 + 1) % n
            elif suit1[index1][0] < 0:
                executed.append(suit1[index1])
                index1 = (index1 + 1) % n



        if dut.hit_2.value or suit2[index2][0] < 0:
            if suit2[index2][0] == 0 and dut.hit_2.value:
                py_data = m.load_ONLY_ONE(suit2[index2][1])
                assert py_data == int(str(dut.data_out_2.value),
                                        2), f"Data inconsistent: {int(str(dut.data_out_2.value), 2)} orig {dut.data_out_2.value} expected {py_data} in cycle{i}"
                executed.append(suit2[index2])
                index2 = (index2 + 1) % n
            elif suit2[index2][0] == 1 and dut.hit_2.value:
                m.store(suit2[index2][1], suit2[index2][2])
                executed.append(suit2[index2])
                # print("STORED! 2")

                index2 = (index2 + 1) % n
            elif suit2[index2][0] < 0:
                executed.append(suit2[index2])
                index2 = (index2 + 1) % n

def create_random_suit(n,suit_nr):
    suit = []
    for _ in range(n):
        suit.append([random.randint(-3, 1), random.randint(0 + 16 * suit_nr + suit_nr, 16 * (suit_nr + 1) + suit_nr), random.randint(0, 4096 * 2)])
    return suit
