#!/usr/bin/python

import subprocess
import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer


class Tb(object):
    def __init__(self, dut):
        self.dut = dut
        subprocess.run(["python3", "./frame_gen.py"])
        cocotb.start_soon(Clock(self.dut.clk, 10, units="ns").start())

    async def clk_tick(self):
        await RisingEdge(self.dut.clk)

    async def reset(self):
        self.dut.s_rst_n.value = 0
        await RisingEdge(self.dut.clk)
        self.dut.s_rst_n.value = 1


@cocotb.test()
async def main(dut):
    cocotb.log.info("Start of simulation")

    tb = Tb(dut)
    await tb.clk_tick()
    await tb.reset()

    await Timer(100, units='ns')


    cocotb.log.info("End of simulation")
        
if __name__ == "__main__":
    sys.exit(main())