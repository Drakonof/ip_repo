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

    async def clk_tick(self):
        await RisingEdge(self.dut.clk)

    async def reset(self):
        self.dut.s_rst_n.value = 0
        await RisingEdge(self.dut.clk)
        self.dut.s_rst_n.value = 1

    async def write_word(self, word):
        self.dut.data_in.value = word
        await RisingEdge(self.dut.clk)

    async def read_word(self):
        word = self.dut.data_out.value
        await RisingEdge(self.dut.clk)
        return word

    async def write_full(self):
        word = 1
        self.dut.wr_en.value = 1
        while self.dut.full.value == 0:
            await self.write_word(word)
            word += 1
        self.dut.wr_en.value = 0
        await RisingEdge(self.dut.clk)

    async def read_full(self):
        words = []
        self.dut.rd_en.value = 1
        while self.dut.empty.value == 0:
           words.append(await self.read_word())
        self.dut.rd_en.value = 0
        await RisingEdge(self.dut.clk)

    async def forward_read_word(self):
        self.dut.rd_en.value = 1
        word = self.dut.data_out.value
        await RisingEdge(self.dut.clk)
        self.dut.rd_en.value = 0
        await RisingEdge(self.dut.clk)

    async def rand_write(self):
        for _ in range(10):
            en_time = random.randint(0, 10)
            dis_time = random.randint(0, 10)

            for i in range(en_time):
                self.dut.wr_en.value = 1
                self.dut.data_in.value = i
                await RisingEdge(self.dut.clk)

            for _ in range(dis_time):
                self.dut.wr_en.value = 0
                await RisingEdge(self.dut.clk)

    async def rand_read(self):
        for _ in range(10):
            en_time = random.randint(0, 10)
            dis_time = random.randint(0, 10)

            for _ in range(en_time):
                self.dut.rd_en.value = 1
                await RisingEdge(self.dut.clk)

            for _ in range(dis_time):
                self.dut.rd_en.value = 0
                await RisingEdge(self.dut.clk)


           

@cocotb.test()
async def main(dut):
    cocotb.log.info("Start of simulation")

    tb = Tb(dut)
    await tb.clk_tick()
    await tb.reset()

    for _ in range(2):
        await tb.write_full()
        await tb.read_full()

    await tb.write_full()
    await tb.reset()
    for _ in range(3):
        await tb.forward_read_word()


    rand_rd_thread = cocotb.fork(tb.rand_write())
    rand_wr_thread = cocotb.fork(tb.rand_read())

    # Wait for the test to complete
    await cocotb.triggers.Combine(rand_rd_thread, rand_wr_thread)



    await Timer(100, units='ns')


    cocotb.log.info("End of simulation")
        
if __name__ == "__main__":
    sys.exit(main())