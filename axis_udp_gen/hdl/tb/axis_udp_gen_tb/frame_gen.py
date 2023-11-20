import sys
import os

def create_init_mem_file():
    init_file_name = 'init.mem'

    if os.path.exists(init_file_name):
        os.remove(init_file_name)

    init_array = [
    0x0405da0102030405, 
    0x122211115a010203,
    0x1333333314444444,
    0x1555555519216801,
    0x192168001234abcd
    ]

    for i in range(100):
        init_array.append(i)

    init_array.insert(0, len(init_array))

    
    file = open(init_file_name, 'w')
    for value in init_array:
        file.write(f'{value:02X}\n')
    
    if file:
        file.close()

if __name__ == "__main__":
    sys.exit(create_init_mem_file())