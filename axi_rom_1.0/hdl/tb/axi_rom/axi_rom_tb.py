#!/usr/bin/python

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


class Axi_rom_tb(object):
    def __init__(self, dut):
        self.dut = dut
        cocotb.start_soon(Clock(self.dut.axi_clk, 10, units="ns").start())

    async def reset(self):
        self.dut.axi_s_rst_n.value = 0
        self.dut.s_axi_rready.value = 0
        self.dut.s_axi_arvalid.value = 0
        self.dut.s_axi_araddr.value  = 0
        await RisingEdge(self.dut.axi_clk)
        self.dut.axi_s_rst_n.value = 1

    async def read_addr(self, addr):
        self.dut.s_axi_arvalid.value = 1
        self.dut.s_axi_araddr.value  = addr
        await RisingEdge(self.dut.axi_clk)

        while self.dut.s_axi_arready == 0:
            await RisingEdge(self.dut.axi_clk)

        self.dut.s_axi_arvalid.value = 0 
        while self.dut.s_axi_rvalid == 0:
            await RisingEdge(self.dut.axi_clk)

        data = self.dut.s_axi_rdata.value
        await RisingEdge(self.dut.axi_clk)
        self.dut.s_axi_rready.value = 1
        await RisingEdge(self.dut.axi_clk)
        self.dut.s_axi_rready.value = 0

        return data


    async def read_rand_addr(self, max_range):
        rand_addr = random.randint(0, max_range)
        cocotb.log.info(f"Random address: {rand_addr}  Data: {await self.read_addr(rand_addr)}")

    #todo: compare with file content 
    async def reading_whole_mem(self, max_range):
        for addr in range(0, max_range):
            cocotb.log.info(f"Address: {addr}  Data: {await self.read_addr(addr)}")
            

@cocotb.test()
async def main(dut):
    highest_addr = 8
    max_rand_val = 7

    cocotb.log.info("Start of simulation")

    tb = Axi_rom_tb(dut)
    await tb.reset()
    await tb.reading_whole_mem(highest_addr)
    await tb.read_rand_addr(max_rand_val)
    await tb.read_rand_addr(max_rand_val)

    cocotb.log.info("End of simulation")
        
if __name__ == "__main__":
    sys.exit(main())