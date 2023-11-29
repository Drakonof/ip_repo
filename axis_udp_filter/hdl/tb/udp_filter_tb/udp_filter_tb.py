#!/usr/bin/python

import subprocess
import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer


frame_files_arr = ["frame_all_correct.mem", "frame_wrong_ethertype.mem", "frame_wrong_vertion.mem", 
                   "frame_wrong_protocol.mem", "frame_wrong_ipv4_des_addr.mem", "frame_all_correct.mem"]

class Tb(object):
    def __init__(self, dut):
        sub_proc = lambda file_name, arg_0, arg_1: subprocess.run(["python3", "./frame_gen.py", "--file_name", file_name, arg_0, arg_1])

        self.dut = dut
        self.ipv4_dst_addr = 0xC0A80001

        sub_proc(frame_files_arr[1], "--ethertype", "0070")
        sub_proc(frame_files_arr[2], "--vertion", "6")
        sub_proc(frame_files_arr[3], "--protocol", "10")
        sub_proc(frame_files_arr[4], "--ipv4_des_addr", "C0A80003")

        # subprocess.run(["python3", "./frame_gen.py", "--file_name", "frame_wrong_ethertype.mem", "--ethertype", "0070"])
        # subprocess.run(["python3", "./frame_gen.py", "--file_name", "frame_wrong_vertion.mem", "--vertion", "6"])
        # subprocess.run(["python3", "./frame_gen.py", "--file_name", "frame_wrong_protocol.mem", "--protocol", "10"])
        # subprocess.run(["python3", "./frame_gen.py", "--file_name", "frame_wrong_ipv4_des_addr.mem", "--ipv4_des_addr", "19216802"])
        subprocess.run(["python3", "./frame_gen.py", "--file_name", "frame_all_correct.mem"])
        
        cocotb.start_soon(Clock(self.dut.clk, 10, units="ns").start())

    async def clk_tick(self):
        await RisingEdge(self.dut.clk)

    async def reset(self):
        self.dut.s_rst_n.value = 0
        await RisingEdge(self.dut.clk)
        self.dut.s_rst_n.value = 1

    async def send_frame(self, file_name):
        frame_array = []

        try:
            with open(file_name, 'r') as file:
                lines = file.readlines()
                for line in lines:
                    value = int(line.strip(), 16)
                    frame_array.append(value)
        except FileNotFoundError:
            print(f"File not found at path: {file_name}")
        except IOError:
            print(f"Error reading file: {file_name}")

        frame_size = frame_array[0]
        self.dut.en.value = 1
        self.dut.ipv4_addr.value = self.ipv4_dst_addr
        await RisingEdge(self.dut.clk)

        for i in range(1,frame_size):
            self.dut.frame.value = frame_array[i]
            await RisingEdge(self.dut.clk)

        self.dut.frame.value = frame_array[frame_size]
        self.dut.frame_last.value = 1
        await RisingEdge(self.dut.clk)
        self.dut.en.value = 0
        self.dut.frame_last.value = 0
        await RisingEdge(self.dut.clk)
        self.dut.fifo_empty.value = 1
        await RisingEdge(self.dut.clk)
        self.dut.fifo_empty.value = 0


@cocotb.test()
async def main(dut):
    cocotb.log.info("Start of simulation")

    tb = Tb(dut)
    await tb.clk_tick()
    await tb.reset()
    for i in frame_files_arr:
        await tb.send_frame(i)

    await Timer(100, units='ns')


    cocotb.log.info("End of simulation")
        
if __name__ == "__main__":
    sys.exit(main())