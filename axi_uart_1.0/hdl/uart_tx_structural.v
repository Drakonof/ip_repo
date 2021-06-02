`timescale 1ns / 1ps

module uart_tx_structural #
(
    parameter integer DATA_WIDTH             = 8                             ,
    parameter integer BAUD_GEN_CNTER_MAX_VAL = 512                           ,
    parameter integer BAUD_GEN_CNTER_WIDTH   = $clog2(BAUD_GEN_CNTER_MAX_VAL)
)
(
    input wire                           clk_i           ,
    input wire                           s_rst_n_i       ,
    input wire                           enable_i        ,
    
    input wire [DATA_WIDTH - 1 : 0]      piso_data_i     , 
    input wire                           data_bit_num_i  , 
    input wire                           stop_bit_num_i  ,
    input [BAUD_GEN_CNTER_WIDTH - 1 : 0] baud_tick_val_i ,
    
    output wire                          start_complete_o,
    output wire                          data_complete_o ,
    output wire                          tx_complete_o   ,
    
    output wire                          tx_o
);
    localparam integer DATA_BIT_CNTER_WIDTH = $clog2(DATA_WIDTH);
    
    wire                                baud_tick           ; 
    wire                                baud_gen_cnter_en   ;
    wire                                baud_gen_cnter_rst_n;
    wire [BAUD_GEN_CNTER_WIDTH - 1 : 0] baud_gen_cnter_val  ; 
    
    wire                                data_bit_cnter_en   ;
    wire                                data_bit_cnter_rst_n;
    wire [DATA_BIT_CNTER_WIDTH - 1 : 0] data_bit_cnter_val  ; 
    
    wire                                piso_en             ; 
    wire                                piso_wr_en          ;
    wire                                piso_serial         ;

    counter #
    (
        .MAX_VALUE (BAUD_GEN_CNTER_MAX_VAL)
    )
    baud_gen_cnter_inst
    (
        .clk_i     (clk_i               ),
        
        .en_i      (baud_gen_cnter_en   ),
        .s_rst_n_i (baud_gen_cnter_rst_n),
        
        .val_o     (baud_gen_cnter_val  )
    );
 
    comparator #
    (
        .DATA_WIDTH (BAUD_GEN_CNTER_WIDTH)
    )
    baud_gen_inst
    (
        .data_0_i  (baud_tick_val_i   ),
        .data_1_i  (baud_gen_cnter_val),
              
        .equal_o   (baud_tick         ),
        .greater_o (                  ),
        .lower_o   (                  )
    );

    counter #
    (
        .MAX_VALUE (DATA_WIDTH)
    )
    data_bit_cnter_inst
    (
        .clk_i     (clk_i               ),
        
        .en_i      (data_bit_cnter_en   ),
        .s_rst_n_i (data_bit_cnter_rst_n),
        
        .val_o     (data_bit_cnter_val  )
    );
 
    piso # 
    (
        .DATA_WIDTH   (DATA_WIDTH),
        .DO_MSB_FIRST ("FALSE"   )     
    )
    piso_inst
    (
        .clk_i       (clk_i      ),
        .s_rst_n_i   (s_rst_n_i  ),
        .en_i        (piso_en    ),
                    
        .wr_en_i     (piso_wr_en ),
        .data_i      (piso_data_i),
                    
        .data_o      (piso_serial)
    );
    
    uart_tx #
    (
        .MAX_DATA_BIT_NUM(DATA_WIDTH)
    )
    uart_tx_inst
    (
        .clk_i                  (clk_i               ),
        .s_rst_n_i              (s_rst_n_i           ),
        .enable_i               (enable_i            ),

        .piso_en_o              (piso_en             ),
        .piso_data_we_o         (piso_wr_en          ),
        .piso_serial_i          (piso_serial         ),
        
        .data_bit_cnter_en_o    (data_bit_cnter_en   ),
        .data_bit_cnter_rst_n_o (data_bit_cnter_rst_n),
        .data_bit_num_i         (data_bit_num_i      ),      
        .data_bit_cnter_val_i   (data_bit_cnter_val  ),

        .stop_bit_num_i         (stop_bit_num_i      ),
        
        .baud_gen_cnter_en_o    (baud_gen_cnter_en   ),
        .baud_gen_cnter_rst_n_o (baud_gen_cnter_rst_n),       
        .baud_tick_i            (baud_tick           ),
       
        .start_complete_o       (start_complete_o    ),
        .data_complete_o        (data_complete_o     ),
        .tx_complete_o          (tx_complete_o       ),
        
        .tx_o                   (tx_o                )
    );
endmodule
