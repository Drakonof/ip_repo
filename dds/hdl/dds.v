`timescale 1ns / 1ps

module dds #
(
    parameter integer DATA_WIDTH         = 16                    ,
    parameter integer ROM_DEPTH          = 1024                  ,
    parameter         INIT_FILE          = ""                    ,
   
    parameter integer FCW_WIDTH          = $clog2(ROM_DEPTH) + 14,
    parameter integer PHASE_OFFSET_WIDTH = 10
)
(
    input  wire                              clk_i            ,
    input  wire                              s_rst_n_i        ,
    input  wire                              en_i             ,
    
    input  wire [FCW_WIDTH - 1 : 0]          fcw_i            ,
    input  wire [PHASE_OFFSET_WIDTH - 1 : 0] phase_offset_i   , //for instance: ROM_DEPTH / 2 == (2 * pi) / 2 == pi
    input  wire                              phase_offset_wr_i,
    
    output wire [DATA_WIDTH - 1 : 0]        sinus_o
);
    localparam integer LOOKUP_TABLE_INDEX_WIDTH = $clog2(ROM_DEPTH);
    localparam integer ACCUMULATOR_WIDTH        = FCW_WIDTH;

    wire [LOOKUP_TABLE_INDEX_WIDTH - 1 : 0] lookup_table_index;
    
    rom_distributed #
    (
        .DATA_WIDTH    (DATA_WIDTH              ),
        .ROM_DEPTH     (ROM_DEPTH               ),
        .INIT_FILE     (INIT_FILE               ),
        .ADDRESS_WIDTH (LOOKUP_TABLE_INDEX_WIDTH)
    ) 
    rom_distributed_inst
    (
        .address_i (lookup_table_index),
        .data_o    (sinus_o           )
    );
    
    dds_generator # 
    (
        .LOOKUP_TABLE_INDEX_WIDTH (LOOKUP_TABLE_INDEX_WIDTH),
        .ACCUMULATOR_WIDTH        (ACCUMULATOR_WIDTH       ),
        .PHASE_OFFSET_WIDTH       (PHASE_OFFSET_WIDTH      ),
        .FCW_WIDTH                (FCW_WIDTH               )
    )
    dds_generator_inst
    (
        .clk_i                (clk_i             ),
        .s_rst_n_i            (s_rst_n_i         ),
        .en_i                 (en_i              ),
             
        .phase_offset_wr_i    (phase_offset_wr_i ),                      
        .phase_offset_i       (phase_offset_i    ),
        .fcw_i                (fcw_i             ),
                              
        .lookup_table_index_o (lookup_table_index)
     ); 
endmodule

