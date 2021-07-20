transcript on
vlib work
vmap work work

# variables---------
set dut   ../../hdl/dds.v
set var_1 ../../hdl/dds_generator.v
set var_2 ../../hdl/rom_distributed.v
set tb    dds_tb.v
# ------------------

vlog $dut $tb $var_1 $var_2

 
vsim -t 100ns -voptargs="+acc" dds_tb

# waves    ---------
add wave /dds_tb/clk


add wave -radix hex -format  analog-step -max 65535 -min -65535 -height 100 /dds_tb/sinus_0
add wave -radix hex -format  analog-step -max 65535 -min -65535 -height 100 /dds_tb/sinus_1
add wave -radix hex -format  analog-step -max 32767 -min -32767 -height 100 /dds_tb/sinus_2
add wave -radix hex -format  analog-step -max 32767 -min -32767 -height 100 /dds_tb/sinus_3

add wave -radix hex /dds_tb/fcw_0
add wave -radix hex /dds_tb/phase_offset_0
add wave -radix hex /dds_tb/phase_offset_wr_0

add wave -radix hex /dds_tb/fcw_1
add wave -radix hex /dds_tb/phase_offset_1
add wave -radix hex /dds_tb/phase_offset_wr_1

add wave -radix hex /dds_tb/fcw_2
add wave -radix hex /dds_tb/phase_offset_2
add wave -radix hex /dds_tb/phase_offset_wr_2

add wave -radix hex /dds_tb/fcw_3
add wave -radix hex /dds_tb/phase_offset_3
add wave -radix hex /dds_tb/phase_offset_wr_3
# ------------------

configure wave -timelineunits us

run -all 
wave zoom full