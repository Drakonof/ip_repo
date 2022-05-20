/*--------------------------------------------------
| engineer : A. Shimko
|
| module   : piso.sv (parallel in serial out)
|
| testbench: piso_tb.sv
| 
| brief    :
|
| todo     :
|
| 13.12.21 : add (piso.sv): created
| 12.03.22 : fix (piso.sv): all '1 constructions were replaced to 1'h1
| 16.03.22 : fix (piso.sv): the i_en input was added
| 18.03.22 : reivew (piso.sv): [DATA_WIDTH - 1:0] -> [DATA_WIDTH - 1 : 0]
| 01.04.22 : reivew (piso.sv): changed i/o_ prefects to _i/o prefixes
| 01.04.22 : fix (piso.sv): changed parameters
|
|            1. removed DO_FAST parameter
|            2. renamed DO_MSB_FIRST to DIRECTION
|            3. renamed DIRECTION cases ("true" and "false") to "msb_first", "lsb_first"
| 01.04.22 : fix (piso.sv): removed rst for buff and o_data
| 01.04.22 : fix (piso.sv): changed comparing with the constans
|
|            1. "'0" to "1'b0"
|            2. "1'h1" to "1'b1"
| 18.04.22 : fix (piso.sv): moved data_o to continuous assesign
|
*/

/*
piso # 
(
    .DATA_WIDTH (), // default: 8
    .DIRECTION  ()  // default: "msb_first", cases: "msb_first", "lsb_first"
)
piso_inst                         
(
    .clk_i        (),
    .s_rst_n_i    (),
    .en_i         (),

    .wr_en_i      (),
    .data_i       (), // width: DATA_WIDTH

    .data_valid_o (),
    .data_o       ()
);
*/

`timescale 1ns / 1ps

module piso # 
(
    parameter integer DATA_WIDTH = 8,
    parameter         DIRECTION  = "msb_first" // "msb_first", "lsb_first"    
)
(
    input  logic                      clk_i,
    input  logic                      s_rst_n_i,
    input  logic                      en_i,

    input  logic                      wr_en_i,
    input  logic [DATA_WIDTH - 1 : 0] data_i,

    output logic                      data_valid_o,
    output logic                      data_o
);
    localparam integer MSB    = DATA_WIDTH - 1;
    localparam integer LSB    = 0;
    localparam integer SH_BIT = (DIRECTION == "msb_first") ? MSB : LSB;

    logic [DATA_WIDTH - 1 : 0] buff;

    generate
        if (DIRECTION == "msb_first") begin : first_msb_mode
            always_ff @ (posedge clk_i) begin
                if (wr_en_i == 1'b1) begin
                    buff <= data_i;
                end else if (en_i == 1'b1) begin
                    buff <= {buff[MSB - 1 : LSB], 1'b0};
                end
            end
        end
        else begin  : lsb_mode 
            always_ff @ (posedge clk_i) begin : first_lsb_mode
                if (wr_en_i == 1'b1) begin
                    buff <= data_i;
                end else if (en_i == 1'b1) begin
                    buff <= {1'b0, buff[MSB : LSB + 1]};
                end
            end
        end
    endgenerate

    always_comb begin
        data_o = buff[SH_BIT];
    end

    always_ff @ (posedge clk_i) begin
        if (s_rst_n_i == 1'b0)  begin
            data_valid_o <= 1'b0;
        end else begin
            data_valid_o <= (wr_en_i == 1'b0);
        end 
    end 
endmodule
