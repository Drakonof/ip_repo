transcript on
vlib work
vmap work work

# variables---------
set dut ../../hdl/rom_distributed.v
set tb rom_distributed_tb.v
# ------------------

vlog $dut $tb
 
vsim -t 100ns -voptargs="+acc" rom_distributed_tb

# waves    ---------
add wave -radix hex /rom_distributed_tb/dut_value
add wave -radix hex /rom_distributed_tb/file_value
add wave -radix hex /rom_distributed_tb/errors
# ------------------

configure wave -timelineunits us

run -all 
wave zoom full