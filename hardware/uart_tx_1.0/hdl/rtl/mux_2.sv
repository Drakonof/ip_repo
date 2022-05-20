/*--------------------------------------------------
| engineer : A. Shimko
|
| module   : mux_2.sv
|
| testbench: mux_2_tb.sv
| 
| brief    :
|
| todo     :
| 
| 12.04.22 : add(mux_2.sv): first commit
|
*/

/*
mux_2 # 
(
    .DATA_WIDTH (), // default: 1
)
mux_2_inst                         
(
    .data_0_i (),
    .data_1_i (),
    
    .select_i (),
    
    .data_o   ()
);
*/

`timescale 1ns / 1ps

module mux_2 #
(
    parameter integer DATA_WIDTH = 1
)
(

    input  logic [DATA_WIDTH - 1 : 0] data_0_i,
    input  logic [DATA_WIDTH - 1 : 0] data_1_i,

    input  logic                      select_i,
    
    output logic [DATA_WIDTH - 1 : 0] data_o
);
    
    always_comb begin
        data_o = (select_i == 1'b1) ? data_1_i : data_0_i;
    end

endmodule