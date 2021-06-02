`timescale 1ns / 1ps

module piso # 
(
    parameter         DATA_WIDTH   = 8     ,
    parameter integer DO_MSB_FIRST = "TRUE"      
)
(
    input  wire                     clk_i     ,
    input  wire                     s_rst_n_i ,
    input  wire                     en_i      ,
    
    input  wire                     wr_en_i   ,
    input  wire  [DATA_WIDTH - 1:0] data_i    ,

    output wire                     data_o
);
    localparam integer MSB = DATA_WIDTH - 1;
    localparam integer LSB = 0             ;

    reg [DATA_WIDTH - 1 : 0] buff;
    
    generate
        if ("TRUE" == DO_MSB_FIRST) begin
            assign data_o = buff[MSB];
            
            always @ (posedge clk_i) begin
                if (1'h0 == s_rst_n_i) begin
                    buff <= {DATA_WIDTH{1'h0}};
                end
                else begin
                    if (1'h1 == wr_en_i) begin
                        buff <= data_i;
                    end
                    
                    if (1'h1 == en_i) begin
                        buff <= {buff[MSB - 1 : LSB], 1'h0};
                    end  
                end
            end
        end
        else begin
             assign data_o =(wr_en_i) ? data_i[LSB] : buff[LSB];
             
             always @ (posedge clk_i) begin
                if (1'h0 == s_rst_n_i) begin
                    buff <= {DATA_WIDTH{1'h0}};
                end
                else begin
                    if (1'h1 == wr_en_i) begin
                        buff <= data_i;
                    end 
                    
                    if (1'h1 == en_i) begin
                       buff <= {1'h0, buff[MSB : LSB + 1]};
                    end 
                end 
            end
        end
    endgenerate
endmodule