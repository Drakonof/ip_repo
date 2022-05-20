/*--------------------------------------------------
| engineer : A. Shimko
|
| module   : piso.sv (parallel in serial out)
|
| testbench: piso_tb.sv
| 
| brief    :
|
| todo     :
| 
| 13.12.21 : add (piso_tb.sv): created
| 12.03.22 : fix (piso_tb.sv): all '1 constructions were replaced to 1'h1
| 18.03.22 : fix (piso_tb.sv): replaced a ternary increment/decrement for the i variable to the if/else statment
| 01.04.22 : review (piso_tb.sv): changed dut's i/o_ prefects to _i/o prefixes
| 01.04.22 : fix (piso_tb.sv): changed dut's parameters
|
|            1. removed DO_FAST parameter
|            2. renamed DO_MSB_FIRST to DIRECTION
|            3. renamed DIRECTION cases ("true" and "false") to "msb_first", "lsb_first"
| 18.04.22 : fix (piso_tb.sv): adjusted for moved data_o to continuous assesign
|
|            1. removed @(posedge clk) between wait(data_valid) @(posedge clk) and repeat(DATA_WIDTH) in task check_piso
|            2. moved en <= 1'h1 to task check_piso from the initial
|
*/

`timescale 1ns / 1ps

module piso_tb;
    localparam                      DIRECTION    = "msb_first";
    localparam integer              DATA_WIDTH   = 8;
    localparam [DATA_WIDTH - 1 : 0] MAX_VALUE    = ((2 << DATA_WIDTH) - 1);
    localparam integer              CLOCK_PERIOD = 100;
    localparam integer              REPEATS      = 1000;

    bit                      serl_data ;  
    bit                      data_valid; 

    bit                      clk        = '0;                
    bit                      s_rst_n    = 1'h1;
    bit                      en         = '0;

    bit                      wr_en      = '0; 
    bit [DATA_WIDTH - 1 : 0] parl_data  = '0;
    bit [DATA_WIDTH - 1 : 0] comp_data  = '0;

    integer errors = 0;
    integer i      = 0;

    piso #
    (
        .DATA_WIDTH (DATA_WIDTH  ),
        .DIRECTION  (DIRECTION)
    )
    piso_dut
    (
        .clk_i        (clk       ), 
        .s_rst_n_i    (s_rst_n   ),
        .en_i         (en        ), 

        .wr_en_i      (wr_en     ),
        .data_i       (parl_data ),

        .data_valid_o (data_valid),            
        .data_o       (serl_data )
    );

    task check_piso; begin
        repeat(REPEATS) begin
            comp_data = $urandom % MAX_VALUE;

            wr_en     <= 1'h1;
            parl_data <= comp_data;
            @(posedge clk);
            
            en        <= 1'h1;
            wr_en     <= '0;
            i         = (DIRECTION == "msb_first") ? DATA_WIDTH - 1 : 0;
            wait(data_valid) @(posedge clk);

            repeat(DATA_WIDTH) begin 
            
                if (serl_data != comp_data[i]) begin
                    errors++;
                    $display($time, "An error ocurred. A data bit is: %b, but have to be %b\n", serl_data, comp_data[i]);
                end 

                if (DIRECTION == "msb_first") begin
                    --i;
                end 
                else begin
                    ++i;
                end
                
                @(posedge clk);
            end
        end
    end
    endtask

    always begin
        #(CLOCK_PERIOD / 2) clk = !clk;
    end   

    initial begin
        $display($time, " piso_tb: started");
        s_rst_n   <= '0;

        wr_en     <= '0;
        parl_data <= '0;
        @(posedge clk);

        s_rst_n   <= 1'h1;
        
        @(posedge clk);

        check_piso;

        if (errors == 0) begin
            $display($time, " piso_tb: test passed");
        end 
        else begin
            $display($time, " piso_tb: test failed with %d errors", errors);
        end
        
        $display($time, " piso_tb: finished");

        $stop();
    end 
endmodule