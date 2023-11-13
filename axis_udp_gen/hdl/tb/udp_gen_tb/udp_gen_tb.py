#!/usr/bin/python

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer


class Tb(object):
    def __init__(self, dut):
        self.dut = dut
        cocotb.start_soon(Clock(self.dut.clk, 10, units="ns").start())

    async def reset(self):
        self.dut.s_rst_n.value = 0
        await RisingEdge(self.dut.clk)
        self.dut.s_rst_n.value = 1

    async def set(self):
        self.dut.dst_mac_addr.value = 0x444546474849
        self.dut.src_ipv4_addr.value = 0x19216801
        self.dut.dst_ipv4_addr.value = 0x19216802
        self.dut.src_udp_port.value = 0x2134
        self.dut.dst_udp_port.value = 0x5467

    async def start(self):
        self.dut.en.value = 1
        await RisingEdge(self.dut.clk)

    async def stop(self):
        self.dut.en.value = 0
        await RisingEdge(self.dut.clk)

            

@cocotb.test()
async def main(dut):
    cocotb.log.info("Start of simulation")

    tb = Tb(dut)
    await tb.reset()
    await tb.set()
    await tb.start()
    await Timer(1000, units='ns')


    cocotb.log.info("End of simulation")
        
if __name__ == "__main__":
    sys.exit(main())