/*--------------------------------------------------
| engineer : A. Shimko
|
| module   : uart_tx.sv
|
| testbench: uart_tx_tb.sv
|
| brief    :
|
| todo     :
|
| 15.04.22 : add (uart_tx.sv): created
| 28.04.22 : add (uart_tx.sv): added fifo
|            
|            1. added FIFO_ADDR_WIDTH to the parameters
|            2. added data_valid_i, busy_o and fifo_rd_en to the signals
|
| 28.04.22 : add (uart_tx.sv): and_2 for uart_ctrl_en 
|
*/

/*
uart_tx #
(
    .BD_GEN_MAX_VAL (), // default: 8
    .DATA_WIDTH     ()  // default: 8
)
uart_tx_inst
(
    .clk_i            (),
    .s_rst_n_i        (),

    .en_i             (),

    .data_bit_num_i   (), // width: 8
    .stop_bit_num_i   (),
    .baud_rate_val_i  (), // width: $clog2(BAUD_GEN_MAX_VAL) 

    .data_i           (), // width: 4 
    
    .tx_o             ()
);
*/
 
`timescale 1ns / 1ps

module uart_tx #
(
    parameter integer BAUD_GEN_MAX_VAL = 8, 
    parameter integer MAX_DATA_WIDTH   = 8,
    parameter integer FIFO_ADDR_WIDTH  = 8,

    localparam         PISO_DIRECTION          = "msb_first",
    localparam integer BAUD_GEN_CMP_DATA_WIDTH = $clog2(BAUD_GEN_MAX_VAL),
    localparam integer PACK_SIZE_WIDTH         = 4
)
(
    input  logic                                   clk_i,
    input  logic                                   s_rst_n_i,

    input  logic                                   en_i,

    input  logic [PACK_SIZE_WIDTH - 1 : 0]         data_bit_num_i,
    input  logic                                   stop_bit_num_i,
    input  logic [BAUD_GEN_CMP_DATA_WIDTH - 1 : 0] baud_rate_val_i,
    output logic                                   baud_tick_o,

    input  logic                                   data_valid_i,
    input  logic [MAX_DATA_WIDTH - 1 : 0]          data_i,

    output logic                                   busy_o,
    output logic                                   tx_o
);
    localparam integer MUX_DATA_WIDTH   = 1;
    localparam integer DATA_SIZE_WIDTH  = 4;
    localparam integer FIFO_A_FULL_VAL  = 2;
    localparam integer FIFO_A_EMPTY_VAL = 2;

    logic                                   mux_sel;
    logic                                   cntl_data;
    logic                                   fifo_empty;
    logic                                   ctrl_en;
    logic                                   fifo_rd_en;

    logic                                   piso_ser_data;
    logic                                   piso_wr_en;
    logic                                   piso_cntl_en;
    logic                                   piso_en;
    logic [MAX_DATA_WIDTH - 1 : 0]          piso_parl_data;

    logic                                   baud_tick;
    logic                                   baud_gen_en;
    logic                                   baud_gen_rst_n;

    logic [BAUD_GEN_CMP_DATA_WIDTH - 1 : 0] baud_rate_val;

    sync_fifo #
    (
        .DATA_WIDTH       (MAX_DATA_WIDTH  ),
        .ADDR_WIDTH       (FIFO_ADDR_WIDTH ),

        .RAM_TYPE         ("distributed"   ),

        .ALMOST_FULL_VAL  (FIFO_A_FULL_VAL ),
        .ALMOST_EMPTY_VAL (FIFO_A_EMPTY_VAL)
    )
    sync_fifo_inst                         
    (
        .clk_i          (clk_i         ),
        .s_rst_n_i      (s_rst_n_i     ),

        .wr_en_i        (data_valid_i),
        .wr_data_i      (data_i        ),
        .almost_full_o  (),
        .full_o         (busy_o        ),

        .rd_en_i        (fifo_rd_en    ),
        .rd_data_o      (piso_parl_data),
        .almost_empty_o (),
        .empty_o        (fifo_empty    )
    );


    mux_2 # 
    (
        .DATA_WIDTH (MUX_DATA_WIDTH)
    )
    mux_2_inst                         
    (
        .data_0_i (cntl_data    ),
        .data_1_i (piso_ser_data),
    
        .select_i (mux_sel      ),
    
        .data_o   (tx_o         )
    );


    and_2
    and_2_piso_en
    (
        .data_0_i (baud_tick   ),
        .data_1_i (piso_cntl_en),

        .data_o   (piso_en     )
    );


    and_2
    and_2_uart_ctrl_en
    (
        .data_0_i (en_i              ),
        .data_1_i (fifo_empty == 1'b0),

        .data_o   (ctrl_en           )
    );


    and_2 
    and_2_baud_gen_rst_n
    (
        .data_0_i (s_rst_n_i        ),
        .data_1_i (baud_tick == 1'b0),

        .data_o   (baud_gen_rst_n   ) 
    );


    piso # 
    (
        .DATA_WIDTH (MAX_DATA_WIDTH),
        .DIRECTION  (PISO_DIRECTION)
    )
    piso_inst_0                         
    (
        .clk_i        (clk_i         ),
        .s_rst_n_i    (s_rst_n_i     ),
        .en_i         (piso_en       ),

        .wr_en_i      (piso_wr_en && (fifo_empty == 1'b0)   ),
        .data_i       (piso_parl_data), 

        .data_valid_o (              ),
        .data_o       (piso_ser_data )
    );


    comparator_2 #
    (
        .DATA_WIDTH (BAUD_GEN_CMP_DATA_WIDTH)
    )
    comparator_2_inst
    (
        .data_0_i   (baud_rate_val  ),
        .data_1_i   (baud_rate_val_i),

        .eq_or_gt_o (baud_tick      ) 
    );


    counter # 
    (
        .MAX_VALUE (BAUD_GEN_MAX_VAL)
    )
    bd_gen                         
    (
        .clk_i     (clk_i          ),
        .s_rst_n_i (baud_gen_rst_n ),

        .en_i      (baud_gen_en    ),

        .value_o   (baud_rate_val  )
    );

    assign baud_tick_o = baud_tick;


    uart_tx_ctrl #
    (
        .DATA_SIZE_WIDTH (DATA_SIZE_WIDTH)
    )
    uart_tx_ctrl_inst_0                         
    (
        .clk_i            (clk_i         ),
        .s_rst_n_i        (s_rst_n_i     ),
        .en_i             (ctrl_en       ),

        .baud_tick_i      (baud_tick     ),

        .data_bit_num_i   (data_bit_num_i),
        .stop_bit_num_i   (stop_bit_num_i),
        
        .mux_sel_o        (mux_sel       ),
        .baud_gen_en_o    (baud_gen_en   ),
        .piso_wr_en_o     (piso_wr_en    ),
        .piso_en_o        (piso_cntl_en  ),

        .fifo_rd_en_o     (fifo_rd_en    ),

        .data_o           (cntl_data     )
    );

endmodule