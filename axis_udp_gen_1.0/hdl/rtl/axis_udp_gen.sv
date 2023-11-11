`timescale 1 ns / 1 ps

module axis_udp_gen #
(
  parameter unsigned                 AXIS_DATA_WIDTH = 64,
  
  localparam unsigned MAC_ADDR_WIDTH  = 48,
  parameter [MAC_ADDR_WIDTH - 1 : 0] MAC_ADDR        = 48'h1A1B1C1D1E1F,
  
  localparam unsigned LT_WIDTH        = 16,
  parameter [LT_WIDTH - 1 : 0]       LT              = 16'h0800,
  
  localparam unsigned IPV4_ADDR_WIDTH = 32,
  localparam unsigned UDP_PORT_WIDTH  = 16
)
(
  input  logic                                 axis_clk,
  input  logic                                 axis_s_rst_n,
  
  output logic                                 m_axis_tvalid,
  output logic [AXIS_DATA_WIDTH - 1 : 0]       m_axis_tdata,
  output logic [(AXIS_DATA_WIDTH / 8) - 1 : 0] m_axis_tstrb,
  output logic                                 m_axis_tlast,
  input  logic                                 m_axis_tready,
	
  input  logic [MAC_ADDR_WIDTH - 1 : 0]        dst_mac_addr,
  
  input  logic [IPV4_ADDR_WIDTH - 1 : 0]       src_ipv4_addr,
  input  logic [IPV4_ADDR_WIDTH - 1 : 0]       dst_ipv4_addr,

  input  logic [UDP_PORT_WIDTH - 1 : 0]        src_udp_port,
  input  logic [UDP_PORT_WIDTH - 1 : 0]        dst_udp_port
);


  logic en;
  logic [AXIS_DATA_WIDTH - 1 : 0] data;     
  logic data_valid;
  logic frame_end;
  //udp_gen_inf data_inf();


  axis_udp_gen_ctrl # 
  ( 
  	.AXIS_DATA_WIDTH (AXIS_DATA_WIDTH)
  ) 
  axis_udp_gen_ctrl_inst_0 
  (
  	.m_axis_tvalid (m_axis_tvalid),
  	.m_axis_tdata  (m_axis_tdata ),
  	.m_axis_tstrb  (m_axis_tstrb ),
  	.m_axis_tlast  (m_axis_tlast ),
  	.m_axis_tready (m_axis_tready),
  	
  	.en_o          (en           ),
  	//.data_inf      (data_inf     )
  	.data_i        (data     ),   
    .data_valid_i  (data_valid),
    .frame_end_i   (frame_end)
  	
  );
  
  udp_gen #
  (
    .MAC_ADDR (MAC_ADDR),
    .LT       (LT      )
  )
  udp_gen_inst_0
  (
    .clk_i                (axis_clk     ),
    .s_rst_n_i            (axis_s_rst_n ),
  
    .en_i                 (en           ),
  
    .dst_mac_addr_i       (dst_mac_addr ),
  
    .src_ipv4_addr_i      (src_ipv4_addr),
    .dst_ipv4_addr_i      (dst_ipv4_addr),
  
    .src_udp_port_i       (src_udp_port ),
    .dst_udp_port_i       (dst_udp_port ),
    
    //.udp_gen_inf          (data_inf     )
    
    .data_o        (data     ),   
    .data_valid_o  (data_valid),
    .frame_end_o   (frame_end)
  );
 
  
endmodule
