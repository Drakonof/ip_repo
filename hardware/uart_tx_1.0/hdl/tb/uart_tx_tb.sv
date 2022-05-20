/*--------------------------------------------------
| engineer : A. Shimko
|
| testbench: uart_tx_tb.sv
|
| module   : uart_tx.sv
| 
| brief    :
|
| todo     : assert, piso_wr_en, piso_en
|
| 15.04.22 : add (uart_tx_ctrl_tb.sv): created
| 29.04.22 : meta (uart_tx_ctrl_tb.sv): meta
|
*/

`timescale 1ns / 1ps

module uart_tx_tb;

    localparam integer                      CLOCK_PERIOD       = 100;
    localparam integer                      TEST_ITER_NUM      = 10000;

    localparam integer                      PACK_SIZE_WIDTH    = 4;
    localparam [PACK_SIZE_WIDTH - 1 : 0]    PACK_SIZE          = ('0 + 4'h8);
    localparam [PACK_SIZE_WIDTH - 1 : 0]    CHECK_CNTR_START   = ('0 + 4'h1);
    localparam [PACK_SIZE_WIDTH - 1 : 0]    CHECK_CNTR_STOP    = ('0 + 4'h9);
    localparam [PACK_SIZE_WIDTH - 1 : 0]    CHECK_CNTR_MAX_VAL = ('0 + 4'h9);

    localparam integer                      BD_TICK_CNTR_WIDTH = 16;

    localparam [BD_TICK_CNTR_WIDTH - 1 : 0] BD_TICK__VAL       = ('0 + 3'h4);

    bit                         clk        = 1'b0;
    bit                         s_rst_n    = 1'b1;
    bit                         en         = 1'b0;
    bit                         bd_tick    = 1'b0;

    //bit                         mux_sel;
    bit                         counter_en;
    bit                         piso_wr_en;
    bit                         piso_en;
    bit                         data_valid;

    bit busy;

    bit baud_tick;

    bit                         ctrl_data;

    bit [8 - 1 : 0] data;
    bit [PACK_SIZE_WIDTH - 1 : 0]    check_coiunter  = '0;
    bit [BD_TICK_CNTR_WIDTH - 1 : 0] bd_tick_counter = '0;

    uart_tx #
    (
        .BAUD_GEN_MAX_VAL   (115200),
        .MAX_DATA_WIDTH     (8),
        .FIFO_ADDR_WIDTH (8)
    )
    uart_tx_dut
    (
        .clk_i            (clk),
        .s_rst_n_i        (s_rst_n),

        .en_i             (en),

        .data_bit_num_i   (8), // width: 8
        .stop_bit_num_i   (0),
        .baud_rate_val_i  (3), // width: $clog2(BD_GEN_MAX_VAL)
        
        .data_valid_i     (data_valid),
        .data_i           (data), // width: 4 

        .baud_tick_o (baud_tick),
        
        .busy_o (busy),
        .tx_o             (ctrl_data)
    );

    initial begin
        forever begin
            #(CLOCK_PERIOD / 2) clk = !clk;
        end 
    end

    // always_ff @(posedge clk) begin
    // 	if(s_rst_n == 1'b0) begin
    // 		bd_tick_counter <= '0;
    // 		bd_tick         <= 1'b0;
    // 	end else if (counter_en == 1'b1) begin
    // 		 if (bd_tick_counter == (BD_TICK__VAL - 2'h2)) begin
    // 		 	bd_tick <= 1'b1;
    // 		 	bd_tick_counter <= bd_tick_counter + 1'b1;
    // 		 end
    // 		 else if (bd_tick_counter == (BD_TICK__VAL - 1)) begin 
    //             bd_tick         <= 1'b0;
    //             bd_tick_counter <= '0;
    // 		 end
    // 		 else begin
    //             bd_tick         <= 1'b0;
    //             bd_tick_counter <= bd_tick_counter + 1'b1;
    // 		 end
    // 	end
    // end

    initial begin
        $display($time, " uart_tx_ctrl_tb: started");

        s_rst_n <= 1'b0;
        data <= 8'h3A;
        @(posedge clk);

        s_rst_n <= 1'h1;
        data_valid <= 1'b1;
        @(posedge clk);

        // data_valid <= 1'b0;

        
        en      <= 1'h1;      


        repeat(TEST_ITER_NUM) begin

            if(!busy) begin
              
               data_valid <= 1'b1;
               data       <= data + 1'b1;
             
            end 
            else
                data_valid <= 1'b0;
            

  
            
            @(posedge clk);
            
           

            
            
            
        end

        $display($time, " uart_tx_ctrl_tb: test passed");
        $display($time, " uart_tx_ctrl_tb: finished");

        $stop();
    end
endmodule