//`include "platform.vh"

`timescale 1 ns / 1 ps


`ifdef XILINX
  `resetall
  `default_nettype none
`endif


module axis_round_robin_arbiter #
(
  parameter unsigned CHANNEL_NUM = 8
)
(
  input  logic clk_i,
  input  logic rst_n_i,

  input  logic [CHANNEL_NUM - 1 : 0] s_tvalid,
  input  logic [CHANNEL_NUM - 1 : 0] s_tlast,

  output logic [CHANNEL_NUM - 1 : 0] sel_o
);


  localparam unsigned POINTER_WIDTH = $clog2(CHANNEL_NUM);


  logic [POINTER_WIDTH - 1 : 0] pointer;

  typedef enum logic [FMS_STATE_WIDTH - 1 : 0] {
    DATA_STATE,
    LAST_STATE
  } fsm_state_t;

  fsm_state_t fsm_state;
  fsm_state_t next_fsm_state;


  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == '0)
        begin
          pointer <= '0;
        end
      else
        begin
          if (pointer_incr_flag == 'b1)
            begin
              if (pointer == CHANNEL_NUM - 1)
                begin
                  pointer <= '0;
                end
              else
                begin
                  pointer <= pointer + 'b1;
                end
            end
        end
    end

  // 1
  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == '0)
        begin
          fsm_state <= IDLE_STATE;
        end
      else
        begin
          fsm_state <= next_fsm_state;
        end
    end
   
  //2
  always_comb
    begin
      next_fsm_state = fsm_state;
      
      case (fsm_state)

      DATA_STATE:
        begin
          if (s_tvalid[pointer] == 'h1)
            begin
              next_fsm_state = LAST_STATE;
            end
          else
            begin
              next_fsm_state = DATA_STATE;
            end
        end

      LAST_STATE:
        begin
          if ((s_tlast[pointer] == 'h1) && (s_tvalid[pointer] == 'h1))
            begin
              next_fsm_state = DATA_STATE;
            end
          else
            begin
              next_fsm_state = LAST_STATE;
            end
        end

      default:
        begin
          next_fsm_state = DATA_STATE;
        end
      
      endcase
    end


  //3
  always_comb
    begin

      sel_o = 1'b1 << pointer;

      case (fsm_state)

      DATA_STATE:
        begin
          if (s_tvalid[pointer] == 'h1)
            begin
              pointer_incr_flag = 'b0;
            end
          else
            begin
              pointer_incr_flag = 'b1;
            end
        end

      LAST_STATE:
        begin
          if ((s_tlast[pointer] == 'h1) && (s_tvalid[pointer] == 'h1))
            begin
              pointer_incr_flag = 'b0;
            end
          else
            begin
              pointer_incr_flag = 'b1;
            end
        end

      default:
        begin
          next_fsm_state = DATA_STATE;
        end
      
      endcase
    end

endmodule