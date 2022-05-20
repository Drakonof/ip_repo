/*--------------------------------------------------
| engineer : A. Shimko
|
| module   : sync_comparator_2.sv
|
| testbench: sync_comparator_2_tb.sv
| 
| brief    :
|
| todo     :
|
| 15.04.22 : add (comparator_2.sv): first commit
|
*/

/*
sync_comparator_2 #
(
    .DATA_WIDTH () // default: 8
)
sync_comparator_2_inst
(
    .data_0_i   (), // width: DATA_WIDTH 
    .data_1_i   (), // width: DATA_WIDTH

    // data_0 >= data_1
    .eq_or_gt_o () 
);
*/

// are there signal race?
`timescale 1ns / 1ps

module comparator_2 #
(
    parameter integer DATA_WIDTH = 8
)
(
    input  logic [DATA_WIDTH - 1 : 0] data_0_i,
    input  logic [DATA_WIDTH - 1 : 0] data_1_i,

                                      // data_0 >= data_1
    output logic                      eq_or_gt_o 
);
    
    always_comb  begin
         eq_or_gt_o = (data_0_i >= data_1_i);
    end

endmodule