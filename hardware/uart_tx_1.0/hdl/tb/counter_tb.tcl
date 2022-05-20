transcript on
vlib work
vlog -sv ../rtl/counter.sv
vlog -sv counter_tb.sv
vsim -t 100ns -voptargs="+acc" counter_tb
add wave /counter_tb/clk
add wave /counter_tb/enable
add wave /counter_tb/s_rst_n
add wave /counter_tb/value
configure wave -timelineunits us
run -all
wave zoom full
