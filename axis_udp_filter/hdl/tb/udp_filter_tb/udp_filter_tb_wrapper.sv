`timescale 1ns / 1ps

module udp_filter_tb_wrapper #
(
  parameter unsigned DATA_WIDTH = 64,

  localparam unsigned IPV4_ADDR_WIDTH = 32
);


  logic                           clk;

  logic                           s_rst_n;
  logic                           en;

  logic [IPV4_ADDR_WIDTH - 1 : 0] ipv4_addr;

  logic [DATA_WIDTH - 1 : 0]      frame;
  logic                           frame_last;

  logic                           frame_valid;
  
  logic                           fifo_wr_en;
  logic [DATA_WIDTH - 1 : 0]      fifo_data;
  logic                           fifo_empty;

  logic                           fifo_rst_n;


  udp_filter #
  ( 
    .DATA_WIDTH   (DATA_WIDTH)
  )
  udp_filter_dut
  (
    .clk_i         (clk        ),

    .s_rst_n_i     (s_rst_n    ),
    .en_i          (en         ),

    .ipv4_addr_i   (ipv4_addr  ),   

    .frame_i       (frame      ),
    .frame_last_i  (frame_last ),

    .frame_valid_o (frame_valid),
    .fifo_wr_en_o  (fifo_wr_en ),
    .fifo_data_o   (fifo_data  ),
    .fifo_empty_i  (fifo_empty ),
    .fifo_rst_n_o  (fifo_rst_n )
  );


  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, udp_filter_tb_wrapper);
  end


endmodule
