/*--------------------------------------------------
| engineer : A. Shimko
|
| module   : sync_fifo.sv
|
| testbench: sync_fifo_tb.sv
| 
| brief    :
|
| todo     :
| 
| 15.12.21 : add: created
| 12.03.22 : fix: all '1 constructions were replaced to 1'h1
| 18.03.22 : fix: removed a xilinx platform preprocessor
| 01.04.22 : fix: fully rewritten corresponding the dut
| 01.04.22 : fix: all '1 and '0 constructions were replaced to 1'b1 and 1'b0 for single signals
|
*/

`timescale 1ns / 1ps

module sync_fifo_tb;

    localparam integer DATA_WIDTH            = 8;
    localparam integer ADDR_WIDTH            = 8;
    localparam integer ALMOST_FULL_VAL       = 2;
    localparam integer ALMOST_EMPTY_VAL      = 2;

    localparam         RAM_TYPE              = "distributed"; // "distributed", "block"

    localparam integer WR_SL_STATE_0_MIN_VAL = 154;
    localparam integer WR_SL_STATE_0_MAX_VAL = 359;
    localparam integer WR_SL_STATE_1_MIN_VAL = 85;
    localparam integer WR_SL_STATE_1_MAX_VAL = 531;

    localparam integer WR_FS_STATE_0_MIN_VAL = 53;
    localparam integer WR_FS_STATE_0_MAX_VAL = 115;
    localparam integer WR_FS_STATE_1_MIN_VAL = 26;
    localparam integer WR_FS_STATE_1_MAX_VAL = 82;

    localparam integer RD_SL_STATE_0_MIN_VAL = 125;
    localparam integer RD_SL_STATE_0_MAX_VAL = 276;
    localparam integer RD_SL_STATE_1_MIN_VAL = 91;
    localparam integer RD_SL_STATE_1_MAX_VAL = 489;

    localparam integer RD_FS_STATE_0_MIN_VAL = 93;
    localparam integer RD_FS_STATE_0_MAX_VAL = 242;
    localparam integer RD_FS_STATE_1_MIN_VAL = 67;
    localparam integer RD_FS_STATE_1_MAX_VAL = 114;

    localparam integer CLOCK_PERIOD          = 100;
    localparam integer TEST_ITER_NUM         = 1000000;

    localparam integer FIFO_DEPTH            = 2 ** ADDR_WIDTH;  
    localparam integer FILE_INITIAL          = CLOCK_PERIOD * FIFO_DEPTH;

    bit                      clk          = 1'b0;
    bit                      s_rst_n      = 1'b0;
    bit                      wr_en ;
    bit                      rd_en;
    bit [DATA_WIDTH - 1 : 0] wr_data      = '0;

    bit                      almost_full;
    bit                      full;
    bit                      almost_empty;
    bit                      empty;
    bit [DATA_WIDTH - 1 : 0] rd_data;

    bit                      wr_slow_state;
    bit                      wr_fast_state;

    bit                      rd_slow_state;
    bit                      rd_fast_state;

    bit                      en;

    bit [DATA_WIDTH - 1 : 0] rd_counter = '0;
    integer errors = 0;

    always_comb begin
        wr_en = wr_slow_state && wr_fast_state && en && (full == 1'b0); 
        rd_en = rd_slow_state && rd_fast_state && en && (empty == 1'b0);
    end 

    sync_fifo #
    (
        .DATA_WIDTH       (DATA_WIDTH      ),
        .ADDR_WIDTH       (ADDR_WIDTH      ),
        .RAM_TYPE         (RAM_TYPE        ),    

        .ALMOST_FULL_VAL  (ALMOST_FULL_VAL ),
        .ALMOST_EMPTY_VAL (ALMOST_EMPTY_VAL)
    )
    sync_fifo_dut
    ( 
        .clk_i          (clk         ),
        .s_rst_n_i      (s_rst_n     ),

        .wr_en_i        (wr_en       ),
        .wr_data_i      (wr_data     ),
        .almost_full_o  (almost_full ),
        .full_o         (full        ),

        .rd_en_i        (rd_en       ),
        .rd_data_o      (rd_data     ),
        .almost_empty_o (almost_empty),
        .empty_o        (empty       )
    );

    random_state_generator #
    (
        .STATE_0_MIN_VAL (WR_SL_STATE_0_MIN_VAL), 
        .STATE_0_MAX_VAL (WR_SL_STATE_0_MAX_VAL), 
        .STATE_1_MIN_VAL (WR_SL_STATE_1_MIN_VAL), 
        .STATE_1_MAX_VAL (WR_SL_STATE_1_MAX_VAL)
    )
    wr_slow_state_generator
    (
        .clk_i     (clk          ), 
        .s_rst_n_i (s_rst_n      ),
        .state_o   (wr_slow_state)
    );

    random_state_generator #
    (
        .STATE_0_MIN_VAL (WR_FS_STATE_0_MIN_VAL), 
        .STATE_0_MAX_VAL (WR_FS_STATE_0_MAX_VAL), 
        .STATE_1_MIN_VAL (WR_FS_STATE_1_MIN_VAL), 
        .STATE_1_MAX_VAL (WR_FS_STATE_1_MAX_VAL)
    )
    wr_fast_state_generator
    (
        .clk_i     (clk          ), 
        .s_rst_n_i (s_rst_n      ),
        .state_o   (wr_fast_state)
    );

    random_state_generator #
    (
        .STATE_0_MIN_VAL (RD_SL_STATE_0_MIN_VAL), 
        .STATE_0_MAX_VAL (RD_SL_STATE_0_MAX_VAL), 
        .STATE_1_MIN_VAL (RD_SL_STATE_1_MIN_VAL), 
        .STATE_1_MAX_VAL (RD_SL_STATE_1_MAX_VAL)
    )
    rd_slow_state_generator
    (
        .clk_i     (clk          ), 
        .s_rst_n_i (s_rst_n      ),
        .state_o   (rd_slow_state)
    );

    random_state_generator #
    (
        .STATE_0_MIN_VAL (RD_FS_STATE_0_MIN_VAL), 
        .STATE_0_MAX_VAL (RD_FS_STATE_0_MAX_VAL), 
        .STATE_1_MIN_VAL (RD_FS_STATE_1_MIN_VAL), 
        .STATE_1_MAX_VAL (RD_FS_STATE_1_MAX_VAL)
    )
    rd_fast_state_generator
    (
        .clk_i     (clk          ), 
        .s_rst_n_i (s_rst_n      ),
        .state_o   (rd_fast_state)
    );

    always_ff @ (posedge clk) begin
        if(wr_en == 1'b1) begin
            wr_data <= wr_data + 1'h1;
        end
    end

    always_ff @ (posedge clk) begin
        if (rd_en == 1'b1) begin
            if (rd_counter != rd_data)  begin
                errors++;
            end

            rd_counter <= rd_counter + 1'h1;
        end
    end

    always begin
        #(CLOCK_PERIOD / 2) clk = !clk;
    end

    initial begin
        $display($time, " sync_fifo_tb: started");
        s_rst_n <= 1'b0;
        en      <= 1'b0;
        @(posedge clk);

        s_rst_n <= 1'b1;
        en      <= 1'b1;
        repeat (TEST_ITER_NUM) begin
            @(posedge clk);
        end

        if (errors == 0) begin
            $display($time, " sync_fifo_tb: test passed");
        end
        else begin
            $display($time, " sync_fifo_tb: test failed with %d errors", errors);
        end

        $display($time, " sync_fifo_tb: finished");

        $stop();
    end
endmodule
