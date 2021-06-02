`timescale 1ns / 1ps

`include "udp_filter.vh"

module udp_filter #
( 
    parameter integer                STREAM_DATA_WIDTH  = 32              ,
    parameter [`MAC_WIDTH - 1 : 0]   MAC_ADDRESS        = 48'h00350a000201,
    parameter [`IP_V4_WIDTH - 1 : 0] IP_ADDRESS         = 32'h0a12a8c0    ,
    parameter [`UDP_WIDTH - 1 : 0]   UDP_PORT           = 16'h901f        ,
    parameter integer                PAYLOAD_MAX_SIZE   = 1600            ,
    parameter integer                COUNTER_DATA_WIDTH = 11
)
(
    input  wire                                    clk_i          ,
    input  wire                                    s_rst_n_i      ,
    
    output wire  [STREAM_DATA_WIDTH - 1 : 0]       m_axis_tdata_o ,
    output wire  [(STREAM_DATA_WIDTH / 8) - 1 : 0] m_axis_tkeep_o ,
    output wire                                    m_axis_tvalid_o,
    output wire                                    m_axis_tlast_o ,
    input  wire                                    m_axis_tready_i,
    
    input  wire  [STREAM_DATA_WIDTH - 1 : 0]       s_axis_tdata_i ,
    input  wire  [(STREAM_DATA_WIDTH / 8) - 1 : 0] s_axis_tkeep_i ,
    input  wire                                    s_axis_tvalid_i,
    input  wire                                    s_axis_tlast_i ,
    output wire                                    s_axis_tready_o,
    
    output wire                                   counter_enable_o,
    output wire                                   counter_rst_o   ,
    output wire [COUNTER_DATA_WIDTH - 1 : 0]      counter_value_i 
    
`ifdef DEBUG
    ,   
    output wire [15 : 0]                         dbg,
    output wire [31:0]                           dbg_2
`endif
);  

    localparam integer                  STATE_NUMBER             = 11;
    localparam integer                  STATE_WIDTH              = $clog2(STATE_NUMBER);
    localparam integer                  PAYLOAD_WIDTH            = $clog2(PAYLOAD_MAX_SIZE);
    localparam integer                  HEADERS_SIZE             = STREAM_DATA_WIDTH / 2;
    localparam integer                  DCR_HEADERS_SIZE         = HEADERS_SIZE - 1;
    localparam integer                  UDP_TYPE_WIDTH           = 8;
   
    localparam [STATE_WIDTH - 1 : 0]    IDLE_STATE               = 0;
    localparam [STATE_WIDTH - 1 : 0]    ETH_SRC_MAC_STATE        = 1;
    localparam [STATE_WIDTH - 1 : 0]    ETH_FRM_LENGHT_STATE     = 2;
    localparam [STATE_WIDTH - 1 : 0]    IP_PACK_LENGHT_STATE     = 3;
    localparam [STATE_WIDTH - 1 : 0]    IP_PROTOCOL_STATE        = 4;
    localparam [STATE_WIDTH - 1 : 0]    IP_SRC_ADDR_STATE        = 5;
    localparam [STATE_WIDTH - 1 : 0]    IP_DST_ADDR_HEADER_STATE = 6;
    localparam [STATE_WIDTH - 1 : 0]    IP_DST_ADDR_TAIL_STATE   = 7;
    localparam [STATE_WIDTH - 1 : 0]    UDP_SRC_PORT_STATE       = 8;
    localparam [STATE_WIDTH - 1 : 0]    UDP_CRC_STATE            = 9;
    localparam [STATE_WIDTH - 1 : 0]    PAYLOAD_STATE            = 10;
    localparam [STATE_WIDTH - 1 : 0]    ETH_FRM_CRC_STATE        = 11;
    
    localparam [UDP_TYPE_WIDTH - 1 : 0] UDP_PORT_TYPE            = 8'h11;
                                                                 
    wire          dst_mac_valid;
    wire          stream_valid;

    reg                         s_axis_tready;
    reg [HEADERS_SIZE - 1 : 0]  s_axis_tdata_header;

    reg [HEADERS_SIZE - 1 : 0]  ip_dst_addr_header;
    reg [`IP_V4_WIDTH - 1 : 0]  eth_dst_mac_head; 
    reg [PAYLOAD_WIDTH - 1 : 0] ip_pack_payload_lenght;
    reg [STATE_WIDTH - 1 : 0]   fsm_state;
    
    assign counter_enable_o = (PAYLOAD_STATE == fsm_state);
    
    assign counter_rst_o    = ((ETH_FRM_CRC_STATE == fsm_state) || 
                               (1'h0 == s_rst_n_i));
 
    assign m_axis_tkeep_o   = s_axis_tkeep_i;
    assign m_axis_tvalid_o  = (PAYLOAD_STATE == fsm_state);
    
    assign m_axis_tlast_o   = (ip_pack_payload_lenght == counter_value_i);
    
    assign s_axis_tready_o  = ((1'h1 == s_axis_tready) && 
                               (1'h1 == m_axis_tready_i));
                               
    assign m_axis_tdata_o   = (PAYLOAD_STATE == fsm_state) ? {s_axis_tdata_i[DCR_HEADERS_SIZE : 0], s_axis_tdata_header} : 0;
    
    assign dst_mac_valid    = (MAC_ADDRESS == {eth_dst_mac_head, s_axis_tdata_i[DCR_HEADERS_SIZE : 0]});
    
    assign stream_valid     = ((1'h1 == s_axis_tvalid_i) && 
                               (1'h1 == m_axis_tready_i) && 
                               (1'h1 == dst_mac_valid));
                               
`ifdef DEBUG
    reg [15:0] dbg_reg;
    reg [31:0] dbg_2_reg;
    assign dbg = dbg_reg;
    assign dbg_2 = dbg_2_reg;


    always @ (posedge clk_i) begin
        if (1'h0 == s_rst_n_i) begin
            dbg_reg   <= IDLE_STATE;
            dbg_2_reg <= 0;
        end
        else begin  
            case (fsm_state)
                ETH_SRC_MAC_STATE: begin
                    dbg_reg <= ETH_SRC_MAC_STATE;          
                end  
                ETH_FRM_LENGHT_STATE: begin
                    dbg_reg <= ETH_FRM_LENGHT_STATE;
                end
                IP_PACK_LENGHT_STATE: begin           
                    dbg_reg <= IP_PACK_LENGHT_STATE;
                end
                IP_PROTOCOL_STATE: begin                 
                    dbg_reg   <= IP_PROTOCOL_STATE;
                    dbg_2_reg <= s_axis_tdata_i[31 : 24];
                end
                IP_SRC_ADDR_STATE: begin 
                    dbg_reg <= IP_SRC_ADDR_STATE;
                end
                IP_DST_ADDR_HEADER_STATE: begin
                    dbg_reg <= IP_DST_ADDR_HEADER_STATE;
                end
                IP_DST_ADDR_TAIL_STATE: begin
                    dbg_reg   <= IP_DST_ADDR_TAIL_STATE;
                    dbg_2_reg <= s_axis_tdata_i[31 : 16];
                end
                UDP_SRC_PORT_STATE: begin
                    dbg_reg   <= UDP_SRC_PORT_STATE;
                    dbg_2_reg <= s_axis_tdata_i;
                end
                UDP_CRC_STATE: begin   
                    dbg_reg <= UDP_CRC_STATE;
                end
                PAYLOAD_STATE: begin
                    dbg_reg   <= PAYLOAD_STATE;
                    dbg_2_reg <= ip_pack_payload_lenght;
                end    
                ETH_FRM_CRC_STATE: begin
                    dbg_reg   <= ETH_FRM_CRC_STATE;
                end
                default: begin
                    dbg_reg   <= IDLE_STATE;
                    dbg_2_reg <= 0;
                end
            endcase
        end
    end
`endif
    
    always @ (posedge clk_i) begin
        if (1'h0 == s_rst_n_i) begin
            fsm_state              <= IDLE_STATE;
            s_axis_tready          <= 1'h0;
            ip_pack_payload_lenght <= {PAYLOAD_WIDTH{1'h0}};
            ip_dst_addr_header     <= {HEADERS_SIZE{1'h0}};
            s_axis_tdata_header    <= {HEADERS_SIZE{1'h0}};
            eth_dst_mac_head       <= {`MAC_WIDTH{1'h0}};
        end
        else begin  
            case (fsm_state)
                IDLE_STATE: begin
                    s_axis_tready    <= 1'h1;
                    eth_dst_mac_head <= s_axis_tdata_i;
                    
                    if (1'h1 == stream_valid) begin
                        fsm_state <= ETH_SRC_MAC_STATE;
                    end
                end
                ETH_SRC_MAC_STATE: begin
                    fsm_state <= ETH_FRM_LENGHT_STATE;                   
                end  
                ETH_FRM_LENGHT_STATE: begin
                    fsm_state <= IP_PACK_LENGHT_STATE;     
                end
                IP_PACK_LENGHT_STATE: begin
                    fsm_state              <= IP_PROTOCOL_STATE;
                    ip_pack_payload_lenght <= {s_axis_tdata_i[7:0],s_axis_tdata_i[15 : 8]};               
                end
                IP_PROTOCOL_STATE: begin
                    ip_pack_payload_lenght <= ip_pack_payload_lenght - 10'h1C - 10'h8;//todo

                    if (UDP_PORT_TYPE == s_axis_tdata_i[31 : 24]) begin
                        fsm_state <= IP_SRC_ADDR_STATE;
                    end
                    else begin
                        fsm_state <= IDLE_STATE;
                    end
                end
                IP_SRC_ADDR_STATE: begin
                    fsm_state <= IP_DST_ADDR_HEADER_STATE; 
                end
                IP_DST_ADDR_HEADER_STATE: begin
                    ip_dst_addr_header <= s_axis_tdata_i[31 : 16];
                    fsm_state          <= IP_DST_ADDR_TAIL_STATE;
                end
                IP_DST_ADDR_TAIL_STATE: begin
                    if ((IP_ADDRESS == {s_axis_tdata_i[15 : 0], ip_dst_addr_header}) &&
                        (UDP_PORT ==  s_axis_tdata_i[31 : 16]))
                    begin
                        fsm_state <= UDP_SRC_PORT_STATE;
                    end
                    else begin
                        fsm_state     <= IDLE_STATE;
                        s_axis_tready <= 1'h0;
                    end
                end
                UDP_SRC_PORT_STATE: begin
                    fsm_state <= UDP_CRC_STATE;
                end
                UDP_CRC_STATE: begin
                    s_axis_tdata_header <= {s_axis_tdata_i[31 : 16]};
                    fsm_state           <= PAYLOAD_STATE;
                end
                PAYLOAD_STATE: begin
                    s_axis_tdata_header <= {s_axis_tdata_i[31 : 16]};

                    if (ip_pack_payload_lenght == counter_value_i)  begin
                        fsm_state <= ETH_FRM_CRC_STATE;
                    end
                end    
                ETH_FRM_CRC_STATE: begin
                    fsm_state <= IDLE_STATE;
                end
                default: begin
                    fsm_state              <= IDLE_STATE;
                    s_axis_tready          <= 1'h0;
                    ip_pack_payload_lenght <= {PAYLOAD_WIDTH{1'h0}};
                    ip_dst_addr_header     <= {HEADERS_SIZE{1'h0}};
                    s_axis_tdata_header    <= {HEADERS_SIZE{1'h0}};
                    eth_dst_mac_head       <= {STREAM_DATA_WIDTH{1'h0}};
                end
            endcase
        end
    end
endmodule