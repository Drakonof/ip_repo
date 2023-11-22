//`include "platform.vh"


`timescale 1 ns / 1 ps


`ifdef XILINX
  `resetall
  `default_nettype none
`endif


module udp_filter #
(
  parameter unsigned DATA_WIDTH = 64,

  localparam unsigned IPV4_ADDR_WIDTH = 32
)
(
  input  logic                           clk_i,

  input  logic                           s_rst_n_i,
  input  logic                           en_i,

  input  logic [IPV4_ADDR_WIDTH - 1 : 0] ipv4_addr_i,

  input  logic [DATA_WIDTH - 1 : 0]      frame_i,
  input  logic                           frame_valid_i,
  input  logic                           frame_last_i,

  output logic [DATA_WIDTH - 1 : 0]      frame_o,
  output logic                           frame_valid_o,

  output logic                           fifo_rst_n_o
);

  












endmodule