/*--------------------------------------------------
| engineer : A. Shimko
|
| testbench: uart_tx_ctrl_tb.sv
|
| module   : uart_tx_ctrl_tb.sv
| 
| brief    :
|
| todo     : assert, piso_wr_en, piso_en
|
| 15.04.22 : add (uart_tx_ctrl_tb.sv): created
| 19.04.22 : fix (uart_tx_ctrl_tb.sv): changed names of signals of the dut
| 19.04.22 : add (uart_tx_ctrl_tb.sv): added stop bit number
|
*/

`timescale 1ns / 1ps

module uart_tx_ctrl_tb;

    localparam integer                      CLOCK_PERIOD       = 100;
    localparam integer                      TEST_ITER_NUM      = 1000;

    localparam integer                      DATA_SIZE_WIDTH    = 4;
    localparam [DATA_SIZE_WIDTH - 1 : 0]    PACK_SIZE          = ('0 + 4'h8);
    localparam [DATA_SIZE_WIDTH - 1 : 0]    CHECK_CNTR_START   = ('0 + 4'h1);
    localparam [DATA_SIZE_WIDTH - 1 : 0]    CHECK_CNTR_STOP    = ('0 + 4'h9);
    localparam [DATA_SIZE_WIDTH - 1 : 0]    CHECK_CNTR_MAX_VAL = ('0 + 4'h9);

    localparam integer                      BD_TICK_CNTR_WIDTH = 16;

    localparam [BD_TICK_CNTR_WIDTH - 1 : 0] BD_TICK__VAL       = ('0 + 3'h4);
    localparam [0 : 0]                      STOP_BIT_NUM       = 1'b0;

    bit                         clk        = 1'b0;
    bit                         s_rst_n    = 1'b1;
    bit                         en         = 1'b0;
    bit                         bd_tick    = 1'b0;

    bit                         mux_sel;
    bit                         counter_en;
    bit                         piso_wr_en;
    bit                         piso_en;

    bit                         ctrl_data;

    bit [DATA_SIZE_WIDTH - 1 : 0]    check_coiunter  = '0;
    bit [BD_TICK_CNTR_WIDTH - 1 : 0] bd_tick_counter = '0;

    uart_tx_ctrl #
    (
        .DATA_SIZE_WIDTH (DATA_SIZE_WIDTH)
    )
    uart_tx_ctrl_dut
    (
        .clk_i          (clk            ),
        .s_rst_n_i      (s_rst_n        ),

        .en_i           (en             ),

        .baud_tick_i    (bd_tick        ),

        .data_bit_num_i (8),
        .stop_bit_num_i (STOP_BIT_NUM   ),
    
        .mux_sel_o      (mux_sel        ),
        .baud_gen_en_o  (counter_en     ),
        .piso_wr_en_o   (piso_wr_en     ),
        .piso_en_o      (piso_en        ),

        .data_o         (ctrl_data      )
    );

    initial begin
        forever begin
            #(CLOCK_PERIOD / 2) clk = !clk;
        end 
    end

    always_ff @(posedge clk) begin
    	if(s_rst_n == 1'b0) begin
    		check_coiunter <= '0;
    	end else if ((bd_tick == 1'b0) && (counter_en == 1'b1)) begin
    		 if (check_coiunter == CHECK_CNTR_MAX_VAL) begin
    		 	check_coiunter <= '0;
    		 end else begin
                check_coiunter <= check_coiunter + 1'b1;
    		 end
    	end
    end

    always_ff @(posedge clk) begin
    	if(s_rst_n == 1'b0) begin
    		bd_tick_counter <= '0;
    		bd_tick         <= 1'b0;
    	end else if (counter_en == 1'b1) begin
    		 if (bd_tick_counter == (BD_TICK__VAL - 2'h2)) begin
    		 	bd_tick <= 1'b1;
    		 	bd_tick_counter <= bd_tick_counter + 1'b1;
    		 end
    		 else if (bd_tick_counter == (BD_TICK__VAL - 1)) begin 
                bd_tick         <= 1'b0;
                bd_tick_counter <= '0;
    		 end
    		 else begin
                bd_tick         <= 1'b0;
                bd_tick_counter <= bd_tick_counter + 1'b1;
    		 end
    	end
    end

    initial begin
        $display($time, " uart_tx_ctrl_tb: started");

        s_rst_n <= 1'b0;
        @(posedge clk);
        @(posedge clk);

        if (ctrl_data != 1'b1) begin
            $error($time, "error: ctrl_data != 1'b1");
            $display($time, " uart_tx_ctrl_tb: test failed");
     //       $stop();
        end

        s_rst_n <= 1'h1;
        en      <= 1'h1;
        @(posedge clk);


        repeat(TEST_ITER_NUM) begin
            if ((check_coiunter == CHECK_CNTR_START) 
                && (ctrl_data != 0)  
                && (mux_sel == 1'b0)) begin
                $error($time, " error: ctrl_data != 0");
                $display($time, " uart_tx_ctrl_tb: test failed");
     //           $stop();
            end else if ((check_coiunter == CHECK_CNTR_STOP) 
                          && (ctrl_data != 1'b1)
                          && (mux_sel == 1'b0)) begin
                $error($time, " error: ctrl_data != 0");
                $display($time, " uart_tx_ctrl_tb: test failed");
      //          $stop();
            end 

            @(posedge clk);
        end

        $display($time, " uart_tx_ctrl_tb: test passed");
        $display($time, " uart_tx_ctrl_tb: finished");

        $stop();
    end
endmodule