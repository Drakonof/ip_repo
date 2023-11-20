`timescale 1 ns / 1 ps

module axis_udp_gen #
(
  parameter unsigned AXIS_DATA_WIDTH = 64,

  localparam unsigned MAX_FRAME_SIZE = 1518,
  parameter unsigned MEM_DEPTH       = (MAX_FRAME_SIZE / AXIS_DATA_WIDTH) * 8,

  parameter          INIT_FILE       = ""
)
(
  input  logic                                 axis_clk,
  input  logic                                 axis_s_rst_n,
  
  output logic                                 m_axis_tvalid,
  output logic [AXIS_DATA_WIDTH - 1 : 0]       m_axis_tdata,
  output logic [(AXIS_DATA_WIDTH / 8) - 1 : 0] m_axis_tstrb,
  output logic                                 m_axis_tlast,
  input  logic                                 m_axis_tready
);


  localparam unsigned MEM_ADDR_WIDTH = $clog2(MEM_DEPTH);
  

  logic                           en;

  //udp_gen_inf data_inf();
  logic [AXIS_DATA_WIDTH - 1 : 0] data;
  logic                           data_valid;
  logic                           frame_end;

  logic [AXIS_DATA_WIDTH - 1 : 0] mem_data; 
  logic [MEM_ADDR_WIDTH - 1 : 0]  mem_addr;


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
  ( .DATA_WIDTH (AXIS_DATA_WIDTH),
    .ADDR_WIDTH (MEM_ADDR_WIDTH )
  )
  udp_gen_inst_0
  (
    .clk_i          (axis_clk    ),
    .s_rst_n_i      (axis_s_rst_n),
  
    .en_i           (en          ),
    
    //.data_inf      (data_inf     )
    .data_o         (data        ),   
    .data_valid_o   (data_valid  ),
    .frame_end_o    (frame_end   ),

    .mem_data_i     (mem_data    ),
    .mem_addr_o     (mem_addr    )

  );

  rom #
  (
    .DATA_WIDTH (AXIS_DATA_WIDTH),
    .ADDR_WIDTH (MEM_ADDR_WIDTH ),
  
`ifdef XILINX
    .RAM_TYPE   ("block"       ),
`endif

    .INIT_FILE (INIT_FILE      )
  )
  rom_inst_0
  (
    .clk_i  (axis_clk),
    .addr_i (mem_addr),

    .data_o (mem_data)
  );
 
  
endmodule
