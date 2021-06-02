`timescale 1ns / 1ps

module comparator #
(
     parameter integer DATA_WIDTH = 1
)
(
    input  wire [DATA_WIDTH - 1 : 0] data_0_i ,
    input  wire [DATA_WIDTH - 1 : 0] data_1_i ,
           
    output wire                      equal_o  ,
    output wire                      greater_o,
    output wire                      lower_o
);

    assign equal_o   = (data_0_i == data_1_i);
    assign greater_o = (data_0_i > data_1_i) ;
    assign lower_o   = (data_0_i < data_1_i) ;

endmodule
