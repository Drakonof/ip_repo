// 0 - control:  0000_0000 0000_0000 000S_000P 000D_000E
// 1 - baudrate: BBBB_BBBB BBBB_BBBB BBBB_BBBB BBBB_BBBB
// 2 - tx data:  0000_0000 0000_0000 0000_0000 DDDD_DDDD
// 3 - rx data:  0000_0000 0000_0000 0000_0000 DDDD_DDDD
// 4 - status:   0000_0000 0000_0000 000r_000t 000d_000s
`timescale 1ns / 1ps

module uart_controller_sructural #
(
    parameter integer AXI_DATA_WIDTH    = 32                         ,
    parameter integer DATA_WIDTH        = 8                          ,
    parameter integer BAUD_VALUE_WIDTH  = 16                         ,
    parameter integer REG_SPACE_DEPTH   = 16                         ,
    parameter integer REG_ADDRESS_WIDTH = $clog2(REG_SPACE_DEPTH) + 2
)
(
    input  wire                                axi_clk_i       ,    
    input  wire                                axi_a_rst_n_i   , 
                                                
    input  wire [REG_ADDRESS_WIDTH - 1 : 0]    s_axi_awaddr_i  ,
    input  wire [2 : 0]                        s_axi_awprot_i  ,
    input  wire                                s_axi_awvalid_i ,
    output wire                                s_axi_awready_o ,
                
    input  wire [AXI_DATA_WIDTH - 1 : 0]       s_axi_wdata_i   ,
    input  wire [(AXI_DATA_WIDTH / 8) - 1 : 0] s_axi_wstrb_i   ,
    input  wire                                s_axi_wvalid_i  ,
    output wire                                s_axi_wready_o  ,
                 
    output wire [1 : 0]                        s_axi_bresp_o   ,
    output wire                                s_axi_bvalid_o  ,
    input  wire                                s_axi_bready_i  ,
              
    input  wire [REG_ADDRESS_WIDTH - 1 : 0]    s_axi_araddr_i  ,
    input  wire [2 : 0]                        s_axi_arprot_i  ,
    input  wire                                s_axi_arvalid_i ,
    output wire                                s_axi_arready_o ,
                  
    output wire [AXI_DATA_WIDTH - 1 : 0]       s_axi_rdata_o   ,
    output wire [1 : 0]                        s_axi_rresp_o   ,
    output wire                                s_axi_rvalid_o  ,
    input  wire                                s_axi_rready_i  ,
    
    output wire                                tx_enable_o     ,
    output wire [DATA_WIDTH - 1 : 0]           tx_data_o       , 
    
    output wire                                data_bit_num_o  ,
    output wire                                stop_bit_num_o  ,
    output wire [BAUD_VALUE_WIDTH - 1 : 0]     baud_tick_val_o ,
    
    input wire                                 start_complete_i,
    input wire                                 data_complete_i ,
    input wire                                 tx_complete_i
);
    uart_controller #
    (
        .AXI_DATA_WIDTH    (AXI_DATA_WIDTH   ),
        .DATA_WIDTH        (DATA_WIDTH       ),
        .REG_SPACE_DEPTH   (REG_SPACE_DEPTH  ),
        .BAUD_VALUE_WIDTH  (BAUD_VALUE_WIDTH )
    )
    uart_controller_inst
    (
        .axi_clk_i         (axi_clk_i         ),      
        .axi_a_rst_n_i     (axi_a_rst_n_i     ),  
                  
        .s_axi_awaddr_i    (s_axi_awaddr_i    ), 
        .s_axi_awprot_i    (s_axi_awprot_i    ), 
        .s_axi_awvalid_i   (s_axi_awvalid_i   ),
        .s_axi_awready_o   (s_axi_awready_o   ),
                  
        .s_axi_wdata_i     (s_axi_wdata_i     ),  
        .s_axi_wstrb_i     (s_axi_wstrb_i     ),  
        .s_axi_wvalid_i    (s_axi_wvalid_i    ), 
        .s_axi_wready_o    (s_axi_wready_o    ), 
                  
        .s_axi_bresp_o     (s_axi_bresp_o     ),  
        .s_axi_bvalid_o    (s_axi_bvalid_o    ), 
        .s_axi_bready_i    (s_axi_bready_i    ), 
                  
        .s_axi_araddr_i    (s_axi_araddr_i    ), 
        .s_axi_arprot_i    (s_axi_arprot_i    ), 
        .s_axi_arvalid_i   (s_axi_arvalid_i   ),
        .s_axi_arready_o   (s_axi_arready_o   ),
                         
        .s_axi_rdata_o     (s_axi_rdata_o     ),  
        .s_axi_rresp_o     (s_axi_rresp_o     ),  
        .s_axi_rvalid_o    (s_axi_rvalid_o    ), 
        .s_axi_rready_i    (s_axi_rready_i    ),
    
        .tx_enable_o       (tx_enable_o       ),
        .tx_data_o         (tx_data_o         ),
        
        .data_bit_num_o    (data_bit_num_o ),
        .stop_bit_num_o    (stop_bit_num_o ),
        .baud_tick_val_o   (baud_tick_val_o),
        
        .start_complete_i  (start_complete_i),
        .data_complete_i   (data_complete_i) ,
        .tx_complete_i     (tx_complete_i  )
    );
endmodule
