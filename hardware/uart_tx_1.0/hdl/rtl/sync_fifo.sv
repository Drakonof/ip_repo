/*--------------------------------------------------
| engineer : A. Shimko
|
| module   : sync_fifo.sv
|
| testbench: sync_fifo_tb.sv
| 
| brief    :
|
| todo     :
|
| 15.12.21 : add(sync_fifo.sv): created
| 23.12.21 : fix(sync_fifo.sv): the FIFO_DEPTH parameter was both 
|
|            1. replaced to a ADDR_WIDTH parameter and 
|            2. moved to localparam from parameter
|
| 12.03.22 : fix(sync_fifo.sv): all '1 constructions were replaced to 1'h1
| 01.04.22 : fix(sync_fifo.sv): fully rewritten
| 28.04.22 : fix(sync_fifo.sv): changed if statements from not synthesized place to asserts
|
*/

/*
sync_fifo # 
(
    .DATA_WIDTH       (), // default: 8
    .ADDR_WIDTH       (), // default: 8

    .RAM_TYPE         (), // default: block, cases: "distributed", "block"

    .ALMOST_FULL_VAL  (), // default: 2
    .ALMOST_EMPTY_VAL (), // default: 2
)
sync_fifo_inst                         
(
    .clk_i          (),
    .s_rst_n_i      (),

    .wr_en_i        (),
    .wr_data_i      (), // width: DATA_WIDTH
    .almost_full_o  (),
    .full_o         (),

    .rd_en_i        (),
    .rd_data_o      (), // width: DATA_WIDTH
    .almost_empty_o (),
    .empty_o        ()
);
*/

`timescale 1ns / 1ps

module sync_fifo #
(
    parameter integer DATA_WIDTH         = 8,
    
    parameter integer ADDR_WIDTH         = 8,
    
    parameter         RAM_TYPE           = "block", // "distributed", "block"  

    parameter integer ALMOST_FULL_VAL  = 2, // hom much of words to an full state
    parameter integer ALMOST_EMPTY_VAL = 2,  // hom much of words to an empty state
    
    localparam integer FIFO_DEPTH = (2 ** ADDR_WIDTH)
)
(
    input  logic                      clk_i,
    input  logic                      s_rst_n_i,
    
    input  logic                      wr_en_i,
    input  logic [DATA_WIDTH - 1 : 0] wr_data_i,
    output logic                      almost_full_o,
    output logic                      full_o,
    
    input  logic                      rd_en_i,
    output logic [DATA_WIDTH - 1 : 0] rd_data_o,
    output logic                      almost_empty_o,
    output logic                      empty_o
);
    localparam integer A_FULL        = FIFO_DEPTH - ALMOST_FULL_VAL; 
    localparam integer A_EMPTY       = ALMOST_EMPTY_VAL;
    
    logic [ADDR_WIDTH - 1 : 0] wr_addr;
    logic [ADDR_WIDTH - 1 : 0] rd_addr;

    logic [ADDR_WIDTH : 0]     wr_pointer;
    logic [ADDR_WIDTH : 0]     rd_pointer;

    (*ram_style = RAM_TYPE*) 
    logic [DATA_WIDTH - 1 : 0] mem [0 : FIFO_DEPTH - 1] ;

    always_comb begin
        wr_addr        = wr_pointer [ADDR_WIDTH - 1 : 0];
        rd_addr        = rd_pointer [ADDR_WIDTH - 1 : 0];

        full_o         = (wr_pointer != rd_pointer) && (wr_addr == rd_addr); 
        empty_o        = (wr_pointer == rd_pointer) && (wr_addr == rd_addr); 

        almost_full_o  = (wr_pointer - rd_pointer) >= A_FULL;
        almost_empty_o = (wr_pointer - rd_pointer) <= A_EMPTY;

        rd_data_o      = mem[rd_addr];
    end
  
    always_ff @ (posedge clk_i) begin : wr_pointer_control
        if (s_rst_n_i == 1'b0) begin
            wr_pointer <= '0;
        end 
        else if ((wr_en_i == 1'b1) && (full_o == 1'b0)) begin
            wr_pointer <= wr_pointer + 1'b1;
        end
    end
    
    always_ff @ (posedge clk_i) begin  : rd_pointer_control
        if (s_rst_n_i == 1'b0) begin
            rd_pointer <= '0;
        end 
        else if ((rd_en_i == 1'b1) && (empty_o == 1'b0)) begin
            rd_pointer <= rd_pointer + 1'b1;
        end
    end

    always_ff @ (posedge clk_i) begin  : wr_data
        if ((wr_en_i == 1'b1) && (full_o == 1'b0)) begin
            mem[wr_addr] <= wr_data_i;
        end
    end
    
    // Not synthesized
    always @ (posedge clk_i) begin
        assert ((wr_en_i == 1'b1) && (full_o == 1'b1)) begin
            $display("full fifo is being written ");
        end

        assert ((rd_en_i == 1'b1) && (empty_o == 1'b1)) begin
            $display("empty fifo is being read");
        end
    end

endmodule
