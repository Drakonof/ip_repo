`include "platform.vh"

`timescale 1 ns / 1 ps

module axi_rom_ctrl #
(
  parameter integer AXI_DATA_WIDTH	= 32,
  parameter integer AXI_ADDR_WIDTH	= 4,
  
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
  
  output logic [AXI_RESP_WIDTH - 1: 0]        s_axi_bresp,  
  output logic                                s_axi_bvalid, 
  input  logic                                s_axi_bready, 
  
  input  logic [AXI_ADDR_WIDTH - 1 : 0]       s_axi_araddr, 
  input  logic [AXI_PROT_WIDTH - 1 : 0]       s_axi_arprot, 
  input  logic                                s_axi_arvalid,
  output logic                                s_axi_arready,
  
  output logic [AXI_DATA_WIDTH - 1 : 0]       s_axi_rdata,  
  output logic [AXI_RESP_WIDTH - 1: 0]        s_axi_rresp,  
  output logic                                s_axi_rvalid, 
  input  logic                                s_axi_rready,
  
  output logic                                rom_addr_o,
  input  logic                                rom_data_i
);
  logic  	                     axi_arready;
  logic  	                     axi_rvalid;
  logic [AXI_ADDR_WIDTH - 1 : 0] axi_araddr;
  logic [AXI_DATA_WIDTH - 1 : 0] axi_rdata;
  logic [AXI_RESP_WIDTH - 1 : 0] axi_rresp;
 
  logic	                         slv_reg_rden;
  logic                          read_ready;
  logic                          read_valid;
  logic                          addr_read_ready;
  
  always_comb
    begin
      s_axi_awready = '0;
      s_axi_wready  = '0;
      
      s_axi_bresp   = '0;
      s_axi_bvalid  = '0;
      
      s_axi_arready = axi_arready;
      s_axi_rdata   = axi_rdata;
      s_axi_rresp   = axi_rresp;
      s_axi_rvalid  = axi_rvalid;
      
      rom_addr_o    = axi_araddr;
    end 
    
  always_comb
    begin
      slv_reg_rden    = axi_arready & s_axi_arvalid & ~axi_rvalid;
      read_ready      = axi_arready && s_axi_arvalid && ~axi_rvalid;
      read_valid      = axi_rvalid && s_axi_rready;
      addr_read_ready = ~axi_arready && s_axi_arvalid;
    end
  
  always_ff @(posedge axi_clk)
    begin
      if (axi_s_rst_n == 1'h0)
        begin
          axi_arready <= '0;
          axi_araddr  <= '0;
        end 
      else
        begin    
          if (addr_read_ready == 1'h1)
            begin
              axi_arready <= 'h1;
              axi_araddr  <= s_axi_araddr;
            end
          else
            begin
              axi_arready <= 'h0;
            end
        end 
    end       
  
  always_ff @(posedge axi_clk)
    begin
      if (axi_s_rst_n == 1'h0)
        begin
          axi_rvalid <= 0;
          axi_rresp  <= 0;
        end 
      else
        begin    
          if (read_ready == 1'h1)
            begin
              axi_rvalid <= 'h1;
              axi_rresp  <= '0;
            end   
          else if (read_valid == 1'h1)
            begin
              axi_rvalid <= 'h0;
            end                
        end
    end    

  always_ff @(posedge axi_clk)
    begin
      if (axi_s_rst_n == 1'h0)
        begin
          axi_rdata <= '0;
        end 
      else
        begin    
          if (slv_reg_rden)
            begin
              axi_rdata <= rom_data_i;
            end   
        end
    end    
  
endmodule
