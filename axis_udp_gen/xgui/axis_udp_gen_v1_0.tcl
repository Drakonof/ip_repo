# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"

  ipgui::add_param $IPINST -name "AXIS_DATA_WIDTH"
  ipgui::add_param $IPINST -name "MAC_ADDR"
  ipgui::add_param $IPINST -name "LT"

}

proc update_PARAM_VALUE.AXIS_DATA_WIDTH { PARAM_VALUE.AXIS_DATA_WIDTH } {
	# Procedure called to update AXIS_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXIS_DATA_WIDTH { PARAM_VALUE.AXIS_DATA_WIDTH } {
	# Procedure called to validate AXIS_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.LT { PARAM_VALUE.LT } {
	# Procedure called to update LT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LT { PARAM_VALUE.LT } {
	# Procedure called to validate LT
	return true
}

proc update_PARAM_VALUE.MAC_ADDR { PARAM_VALUE.MAC_ADDR } {
	# Procedure called to update MAC_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAC_ADDR { PARAM_VALUE.MAC_ADDR } {
	# Procedure called to validate MAC_ADDR
	return true
}


proc update_MODELPARAM_VALUE.AXIS_DATA_WIDTH { MODELPARAM_VALUE.AXIS_DATA_WIDTH PARAM_VALUE.AXIS_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIS_DATA_WIDTH}] ${MODELPARAM_VALUE.AXIS_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.MAC_ADDR { MODELPARAM_VALUE.MAC_ADDR PARAM_VALUE.MAC_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAC_ADDR}] ${MODELPARAM_VALUE.MAC_ADDR}
}

proc update_MODELPARAM_VALUE.LT { MODELPARAM_VALUE.LT PARAM_VALUE.LT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LT}] ${MODELPARAM_VALUE.LT}
}

