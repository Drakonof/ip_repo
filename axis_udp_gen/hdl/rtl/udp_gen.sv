//todo: pad_null_state

//`include "platform.vh"

//`resetall
//`default_nettype none

`timescale 1ps/1ps

//todo: interface, struct

//(* dont_touch = "yes" *)
module udp_gen #
(
  parameter unsigned DATA_WIDTH = 64,
  parameter unsigned ADDR_WIDTH = 8
)
(
  input  logic                      clk_i,
  input  logic                      s_rst_n_i,
  
  input  logic                      en_i,
  
  output logic [DATA_WIDTH - 1 : 0] data_o,    
  output logic                      data_valid_o,
  output logic                      frame_end_o,

  input  logic [DATA_WIDTH - 1 : 0] mem_data_i,
  output logic [ADDR_WIDTH - 1 : 0] mem_addr_o
  
 // udp_gen_inf data_inf
); 
  localparam unsigned                     FMS_STATE_NR        = 5;
  localparam unsigned                     FMS_STATE_WIDTH     = $clog2(FMS_STATE_NR);
    
  localparam unsigned                     GAP_COUNTER_MAX_VAL = 'd12;
  localparam unsigned                     GAP_COUNTER_WIDTH   = $clog2(GAP_COUNTER_MAX_VAL);


  typedef enum logic [FMS_STATE_WIDTH - 1 : 0] {
    IDLE_STATE,
    SIZE_STATE,
    DATA_STATE,
    LAST_DATA_STATE,
    GAP_STATE
  } fsm_state_t;

  
  fsm_state_t fsm_state;
  fsm_state_t next_fsm_state;
  
  logic [ADDR_WIDTH - 1 : 0] mem_addr;
  logic [ADDR_WIDTH - 1 : 0] frame_size;

  logic [GAP_COUNTER_WIDTH - 1 : 0] gap_counter;


  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == '0)
        begin
          frame_size <= '0;
        end
      else if ((fsm_state == IDLE_STATE) && (en_i == 'h1))
        begin
          frame_size <= mem_data_i[ADDR_WIDTH - 1 : 0];
        end
    end

  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == '0)
        begin
          mem_addr <= '0;
        end
      else if (gap_counter == (GAP_COUNTER_MAX_VAL - 'h2)) // 2? waiting pre end of gap
        begin
          mem_addr <= '0;
        end
      else if (en_i == 'h1)
        begin
          mem_addr <= mem_addr + 'h1;
        end
    end

  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == '0)
        begin
          gap_counter <= '0;
        end
      else if (gap_counter == (GAP_COUNTER_MAX_VAL - 'h1))
        begin
          gap_counter <= '0;
        end
      else if (fsm_state == GAP_STATE)
        begin
          gap_counter <= gap_counter + 'h1;
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
    
  // 2
  always_comb
    begin
      next_fsm_state = fsm_state;
      
      case (fsm_state)
      
      IDLE_STATE:
        begin
          if (en_i == 'h1)
            begin
              next_fsm_state = SIZE_STATE;
            end
        end

      SIZE_STATE:
        begin
          if (en_i == 'h1)
            begin
              next_fsm_state = DATA_STATE;
            end
        end
        
      DATA_STATE:
        begin
          if ((en_i == 'h1) && (mem_addr == frame_size))
            begin
              next_fsm_state = LAST_DATA_STATE;
            end
        end

      LAST_DATA_STATE:
        begin
          if (en_i == 'h1)
            begin
              next_fsm_state = GAP_STATE;
            end
        end
        
      GAP_STATE:
        begin
          if (gap_counter == (GAP_COUNTER_MAX_VAL - 'h1))
            begin
              if (en_i == 'h1)
                begin
                  next_fsm_state = SIZE_STATE;
                end
              else
                begin
                  next_fsm_state = IDLE_STATE;
                end
            end
        end
        
      default:
        begin
          next_fsm_state = IDLE_STATE;
        end
      
      endcase
    end
    
  // 3
  always_comb
    begin
      case (fsm_state)
      
      IDLE_STATE:
        begin
          data_valid_o = '0;
          frame_end_o  = '0;

          data_o       = '0;
          mem_addr_o   = '0;

          if (en_i == 'h1)
            begin
              mem_addr_o  = mem_addr;
            end
        end

      SIZE_STATE:
        begin
          data_valid_o = '0;
          frame_end_o  = '0;
          
          mem_addr_o   = mem_addr;
          data_o       = '0;
        end
        
      DATA_STATE:
        begin
          data_valid_o = 'h1;
          frame_end_o  = '0;
          
          mem_addr_o   = mem_addr;
          data_o       = mem_data_i;
        end
        
      LAST_DATA_STATE:
        begin
          data_valid_o = 'h1;
          frame_end_o  = 'h1;
          
          mem_addr_o   = '0;
          data_o       = mem_data_i;
        end
        
      GAP_STATE:
        begin
          data_valid_o = '0;
          frame_end_o  = '0;

          mem_addr_o   = '0;
          data_o       = '0;
        end
        
      default:
        begin
          data_valid_o = '0;
          frame_end_o  = '0;

          mem_addr_o   = '0;
          data_o       = '0;
        end
        
      endcase
    end

endmodule