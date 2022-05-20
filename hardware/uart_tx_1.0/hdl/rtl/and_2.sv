/*--------------------------------------------------
| engineer : A. Shimko
|
| module   : and_2.sv
|
| testbench: 
| 
| brief    :
|
| todo     : tb
|
| 19.04.22 : add (and_2.sv): first commit
|
*/

/*
and_2 
and_2_inst
(
    .data_0_i (),
    .data_1_i (),

    .data_o   () 
);
*/

// are there signal race?
`timescale 1ns / 1ps

module and_2 #
(
    parameter integer DATA_WIDTH = 8
)
(
    input  logic data_0_i,
    input  logic data_1_i,

    output logic data_o 
);
    
    always_comb  begin
         data_o = (data_0_i && data_1_i);
    end

endmodule