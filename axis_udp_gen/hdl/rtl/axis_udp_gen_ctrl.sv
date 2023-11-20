`timescale 1 ns / 1 ps

module axis_udp_gen_ctrl #
(
  parameter unsigned AXIS_DATA_WIDTH	= 64
)
(
  output logic                                 m_axis_tvalid,
  output logic [AXIS_DATA_WIDTH - 1 : 0]       m_axis_tdata,
  output logic [(AXIS_DATA_WIDTH / 8) - 1 : 0] m_axis_tstrb,
  output logic                                 m_axis_tlast,
  input  logic                                 m_axis_tready,
  
  output logic                                 en_o,
 // udp_gen_inf                                  data_inf
 input logic [AXIS_DATA_WIDTH - 1 : 0]  data_i    , 
 input logic data_valid_i,
 input logic frame_end_i
);

  always_comb
    begin
      m_axis_tvalid = data_valid_i;
      m_axis_tdata  = data_i;
      m_axis_tstrb  = 8'hff; //todo:
      m_axis_tlast  = frame_end_i;
      en_o          = m_axis_tready;
    end


endmodule
