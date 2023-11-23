//`include "platform.vh"

//todo: strobes


`timescale 1 ns / 1 ps


`ifdef XILINX
  `resetall
  `default_nettype none
`endif


module fifo #
(
  parameter unsigned             DATA_WIDTH   = 32,

  parameter unsigned             ADDR_WIDTH   = 8,

`ifdef XILINX
  parameter                      RAM_STYLE    = "auto", // "distributed", "block", "registers", "ultra", "mixed", "auto"
`endif

  parameter unsigned ALMOST_FULL  = 2,
  parameter unsigned ALMOST_EMPTY = 2
)
(
  input  logic                      clk_i,

  input  logic                      s_rst_n_i,

  input  logic                      wr_en_i,
  input  logic [DATA_WIDTH - 1 : 0] data_i,
  output logic                      almost_full_o,
  output logic                      full_o,

  input  logic                      rd_en_i,
  output logic [DATA_WIDTH - 1 : 0] data_o,
  output logic                      almost_empty_o,
  output logic                      empty_o
);


  localparam unsigned FIFO_DEPTH = (2 ** ADDR_WIDTH);

  initial
    begin
    if ((ALMOST_FULL > FIFO_DEPTH) || (ALMOST_FULL < 'h1))
      begin
          $error("Incorrect parameter value: ALMOST_FULL == %h, FIFO_DEPTH == %h", ALMOST_FULL, FIFO_DEPTH);    
      end 

    if ((ALMOST_EMPTY > FIFO_DEPTH) || (ALMOST_EMPTY < 'h1))
      begin
        $error("Incorrect parameter value: ALMOST_EMPTY == %dh, FIFO_DEPTH == %h", ALMOST_EMPTY, FIFO_DEPTH);
      end

    if (ADDR_WIDTH == 0)
      begin
        $error("Incorrect parameter value: ADDR_WIDTH");
      end

    if (DATA_WIDTH == 0)
      begin
        $error("Incorrect parameter value: ADDR_WIDTH");
      end
  end

  localparam [ADDR_WIDTH : 0]  A_FULL     = FIFO_DEPTH - ALMOST_FULL;
  localparam [ADDR_WIDTH : 0]  A_EMPTY    = ALMOST_EMPTY;

  logic [ADDR_WIDTH : 0]     wr_pointer; // one bit extra
  logic [ADDR_WIDTH : 0]     rd_pointer; // one bit extra

  logic [ADDR_WIDTH - 1 : 0] wr_addr;
  logic [ADDR_WIDTH - 1 : 0] rd_addr;

  logic                      full;
  logic                      empty;

  logic                      almost_full;
  logic                      almost_full_d;

  logic                      almost_empty;
  logic                      almost_empty_d;

`ifdef XILINX
  (*ram_style = RAM_STYLE*)
`endif
  logic [DATA_WIDTH - 1 : 0] mem [0 : FIFO_DEPTH - 1];


  always_comb
    begin
      wr_addr = wr_pointer [ADDR_WIDTH - 1 : 0];
      rd_addr = rd_pointer [ADDR_WIDTH - 1 : 0];
    end

  always_comb
    begin
      full           = (wr_pointer != rd_pointer) && (wr_addr == rd_addr);
      full_o         = full;
      almost_full    = (wr_pointer - rd_pointer) >= A_FULL;

      almost_full_o  = almost_full && ~almost_full_d;


      empty          = (wr_pointer == rd_pointer) && (wr_addr == rd_addr);
      empty_o        = empty;
      almost_empty   = (wr_pointer - rd_pointer) <= A_EMPTY;

      almost_empty_o = almost_empty && ~almost_empty_d;
    end

  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == '0)
        begin
          almost_full_d <= '0;
        end
      else
        begin
          almost_full_d <= almost_full;
        end
    end

  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == '0)
        begin
          almost_empty_d <= '0;
        end
      else
        begin
          almost_empty_d <= almost_empty;
        end
    end

  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == 'h0)	
        begin
          wr_pointer      <= '0;
        end
      else if ((wr_en_i == 'h1) && (full != 'h1))
      	begin
      	  wr_pointer <= wr_pointer + 'h1;
      	end
    end

  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == 'h0)	
        begin
          rd_pointer <= '0;
        end
      else if ((rd_en_i == 'h1) && (empty != 'h1))
      	begin
      	  rd_pointer <= rd_pointer + 'h1;
      	end
    end

  always_comb
    begin
      data_o = mem[rd_addr];
    end

  always_ff @(posedge clk_i)
    begin
      if ((wr_en_i == 'h1) && (full != 'h1))
      	begin
      	  mem[wr_addr] <= data_i;
      	end
    end

  always @(posedge clk_i)
    begin
      assert ((wr_en_i == 'h1) && (full == 'h1)) 
        begin
          $display("full fifo is being written ");
        end

      assert ((rd_en_i == 'h1) && (empty == 'h1))
        begin
          $display("empty fifo is being read");
        end
    end


endmodule