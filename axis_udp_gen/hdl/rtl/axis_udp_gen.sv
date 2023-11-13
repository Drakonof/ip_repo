`timescale 1 ns / 1 ps

module axis_udp_gen #
(
  parameter unsigned                 AXIS_DATA_WIDTH = 64,

  localparam unsigned AXI_DATA_WIDTH = AXIS_DATA_WIDTH,
  parameter unsigned                 AXI_ADDR_WIDTH  = 4,

  localparam unsigned AXI_PROT_WIDTH = 3,
  localparam unsigned AXI_RESP_WIDTH = 2

  parameter                          INIT_FILE       = ""
)
(
  // axis
  input  logic                                 axis_clk,
  input  logic                                 axis_s_rst_n,
  
  output logic                                 m_axis_tvalid,
  output logic [AXIS_DATA_WIDTH - 1 : 0]       m_axis_tdata,
  output logic [(AXIS_DATA_WIDTH / 8) - 1 : 0] m_axis_tstrb,
  output logic                                 m_axis_tlast,
  input  logic                                 m_axis_tready,
  
  // axi
  input  logic                                 axi_clk,
  input  logic                                 axi_s_rst_n,

  input  logic [AXI_ADDR_WIDTH - 1 : 0]        s_axi_awaddr,
  input  logic [AXI_PROT_WIDTH - 1 : 0]        s_axi_awprot,
  input  logic                                 s_axi_awvalid,
  output logic                                 s_axi_awready,
  
  input  logic [AXI_DATA_WIDTH - 1 : 0]        s_axi_wdata,
  input  logic [(AXI_DATA_WIDTH / 8) - 1 : 0]  s_axi_wstrb,
  input  logic                                 s_axi_wvalid,
  output logic                                 s_axi_wready,
  
  output logic [AXI_RESP_WIDTH - 1 : 0]        s_axi_bresp,
  output logic                                 s_axi_bvalid,
  input  logic                                 s_axi_bready,
  
  input  logic [AXI_ADDR_WIDTH - 1 : 0]        s_axi_araddr,
  input  logic [AXI_PROT_WIDTH - 1 : 0]        s_axi_arprot,
  input  logic                                 s_axi_arvalid,
  output logic                                 s_axi_arready,
  
  output logic [AXI_DATA_WIDTH - 1 : 0]        s_axi_rdata,
  output logic [AXI_RESP_WIDTH - 1 : 0]        s_axi_rresp,
  output logic                                 s_axi_rvalid,
  input  logic                                 s_axi_rready
);


  logic en;
  logic [AXIS_DATA_WIDTH - 1 : 0] data;
  logic [AXIS_DATA_WIDTH - 1 : 0] mem_data;     
  logic data_valid;
  logic frame_end;

  logic [AXI_ADDR_WIDTH - 1 : 0]  mem_addr;
  logic mem_rd_en;
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
  ( .DATA_WIDTH (AXI_DATA_WIDTH),
    .ADDR_WIDTH (AXI_ADDR_WIDTH),

    .MAC_ADDR   (MAC_ADDR      )
  )
  udp_gen_inst_0
  (
    .clk_i          (axis_clk    ),
    .s_rst_n_i      (axis_s_rst_n),
  
    .en_i           (en          )
    
    .data_o         (data        ),   
    .data_valid_o   (data_valid  ),
    .frame_end_o    (frame_end   ),

    .mem_data_i     (mem_data    ),
    .mem_addr_o     (mem_addr    ),
    .mem_rd_en_o    (mem_rd_en   )

  );

  axi_udp_gen_ctrl #
  (
    .AXI_DATA_WIDTH (AXI_DATA_WIDTH),
    .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH)
  )
  axis_udp_gen_ctrl_inst_0
  (
    .axi_clk        (axi_clk      ),
    .axi_s_rst_n    (axi_s_rst_n  ),
    
    .s_axi_awaddr   (s_axi_awaddr ),
    .s_axi_awprot   (s_axi_awprot ),
    .s_axi_awvalid  (s_axi_awvalid),
    .s_axi_awready  (s_axi_awready),
    
    .s_axi_wdata    (s_axi_wdata  ),
    .s_axi_wstrb    (s_axi_wstrb  ),
    .s_axi_wvalid   (s_axi_wvalid ),
    .s_axi_wready   (s_axi_wready ),
    
    .s_axi_bresp    (s_axi_bresp  ),
    .s_axi_bvalid   (s_axi_bvalid ),
    .s_axi_bready   (s_axi_bready ),
    
    .s_axi_araddr   (s_axi_araddr ),
    .s_axi_arprot   (s_axi_arprot ),
    .s_axi_arvalid  (s_axi_arvalid),
    .s_axi_arready  (s_axi_arready),
    
    .s_axi_rdata    (s_axi_rdata  ),
    .s_axi_rresp    (s_axi_rresp  ),
    .s_axi_rvalid   (s_axi_rvalid ),
    .s_axi_rready   (s_axi_rready ),
    
    .bram_addr_o    (bram_addr    ),
    .bram_data_o    (bram_data    ),
    .bram_wr_en_o   (bram_wr_en   ),
    .bram_byte_valid_o (bram_byte_valid)
  );

  simple_dual_port_ram #
  (
    .DATA_WIDTH (AXI_DATA_WIDTH),
    .ADDR_WIDTH (AXI_ADDR_WIDTH),

`ifdef XILINX
    .RAM_TYPE   ("block"       ),
`endif

    .INIT_FILE  (INIT_FILE     )
  )
  simple_dual_port_ram_inst_0
  (
    .wr_clk_i        (axi_clk),

    .wr_en_i         (bram_wr_en),
    .wr_data_i       (bram_data),
    .wr_byte_valid_i (bram_byte_valid),
    .wr_addr_i       (bram_addr),

    .rd_clk_i        (axis_clk),

    .rd_en_i         (mem_rd_en),
    .rd_data_o       (mem_data),
    .rd_addr_i       (mem_addr)
  );
 
  
endmodule
