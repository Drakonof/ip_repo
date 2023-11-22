`timescale 1ns / 1ps

module fifo_tb_wrapper #
(
  parameter unsigned             DATA_WIDTH   = 32,

  parameter unsigned             ADDR_WIDTH   = 8,

  parameter unsigned ALMOST_FULL  = 2,
  parameter unsigned ALMOST_EMPTY = 2
);


  logic                      clk;

  logic                      s_rst_n;

  logic                      wr_en;
  logic [DATA_WIDTH - 1 : 0] data_in;
  logic                      almost_full;
  logic                      full;

  logic                      rd_en;
  logic [DATA_WIDTH - 1 : 0] data_out;
  logic                      almost_empty;
  logic                      empty;


  fifo #
  ( .DATA_WIDTH   (DATA_WIDTH  ),
    .ADDR_WIDTH   (ADDR_WIDTH  ),
    .ALMOST_FULL  (ALMOST_FULL ),
    .ALMOST_EMPTY (ALMOST_EMPTY)
  )
  fifo_dut
  (
    .clk_i          (clk         ),
    .s_rst_n_i      (s_rst_n     ),
  
    .wr_en_i        (wr_en       ),
    .data_i         (data_in     ),   
    .almost_full_o  (almost_full ),
    .full_o         (full        ),

    .rd_en_i        (rd_en       ),
    .data_o         (data_out    ),
    .almost_empty_o (almost_empty),
    .empty_o        (empty       )
  );


  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, fifo_tb_wrapper);
  end


endmodule
