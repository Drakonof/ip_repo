def create_init_mem_file():

    init_array = [
    0x0f, 
    0xda1234, 
    0x112233, 
    0xaabbcc, 
    0x445566, 
    0xddeeff, 
    0x778899, 
    0x246812, 
    0xacefde, 
    0xAB3456, 
    0xabcdef, 
    0xabB223, 
    0xabbbcc, 
    0xab5566, 
    0xabeeff, 
    0xab8899]

    with open('init.mem', 'w') as file:
        for value in init_array:
            file.write(f'{value:02X}\n')

if __name__ == "__main__":
    sys.exit(create_init_mem_file())