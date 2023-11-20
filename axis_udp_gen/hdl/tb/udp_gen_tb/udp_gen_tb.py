#!/usr/bin/python

#todo: exaptions

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer


class Tb(object):
    def __init__(self, dut):
        self.dut = dut
        self.frame_array = []
        
        file = open('init.mem', 'r')
        lines = file.readlines()
        for line in lines:
            value = int(line.strip(), 16)
            self.frame_array.append(value)

        self.frame_size = self.frame_array[0] + 2 # plus size and last value of frame
        self.gap_size = 12

        cocotb.start_soon(Clock(self.dut.clk, 10, units="ns").start())


    async def clk_tick(self):
        await RisingEdge(self.dut.clk)

    async def reset(self):
        self.dut.s_rst_n.value = 0
        await RisingEdge(self.dut.clk)
        self.dut.s_rst_n.value = 1

    async def enable(self, en):
        self.dut.en.value = en

    async def send_frame(self):
        for i in range(self.frame_size):
            self.dut.mem_data.value = self.frame_array[self.dut.mem_addr.value]
            await RisingEdge(self.dut.clk)

        for i in range(self.gap_size):
            self.dut.mem_data.value = self.frame_array[self.dut.mem_addr.value]
            await RisingEdge(self.dut.clk)
 
@cocotb.test()
async def main(dut):
    cocotb.log.info("Start of simulation")

    tb = Tb(dut)
    await tb.reset()
    await tb.enable(1)
    await tb.send_frame()
    await tb.send_frame()
    await tb.enable(0)
    await tb.clk_tick()
    await tb.enable(1)
    await tb.send_frame()
    await tb.enable(0)


    await Timer(1000, units='ns')


    cocotb.log.info("End of simulation")
        
if __name__ == "__main__":
    sys.exit(main())