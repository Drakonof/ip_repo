import subprocess
import argparse

from pcie_device import *

parser = argparse.ArgumentParser(description='AXI ROM IP')
parser.add_argument('-p', '--pci', type=int, help='Specify an address on PCI bus.')
parser.add_argument('-n', '--number', type=int, help='Specify number of bytes to read.')

args = parser.parse_args()

pd = Pcie_device(args.pci)

def read_rom():
	for i in range(args.number):
		ret = pd.read('rom')
		print(ret)
		
if __name__ == "__main__":
    sys.exit(read_rom())
