SIM?=verilator
TOPLEVEL_LANG?=verilog

COCOTB_HDL_TIMEUNIT=1ns
COCOTB_HDL_TIMEPRECISION=1ns

SRC_DIR=../../rtl

DUT=axis_udp_gen_tb_wrapper
TOPLEVEL=$(DUT)
MODULE=axis_udp_gen_tb

VERILOG_SOURCES+=$(DUT).sv
VERILOG_SOURCES+=$(SRC_DIR)/udp_gen.sv
VERILOG_SOURCES+=$(SRC_DIR)/axis_udp_gen.sv
VERILOG_SOURCES+=$(SRC_DIR)/axis_udp_gen_ctrl.sv
VERILOG_SOURCES+=$(SRC_DIR)/rom.sv
#VERILOG_SOURCES+=$(SRC_DIR)/udp_gen_inf.sv

EXTRA_ARGS += --trace --trace-structs

GFLAGS=-S gtkwave.tcl

include $(shell cocotb-config --makefiles)/Makefile.sim

all:
	echo $(COMPILE_ARGS)
	gtkwave $(GFLAGS) *.vcd 2>/dev/null || $(GTKWAVE_OSX) $(GFLAGS) *.vcd 2>/dev/null

clean::
	rm -rf *.vcd