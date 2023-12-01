`timescale 1ns / 1ps

module axis_udp_filter_tb_wrapper #
(
  parameter unsigned MAX_FRAME_SIZE  = 1518,

  localparam unsigned AXIS_DATA_WIDTH = 64,
  localparam unsigned IPV4_ADDR_WIDTH = 32
);

  logic                                 clk;
  logic                                 s_rst_n;

  logic                                 en;

  logic                                 m_axis_tvalid;
  logic [AXIS_DATA_WIDTH - 1 : 0]       m_axis_tdata;
  logic [(AXIS_DATA_WIDTH / 8) - 1 : 0] m_axis_tstrb;
  logic                                 m_axis_tlast;
  logic                                 m_axis_tready;
  
  logic                                 s_axis_tvalid;
  logic [AXIS_DATA_WIDTH - 1 : 0]       s_axis_tdata;
  logic [(AXIS_DATA_WIDTH / 8) - 1 : 0] s_axis_tstrb;
  logic                                 s_axis_tlast;
  logic                                 s_axis_tready;

  logic [IPV4_ADDR_WIDTH - 1 : 0]       ipv4_addr;


  axis_udp_filter #
  (
    .MAX_FRAME_SIZE (MAX_FRAME_SIZE)
  )
  axis_udp_filter_dut
  (
    .axis_clk      (clk          ),

    .axis_s_rst_n  (s_rst_n      ),
    .en            (en           ),  

    .m_axis_tvalid (m_axis_tvalid),
    .m_axis_tdata  (m_axis_tdata ),
    .m_axis_tstrb  (m_axis_tstrb ),
    .m_axis_tlast  (m_axis_tlast ),
    .m_axis_tready (m_axis_tready),

    .s_axis_tvalid (s_axis_tvalid),
    .s_axis_tdata  (s_axis_tdata ),
    .s_axis_tstrb  (s_axis_tstrb ),
    .s_axis_tlast  (s_axis_tlast ),
    .s_axis_tready (s_axis_tready),

    .ipv4_addr     (ipv4_addr    )
  );


  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, axis_udp_filter_tb_wrapper);
  end


endmodule
