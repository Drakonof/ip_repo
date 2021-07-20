`timescale 1ns / 1ps

module dds_generator # 
(
    parameter integer LOOKUP_TABLE_INDEX_WIDTH = 10,
    parameter integer ACCUMULATOR_WIDTH        = 24,
    parameter integer PHASE_OFFSET_WIDTH       = 10,
    parameter integer FCW_WIDTH                = 8        
)
(
    input  wire                                    clk_i               ,
    input  wire                                    s_rst_n_i           ,
    input  wire                                    en_i                ,
    
    input  wire                                    phase_offset_wr_i   ,
    input  wire [PHASE_OFFSET_WIDTH - 1 : 0]       phase_offset_i      ,
    input  wire [FCW_WIDTH - 1 : 0]                fcw_i               ,
    
    output wire [LOOKUP_TABLE_INDEX_WIDTH - 1 : 0] lookup_table_index_o
);
    localparam integer ACCUMULATOR_WIDTH_LSB = ACCUMULATOR_WIDTH - LOOKUP_TABLE_INDEX_WIDTH;
    
    reg [ACCUMULATOR_WIDTH - 1:0] accumulator;

    always @ (posedge clk_i) begin
        if(1'h0 == s_rst_n_i ) begin
            accumulator[ACCUMULATOR_WIDTH_LSB - 1 : 0]             <= 0;
            accumulator[ACCUMULATOR_WIDTH : ACCUMULATOR_WIDTH_LSB] <=  phase_offset_i;              
        end
        else if (1'h1 ==  phase_offset_wr_i) begin
            accumulator[ACCUMULATOR_WIDTH_LSB - 1 : 0]             <= 0;
            accumulator[ACCUMULATOR_WIDTH : ACCUMULATOR_WIDTH_LSB] <=  phase_offset_i;
        end else if (1'h1 == en_i) begin
            if (({10{1'h1}} - 2) == accumulator[ACCUMULATOR_WIDTH : ACCUMULATOR_WIDTH_LSB]) begin
                accumulator[ACCUMULATOR_WIDTH : ACCUMULATOR_WIDTH_LSB] <= 0;
            end
            else begin
                accumulator <= accumulator + fcw_i;
            end
        end
    end
    
    assign lookup_table_index_o = accumulator[ACCUMULATOR_WIDTH : ACCUMULATOR_WIDTH_LSB];
endmodule
