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
  udp_gen_inf                                  data_inf
);

  always_comb
    begin
      m_axis_tvalid = data_inf.data_valid;
      m_axis_tdata  = data_inf.data;
      m_axis_tstrb  = '1;
      m_axis_tlast  = data_inf.frame_end;
      en_o          = m_axis_tready;
    end


endmodule
