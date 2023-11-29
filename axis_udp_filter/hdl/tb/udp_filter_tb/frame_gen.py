import sys
import os
import argparse

def create_init_mem_file():
    parser = argparse.ArgumentParser()

    parser.add_argument('--file_name', type=str, default='frame.mem', help='frame')
    parser.add_argument('--ethertype', type=str, default='0800', help='ethertype')
    parser.add_argument('--vertion', type=str, default='4', help='vertion')
    parser.add_argument('--protocol', type=str, default='11', help='protocol')
    parser.add_argument('--ipv4_des_addr', type=str, default='C0A80001', help='ipv4_des_addr')
    parser.add_argument('--ipv4_src_addr', type=str, default='C0A80000', help='ipv4_src_addr')
    parser.add_argument('--count', type=str, default='10', help='count')

    args = parser.parse_args()

    init_file_name = args.file_name

    dst_mac = "da0102030405"
    src_mac = "5a0102030405"
    ihl = "5"
    ttl = "40"

    init_array = [
    src_mac[8:] + dst_mac,
    "00" + args.vertion + ihl + args.ethertype + src_mac[:8],
    args.protocol + ttl +"00000000" + str(hex(int(ihl) + int(args.count)))[2:].zfill(4),
    args.ipv4_src_addr[4:] + args.ipv4_des_addr + "0000",
    args.ipv4_src_addr[:4] 
    ]

    if os.path.exists(init_file_name):
        os.remove(init_file_name)

    for i in range(int(args.count)):
        init_array.append(i)

    init_array.insert(0, hex(len(init_array)))

    #todo:
    file = open(init_file_name, 'w')
    for value in init_array:
        file.write(f'{value}\n')
    
    if file:
        file.close()

if __name__ == "__main__":
    sys.exit(create_init_mem_file())