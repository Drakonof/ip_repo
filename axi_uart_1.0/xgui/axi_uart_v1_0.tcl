# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"

}

proc update_PARAM_VALUE.AXI_DATA_WIDTH { PARAM_VALUE.AXI_DATA_WIDTH } {
	# Procedure called to update AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_DATA_WIDTH { PARAM_VALUE.AXI_DATA_WIDTH } {
	# Procedure called to validate AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.BAUD_MAX_VALUE { PARAM_VALUE.BAUD_MAX_VALUE } {
	# Procedure called to update BAUD_MAX_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BAUD_MAX_VALUE { PARAM_VALUE.BAUD_MAX_VALUE } {
	# Procedure called to validate BAUD_MAX_VALUE
	return true
}

proc update_PARAM_VALUE.CLK_VALUE_MHZ { PARAM_VALUE.CLK_VALUE_MHZ } {
	# Procedure called to update CLK_VALUE_MHZ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLK_VALUE_MHZ { PARAM_VALUE.CLK_VALUE_MHZ } {
	# Procedure called to validate CLK_VALUE_MHZ
	return true
}

proc update_PARAM_VALUE.REG_ADDRESS_WIDTH { PARAM_VALUE.REG_ADDRESS_WIDTH } {
	# Procedure called to update REG_ADDRESS_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.REG_ADDRESS_WIDTH { PARAM_VALUE.REG_ADDRESS_WIDTH } {
	# Procedure called to validate REG_ADDRESS_WIDTH
	return true
}

proc update_PARAM_VALUE.REG_SPACE_DEPTH { PARAM_VALUE.REG_SPACE_DEPTH } {
	# Procedure called to update REG_SPACE_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.REG_SPACE_DEPTH { PARAM_VALUE.REG_SPACE_DEPTH } {
	# Procedure called to validate REG_SPACE_DEPTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_BASEADDR { PARAM_VALUE.C_S00_AXI_BASEADDR } {
	# Procedure called to update C_S00_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_BASEADDR { PARAM_VALUE.C_S00_AXI_BASEADDR } {
	# Procedure called to validate C_S00_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_HIGHADDR { PARAM_VALUE.C_S00_AXI_HIGHADDR } {
	# Procedure called to update C_S00_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_HIGHADDR { PARAM_VALUE.C_S00_AXI_HIGHADDR } {
	# Procedure called to validate C_S00_AXI_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.CLK_VALUE_MHZ { MODELPARAM_VALUE.CLK_VALUE_MHZ PARAM_VALUE.CLK_VALUE_MHZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLK_VALUE_MHZ}] ${MODELPARAM_VALUE.CLK_VALUE_MHZ}
}

proc update_MODELPARAM_VALUE.BAUD_MAX_VALUE { MODELPARAM_VALUE.BAUD_MAX_VALUE PARAM_VALUE.BAUD_MAX_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BAUD_MAX_VALUE}] ${MODELPARAM_VALUE.BAUD_MAX_VALUE}
}

proc update_MODELPARAM_VALUE.REG_ADDRESS_WIDTH { MODELPARAM_VALUE.REG_ADDRESS_WIDTH PARAM_VALUE.REG_ADDRESS_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.REG_ADDRESS_WIDTH}] ${MODELPARAM_VALUE.REG_ADDRESS_WIDTH}
}

proc update_MODELPARAM_VALUE.AXI_DATA_WIDTH { MODELPARAM_VALUE.AXI_DATA_WIDTH PARAM_VALUE.AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.REG_SPACE_DEPTH { MODELPARAM_VALUE.REG_SPACE_DEPTH PARAM_VALUE.REG_SPACE_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.REG_SPACE_DEPTH}] ${MODELPARAM_VALUE.REG_SPACE_DEPTH}
}

