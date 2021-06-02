`timescale 1ns / 1ps

module uart_controller #
(
    parameter integer AXI_DATA_WIDTH    = 32                         ,
    parameter integer DATA_WIDTH        = 8                          ,
    parameter integer REG_SPACE_DEPTH   = 8                          ,
    parameter integer REG_ADDRESS_WIDTH = $clog2(REG_SPACE_DEPTH) + 2,
    parameter integer BAUD_VALUE_WIDTH  = 16
)
(
   input  wire                                axi_clk_i        ,      
   input  wire                                axi_a_rst_n_i    ,  
               
   input  wire [REG_ADDRESS_WIDTH - 1 : 0]    s_axi_awaddr_i   , 
   input  wire [2 : 0]                        s_axi_awprot_i   , //-
   input  wire                                s_axi_awvalid_i  ,
   output wire                                s_axi_awready_o  ,
            
   input  wire [AXI_DATA_WIDTH - 1 : 0]       s_axi_wdata_i    ,  
   input  wire [(AXI_DATA_WIDTH / 8) - 1 : 0] s_axi_wstrb_i    ,  
   input  wire                                s_axi_wvalid_i   , 
   output wire                                s_axi_wready_o   , 
           
   output wire [1 : 0]                        s_axi_bresp_o    ,  
   output wire                                s_axi_bvalid_o   , 
   input  wire                                s_axi_bready_i   , 
           
   input  wire [REG_ADDRESS_WIDTH - 1 : 0]    s_axi_araddr_i   , 
   input  wire [2 : 0]                        s_axi_arprot_i   , 
   input  wire                                s_axi_arvalid_i  ,
   output wire                                s_axi_arready_o  ,
           
   output wire [AXI_DATA_WIDTH - 1 : 0]       s_axi_rdata_o    ,  
   output wire [1 : 0]                        s_axi_rresp_o    ,  
   output wire                                s_axi_rvalid_o   , 
   input  wire                                s_axi_rready_i   ,
 
   output wire                                tx_enable_o      ,
   output wire [DATA_WIDTH - 1 : 0]           tx_data_o        , 

   output wire                                data_bit_num_o   ,
   output wire                                parity_o         , //-
   output wire                                stop_bit_num_o   ,
   output wire [BAUD_VALUE_WIDTH - 1 : 0]     baud_tick_val_o  ,
   
   input wire                                 start_complete_i,
   input wire                                 data_complete_i ,
   input wire                                 tx_complete_i   
);
    localparam integer                     ADDR_LSB           = (AXI_DATA_WIDTH / 32) + 1       ;

    localparam integer                     TX_EN_BIT          = 0                               ;
    localparam integer                     DATA_BIT_NUM_BIT   = 4                               ;
    localparam integer                     PARITY_BIT         = 8                               ;
    localparam integer                     STOP_BIT_NUM_BIT   = 12                              ;
    localparam integer                     START_COMPLETE_BIT = 0                               ;
    localparam integer                     DATA_COMPLETE_BIT  = 4                               ;
    localparam integer                     TX_COMPLETE_BIT    = 8                               ;

    
    localparam [REG_ADDRESS_WIDTH - 1 : 0] CNTR_REG           = {REG_ADDRESS_WIDTH{1'h0}}       ;
    localparam [REG_ADDRESS_WIDTH - 1 : 0] BAUD_REG           = {REG_ADDRESS_WIDTH{1'h0}} + 1'h1;
    localparam [REG_ADDRESS_WIDTH - 1 : 0] TX_DATA_REG        = {REG_ADDRESS_WIDTH{1'h0}} + 2'h2;
    localparam [REG_ADDRESS_WIDTH - 1 : 0] STAT_REG           = {REG_ADDRESS_WIDTH{1'h0}} + 2'h3;
    localparam [REG_ADDRESS_WIDTH - 1 : 0] RX_DATA_REG        = {REG_ADDRESS_WIDTH{1'h0}} + 3'h4;
  
    wire                             axi_rd_en     ;
	wire                             axi_wr_en     ;
	wire                             axi_awready_en;
	
	wire [REG_ADDRESS_WIDTH - 1 : 0] wr_address    ;
	
	reg  	                        axi_awready                    ;
	reg  	                        axi_wready                     ;
	reg  	                        axi_rvalid                     ;
	reg  	                        axi_bvalid                     ;
	reg  	                        axi_arready                    ;
	reg [1 : 0] 	                axi_rresp                      ;
	reg [1 : 0] 	                axi_bresp                      ;
    reg [REG_ADDRESS_WIDTH - 1 : 0] axi_awaddr                     ;
    reg [REG_ADDRESS_WIDTH - 1 : 0] axi_araddr                     ;
    reg [AXI_DATA_WIDTH-1 : 0]      axi_rdata                      ; 
    
    reg                             tx_enable                      ;
    reg [DATA_WIDTH - 1 : 0]        tx_data                        ;
    
    reg                             data_bit_num                   ;
    reg                             parity                         ; 
    reg                             stop_bit_num                   ;
    reg [BAUD_VALUE_WIDTH - 1 : 0]  baud_tick_val                  ;
    
    reg                             tx_cmpl_st                     ;
   
    reg                             rd_valid                       ;
    reg [REG_ADDRESS_WIDTH - 1 : 0] rd_addr                        ;
    
    reg [AXI_DATA_WIDTH-1:0]        block_ram [REG_SPACE_DEPTH-1:0];
    
    integer i = 0;
    
    assign axi_awready_en   = s_axi_awvalid_i && s_axi_wvalid_i &&
                              ~axi_awready                             ;
   
	assign s_axi_awready_o	= axi_awready                               ;  
	assign s_axi_wready_o	= axi_wready                                ;  
	assign s_axi_rvalid_o	= rd_valid                                  ; 
	assign s_axi_bvalid_o	= axi_bvalid                                ;  
	assign s_axi_arready_o	= axi_arready                               ;  
	assign s_axi_rresp_o	= axi_rresp                                 ;    
	assign s_axi_bresp_o	= axi_bresp                                 ;    
	assign s_axi_rdata_o	= block_ram[rd_addr]                        ; 

	assign wr_address       = axi_awaddr[REG_ADDRESS_WIDTH - 1:ADDR_LSB];

    assign axi_rd_en        = (axi_arready && s_axi_arvalid_i && 
                              ~axi_rvalid)                              ;
    assign axi_wr_en        = (axi_wready && s_axi_wvalid_i && 
                              axi_awready && s_axi_awvalid_i)           ;
   
    assign tx_enable_o      = tx_enable                                 ;
    assign tx_data_o        = tx_data                                   ;
  
    assign stop_bit_num_o   = stop_bit_num                              ;
    assign baud_tick_val_o  = baud_tick_val                             ;
    assign data_bit_num_o   = data_bit_num                              ;
    
    always @(posedge axi_clk_i) begin // todo:struct block
	    if (1'b0 == axi_a_rst_n_i) begin
	        tx_cmpl_st <= 1'h0;
	    end
	    else begin
	        tx_cmpl_st <= ~tx_cmpl_st && tx_complete_i && block_ram[CNTR_REG][TX_EN_BIT];
	    end
	end
	
	always @(posedge axi_clk_i) begin
        rd_valid <= axi_rd_en; 
        rd_addr <= axi_araddr[REG_ADDRESS_WIDTH - 1:ADDR_LSB];
        
        if (tx_cmpl_st) begin
            block_ram[CNTR_REG][TX_EN_BIT] <= 1'h0;
        end
        else if((1'h1 == axi_wr_en) && (wr_address < 3)) begin
            for (i = 0; i < (AXI_DATA_WIDTH / 8); i = i + 1) begin
                if (1'h1 == s_axi_wstrb_i[i]) begin 
                    block_ram[wr_address][(i * 8) +: 8] <= s_axi_wdata_i[(i * 8) +: 8]; 
                end
            end
        end 
        
        block_ram[STAT_REG][START_COMPLETE_BIT] <= start_complete_i;
        block_ram[STAT_REG][DATA_COMPLETE_BIT]  <= data_complete_i;
        block_ram[STAT_REG][TX_COMPLETE_BIT]    <= tx_complete_i;
         
    end   
    
    always @(posedge axi_clk_i) begin
	    if (1'b0 == axi_a_rst_n_i) begin
	        tx_enable     <= 1'h0; 
	        data_bit_num  <= 1'h0;
	        parity        <= 1'h0;
	        stop_bit_num  <= 1'h0;
	        baud_tick_val <= {BAUD_VALUE_WIDTH{1'h0}};
	        tx_data       <= {DATA_WIDTH{1'h0}};
	    end 
	    else  begin
	        tx_enable     <= block_ram[CNTR_REG][TX_EN_BIT];
	        data_bit_num  <= block_ram[CNTR_REG][DATA_BIT_NUM_BIT];
	        parity        <= block_ram[CNTR_REG][PARITY_BIT];
	        stop_bit_num  <= block_ram[CNTR_REG][STOP_BIT_NUM_BIT];
	        baud_tick_val <= block_ram[BAUD_REG][BAUD_VALUE_WIDTH - 1 : 0];
	        tx_data       <= block_ram[TX_DATA_REG][DATA_WIDTH - 1 : 0];
	    end
	end

	always @(posedge axi_clk_i) begin
	    if (1'h0 == axi_a_rst_n_i) begin
	        axi_awready <= 1'h0;
	    end 
	    else begin    
	        if (1'h1 == axi_awready_en) begin
	            axi_awready <= 1'h1;
	            axi_awaddr  <= s_axi_awaddr_i;
	        end
	        else if (s_axi_bready_i && axi_bvalid) begin
	            axi_awready <= 1'h0;
	        end
	        else begin
	            axi_awready <= 1'h0;
	        end
	    end 
	end       
	
	always @(posedge axi_clk_i) begin
	    if (1'h0 == axi_a_rst_n_i) begin
	        axi_wready <= 1'h0;
	    end 
	    else begin    
	        if (~axi_wready && s_axi_wvalid_i && s_axi_awvalid_i) begin
	            axi_wready <= 1'h1;
	        end
	        else begin
	            axi_wready <= 1'h0;
	        end
	    end 
	end       

	always @(posedge axi_clk_i) begin
	    if (1'h0 == axi_a_rst_n_i) begin
	        axi_bvalid  <= 1'h0;
	        axi_bresp   <= 2'h0;
	    end 
	    else begin    
	        if (axi_awready && s_axi_awvalid_i && ~axi_bvalid && axi_wready && s_axi_wvalid_i) begin
	            axi_bvalid <= 1'h1;
	            axi_bresp  <= 2'h0; 
	        end                   
	        else begin
	            if (s_axi_bready_i && axi_bvalid) begin
	                axi_bvalid <= 1'h0; 
	            end  
	        end
	    end
	end   

	always @ (posedge axi_clk_i) begin
	    if (1'h0 == axi_a_rst_n_i) begin
	        axi_arready <= 1'h0;
	        axi_araddr  <= {REG_ADDRESS_WIDTH{1'h0}};
	      end 
	    else begin    
	        if (~axi_arready && s_axi_arvalid_i) begin
	            axi_arready <= 1'h1;
	            axi_araddr  <= s_axi_araddr_i;
	        end
	        else begin
	            axi_arready <= 1'h0;
	        end
	    end 
	end       

	always @(posedge axi_clk_i) begin
	    if (1'h0 == axi_a_rst_n_i)  begin
	        axi_rvalid <= 1'h0;
	        axi_rresp  <= 2'h0;
	    end 
	    else begin    
	        if (axi_arready && s_axi_arvalid_i && ~axi_rvalid) begin
	            axi_rvalid <= 1'h1;
	            axi_rresp  <= 2'h0;
	        end   
	        else if (axi_rvalid && s_axi_rready_i) begin
	            axi_rvalid <= 1'h0;
	        end                
	    end
	end    
endmodule


































