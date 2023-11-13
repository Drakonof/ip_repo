import mmap
import os
import json

class Pcie_device:
	def __init__(self, offset):
		j = open('axil_regs_cfg.json')
		self.j_data = json.load(j)
		
		self.rescan()
		
		mem_addr = 0
		
		f = os.open('/dev/mem', os.O_RDWR)
		self.m = mmap.mmap(f, 0x11fff, flags=mmap.MAP_SHARED, prot=(mmap.PROT_READ|mmap.PROT_WRITE), offset=offset)

	def read(self, component_name, reg_name):
		reg_addr = int(self.j_data[component_name]['start_address'], 0) + int(self.j_data[component_name]['reg'][reg_name]['addr_offset'], 0)
		self.m.seek(reg_addr)
		ret = self.m.read()
		return ret
		
	def read(self, component_name):
		reg_addr = int(self.j_data[component_name]['start_address'], 0)
		self.m.seek(reg_addr + self.mem_addr)
		ret = self.m.read()
		return ret

	def write(self, component_name, reg_name, data):
		reg_addr = int(self.j_data[component_name]['start_address'], 0) + int(self.j_data[component_name]['reg'][reg_name]['addr_offset'], 0)
		self.m.seek(reg_addr)
		self.m.write(data)

	def rescan(self):
		os.system("echo 1 > /sys/bus/pci/devices/0000\:02\:00.0/remove")
		os.system("echo 1 > /sys/bus/pci/rescan")
		os.system("echo 1 > /sys/bus/pci/devices/0000\:02\:00.0/enable")

	def __del__(self):
		self.m.close()

