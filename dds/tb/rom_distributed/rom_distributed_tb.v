`timescale 1ns / 1ps

`define INIT_FILE      "/media/shimko/2E0A00DD0A00A445/workspace_vivado_2018_3/ip_space/etc/rom_async.mem"

module rom_distributed_tb;
    localparam integer DATA_WIDTH = 16                   ;
    localparam integer ROM_DEPTH  = 1024                 ;
    localparam integer ADDRESS_WIDTH  = $clog2(ROM_DEPTH);   
     
    wire [DATA_WIDTH - 1 : 0] dut_value;
    
    reg [DATA_WIDTH - 1 : 0]    file_value;
    reg [ADDRESS_WIDTH - 1 : 0] address   ;
    
    integer file   = 0;
    integer errors = 0;
 
    rom_distributed #
    (
        .DATA_WIDTH    (DATA_WIDTH   ),
        .ROM_DEPTH     (ROM_DEPTH    ),
        .INIT_FILE     (`INIT_FILE   ),
        .ADDRESS_WIDTH (ADDRESS_WIDTH)
    ) 
    rom_distributed_dut
    (
        .address_i (address  ),
        .data_o    (dut_value)
    );
    
    initial begin
        file_value = 0;
        address    = 0;
        
        file = $fopen(`INIT_FILE, "r");
        
        if (0 != file) begin
            repeat(ROM_DEPTH) begin
                $fscanf(file, "%h", file_value); 
                 
                #100 if (file_value !== dut_value) begin
                    errors = errors + 1;
                end
                 
                 address = address + 1;   
            end
            
            if (0 == errors) begin
                $display("The test passed.\n");
            end
            else begin
                $display("The test failed with %d errors.\n", errors);
            end
        end
        else begin
            $display("A descripter of a '%s' file is 0.\n", `INIT_FILE);
        end
        
        $stop();
    end
endmodule
