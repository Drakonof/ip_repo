//`include "platform.vh"

`timescale 1 ns / 1 ps

module axi_rom #
(
  parameter unsigned AXI_DATA_WIDTH	= 32,
  parameter unsigned AXI_ADDR_WIDTH	= 4,
 
`ifdef XILINX 
  parameter          RAM_TYPE    = "block", // "distributed", "block"
`endif
  parameter          INIT_FILE      = "/home/artem/workspace/H/ip_repo/axi_rom_1.0/hdl/tb/rom_tb/rom_init.mem",
  
  localparam unsigned AXI_PROT_WIDTH = 3,
  localparam unsigned AXI_RESP_WIDTH = 2
)
(
  input  logic                                axi_clk,
  input  logic                                axi_s_rst_n,

  input  logic [AXI_ADDR_WIDTH - 1 : 0]       s_axi_awaddr,
  input  logic [AXI_PROT_WIDTH - 1 : 0]       s_axi_awprot,
  input  logic                                s_axi_awvalid,
  output logic                                s_axi_awready,
  
  input  logic [AXI_DATA_WIDTH - 1 : 0]       s_axi_wdata,
  input  logic [(AXI_DATA_WIDTH / 8) - 1 : 0] s_axi_wstrb,
  input  logic                                s_axi_wvalid,
  output logic                                s_axi_wready,
  
  output logic [AXI_RESP_WIDTH - 1 : 0]       s_axi_bresp,
  output logic                                s_axi_bvalid,
  input  logic                                s_axi_bready,
  
  input  logic [AXI_ADDR_WIDTH - 1 : 0]       s_axi_araddr,
  input  logic [AXI_PROT_WIDTH - 1 : 0]       s_axi_arprot,
  input  logic                                s_axi_arvalid,
  output logic                                s_axi_arready,
  
  output logic [AXI_DATA_WIDTH - 1 : 0]       s_axi_rdata,
  output logic [AXI_RESP_WIDTH - 1 : 0]       s_axi_rresp,
  output logic                                s_axi_rvalid,
  input  logic                                s_axi_rready
);

  logic [AXI_ADDR_WIDTH - 1 : 0] rom_addr;
  logic [AXI_DATA_WIDTH - 1 : 0] rom_data;

  axi_rom_ctrl # 
  ( 
    .AXI_DATA_WIDTH (AXI_DATA_WIDTH),
    .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH)
  ) 
  axi_rom_ctrl_inst 
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
    
    .rom_addr_o     (rom_addr     ),
    .rom_data_i     (rom_data     )
  );

  rom #
  (
    .DATA_WIDTH (AXI_DATA_WIDTH),
    .ADDR_WIDTH (AXI_ADDR_WIDTH),
    
`ifdef XILINX 
    .RAM_TYPE   (RAM_TYPE      ),
`endif

    .INIT_FILE  (INIT_FILE     )
  )
  rom_inst
  (
    .clk_i  (axi_clk ),
    .addr_i (rom_addr),
  
    .data_o (rom_data)
  );

`ifndef XILINX
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, axi_rom);
  end
`endif

endmodule
