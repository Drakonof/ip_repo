// todo true dual!
module true_dual_block_ram #
(
    parameter integer DATA_WIDTH     = 32               ,
    parameter integer RAM_DEPTH      = 10               ,
    parameter integer ADDR_WIDTH     = $clog2(RAM_DEPTH),
    parameter         INIT_FILE_NAME = ""
) 
(
    input   wire                            a_clk_i,
    
    input   wire                            a_wr_en_i,
    input   wire [ADDR_WIDTH-1:0]           a_wr_addr_i,
    input   wire [DATA_WIDTH-1:0]           a_data_i,
    input   wire [(DATA_WIDTH / 8) - 1 : 0] a_wr_byte_valid_i,
    
    input   wire                            a_rd_en_i,
    input   wire [ADDR_WIDTH-1:0]           a_rd_addr_i,
    output  wire [DATA_WIDTH-1:0]           a_data_o,
    output  wire                            a_rd_valid_o,
    
    input   wire                            b_clk_i,     
                                                         
    input   wire                            b_wr_en_i,   
    input   wire [ADDR_WIDTH-1:0]           b_wr_addr_i, 
    input   wire [DATA_WIDTH-1:0]           b_data_i,    
    input   wire [(DATA_WIDTH / 8) - 1 : 0] b_wr_byte_valid_i,
                                                         
    input   wire                            b_rd_en_i,   
    input   wire [ADDR_WIDTH-1:0]           b_rd_addr_i, 
    output  wire [DATA_WIDTH-1:0]           b_data_o,    
    output  wire                            b_rd_valid_o
);
    reg a_rd_valid;
    reg b_rd_valid;
    
    reg [DATA_WIDTH-1:0] a_data_out; 
    reg [DATA_WIDTH-1:0] b_data_out;
    
    reg [ADDR_WIDTH-1:0] b_rd_addr, a_rd_addr;
 
    reg [DATA_WIDTH-1:0] block_ram [RAM_DEPTH-1:0];

    integer i;
    
    assign a_data_o = block_ram[a_rd_addr];
    assign a_rd_valid_o = a_rd_valid;
    
    assign b_data_o = block_ram[b_rd_addr];
    assign b_rd_valid_o = b_rd_valid;
    
    
    generate 
    if ("" != INIT_FILE_NAME) begin : init_block_ram_from_file
        initial begin
            $readmemh(INIT_FILE_NAME, block_ram);
        end
    end
    endgenerate
     
    always @(posedge a_clk_i) begin

        a_rd_valid <= a_rd_en_i; 
        a_rd_addr <= a_rd_addr_i;
    
        if(1'h1 == a_wr_en_i) begin
            for (i = 0; i < (DATA_WIDTH / 8); i = i + 1) begin
                if (1'h1 == a_wr_byte_valid_i[i]) begin 
                    block_ram[a_wr_addr_i][(i * 8) +: 8] <= a_data_i[(i * 8) +: 8]; 
                end
            end
        end 
       //else if (1'h1 == a_rd_en_i) begin //      
       //         a_data_out <= block_ram[a_rd_addr_i]; 
       //end
    end
    
    
    always @(posedge b_clk_i) begin
       
        b_rd_valid <= b_rd_en_i;
        b_rd_addr <= b_rd_addr_i;
    
        if(1'h1 == b_wr_en_i) begin
            for (i = 0; i < (DATA_WIDTH / 8); i = i + 1) begin
                if (1'h1 == b_wr_byte_valid_i[i]) begin 
                    block_ram[b_wr_addr_i][(i * 8) +: 8] <= b_data_i[(i * 8) +: 8]; 
                end
            end
        end 
        //else if (1'h1 == b_rd_en_i) begin //
       //      b_data_out <= block_ram[a_rd_addr_i]; 
       //end
    end

 
endmodule