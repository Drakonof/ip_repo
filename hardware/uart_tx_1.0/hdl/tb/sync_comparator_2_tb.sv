/*--------------------------------------------------
| engineer : A. Shimko
|
| testbench: sync_comparator_2_tb.sv
|
| module   : sync_sync_comparator_2.sv
|
| brief    :
|
| todo     :
|
| 12.04.22 : add (sync_comparator_2_tb.sv): first commit
| 15.04.22 : add (sync_comparator_2_tb.sv): added s_rst_n_i
|
*/


`timescale 1ns / 1ps

module sync_comparator_2_tb;

    localparam integer DATA_WIDTH    = 8;  
    localparam integer MAX_VALUE     = 2 ** DATA_WIDTH; 

    localparam integer SEED_0        = 10; 
    localparam integer SEED_1        = 11; 

    localparam integer CLOCK_PERIOD  = 100;
    localparam integer TEST_ITER_NUM = 1000000;

    bit                      clk      = 1'b0;
    bit                      s_rst_n  = 1'h1;

    bit                      eq_or_gt = 1'b0;

    bit [DATA_WIDTH - 1 : 0] data_0   = '0;
    bit [DATA_WIDTH - 1 : 0] data_1   = '0;

    integer errors = 0;

    sync_comparator_2 #
    (
        .DATA_WIDTH (DATA_WIDTH)
    )
    sync_comparator_2_dut
    (
        .clk_i      (clk     ),
        .s_rst_n_i  (s_rst_n ),

        .data_0_i   (data_0  ),
        .data_1_i   (data_1  ),

        .eq_or_gt_o (eq_or_gt) 
    );

    always begin
        #(CLOCK_PERIOD / 2) clk = !clk;
    end

    initial begin
        $display($time, " sync_comparator_2_tb: started");

        s_rst_n   <= '0;
        @(posedge clk);

        s_rst_n   <= 1'h1;
        @(posedge clk);

        repeat (TEST_ITER_NUM) begin
            data_0 <= $urandom(SEED_0) % MAX_VALUE;
            data_1 <= $urandom(SEED_1) % MAX_VALUE;

            @(posedge clk);

            @(posedge clk);
            @(posedge clk);

            if (data_0 < data_1) begin
                if (eq_or_gt == 1'b1) begin
                    errors++;
                end
            end else  begin 
                if (eq_or_gt == 1'b0) begin
                    errors++;
                end
            end 
        end

        if (errors == 0) begin
            $display($time, " sync_comparator_2_tb: test passed");
        end
        else begin
            $display($time, " sync_comparator_2_tb: test failed with %d errors", errors);
        end

        $display($time, " sync_comparator_2_tb: finished");

        $stop();
    end
endmodule
