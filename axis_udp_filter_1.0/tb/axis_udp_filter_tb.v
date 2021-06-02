`include "udp_filter.vh"

`timescale 1ns / 1ps

`define  UDP_PACK_FILE     "./udp_pack.txt"
`define  FILTRED_DATA_FILE "/./filtred_data.txt"

module axis_udp_filter_tb; 

    localparam integer               DATA_WIDTH       = 32;
    localparam integer               BURST_SIZE       = 27;
    localparam integer               CLOCK_PERIOD     = 100;
    localparam integer               TKEEP_WIDTH      = DATA_WIDTH / 8;
    localparam [TKEEP_WIDTH - 1 : 0] TKEEP_VALUE      = {TKEEP_WIDTH{1'h1}};

    localparam integer               PAYLOAD_MAX_SIZE = 1600;
    localparam [`MAC_WIDTH - 1 : 0]  MAC_ADDRESS      = 48'h000a35000102; // 00 10 53 00 01 02
    localparam [`IP_V4_WIDTH -1 : 0] IP_ADDRESS       = 32'hc0a8120a;     // 192.168.18.10
    localparam [`UDP_WIDTH - 1 : 0]  UDP_PORT         = 16'h1f90;         // 8080
    
    localparam integer               DATA_ARRAY_SIZE    = 3;
    
    wire                              m_axis_tvalid;
    wire                              m_axis_tlast;
    wire                              m_axis_tready;
    wire [DATA_WIDTH - 1 : 0]         m_axis_tdata;
    wire [TKEEP_WIDTH - 1 : 0]        m_axis_tkeep;
    
    wire                              wf_axis_tvalid;
    wire                              wf_axis_tlast;
    wire [DATA_WIDTH - 1 : 0]         wf_axis_tdata;
    wire [TKEEP_WIDTH - 1 : 0]        wf_axis_tkeep;
    
    reg clk;
    reg rst_n;
    reg enable;
    
    reg wf_axis_tready;
    
    reg [DATA_WIDTH - 1 : 0] filtered_data_array [DATA_ARRAY_SIZE - 1 : 0];
    
    integer i       = 0;
    integer file_dc = 0;
    
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

    axis_udp_filter #
    (            
        .STREAM_DATA_WIDTH (DATA_WIDTH       ),              
        .MAC_ADDRESS       (MAC_ADDRESS      ),
        .IP_PART_1         (IP_ADDRESS[31:24]),             
        .IP_PART_2         (IP_ADDRESS[23:16]),             
        .IP_PART_3         (IP_ADDRESS[15:8] ),              
        .IP_PART_4         (IP_ADDRESS[7:0]  ),               
        .UDP_PORT          (UDP_PORT         ),            
        .PAYLOAD_MAX_SIZE  (PAYLOAD_MAX_SIZE ) 
    )
    axis_udp_filter_dut_0
    (
        .axis_clk      (clk),
        .axis_s_rst_n  (rst_n),
                         
        .m_axis_tdata  (wf_axis_tdata ),
        .m_axis_tvalid (wf_axis_tvalid),
        .m_axis_tlast  (wf_axis_tlast ),
        .m_axis_tready (wf_axis_tready),
                         
        .s_axis_tdata  (m_axis_tdata  ),
        .s_axis_tvalid (m_axis_tvalid ),
        .s_axis_tlast  (m_axis_tlast  ),
        .s_axis_tready (m_axis_tready ) 
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
