/*----------------------------------------------------------------------------------------------------
 * engineer:     
 *
 * created:         16.11.20  
 *
 * device:          cross-platform
 *
 * description:      A single clock simple dual ram memory.
 *
 * dependencies:    non
 *
 * doc:             non
 *
 * rtl:             simple_dual_bram.v
 *
 * tb:              simple_dual_bram.v
 *
 * version:         1.0
 *
 * revisions:       16.11.20    - There was createde the base vertion file;      
 */

 /* 
  sl_dual_block_ram #
  (
    .DATA_WIDTH         (),
    .ADDRESS_WIDTH      (),
    .INIT_DAT_FILE_NAME () // format: "NAME"
  )
  sl_dual_block_ram_inst0
  (
    .clk_i            (),
    
    .wr_data_i        (), // width: DATA_WIDTH
    .wr_address_i     (), // width: ADDRESS_WIDTH
    .wr_enable_i      (),
    .wr_byte_enable_i (), // width: (DATA_WIDTH / `BYTE_WIDTH)

    .rd_data_o        (), // width: DATA_WIDTH
    .rd_address_i     (), // width: ADDRESS_WIDTH
    .rd_enable_i      (),
    .rd_valid_o       ()
  );
 */
`timescale 1ns / 10ps

module simple_dual_bram # 
(
  parameter integer DATA_WIDTH     = 8,
  parameter integer ADDRESS_WIDTH  = 8,
  parameter         INIT_FILE_NAME = ""
)
(
  input  wire                            clk_i,

  input  wire [DATA_WIDTH - 1 : 0]       wr_data_i,
  input  wire [ADDRESS_WIDTH - 1 : 0]    wr_address_i,                    
  input  wire                            wr_enable_i,
  input  wire [(DATA_WIDTH / 8) - 1 : 0] wr_byte_valid_i,

  output wire [DATA_WIDTH - 1 : 0]       rd_data_o,
  input  wire [ADDRESS_WIDTH - 1 : 0]    rd_address_i,                    
  input  wire                            rd_enable_i,
  output wire                            rd_valid_o
);

  localparam integer BLOCK_RAM_DEPTH = (1 << ADDRESS_WIDTH); //??
  

  reg                         rd_valid;
  reg [ADDRESS_WIDTH - 1 : 0] rd_address;
  
  reg [DATA_WIDTH - 1 : 0]    block_ram [0 : ADDRESS_WIDTH - 1];

  integer i = 0;

  generate 
    if ("" != INIT_FILE_NAME) 
      begin : init_block_ram_from_file
        initial
          begin
            $readmemh(INIT_FILE_NAME, block_ram);
          end
      end
  endgenerate

  assign   rd_data_o  = /*(1'h1 == rd_valid) ? */block_ram[rd_address];// : {DATA_WIDTH{1'h0}};
  assign   rd_valid_o = rd_valid;

  always @ (posedge clk_i)
    begin
      if (1'h1 == wr_enable_i)
        begin
          for (i = 0; i < (DATA_WIDTH / 8); i = i + 1)
            begin
              if (1'h1 == wr_byte_valid_i[i])
                begin
                  block_ram[wr_address_i][(i * 8) +: 8] <= wr_data_i[(i * 8) +: 8]; 
                end
            end 
        end

      rd_valid    <= rd_enable_i;
      rd_address  <= rd_address_i;
    end

endmodule
