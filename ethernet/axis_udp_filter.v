`timescale 1 ns / 1 ps

module axis_udp_filter #
(
    parameter integer STREAM_DATA_WIDTH = 32,
    parameter [47:0]  MAC_ADDRESS       = 48'h00350a000201,
    parameter [7:0]   IP_PART_1         = 192, 
    parameter [7:0]   IP_PART_2         = 168, 
    parameter [7:0]   IP_PART_3         = 18, 
    parameter [7:0]   IP_PART_4         = 10, 
    parameter integer UDP_PORT          = 8080,
    parameter integer PAYLOAD_MAX_SIZE  = 1600
)
(
	input wire                                    axis_clk    ,
	input wire                                    axis_s_rst_n,
	
	output wire                                   s_axis_tready ,
	input  wire [STREAM_DATA_WIDTH - 1 : 0]       s_axis_tdata  ,
	input  wire [(STREAM_DATA_WIDTH / 8) - 1 : 0] s_axis_tstrb  ,
	input  wire                                   s_axis_tlast  ,
	input  wire                                   s_axis_tvalid ,

	output wire                                   m_axis_tvalid ,
	output wire [STREAM_DATA_WIDTH - 1 : 0]       m_axis_tdata  ,
	output wire [(STREAM_DATA_WIDTH / 8) - 1 : 0] m_axis_tstrb  ,
	output wire                                   m_axis_tlast  ,
	input  wire                                   m_axis_tready

`ifdef DEBUG
	,	
    output wire [15:0]                         dbg,
	output wire [31:0]                         dbg_2
`endif
);

    localparam integer                      COUNTER_DATA_WIDTH  = 11;
    localparam [COUNTER_DATA_WIDTH - 1 : 0] COUNTER_TC_VALUE    = PAYLOAD_MAX_SIZE;
    localparam [47 : 0]                     COUNTER_COUNT_BY    = 48'h4;
    
    localparam [47 : 0]                     SWAPPED_MAC_ADDRESS = {MAC_ADDRESS[23 : 16], MAC_ADDRESS[31 : 24], 
                                                                   MAC_ADDRESS[39 : 32], MAC_ADDRESS[47 : 40], 
                                                                   MAC_ADDRESS[7 : 0],   MAC_ADDRESS[15 : 8]};
                                                                   
    localparam [31 : 0]                     SWAPPED_IP_ADDRESS  = {IP_PART_4,IP_PART_3,IP_PART_2,IP_PART_1};
    localparam [15 : 0]                     SWAPPED_UDP_ADDRESS = {UDP_PORT[7 : 0], UDP_PORT[15 : 8]};
    
    wire                              counter_enable;
    wire                              counter_rst;
    wire [COUNTER_DATA_WIDTH - 1 : 0] counter_value;

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
        .CLK (axis_clk    ),
        .CE  (counter_enable),
        .RST (counter_rst   )
    );

    udp_filter #
    ( 
        .STREAM_DATA_WIDTH  (STREAM_DATA_WIDTH  ),
        .MAC_ADDRESS        (SWAPPED_MAC_ADDRESS),
        .IP_ADDRESS         (SWAPPED_IP_ADDRESS ),
        .UDP_PORT           (SWAPPED_UDP_ADDRESS),
        .PAYLOAD_MAX_SIZE   (PAYLOAD_MAX_SIZE   ),
        .COUNTER_DATA_WIDTH (COUNTER_DATA_WIDTH )
    )
    udp_filter_inst_0
    (
        .clk_i            (axis_clk    ),
        .s_rst_n_i        (axis_s_rst_n),
                          
        .m_axis_tdata_o   (m_axis_tdata  ),
        .m_axis_tkeep_o   (m_axis_tstrb  ),
        .m_axis_tvalid_o  (m_axis_tvalid ),
        .m_axis_tlast_o   (m_axis_tlast  ),
        .m_axis_tready_i  (m_axis_tready ),
                          
        .s_axis_tdata_i   (s_axis_tdata  ),
        .s_axis_tkeep_i   (s_axis_tstrb  ),
        .s_axis_tvalid_i  (s_axis_tvalid ),
        .s_axis_tlast_i   (s_axis_tlast  ),
        .s_axis_tready_o  (s_axis_tready ),
       
        .counter_enable_o (counter_enable),
        .counter_rst_o    (counter_rst   ),
        .counter_value_i  (counter_value )
 
 `ifdef DEBUG    
        ,   
        .dbg              (dbg),
        .dbg_2            (dbg_2)
`endif
    );

endmodule
