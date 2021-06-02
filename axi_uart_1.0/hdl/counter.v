`timescale 1ns / 1ps

module counter #
(
    parameter integer MAX_VALUE = 8                ,
    parameter integer WIDTH     = $clog2(MAX_VALUE)
)
(
    input  wire                 clk_i    ,
    
    input  wire                 en_i     ,
    input  wire                 s_rst_n_i,

    output wire [WIDTH - 1 : 0] val_o
);
    reg [WIDTH - 1 : 0] counter;

    assign val_o = counter;
    
    always @ (posedge clk_i) begin
        if (1'h0 == s_rst_n_i) begin
            counter <= {WIDTH{1'h0}};
        end
        else if (1'h1 == en_i) begin
            if (MAX_VALUE == counter) begin
               counter <= {WIDTH{1'h0}};
            end
            else begin
                counter <= counter + 1'h1;
            end   
        end
    end
endmodule
