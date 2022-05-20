# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Group
  set parameters [ipgui::add_group $IPINST -name "parameters"]
  ipgui::add_param $IPINST -name "BAUD_GEN_MAX_VAL" -parent ${parameters}
  ipgui::add_param $IPINST -name "MAX_DATA_WIDTH" -parent ${parameters}
  ipgui::add_param $IPINST -name "FIFO_ADDR_WIDTH" -parent ${parameters}


}

proc update_PARAM_VALUE.BAUD_GEN_CMP_DATA_WIDTH { PARAM_VALUE.BAUD_GEN_CMP_DATA_WIDTH } {
	# Procedure called to update BAUD_GEN_CMP_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BAUD_GEN_CMP_DATA_WIDTH { PARAM_VALUE.BAUD_GEN_CMP_DATA_WIDTH } {
	# Procedure called to validate BAUD_GEN_CMP_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.BAUD_GEN_MAX_VAL { PARAM_VALUE.BAUD_GEN_MAX_VAL } {
	# Procedure called to update BAUD_GEN_MAX_VAL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BAUD_GEN_MAX_VAL { PARAM_VALUE.BAUD_GEN_MAX_VAL } {
	# Procedure called to validate BAUD_GEN_MAX_VAL
	return true
}

proc update_PARAM_VALUE.FIFO_ADDR_WIDTH { PARAM_VALUE.FIFO_ADDR_WIDTH } {
	# Procedure called to update FIFO_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FIFO_ADDR_WIDTH { PARAM_VALUE.FIFO_ADDR_WIDTH } {
	# Procedure called to validate FIFO_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.MAX_DATA_WIDTH { PARAM_VALUE.MAX_DATA_WIDTH } {
	# Procedure called to update MAX_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAX_DATA_WIDTH { PARAM_VALUE.MAX_DATA_WIDTH } {
	# Procedure called to validate MAX_DATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.BAUD_GEN_MAX_VAL { MODELPARAM_VALUE.BAUD_GEN_MAX_VAL PARAM_VALUE.BAUD_GEN_MAX_VAL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BAUD_GEN_MAX_VAL}] ${MODELPARAM_VALUE.BAUD_GEN_MAX_VAL}
}

proc update_MODELPARAM_VALUE.MAX_DATA_WIDTH { MODELPARAM_VALUE.MAX_DATA_WIDTH PARAM_VALUE.MAX_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAX_DATA_WIDTH}] ${MODELPARAM_VALUE.MAX_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.FIFO_ADDR_WIDTH { MODELPARAM_VALUE.FIFO_ADDR_WIDTH PARAM_VALUE.FIFO_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FIFO_ADDR_WIDTH}] ${MODELPARAM_VALUE.FIFO_ADDR_WIDTH}
}

