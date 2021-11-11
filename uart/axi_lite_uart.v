// todo: pos resets
`timescale 1 ns / 1 ps

module axi_lite_usart # 
(
	parameter integer AXI_DATA_WIDTH    = 32                         ,
	parameter integer CLK_VALUE_MHZ     = 50                         ,
	parameter integer BAUD_MAX_VALUE    = 115200                     , 
	parameter integer REG_SPACE_DEPTH   = 6                          ,
	parameter integer REG_ADDRESS_WIDTH = $clog2(REG_SPACE_DEPTH) + 2
)
(
	input  wire                                axi_clk      ,
	input  wire                                axi_a_rst_n  ,
	
	input  wire [REG_ADDRESS_WIDTH - 1 : 0]    s_axi_awaddr ,
	input  wire [2 : 0]                        s_axi_awprot ,
	input  wire                                s_axi_awvalid,
	output wire                                s_axi_awready,
	
	input  wire [AXI_DATA_WIDTH - 1 : 0]       s_axi_wdata  ,
	input  wire [(AXI_DATA_WIDTH / 8) - 1 : 0] s_axi_wstrb  ,
	input  wire                                s_axi_wvalid ,
	output wire                                s_axi_wready ,

	output wire [1 : 0]                        s_axi_bresp  ,
	output wire                                s_axi_bvalid ,
	input  wire                                s_axi_bready ,
	
	input  wire [REG_ADDRESS_WIDTH - 1 : 0]    s_axi_araddr ,
	input  wire [2 : 0]                        s_axi_arprot ,
	input  wire                                s_axi_arvalid,
	output wire                                s_axi_arready,
	
	output wire [AXI_DATA_WIDTH - 1 : 0]       s_axi_rdata  ,
	output wire [1 : 0]                        s_axi_rresp  ,
	output wire                                s_axi_rvalid ,
	input  wire                                s_axi_rready ,
	
	output wire                                tx
);
    
    localparam integer BAUD_GEN_CNTER_MAX_VAL     = (CLK_VALUE_MHZ * 1000000) / BAUD_MAX_VALUE + 1;
    localparam integer TX_RX_DATA_BIT_CNTER_WIDTH = $clog2(BAUD_GEN_CNTER_MAX_VAL)                ;
    
    localparam integer BAUD_MAX_VALUE_WIDTH       = $clog2(BAUD_MAX_VALUE)                        ;
    
    localparam integer PACK_BIT_NUM_MAX_VALUE     = 8                                             ;

    localparam         INIT_FILE_NAME             = ""                                            ;
       
    wire                                   data_bit_num   ;
    wire                                   stop_bit_num   ;
    wire [BAUD_MAX_VALUE_WIDTH - 1:0]      baud_tick_value; 
    
    wire                                   tx_enable      ;
    wire [PACK_BIT_NUM_MAX_VALUE - 1 : 0]  tx_data        ;
    
    wire                                   start_complete ;
    wire                                   data_complete  ;
    wire                                   tx_complete    ;
    
    uart_controller_sructural #
    (
        .AXI_DATA_WIDTH   (AXI_DATA_WIDTH        ),
        .DATA_WIDTH       (PACK_BIT_NUM_MAX_VALUE),
        .BAUD_VALUE_WIDTH (BAUD_MAX_VALUE_WIDTH  ),
        .REG_SPACE_DEPTH  (REG_SPACE_DEPTH       )
    )
    uart_controller_sructural_inst
    (
        .axi_clk_i         (axi_clk         ),    
        .axi_a_rst_n_i     (axi_a_rst_n     ),
                      
        .s_axi_awaddr_i     (s_axi_awaddr   ),
        .s_axi_awprot_i     (s_axi_awprot   ),
        .s_axi_awvalid_i    (s_axi_awvalid  ),
        .s_axi_awready_o    (s_axi_awready  ),
                        
        .s_axi_wdata_i      (s_axi_wdata    ),
        .s_axi_wstrb_i      (s_axi_wstrb    ),
        .s_axi_wvalid_i     (s_axi_wvalid   ),
        .s_axi_wready_o     (s_axi_wready   ),
                      
        .s_axi_bresp_o      (s_axi_bresp    ),
        .s_axi_bvalid_o     (s_axi_bvalid   ),
        .s_axi_bready_i     (s_axi_bready   ),
                        
        .s_axi_araddr_i     (s_axi_araddr   ),
        .s_axi_arprot_i     (s_axi_arprot   ),
        .s_axi_arvalid_i    (s_axi_arvalid  ),
        .s_axi_arready_o    (s_axi_arready  ),
                        
        .s_axi_rdata_o      (s_axi_rdata    ),
        .s_axi_rresp_o      (s_axi_rresp    ),
        .s_axi_rvalid_o     (s_axi_rvalid   ),
        .s_axi_rready_i     (s_axi_rready   ),
     
        .tx_enable_o        (tx_enable      ),                   
        .tx_data_o          (tx_data        ),
        
        .data_bit_num_o     (data_bit_num   ),
        .stop_bit_num_o     (stop_bit_num   ),
        .baud_tick_val_o    (baud_tick_value),
        
        .start_complete_i   (start_complete ),  
        .data_complete_i    (data_complete  ),
        .tx_complete_i      (tx_complete    )
    );
    
    uart_tx_structural #
    (
        .DATA_WIDTH             (PACK_BIT_NUM_MAX_VALUE),
        .BAUD_GEN_CNTER_MAX_VAL (BAUD_GEN_CNTER_MAX_VAL)
    )
    uart_tx_structural_inst
    (
        .clk_i             (axi_clk        ),
        .s_rst_n_i         (axi_a_rst_n    ),
        .enable_i          (tx_enable      ),
        
        .piso_data_i       (tx_data        ), 
        .data_bit_num_i    (data_bit_num   ),
        .stop_bit_num_i    (stop_bit_num   ),
        .baud_tick_val_i   (baud_tick_value),
        
        .start_complete_o  (start_complete ),
        .data_complete_o   (data_complete  ),
        .tx_complete_o     (tx_complete    ),

        .tx_o              (tx             )
    );
endmodule























