import sys
import os
import argparse

def create_init_mem_file():
    parser = argparse.ArgumentParser()

    parser.add_argument('--file_name', type=str, default='frame.mem', help='frame')
    parser.add_argument('--ethertype', type=str, default='0800', help='ethertype')
    parser.add_argument('--vertion', type=str, default='4', help='vertion')
    parser.add_argument('--protocol', type=str, default='11', help='protocol')
    parser.add_argument('--ipv4_des_addr', type=str, default='19216801', help='ipv4_des_addr')
    parser.add_argument('--ipv4_src_addr', type=str, default='19216800', help='ipv4_src_addr')
    parser.add_argument('--count', type=str, default='10', help='count')

    args = parser.parse_args()

    init_file_name = args.file_name

    init_array = [
    "0405da0102030405",
    "999" + args.vertion + args.ethertype + "5a010203",
    args.protocol + "99999999999999",
    "55555555" + args.ipv4_des_addr,
    args.ipv4_src_addr
    ]

    if os.path.exists(init_file_name):
        os.remove(init_file_name)

    for i in range(int(args.count)):
        init_array.append(i)

    init_array.insert(0, len(init_array) * 8)
    
    file = open(init_file_name, 'w')
    for value in init_array:
        file.write(f'{value}\n')
    
    if file:
        file.close()

if __name__ == "__main__":
    sys.exit(create_init_mem_file())