SIM?=verilator
TOPLEVEL_LANG?=verilog

COCOTB_HDL_TIMEUNIT=1ns
COCOTB_HDL_TIMEPRECISION=1ns

SRC_DIR=../../rtl

DUT=fifo_tb_wrapper
TOPLEVEL=$(DUT)
MODULE=fifo_tb

VERILOG_SOURCES+=$(DUT).sv
VERILOG_SOURCES+=$(SRC_DIR)/fifo.sv

EXTRA_ARGS += --trace --trace-structs
EXTRA_ARGS += -GDATA_WIDTH=16
EXTRA_ARGS += -GADDR_WIDTH=4

#GFLAGS=-S gtkwave.tcl

include $(shell cocotb-config --makefiles)/Makefile.sim

all:
	echo $(COMPILE_ARGS)
#	gtkwave $(GFLAGS) *.vcd 2>/dev/null || $(GTKWAVE_OSX) $(GFLAGS) *.vcd 2>/dev/null

clean::
	rm -rf *.vcd