//`include "platform.vh"


`timescale 1 ns / 1 ps


`ifdef XILINX
  `resetall
  `default_nettype none
`endif

module axis_udp_filter #
(
  parameter unsigned AXIS_DATA_WIDTH = 64,

`ifdef XILINX
   parameter         RAM_STYLE       = "auto", // "distributed", "block", "registers", "ultra", "mixed", "auto"
`endif

  parameter unsigned MAX_FRAME_SIZE  = 1518,

  localparam unsigned IPV4_ADDR_WIDTH = 32
)
(
  input  logic                                 axis_clk,
  input  logic                                 axis_s_rst_n,

  input  logic                                 en, 

  output logic                                 m_axis_tvalid,
  output logic [AXIS_DATA_WIDTH - 1 : 0]       m_axis_tdata,
  output logic [(AXIS_DATA_WIDTH / 8) - 1 : 0] m_axis_tstrb,
  output logic                                 m_axis_tlast,
  input  logic                                 m_axis_tready
  
  input  logic                                 s_axis_tvalid,
  input  logic [AXIS_DATA_WIDTH - 1 : 0]       s_axis_tdata,
  input  logic [(AXIS_DATA_WIDTH / 8) - 1 : 0] s_axis_tstrb,
  input  logic                                 s_axis_tlast,
  output logic                                 s_axis_tready,

  input  logic [IPV4_ADDR_WIDTH - 1 : 0]       ipv4_addr_i
);
  

  localparam unsigned FIFO_ADDR_WIDTH = $clog2(MAX_FRAME_SIZE);
  localparam unsigned ALMOST_FULL     = 2;
  localparam unsigned ALMOST_EMPTY    = 2;

  logic                           fifo_rst_n;
  logic                           fifo_sys_rst_n;
  logic                           wr_en;
  logic [AXIS_DATA_WIDTH - 1 : 0] data_to_fifo;
 // todo: logic                           full;

  logic                           rd_en;
  logic [AXIS_DATA_WIDTH - 1 : 0] data_from_fifo;
  logic                           almost_empty;
  logic                           empty;
  
  logic                           filter_en;
  logic [AXIS_DATA_WIDTH - 1 : 0] frame;
  logic                           frame_last;
  logic                           frame_valid;


  fifo #
  (
    .DATA_WIDTH   (AXIS_DATA_WIDTH),

    .ADDR_WIDTH   (FIFO_ADDR_WIDTH),

  `ifdef XILINX
    .RAM_STYLE    (RAM_STYLE      ),
  `endif

    .ALMOST_FULL  (ALMOST_FULL    ),
    .ALMOST_EMPTY (ALMOST_EMPTY   )
  )
  fifo_inst
  (
    .clk_i          (axis_clk      ),
  
    .s_rst_n_i      (fifo_sys_rst_n),

    .wr_en_i        (wr_en         ),
    .data_i         (data_to_fifo  ),
    .almost_full_o  (),
    .full_o         (),

    .rd_en_i        (rd_en         ),
    .data_o         (data_from_fifo),
    .almost_empty_o (almost_empty  ),
    .empty_o        (empty         )
  );

  udp_filter #
  (
    .DATA_WIDTH      (AXIS_DATA_WIDTH),

    .IPV4_ADDR_WIDTH (IPV4_ADDR_WIDTH)
  )
  udp_filter_inst
  (
    .clk_i         (axis_clk    ),

    .s_rst_n_i     (axis_s_rst_n),
    .en_i          (filter_en   ),

    .ipv4_addr_i   (ipv4_addr_i ),

    .frame_i       (frame       ),
    .frame_last_i  (frame_last  ),

    .frame_valid_o (frame_valid ),
  
    .fifo_wr_en_o  (wr_en       ),
    .fifo_data_o   (data_to_fifo),
    .fifo_empty_i  (empty       ),
    .fifo_rst_n_o  (fifo_rst_n  )
  );