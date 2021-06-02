# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  ipgui::add_param $IPINST -name "PAYLOAD_MAX_SIZE"
  #Adding Group
  set MAC_address [ipgui::add_group $IPINST -name "MAC address"]
  ipgui::add_param $IPINST -name "MAC_ADDRESS" -parent ${MAC_address} -show_label false

  #Adding Group
  set IP_address [ipgui::add_group $IPINST -name "IP address" -layout horizontal]
  ipgui::add_param $IPINST -name "IP_PART_1" -parent ${IP_address} -show_label false
  ipgui::add_param $IPINST -name "IP_PART_2" -parent ${IP_address}
  ipgui::add_param $IPINST -name "IP_PART_3" -parent ${IP_address}
  ipgui::add_param $IPINST -name "IP_PART_4" -parent ${IP_address}

  #Adding Group
  set UDP_port [ipgui::add_group $IPINST -name "UDP port"]
  ipgui::add_param $IPINST -name "UDP_PORT" -parent ${UDP_port} -show_label false


}

proc update_PARAM_VALUE.IP_PART_1 { PARAM_VALUE.IP_PART_1 } {
	# Procedure called to update IP_PART_1 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IP_PART_1 { PARAM_VALUE.IP_PART_1 } {
	# Procedure called to validate IP_PART_1
	return true
}

proc update_PARAM_VALUE.IP_PART_2 { PARAM_VALUE.IP_PART_2 } {
	# Procedure called to update IP_PART_2 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IP_PART_2 { PARAM_VALUE.IP_PART_2 } {
	# Procedure called to validate IP_PART_2
	return true
}

proc update_PARAM_VALUE.IP_PART_3 { PARAM_VALUE.IP_PART_3 } {
	# Procedure called to update IP_PART_3 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IP_PART_3 { PARAM_VALUE.IP_PART_3 } {
	# Procedure called to validate IP_PART_3
	return true
}

proc update_PARAM_VALUE.IP_PART_4 { PARAM_VALUE.IP_PART_4 } {
	# Procedure called to update IP_PART_4 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IP_PART_4 { PARAM_VALUE.IP_PART_4 } {
	# Procedure called to validate IP_PART_4
	return true
}

proc update_PARAM_VALUE.MAC_ADDRESS { PARAM_VALUE.MAC_ADDRESS } {
	# Procedure called to update MAC_ADDRESS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAC_ADDRESS { PARAM_VALUE.MAC_ADDRESS } {
	# Procedure called to validate MAC_ADDRESS
	return true
}

proc update_PARAM_VALUE.PAYLOAD_MAX_SIZE { PARAM_VALUE.PAYLOAD_MAX_SIZE } {
	# Procedure called to update PAYLOAD_MAX_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PAYLOAD_MAX_SIZE { PARAM_VALUE.PAYLOAD_MAX_SIZE } {
	# Procedure called to validate PAYLOAD_MAX_SIZE
	return true
}

proc update_PARAM_VALUE.STREAM_DATA_WIDTH { PARAM_VALUE.STREAM_DATA_WIDTH } {
	# Procedure called to update STREAM_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.STREAM_DATA_WIDTH { PARAM_VALUE.STREAM_DATA_WIDTH } {
	# Procedure called to validate STREAM_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.UDP_PORT { PARAM_VALUE.UDP_PORT } {
	# Procedure called to update UDP_PORT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.UDP_PORT { PARAM_VALUE.UDP_PORT } {
	# Procedure called to validate UDP_PORT
	return true
}


proc update_MODELPARAM_VALUE.STREAM_DATA_WIDTH { MODELPARAM_VALUE.STREAM_DATA_WIDTH PARAM_VALUE.STREAM_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.STREAM_DATA_WIDTH}] ${MODELPARAM_VALUE.STREAM_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.MAC_ADDRESS { MODELPARAM_VALUE.MAC_ADDRESS PARAM_VALUE.MAC_ADDRESS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAC_ADDRESS}] ${MODELPARAM_VALUE.MAC_ADDRESS}
}

proc update_MODELPARAM_VALUE.IP_PART_1 { MODELPARAM_VALUE.IP_PART_1 PARAM_VALUE.IP_PART_1 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IP_PART_1}] ${MODELPARAM_VALUE.IP_PART_1}
}

proc update_MODELPARAM_VALUE.IP_PART_2 { MODELPARAM_VALUE.IP_PART_2 PARAM_VALUE.IP_PART_2 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IP_PART_2}] ${MODELPARAM_VALUE.IP_PART_2}
}

proc update_MODELPARAM_VALUE.IP_PART_3 { MODELPARAM_VALUE.IP_PART_3 PARAM_VALUE.IP_PART_3 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IP_PART_3}] ${MODELPARAM_VALUE.IP_PART_3}
}

proc update_MODELPARAM_VALUE.IP_PART_4 { MODELPARAM_VALUE.IP_PART_4 PARAM_VALUE.IP_PART_4 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IP_PART_4}] ${MODELPARAM_VALUE.IP_PART_4}
}

proc update_MODELPARAM_VALUE.UDP_PORT { MODELPARAM_VALUE.UDP_PORT PARAM_VALUE.UDP_PORT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.UDP_PORT}] ${MODELPARAM_VALUE.UDP_PORT}
}

proc update_MODELPARAM_VALUE.PAYLOAD_MAX_SIZE { MODELPARAM_VALUE.PAYLOAD_MAX_SIZE PARAM_VALUE.PAYLOAD_MAX_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PAYLOAD_MAX_SIZE}] ${MODELPARAM_VALUE.PAYLOAD_MAX_SIZE}
}

