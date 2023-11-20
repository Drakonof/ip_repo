`timescale 1ns / 1ps

module udp_gen_tb_wrapper #
(
  parameter unsigned DATA_WIDTH = 64,
  parameter unsigned ADDR_WIDTH = 8
);
  logic                      clk;
  logic                      s_rst_n;
  
  logic                      en;

  logic [DATA_WIDTH - 1 : 0] data;
  logic                      data_valid;
  logic                      frame_end;

  logic [DATA_WIDTH - 1 : 0] mem_data;
  logic [ADDR_WIDTH - 1 : 0] mem_addr;

  //udp_gen_inf data_inf();

  udp_gen #
  ( .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH)
  )
  udp_gen_dut
  (
    .clk_i          (clk    ),
    .s_rst_n_i      (s_rst_n),
  
    .en_i           (en          ),
    
    .data_o         (data        ),   
    .data_valid_o   (data_valid  ),
    .frame_end_o    (frame_end   ),

    .mem_data_i     (mem_data    ),
    .mem_addr_o     (mem_addr    )
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, udp_gen_tb_wrapper);
  end

endmodule
