#!/usr/bin/python

#todo: exaptions

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer


class Tb(object):
    def __init__(self, dut):
        self.dut = dut
        cocotb.start_soon(Clock(self.dut.axis_clk, 10, units="ns").start())


    async def clk_tick(self):
        await RisingEdge(self.dut.axis_clk)

    async def reset(self):
        self.dut.axis_s_rst_n.value = 0
        await RisingEdge(self.dut.axis_clk)
        self.dut.axis_s_rst_n.value = 1

    async def send_frame(self, nr):
        for i in range(nr):
            self.dut.m_axis_tready.value = 1

            while True:
                await RisingEdge(self.dut.axis_clk)
                if self.dut.m_axis_tlast.value == 1:
                    self.dut.m_axis_tready.value = 0
                    await RisingEdge(self.dut.axis_clk)
                    break

 
@cocotb.test()
async def main(dut):
    cocotb.log.info("Start of simulation")

    tb = Tb(dut)
    await tb.reset()
    await tb.send_frame(3)

    cocotb.log.info("End of simulation")
        
if __name__ == "__main__":
    sys.exit(main())