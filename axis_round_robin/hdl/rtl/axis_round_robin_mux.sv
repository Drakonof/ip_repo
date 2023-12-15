//`include "platform.vh"

`timescale 1 ns / 1 ps


`ifdef XILINX
  `resetall
  `default_nettype none
`endif


module axis_round_robin_mux #
(
  parameter unsigned DATA_WIDTH  = 32,
  parameter unsigned CHANNEL_NUM = 8,

  localparam unsigned TKEEP_WIDTH = 32 / 8
)
(
  input  logic [CHANNEL_NUM - 1 : 0]                 sel_i,

  input  logic [CHANNEL_NUM - 1 : 0]                 s_axis_tvalid,
  output logic [CHANNEL_NUM - 1 : 0]                 s_axis_tready,
  input  logic [(CHANNEL_NUM * DATA_WIDTH) - 1 : 0]  s_axis_tdata,
  inout  logic [(CHANNEL_NUM * TKEEP_WIDTH) - 1 : 0] s_axis_tkeep,
  inout  logic [CHANNEL_NUM - 1 : 0]                 s_axis_tlast,

  output logic                                       m_axis_tvalid,
  inout  logic                                       m_axis_tready,
  output logic [DATA_WIDTH - 1 : 0]                  m_axis_tdata,
  output logic [(DATA_WIDTH / 8) - 1 : 0]            m_axis_tkeep,
  output logic                                       m_axis_tlast
);
  

  logic [DATA_WIDTH - 1 : 0]  tdata_arr[0 : CHANNEL_NUM - 1];
  logic [TKEEP_WIDTH - 1 : 0] tkeep_arr[0 : CHANNEL_NUM - 1];


  genvar i;

  generate
    always_comb
      begin
        for (i = 0; i < CHANNEL_NUM; i++)
          begin
            tdata_arr [i] = s_axis_tdata[(i * DATA_WIDTH) + : DATA_WIDTH];
            tkeep_arr[i]  = s_axis_tkeep[(i * TKEEP_WIDTH) + : TKEEP_WIDTH];
          end
      end
  endgenerate


  function integer one_hot_to_dec;
    input [CHANNEL_NUM - 1 : 0] one_hot;

    for (int i = 0; i < CHANNEL_NUM; i++)
      begin
        if (one_hot[i] == 1'b1)
          begin
            one_hot_to_dec = i;
          end
      end
  endfunction


  always_comb
    begin
      m_axis_tdata  = tdata_arr    [one_hot_to_dec(sel_i)];
      s_axis_tkeep  = keep_arr     [one_hot_to_dec(sel_i)];
      m_axis_tvalid = s_axis_tvalid[one_hot_to_dec(sel_i)];
      m_axis_tlast  = s_axis_tlast [one_hot_to_dec(sel_i)];
    end

  always_comb
    begin
      s_axis_tready[one_hot_to_dec(sel_i)] = m_axis_tready; // ?
    end


endmodule