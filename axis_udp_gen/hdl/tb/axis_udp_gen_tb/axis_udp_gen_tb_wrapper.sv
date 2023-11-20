`timescale 1ns / 1ps

module axis_udp_gen_tb_wrapper #
(
  parameter unsigned AXIS_DATA_WIDTH = 64,
  parameter unsigned INIT_FILE = "init.mem"
);
  logic                                 axis_clk;
  logic                                 axis_s_rst_n;
  
  logic                                 m_axis_tvalid;
  logic [AXIS_DATA_WIDTH - 1 : 0]       m_axis_tdata;
  logic [(AXIS_DATA_WIDTH / 8) - 1 : 0] m_axis_tstrb;
  logic                                 m_axis_tlast;
  logic                                 m_axis_tready;

  //udp_gen_inf data_inf();

  axis_udp_gen #
  ( .AXIS_DATA_WIDTH (AXIS_DATA_WIDTH),
    .INIT_FILE       (INIT_FILE      )
  )
  axis_udp_gen_dut
  (
    .axis_clk      (axis_clk     ),
    .axis_s_rst_n  (axis_s_rst_n ),
  
    .m_axis_tvalid (m_axis_tvalid),
    
    .m_axis_tdata  (m_axis_tdata ),   
    .m_axis_tstrb  (m_axis_tstrb ),
    .m_axis_tlast  (m_axis_tlast ),

    .m_axis_tready (m_axis_tready)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, axis_udp_gen_tb_wrapper);
  end

endmodule
