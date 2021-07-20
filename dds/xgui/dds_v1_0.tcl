# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ROM_DEPTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INIT_FILE" -parent ${Page_0}


}

proc update_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to update DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to validate DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.FCW_WIDTH { PARAM_VALUE.FCW_WIDTH } {
	# Procedure called to update FCW_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FCW_WIDTH { PARAM_VALUE.FCW_WIDTH } {
	# Procedure called to validate FCW_WIDTH
	return true
}

proc update_PARAM_VALUE.INIT_FILE { PARAM_VALUE.INIT_FILE } {
	# Procedure called to update INIT_FILE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INIT_FILE { PARAM_VALUE.INIT_FILE } {
	# Procedure called to validate INIT_FILE
	return true
}

proc update_PARAM_VALUE.PHASE_OFFSET_WIDTH { PARAM_VALUE.PHASE_OFFSET_WIDTH } {
	# Procedure called to update PHASE_OFFSET_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PHASE_OFFSET_WIDTH { PARAM_VALUE.PHASE_OFFSET_WIDTH } {
	# Procedure called to validate PHASE_OFFSET_WIDTH
	return true
}

proc update_PARAM_VALUE.ROM_DEPTH { PARAM_VALUE.ROM_DEPTH } {
	# Procedure called to update ROM_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ROM_DEPTH { PARAM_VALUE.ROM_DEPTH } {
	# Procedure called to validate ROM_DEPTH
	return true
}


proc update_MODELPARAM_VALUE.DATA_WIDTH { MODELPARAM_VALUE.DATA_WIDTH PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_WIDTH}] ${MODELPARAM_VALUE.DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.ROM_DEPTH { MODELPARAM_VALUE.ROM_DEPTH PARAM_VALUE.ROM_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ROM_DEPTH}] ${MODELPARAM_VALUE.ROM_DEPTH}
}

proc update_MODELPARAM_VALUE.INIT_FILE { MODELPARAM_VALUE.INIT_FILE PARAM_VALUE.INIT_FILE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INIT_FILE}] ${MODELPARAM_VALUE.INIT_FILE}
}

proc update_MODELPARAM_VALUE.FCW_WIDTH { MODELPARAM_VALUE.FCW_WIDTH PARAM_VALUE.FCW_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FCW_WIDTH}] ${MODELPARAM_VALUE.FCW_WIDTH}
}

proc update_MODELPARAM_VALUE.PHASE_OFFSET_WIDTH { MODELPARAM_VALUE.PHASE_OFFSET_WIDTH PARAM_VALUE.PHASE_OFFSET_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PHASE_OFFSET_WIDTH}] ${MODELPARAM_VALUE.PHASE_OFFSET_WIDTH}
}

