`timescale 1ns / 1ps

module rom_distributed #
(
    parameter integer DATA_WIDTH    = 8                ,
    parameter integer ROM_DEPTH     = 256              ,
    parameter         INIT_FILE     = "",
    parameter integer ADDRESS_WIDTH = $clog2(ROM_DEPTH)
) 
(
    input  wire [ADDRESS_WIDTH - 1 : 0] address_i,
    output wire [DATA_WIDTH - 1 : 0]    data_o
);
    reg [DATA_WIDTH - 1 : 0] rom_memory [ROM_DEPTH - 1 : 0];

    initial begin
        if ("" != INIT_FILE) begin
            $readmemh(INIT_FILE, rom_memory);
        end
        else begin
            $error("A rom init file is not specified.");
        end
    end

    assign data_o = rom_memory[address_i];
endmodule 