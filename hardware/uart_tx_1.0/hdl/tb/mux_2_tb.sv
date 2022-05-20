/*--------------------------------------------------
| engineer : A. Shimko
|
| testbench: mux_2_tb.sv
|
| module   : mux_2.sv
| 
| brief    :
|
| todo     :
| 
| 12.04.22 : add(mux_2_tb.sv): first commit
|
*/

`timescale 1ns / 1ps

module mux_2_tb;

    localparam integer DATA_WIDTH     = 8;
    localparam integer COUNTER_WIDTH = $clog2(DATA_WIDTH);

    localparam integer RG_STATE_0_MIN_VAL = 5;
    localparam integer RG_STATE_0_MAX_VAL = 8;
    localparam integer RG_STATE_1_MIN_VAL = 7;
    localparam integer RG_STATE_1_MAX_VAL = 11;

    localparam integer CLOCK_PERIOD       = 100;
    localparam integer REPEAT_VAL         = 10000;

    bit                      clk       = 1'b0;
    bit                      s_rst_n   = 1'b0;
    bit                      rg_state;

    bit [DATA_WIDTH - 1 : 0] data_out  = '0;

    bit [DATA_WIDTH - 1 : 0] counter_0   = '0;
    bit [DATA_WIDTH - 1 : 0] counter_1   = '0;

    random_state_generator # 
    (
        .STATE_0_MIN_VAL (RG_STATE_0_MIN_VAL),
        .STATE_0_MAX_VAL (RG_STATE_0_MAX_VAL),
        .STATE_1_MIN_VAL (RG_STATE_1_MIN_VAL),
        .STATE_1_MAX_VAL (RG_STATE_1_MAX_VAL)
    )
    random_state_generator_inst                         
    (
        .clk_i     (clk     ),
        .s_rst_n_i (s_rst_n ),

        .state_o   (rg_state)
    );

    mux_2 #
    (
        .DATA_WIDTH (DATA_WIDTH)
    )
    mux_2_dut
    (
        .data_0_i (counter_0),
        .data_1_i (counter_1),

        .select_i (rg_state ),
    
        .data_o   (data_out )
    );

    always begin
        #(CLOCK_PERIOD / 2) clk = !clk;
    end

    always_ff @ (posedge clk) begin
        if (s_rst_n == 1'b0) begin
            counter_0 <= '0;
            counter_1 <= '0;
        end else begin
            if (rg_state == 1'b1) begin
                counter_1 <= counter_1 + 2'h2;
            end else begin
                counter_0 <= counter_0 + 1'b1;
            end
        end
    end

    initial begin
        $display($time, " mux_2_tb: started");

        s_rst_n <= '0;
        @(posedge clk);

        s_rst_n <= 1'h1;

        repeat(REPEAT_VAL) begin
            @(posedge clk);
        end

        $display($time, " mux_2_tb: finished");

        $stop();
    end

endmodule
