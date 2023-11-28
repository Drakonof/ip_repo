//`include "platform.vh"


`timescale 1 ns / 1 ps


`ifdef XILINX
  `resetall
  `default_nettype none
`endif

module axis_udp_filter #
(
  
`ifdef XILINX
   parameter         RAM_STYLE       = "auto", // "distributed", "block", "registers", "ultra", "mixed", "auto"
`endif

  parameter unsigned MAX_FRAME_SIZE  = 1518,

  localparam unsigned AXIS_DATA_WIDTH = 64,
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
  logic                           wr_en;
  logic [AXIS_DATA_WIDTH - 1 : 0] data_to_fifo;
  logic                           full;

  logic                           rd_en;
  logic [AXIS_DATA_WIDTH - 1 : 0] data_from_fifo;
  logic                           almost_empty;
  logic                           empty;
  
  logic                           filter_en;
  logic [AXIS_DATA_WIDTH - 1 : 0] frame_data;
  logic                           frame_last;
  logic                           frame_valid;


  axis_udp_filter_if #
  (
    .AXIS_DATA_WIDTH (AXIS_DATA_WIDTH)
  )
  (
    .m_axis_tvalid     (m_axis_tvalid ),
    .m_axis_tdata      (m_axis_tdata  ),
    .m_axis_tstrb      (m_axis_tstrb  ),
    .m_axis_tlast      (m_axis_tlast  ),
    .m_axis_tready     (m_axis_tready ),
  
    .s_axis_tvalid     (s_axis_tvalid ),
    .s_axis_tdata      (s_axis_tdata  ),
    .s_axis_tstrb      (s_axis_tstrb  ),
    .s_axis_tlast      (s_axis_tlast  ),
    .s_axis_tready     (s_axis_tready ),

    .en_i              (en            ),
 
    .fifo_full_i       (full          ),
    .rd_en_o           (rd_en         ),
    .data_from_fifo_i  (data_from_fifo),
    .almost_empty_i    (almost_empty  ),

    .filter_en_o       (filter_en     ),
    .frame_o           (frame_data    ),
    .frame_last_o      (frame_last    ),
    .frame_valid_i     (frame_valid   )
  );

  smart_fifo #
  (
    .DATA_WIDTH   (AXIS_DATA_WIDTH),

    .ADDR_WIDTH   (FIFO_ADDR_WIDTH),

  `ifdef XILINX
    .RAM_STYLE    (RAM_STYLE      ),
  `endif

    .ALMOST_FULL  (ALMOST_FULL    ),
    .ALMOST_EMPTY (ALMOST_EMPTY   )
  )
  smart_fifo_inst
  (
    .clk_i          (axis_clk      ),
  
    .s_rst_n_0_i    (axis_s_rst_n  ),

    .s_rst_n_1_i    (fifo_rst_n    ),

    .wr_en_i        (wr_en         ),
    .data_i         (data_to_fifo  ),
    .almost_full_o  (),
    .full_o         (full          ),

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