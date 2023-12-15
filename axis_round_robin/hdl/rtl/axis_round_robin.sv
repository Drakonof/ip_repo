//`include "platform.vh"

`timescale 1 ns / 1 ps


`ifdef XILINX
  `resetall
  `default_nettype none
`endif


module axis_round_robin #
(
  parameter unsigned DATA_WIDTH  = 32,
  parameter unsigned CHANNEL_NUM = 8,

  localparam unsigned TKEEP_WIDTH = 32 / 8
)
(
  input  logic                                       axis_clk,
  input  logic                                       axis_rst_n,

  input  logic [CHANNEL_NUM - 1 : 0]                 s_0_axis_tvalid,
  output logic [CHANNEL_NUM - 1 : 0]                 s_0_axis_tready,
  input  logic [(CHANNEL_NUM * DATA_WIDTH) - 1 : 0]  s_0_axis_tdata,
  inout  logic [(CHANNEL_NUM * TKEEP_WIDTH) - 1 : 0] s_0_axis_tkeep,
  inout  logic [CHANNEL_NUM - 1 : 0]                 s_0_axis_tlast,

  input  logic [CHANNEL_NUM - 1 : 0]                 s_1_axis_tvalid,
  output logic [CHANNEL_NUM - 1 : 0]                 s_1_axis_tready,
  input  logic [(CHANNEL_NUM * DATA_WIDTH) - 1 : 0]  s_1_axis_tdata,
  inout  logic [(CHANNEL_NUM * TKEEP_WIDTH) - 1 : 0] s_1_axis_tkeep,
  inout  logic [CHANNEL_NUM - 1 : 0]                 s_1_axis_tlast,

  input  logic [CHANNEL_NUM - 1 : 0]                 s_2_axis_tvalid,
  output logic [CHANNEL_NUM - 1 : 0]                 s_2_axis_tready,
  input  logic [(CHANNEL_NUM * DATA_WIDTH) - 1 : 0]  s_2_axis_tdata,
  inout  logic [(CHANNEL_NUM * TKEEP_WIDTH) - 1 : 0] s_2_axis_tkeep,
  inout  logic [CHANNEL_NUM - 1 : 0]                 s_2_axis_tlast,

  input  logic [CHANNEL_NUM - 1 : 0]                 s_3_axis_tvalid,
  output logic [CHANNEL_NUM - 1 : 0]                 s_3_axis_tready,
  input  logic [(CHANNEL_NUM * DATA_WIDTH) - 1 : 0]  s_3_axis_tdata,
  inout  logic [(CHANNEL_NUM * TKEEP_WIDTH) - 1 : 0] s_3_axis_tkeep,
  inout  logic [CHANNEL_NUM - 1 : 0]                 s_3_axis_tlast,

  input  logic [CHANNEL_NUM - 1 : 0]                 s_4_axis_tvalid,
  output logic [CHANNEL_NUM - 1 : 0]                 s_4_axis_tready,
  input  logic [(CHANNEL_NUM * DATA_WIDTH) - 1 : 0]  s_4_axis_tdata,
  inout  logic [(CHANNEL_NUM * TKEEP_WIDTH) - 1 : 0] s_4_axis_tkeep,
  inout  logic [CHANNEL_NUM - 1 : 0]                 s_4_axis_tlast,

  input  logic [CHANNEL_NUM - 1 : 0]                 s_5_axis_tvalid,
  output logic [CHANNEL_NUM - 1 : 0]                 s_5_axis_tready,
  input  logic [(CHANNEL_NUM * DATA_WIDTH) - 1 : 0]  s_5_axis_tdata,
  inout  logic [(CHANNEL_NUM * TKEEP_WIDTH) - 1 : 0] s_5_axis_tkeep,
  inout  logic [CHANNEL_NUM - 1 : 0]                 s_5_axis_tlast,

  input  logic [CHANNEL_NUM - 1 : 0]                 s_6_axis_tvalid,
  output logic [CHANNEL_NUM - 1 : 0]                 s_6_axis_tready,
  input  logic [(CHANNEL_NUM * DATA_WIDTH) - 1 : 0]  s_6_axis_tdata,
  inout  logic [(CHANNEL_NUM * TKEEP_WIDTH) - 1 : 0] s_6_axis_tkeep,
  inout  logic [CHANNEL_NUM - 1 : 0]                 s_6_axis_tlast,

  input  logic [CHANNEL_NUM - 1 : 0]                 s_7_axis_tvalid,
  output logic [CHANNEL_NUM - 1 : 0]                 s_7_axis_tready,
  input  logic [(CHANNEL_NUM * DATA_WIDTH) - 1 : 0]  s_7_axis_tdata,
  inout  logic [(CHANNEL_NUM * TKEEP_WIDTH) - 1 : 0] s_7_axis_tkeep,
  inout  logic [CHANNEL_NUM - 1 : 0]                 s_7_axis_tlast,

  output logic                                       m_axis_tvalid,
  inout  logic                                       m_axis_tready,
  output logic [DATA_WIDTH - 1 : 0]                  m_axis_tdata,
  output logic [(DATA_WIDTH / 8) - 1 : 0]            m_axis_tkeep,
  output logic                                       m_axis_tlast
);

  
  logic [CHANNEL_NUM - 1 : 0]                 sel;

  logic [CHANNEL_NUM - 1 : 0]                 axis_tvalid;
  logic [CHANNEL_NUM - 1 : 0]                 axis_tready;
  logic [(CHANNEL_NUM * DATA_WIDTH) - 1 : 0]  axis_tdata;
  logic [(CHANNEL_NUM * TKEEP_WIDTH) - 1 : 0] axis_tkeep;
  logic [CHANNEL_NUM - 1 : 0]                 axis_tlast;


  always_comb
    begin
      axis_tvalid = {s_0_axis_tvalid, s_1_axis_tvalid, s_2_axis_tvalid, s_3_axis_tvalid, s_4_axis_tvalid, s_5_axis_tvalid, s_6_axis_tvalid, s_7_axis_tvalid};
      axis_tready = {s_0_axis_tready, s_1_axis_tready, s_2_axis_tready, s_3_axis_tready, s_4_axis_tready, s_5_axis_tready, s_6_axis_tready, s_7_axis_tready};
      axis_tdata  = {s_0_axis_tdata, s_1_axis_tdata, s_2_axis_tdata, s_3_axis_tdata, s_4_axis_tdata, s_5_axis_tdata, s_6_axis_tdata, s_7_axis_tdata};
      axis_tkeep  = {s_0_axis_tkeep, s_1_axis_tkeep, s_2_axis_tkeep, s_3_axis_tkeep, s_4_axis_tkeep, s_5_axis_tkeep, s_6_axis_tkeep, s_7_axis_tkeep};
      axis_tlast  = {s_0_axis_tlast, s_1_axis_tlast, s_2_axis_tlast, s_3_axis_tlast, s_4_axis_tlast, s_5_axis_tlast, s_6_axis_tlast, s_7_axis_tlast};
    end


  axis_round_robin_arbiter #
  (
    .CHANNEL_NUM (CHANNEL_NUM)
  )
  axis_round_robin_arbiter_inst_0
  (
    .clk_i    (axis_clk   ),
    .rst_n_i  (axis_rst_n ),

    .s_tvalid (axis_tvalid),
    .s_tlast  (axis_tlast ),

    .sel_o    (sel        )
  );

  axis_round_robin_mux #
  (
    .DATA_WIDTH  (DATA_WIDTH ),
    .CHANNEL_NUM (CHANNEL_NUM)
  )
  axis_round_robin_mux_inst_0
  (
    .sel_i         (sel          ),

    .s_axis_tvalid (axis_tvalid  ),
    .s_axis_tready (axis_tready  ),
    .s_axis_tdata  (axis_tdata   ),
    .s_axis_tkeep  (axis_tkeep   ),
    .s_axis_tlast  (axis_tlast   ),
  
    .m_axis_tvalid (m_axis_tvalid),
    .m_axis_tready (m_axis_tready),
    .m_axis_tdata  (m_axis_tdata ),
    .m_axis_tkeep  (m_axis_tkeep ),
    .m_axis_tlast  (m_axis_tlast )
  );

endmodule