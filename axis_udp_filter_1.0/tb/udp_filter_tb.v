`include "udp_filter.vh"

`define  UDP_PACK_FILE     "/media/shimko/2E0A00DD0A00A445/workspace_vivado_2018_3/ip_space/del/udp_pack.txt"
`define  FILTRED_DATA_FILE "/media/shimko/2E0A00DD0A00A445/workspace_vivado_2018_3/ip_space/del/filtred_data.txt"

`timescale 1ns / 1ps

module udp_filter_tb; 

    localparam integer                      DATA_WIDTH         = 32;
    localparam integer                      BURST_SIZE         = 27;
    localparam integer                      CLOCK_PERIOD       = 100;
    localparam integer                      TKEEP_WIDTH        = DATA_WIDTH / 8;
    localparam [TKEEP_WIDTH - 1 : 0]        TKEEP_VALUE        = {TKEEP_WIDTH{1'h1}};
   
    localparam integer                      PAYLOAD_MAX_SIZE   = 1600;
   
    localparam integer                      COUNTER_DATA_WIDTH = 11; 
    localparam [COUNTER_DATA_WIDTH - 1 : 0] COUNTER_TC_VALUE   = PAYLOAD_MAX_SIZE;
    localparam [47 : 0]                     COUNTER_COUNT_BY   = 48'h4;
    
    localparam [`MAC_WIDTH - 1 : 0]         SWAPPED_MC_ADDRESS = 48'h00350a000201; // 00 53 10 00 02 01
    localparam [`IP_V4_WIDTH -1 : 0]        SWAPPED_IP_ADDRESS = 32'h0a12a8c0;     // 10.18.168.192
    localparam [`UDP_WIDTH - 1 : 0]         SWAPPED_UDP_PORT   = 16'h901f;         // swapped 8080
    
    localparam integer                      DATA_ARRAY_SIZE    = 3;
    
    wire                              m_axis_tvalid;
    wire                              m_axis_tlast;
    wire                              m_axis_tready;
    wire [DATA_WIDTH - 1 : 0]         m_axis_tdata;
    wire [TKEEP_WIDTH - 1 : 0]        m_axis_tkeep;
    
    wire                              wf_axis_tvalid;
    wire                              wf_axis_tlast;
    wire [DATA_WIDTH - 1 : 0]         wf_axis_tdata;
    wire [TKEEP_WIDTH - 1 : 0]        wf_axis_tkeep;
    
    wire                              counter_enable;
    wire                              counter_rst;
    wire [COUNTER_DATA_WIDTH - 1 : 0] counter_value;
    
    reg clk;
    reg rst_n;
    reg enable;
    
    reg wf_axis_tready;
    
    reg [DATA_WIDTH - 1 : 0] filtered_data_array [DATA_ARRAY_SIZE - 1 : 0];
    
    integer i       = 0;
    integer file_dc = 0;
    
    COUNTER_TC_MACRO #
    (
        .COUNT_BY      (COUNTER_COUNT_BY  ),
        .DEVICE        ("7SERIES"         ),
        .DIRECTION     ("UP"              ),
        .RESET_UPON_TC ("TRUE"            ),
        .TC_VALUE      (COUNTER_TC_VALUE  ),
        .WIDTH_DATA    (COUNTER_DATA_WIDTH)
    ) 
    COUNTER_TC_MACRO_inst 
    (
        .Q   (counter_value ),
        .CLK (clk           ),
        .CE  (counter_enable),
        .RST (counter_rst   )
    );
    
    axis_data_generator #
    (
        .AXIS_DATA_WIDTH (DATA_WIDTH    ),
        .AXIS_TKEEP      (TKEEP_VALUE   ),
        .INIT_FILE       (`UDP_PACK_FILE),
        .BURST_SIZE      (BURST_SIZE    )
    )
    axis_data_generator_inst_0
    (
        .clk_i           (clk),
        .s_rst_n_i       (rst_n),
        .enable_i        (enable),                    
                         
        .m_axis_tdata_o  (m_axis_tdata ),
        .m_axis_tkeep_o  (m_axis_tkeep ),
        .m_axis_tvalid_o (m_axis_tvalid),
        .m_axis_tlast_o  (m_axis_tlast ),
        .m_axis_tready_i (m_axis_tready)
    );

    udp_filter #
    ( 
        .STREAM_DATA_WIDTH  (DATA_WIDTH        ),
        .MAC_ADDRESS        (SWAPPED_MC_ADDRESS), // the swapped mac address
        .IP_ADDRESS         (SWAPPED_IP_ADDRESS), // the swapped ip address
        .UDP_PORT           (SWAPPED_UDP_PORT  ), // the swapped udp port number
        .PAYLOAD_MAX_SIZE   (PAYLOAD_MAX_SIZE  ),
        .COUNTER_DATA_WIDTH (COUNTER_DATA_WIDTH)
    )
    udp_filter_dut_0
    (
        .clk_i           (clk),
        .s_rst_n_i       (rst_n),
                         
        .m_axis_tdata_o  (wf_axis_tdata ),
        .m_axis_tkeep_o  (wf_axis_tkeep ), 
        .m_axis_tvalid_o (wf_axis_tvalid),
        .m_axis_tlast_o  (wf_axis_tlast ),
        .m_axis_tready_i (wf_axis_tready),
                         
        .s_axis_tdata_i  (m_axis_tdata  ),
        .s_axis_tkeep_i  (m_axis_tkeep  ),
        .s_axis_tvalid_i (m_axis_tvalid ),
        .s_axis_tlast_i  (m_axis_tlast  ),
        .s_axis_tready_o (m_axis_tready ),
        
        .counter_enable_o (counter_enable),
        .counter_rst_o    (counter_rst   ),
        .counter_value_i  (counter_value ) 
    );
    
    task filter_data; begin
        rst_n          <= 1'h1;
        enable         <= 1'h1;
        wf_axis_tready <= 1'h1;
        @(posedge clk);
        
        wait(wf_axis_tvalid);
        @(posedge clk);
        file_dc = $fopen(`FILTRED_DATA_FILE, "w"); 
        
        if (0 != file_dc) begin
            for (i = 0; 1'h0 == wf_axis_tlast; i = i + 1) begin
                
                filtered_data_array[i] <= wf_axis_tdata;
                @(posedge clk);
            end
            
            filtered_data_array[i] <= wf_axis_tdata;
            @(posedge clk);
            
            $fwrite(file_dc, "%h\n", wf_axis_tdata);

            $fclose(file_dc);
        end
        else begin
            $error($time, " The file open error\n");
        end
    end
    endtask
    
    initial begin
        clk = 1'h0;

        forever begin
            #(CLOCK_PERIOD / 2) clk = !clk;
        end 
    end
    
    initial begin
        rst_n          = 1'h0;
        enable         = 1'h0;
        wf_axis_tready = 1'h0;
        @(posedge clk);
        
        filter_data;

        $display($time, " The test has finished.");  

        $stop();            
    end

endmodule
