`timescale 1ns / 1ps

`define MEM_FILE_0   "/media/shimko/2E0A00DD0A00A445/workspace_vivado_2018_3/ip_space/etc/dds_0.mem"
`define MEM_FILE_2   "/media/shimko/2E0A00DD0A00A445/workspace_vivado_2018_3/ip_space/etc/dds_2.mem"

module dds_tb;

    localparam integer                        CLOCK_PERIOD         = 100                                  ;
    localparam integer                        ITERATION_NUM        = 4 * 1000000                          ;

    localparam integer                        DATA_WIDTH           = 16                                   ;
    localparam integer                        LUT_INDEX_REST       = 14                                   ;
   
    localparam integer                        ROM_DEPTH_0          = 1024                                 ;
    localparam integer                        PHASE_OFFSET_WIDTH_0 = 10                                   ;
    localparam integer                        FCW_WIDTH_0          = PHASE_OFFSET_WIDTH_0 + LUT_INDEX_REST;
    localparam [FCW_WIDTH_0 - 1 : 0]          PI_0                 = 10'h200                              ;
    localparam [FCW_WIDTH_0 - 1 : 0]          SINE_FREQ_0          = {FCW_WIDTH_0{1'h0}} + 9'h100         ;
    localparam [PHASE_OFFSET_WIDTH_0 - 1 : 0] PHASE_OFFSET_0       = {PHASE_OFFSET_WIDTH_0{1'h0}}         ;
    localparam [PHASE_OFFSET_WIDTH_0 - 1 : 0] PHASE_OFFSET_1       = {PHASE_OFFSET_WIDTH_0{1'h0}} + PI_0  ;       
   
    localparam integer                        ROM_DEPTH_2          = 512                                  ;
    localparam integer                        PHASE_OFFSET_WIDTH_2 = 9                                    ;
    localparam integer                        FCW_WIDTH_2          = PHASE_OFFSET_WIDTH_2 + LUT_INDEX_REST;
    localparam [FCW_WIDTH_0 - 1 : 0]          PI_2                 = 9'h100                               ;
    localparam [FCW_WIDTH_0 - 1 : 0]          SINE_FREQ_2          = {FCW_WIDTH_0{1'h0}} + 13'h1000       ;
    localparam [PHASE_OFFSET_WIDTH_0 - 1 : 0] PHASE_OFFSET_2       = {PHASE_OFFSET_WIDTH_2{1'h0}}         ; 
    localparam [PHASE_OFFSET_WIDTH_0 - 1 : 0] PHASE_OFFSET_3       = {PHASE_OFFSET_WIDTH_2{1'h0}} + PI_2  ; 
    
    wire [DATA_WIDTH - 1 : 0] sinus_0;
    wire [DATA_WIDTH - 1 : 0] sinus_1;
    wire [DATA_WIDTH - 1 : 0] sinus_2;
    wire [DATA_WIDTH - 1 : 0] sinus_3;

    reg                       clk               = 1'h0;
    reg                       s_rst_n           = 1'h0;
    reg                       en                = 1'h0;
    reg                       phase_offset_wr_0 = 1'h0;
    reg                       phase_offset_wr_1 = 1'h0;
    reg                       phase_offset_wr_2 = 1'h0;
    reg                       phase_offset_wr_3 = 1'h0;
    reg [FCW_WIDTH_0 - 1 : 0] fcw_0             = SINE_FREQ_0;
    reg [FCW_WIDTH_0 - 1 : 0] fcw_1             = SINE_FREQ_0;
    reg [FCW_WIDTH_2 - 1 : 0] fcw_2             = SINE_FREQ_2;
    reg [FCW_WIDTH_2 - 1 : 0] fcw_3             = SINE_FREQ_2;
    
    reg [PHASE_OFFSET_WIDTH_0 - 1 : 0] phase_offset_0 = PHASE_OFFSET_0; 
    reg [PHASE_OFFSET_WIDTH_0 - 1 : 0] phase_offset_1 = PHASE_OFFSET_1; 
    reg [PHASE_OFFSET_WIDTH_2 - 1 : 0] phase_offset_2 = PHASE_OFFSET_2; 
    reg [PHASE_OFFSET_WIDTH_2 - 1 : 0] phase_offset_3 = PHASE_OFFSET_3;

    dds # 
    ( 
        .DATA_WIDTH         (DATA_WIDTH          ),
        .ROM_DEPTH          (ROM_DEPTH_0         ),
        .INIT_FILE          (`MEM_FILE_0         ),
        .FCW_WIDTH          (FCW_WIDTH_0         ),
        .PHASE_OFFSET_WIDTH (PHASE_OFFSET_WIDTH_0)
    )
    sinus_generator_dut_0
    (
        .clk_i             (clk              ),
        .s_rst_n_i         (s_rst_n          ),
        .en_i              (en               ),
       
        .fcw_i             (fcw_0            ),
        .phase_offset_i    (phase_offset_0   ),
        .phase_offset_wr_i (phase_offset_wr_0),
        .sinus_o           (sinus_0          )
    );
    
    dds # 
    ( 
        .DATA_WIDTH         (DATA_WIDTH          ),
        .ROM_DEPTH          (ROM_DEPTH_0         ),
        .INIT_FILE          (`MEM_FILE_0         ),
        .FCW_WIDTH          (FCW_WIDTH_0         ),
        .PHASE_OFFSET_WIDTH (PHASE_OFFSET_WIDTH_0)
    )
    sinus_generator_dut_1
    (
        .clk_i             (clk              ),
        .s_rst_n_i         (s_rst_n          ),
        .en_i              (en               ),
     
        .fcw_i             (fcw_1            ),
        .phase_offset_i    (phase_offset_1   ),
        .phase_offset_wr_i (phase_offset_wr_1),
        .sinus_o           (sinus_1          )    
    );    
    
    dds # 
    ( 
        .DATA_WIDTH         (DATA_WIDTH          ),
        .ROM_DEPTH          (ROM_DEPTH_2         ),
        .INIT_FILE          (`MEM_FILE_2         ),
        .FCW_WIDTH          (FCW_WIDTH_2         ),
        .PHASE_OFFSET_WIDTH (PHASE_OFFSET_WIDTH_2)
    )
    sinus_generator_dut_2
    (
        .clk_i             (clk              ),
        .s_rst_n_i         (s_rst_n          ),
        .en_i              (en               ),
     
        .fcw_i             (fcw_2            ),
        .phase_offset_i    (phase_offset_2   ),
        .phase_offset_wr_i (phase_offset_wr_2),
        .sinus_o           (sinus_2          )    
    );                                   
    
    dds # 
    ( 
        .DATA_WIDTH         (DATA_WIDTH          ),
        .ROM_DEPTH          (ROM_DEPTH_2         ),
        .INIT_FILE          (`MEM_FILE_2         ),
        .FCW_WIDTH          (FCW_WIDTH_2         ),
        .PHASE_OFFSET_WIDTH (PHASE_OFFSET_WIDTH_2)
    )
    sinus_generator_dut_3
    (
        .clk_i             (clk              ),
        .s_rst_n_i         (s_rst_n          ),
        .en_i              (en               ),
     
        .fcw_i             (fcw_3            ),
        .phase_offset_i    (phase_offset_3   ),
        .phase_offset_wr_i (phase_offset_wr_3),
        .sinus_o           (sinus_3          )    
    );
    
    initial begin
        forever begin
            #(CLOCK_PERIOD / 2) clk = !clk;
        end 
    end

    initial begin
        @(posedge clk);
        
        s_rst_n <= 1'h1;
        en      <= 1'h1;
        @(posedge clk);
        
       repeat(ITERATION_NUM) begin
           @(posedge clk);  
       end
       
       phase_offset_wr_0 <= 1'h1;
       phase_offset_0    <= PHASE_OFFSET_1;
       phase_offset_wr_2 <= 1'h1;
       phase_offset_2    <= PHASE_OFFSET_3;
       @(posedge clk);
       phase_offset_wr_0 <= 1'h0;
       phase_offset_wr_2 <= 1'h0;
       
       repeat(ITERATION_NUM) begin
           @(posedge clk);  
       end

        $stop();
    end

endmodule
