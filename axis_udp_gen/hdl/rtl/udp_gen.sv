//todo: axi mem, rewrite fsm

//`include "platform.vh"

//`resetall
//`default_nettype none

`timescale 1ps/1ps

//todo: interface, struct

//(* dont_touch = "yes" *)
module udp_gen #
(
  parameter unsigned DATA_WIDTH = 64,
  parameter unsigned ADDR_WIDTH = 4
)
(
  input  logic                      clk_i,
  input  logic                      s_rst_n_i,
  
  input  logic                      en_i,
  
  output logic [DATA_WIDTH - 1 : 0] data_o,    
  output logic                      data_valid_o,
  output logic                      frame_end_o,

  input  logic [DATA_WIDTH - 1 : 0] mem_data_i,
  input  logic [ADDR_WIDTH - 1 : 0] mem_addr_o,
  input  logic                      mem_rd_en_o
  
 // udp_gen_inf data_inf
);

  localparam [DATA_WIDTH - 1 : 0] BYTE_COUNTER_INCR   = DATA_WIDTH / 8;

  localparam [DATA_WIDTH - 1 : 0] MIN_DATA_SIZE       = 64;   // 46 bytes payload
  localparam [DATA_WIDTH - 1 : 0] MAX_DATA_SIZE       = 1518; // 1500 bytes payload  //todo:size???
  
  localparam unsigned                     FMS_STATE_NR        = 6;
  localparam unsigned                     FMS_STATE_WIDTH     = $clog2(FMS_STATE_NR);
    
  localparam unsigned                     GAP_COUNTER_MAX_VAL = 'd12;
  localparam unsigned                     GAP_COUNTER_WIDTH   = $clog2(GAP_COUNTER_MAX_VAL);


  
  
  typedef enum logic [FMS_STATE_WIDTH - 1 : 0] {
    IDLE_STATE,
    SIZE_STATE,
    DATA_STATE,
    PAD_NULL_STATE,
    LAST_DATA_STATE,
    GAP_STATE
  } fsm_state_t;

  
  fsm_state_t fsm_state;
  fsm_state_t next_fsm_state;
  
  logic [DATA_WIDTH - 1 : 0] byte_counter;
  logic [ADDR_WIDTH - 1 : 0] mem_addr;
  logic [DATA_WIDTH - 1 : 0] frame_size;

  logic [GAP_COUNTER_WIDTH - 1 : 0] gap_counter;
    
  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == 1'h0)
        begin
          byte_counter <= '0;
        end
      else if (fsm_state == DATA_STATE)
        begin
          byte_counter <= byte_counter + BYTE_COUNTER_INCR;
        end
      else
        begin
          byte_counter <= '0;
        end
    end

  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == 1'h0)
        begin
          mem_addr   <= '0;
          frame_size <= '0;
        end
      else if (fsm_state == SIZE_STATE)
        begin
          mem_addr   <= '0;
          frame_size <= mem_data_i;
        end
      else if (en_i == 'h1)
        begin
          mem_addr <= mem_addr + 1'h1;
        end
    end

  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == 1'h0)
        begin
          gap_counter <= '0;
        end
      else if (fsm_state == GAP_STATE)
        begin
          gap_counter <= gap_counter + 1'h1;
        end
      else if (fsm_state == SIZE_STATE)
        begin
          gap_counter <= '0;
        end
    end

  
  // 1
  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == 1'h0)
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
          if ((en_i == 'h1) && (byte_counter == frame_size - 2'h2))
            begin
              next_fsm_state = LAST_DATA_STATE;
            end
        end

      //todo: pad_null_state
       
      LAST_DATA_STATE:
        begin
          if (en_i == 'h1)
            begin
              next_fsm_state = GAP_STATE;
            end
        end
        
      GAP_STATE:
        begin
          if (gap_counter == (GAP_COUNTER_MAX_VAL - 1'h1))
            begin
              next_fsm_state = IDLE_STATE;
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

          if (en_i == 'h1)
            begin
              mem_addr_o  = mem_addr;
              mem_rd_en_o = 'h1;
            end
        end

      SIZE_STATE:
        begin
          data_valid_o = 'h1;
          frame_end_o  = '0;
          
          mem_addr_o   = mem_addr;
          mem_rd_en_o  = 'h1;
        end
        
      DATA_STATE:
        begin
          data_valid_o = 'h1;
          frame_end_o  = '0;
          
          mem_addr_o   = mem_addr;
          mem_rd_en_o  = 'h1;
          data_o       = mem_data_i;
        end
        
      LAST_DATA_STATE:
        begin
          data_valid_o = 'h1;
          frame_end_o  = '0;
          
          mem_rd_en_o  = 'h1;
          data_o       = mem_data_i;
        end
        
      GAP_STATE:
        begin
          data_valid_o = '0;
          frame_end_o  = '0;
        end
        
      default:
        begin
          data_valid_o = '0;
          frame_end_o  = '0;
        end
        
      endcase
    end

endmodule