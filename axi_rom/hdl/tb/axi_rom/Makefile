SIM?=icarus
TOPLEVEL_LANG?=verilog
WAVES?=0

COCOTB_HDL_TIMEUNIT=1ns
COCOTB_HDL_TIMEPRECISION=1ns

SRC_DIR=../../rtl
DUT=axi_rom
TOPLEVEL=$(DUT)
MODULE=$(DUT)_tb
VERILOG_SOURCES+=$(SRC_DIR)/$(DUT).sv
VERILOG_SOURCES+=$(SRC_DIR)/axi_rom_ctrl.sv
VERILOG_SOURCES+=$(SRC_DIR)/rom.sv

AXI_DATA_WIDTH?=8
AXI_ADDR_WIDTH?=3
#INIT_FILE?=

COMPILE_ARGS+=-P$(TOPLEVEL).AXI_DATA_WIDTH=$(DATA_WIDTH)
COMPILE_ARGS+=-P$(TOPLEVEL).AXI_ADDR_WIDTH=$(ADDR_WIDTH)
#COMPILE_ARGS+=-P$(TOPLEVEL).INIT_FILE=$(INIT_FILE)

ifeq ($(WAVES), 1)
	VERILOG_SOURCES+=iverilog_dump.v
	COMPILE_ARGS+=-s iverilog_dump
else
	GFLAGS=-S gtkwave.tcl
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

all:
	echo $(COMPILE_ARGS)

iverilog_dump.v:
	echo 'module iverilog_dump();' > $@
	echo 'initial begin' >> $@
	echo '    $$dumpfile("$(TOPLEVEL).fst");' >> $@
	echo '    $$dumpvars(0, $(TOPLEVEL));' >> $@
	echo 'end' >> $@
	echo 'endmodule' >> $@

clean::
	rm -rf *.vcd