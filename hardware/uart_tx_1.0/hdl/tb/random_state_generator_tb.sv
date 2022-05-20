/*--------------------------------------------------
| engineer : A. Shimko
|
| module   : random_state_generator.sv
|
| testbench: random_state_generator_tb.sv
| 
| brief    :
|
| todo     :
| 
| 14.12.21 : created
| 12.03.22 : all '1 constructions were replaced to 1'h1
| 01.04.22 : style: changed dut's i/o_ prefects to _i/o prefixes
|
*/
 
`timescale 1ns / 1ps
 
module random_state_generator_tb;

    localparam integer STATE_0_MIN_VAL = 100;
    localparam integer STATE_0_MAX_VAL = 600;
    localparam integer STATE_1_MIN_VAL = 60;
    localparam integer STATE_1_MAX_VAL = 500;
    
    localparam integer CLOCK_PERIOD    = 100;
    localparam integer TEST_ITER_NUM   = 1000000;

    bit clk     = 1'b0;
    bit s_rst_n = 1'h1;

    bit state;

    random_state_generator # 
    (
        .STATE_0_MIN_VAL (STATE_0_MIN_VAL),
        .STATE_0_MAX_VAL (STATE_0_MAX_VAL),
        .STATE_1_MIN_VAL (STATE_1_MIN_VAL),
        .STATE_1_MAX_VAL (STATE_1_MAX_VAL)
    )
    random_state_generator_dut                         
    (
        .clk_i     (clk    ),
        .s_rst_n_i (s_rst_n),
        
        .state_o   (state  )
    );

    always begin
        #(CLOCK_PERIOD / 2) clk = !clk;
    end

    initial begin
        $display($time, " random_state_generator_tb: started");
        s_rst_n <= '0;
        @(posedge clk);
        
        s_rst_n <= 1'h1;
        @(posedge clk);

        repeat(TEST_ITER_NUM) begin
            @(posedge clk);
        end

        $display($time, " random_state_generator_tb: finished");

        $stop();
    end
endmodule
