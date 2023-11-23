//`include "platform.vh"


`timescale 1 ns / 1 ps


`ifdef XILINX
  `resetall
  `default_nettype none
`endif


module axis_udp_filter_if #
(
  parameter unsigned AXIS_DATA_WIDTH = 64
)
(
  input  logic                                 axis_s_rst_n,

  output logic                                 m_axis_tvalid,
  output logic [AXIS_DATA_WIDTH - 1 : 0]       m_axis_tdata,
  output logic [(AXIS_DATA_WIDTH / 8) - 1 : 0] m_axis_tstrb, //todo:
  output logic                                 m_axis_tlast,
  input  logic                                 m_axis_tready
  
  input  logic                                 s_axis_tvalid,
  input  logic [AXIS_DATA_WIDTH - 1 : 0]       s_axis_tdata,
  input  logic [(AXIS_DATA_WIDTH / 8) - 1 : 0] s_axis_tstrb, //todo:
  input  logic                                 s_axis_tlast,
  output logic                                 s_axis_tready,

  input  logic                                 en_i,

  output logic                                 fifo_sys_rst_n_o,
  output logic                                 rd_en_o,
  input  logic [AXIS_DATA_WIDTH - 1 : 0]       data_from_fifo_i,
  input  logic                                 almost_empty_i,

  output logic                                 filter_en_o,
  output logic [AXIS_DATA_WIDTH - 1 : 0]       frame_o,
  output logic                                 frame_last_o,
  input  logic                                 frame_valid_i,
  input  logic                                 fifo_rst_n_i,
);

  always_comb
    begin
      m_axis_tvalid = frame_valid_i;
      m_axis_tdata  = data_from_fifo_i;
      m_axis_tlast  = almost_empty_i;
      rd_en_o       = m_axis_tready;

      filter_en_o = s_axis_tvalid;
      frame_o = s_axis_tdata;
      frame_last_o = s_axis_tlast;
      s_axis_tready = en_i;

      fifo_sys_rst_n_o = axis_s_rst_n & fifo_rst_n_i;
    end


endmodule