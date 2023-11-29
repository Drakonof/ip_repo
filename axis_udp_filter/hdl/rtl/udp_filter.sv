//todo: strobe
//`include "platform.vh"


`timescale 1 ns / 1 ps


`ifdef XILINX
  `resetall
  `default_nettype none
`endif


module udp_filter #
(
  parameter unsigned DATA_WIDTH = 64,

  localparam unsigned IPV4_ADDR_WIDTH = 32
)
(
  input  logic                           clk_i,

  input  logic                           s_rst_n_i,
  input  logic                           en_i,

  input  logic [IPV4_ADDR_WIDTH - 1 : 0] ipv4_addr_i,

  input  logic [DATA_WIDTH - 1 : 0]      frame_i,
  input  logic                           frame_last_i,

  output logic                           frame_valid_o,
  
  output logic                           fifo_wr_en_o,
  output logic [DATA_WIDTH - 1 : 0]      fifo_data_o,
  input  logic                           fifo_empty_i,
 // todo with fifo error: input  logic fifo_full_i,
  output logic                           fifo_rst_n_o

  //todo: output logic                           fifo_error_o
);

  
  localparam unsigned                  FMS_STATE_NR    = 9;
  localparam unsigned                  FMS_STATE_WIDTH = $clog2(FMS_STATE_NR);

  localparam unsigned                  ETHERTYPE_WIDTH = 16;
  localparam [ETHERTYPE_WIDTH - 1 : 0] ETHERTYPE       = 'h0800;

  localparam unsigned                  VERSION_WIDTH   = 4;
  localparam [VERSION_WIDTH - 1 : 0]   VERSION         = 'h4;

  localparam unsigned                  PROTOCOL_WIDTH  = 8;
  localparam [PROTOCOL_WIDTH - 1 : 0]  PROTOCOL        = 'h11;


  typedef enum logic [FMS_STATE_WIDTH - 1 : 0] {
    IDLE_STATE,
    MAC_STATE,
    ETHERTYPE_VERSION_STATE,
    PROTOCOL_STATE,
    DEST_IPV4_1_STATE,
    DEST_IPV4_2_STATE,
    WRONG_FRAME_STATE,
    LAST_STATE,
    FIFO_FINISH_STATE
  } fsm_state_t;

  
  fsm_state_t fsm_state;
  fsm_state_t next_fsm_state;

  logic [IPV4_ADDR_WIDTH - 1 : 0]       ipv4_addr;

  logic                                 wrong_frame;

  // is flipflop needed to catch frame?


  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == '0)
        begin
          ipv4_addr <= '0;
        end
      else if (fsm_state == IDLE_STATE)
        begin
          ipv4_addr <= ipv4_addr_i;
        end
    end

  always_ff @(posedge clk_i)
    begin
      if (s_rst_n_i == '0)
        begin
          wrong_frame <= '0;
        end
      else if (fsm_state == IDLE_STATE)
        begin
          wrong_frame <= '0;
        end
      else if (fsm_state == WRONG_FRAME_STATE)
        begin
          wrong_frame <= 'h1;
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
              next_fsm_state = MAC_STATE;
            end
        end

      MAC_STATE:
        begin
          if (en_i == 'h1)
            begin
              next_fsm_state = ETHERTYPE_VERSION_STATE;
            end
        end
        
      ETHERTYPE_VERSION_STATE:
        begin
          if (en_i == 'h1)
            begin
              if ((frame_i[55 : 52] == VERSION) &&
                  (frame_i[47 : 32] == ETHERTYPE))
                begin
                  next_fsm_state = PROTOCOL_STATE;
                end
              else
                begin
                  next_fsm_state = WRONG_FRAME_STATE;
                end
            end
        end

      PROTOCOL_STATE:
        begin
          if (en_i == 'h1)
            begin
              if (frame_i[63 : 56] == PROTOCOL)
                begin
                  next_fsm_state = DEST_IPV4_1_STATE;
                end
              else
                begin
                  next_fsm_state = WRONG_FRAME_STATE;
                end
            end
        end

      DEST_IPV4_1_STATE:
        begin
          if (en_i == 'h1)
            begin
              if (frame_i[47 : 16] == ipv4_addr)
                begin
                  next_fsm_state = LAST_STATE;
                end
              else
                begin
                  next_fsm_state = WRONG_FRAME_STATE;
                end
            end
        end

      // DEST_IPV4_2_STATE:
      //   begin
      //     if (en_i == 'h1)
      //       begin
      //         if (frame_i[15 : 0] == ipv4_addr[15 : 0])
      //           begin
      //             next_fsm_state = LAST_STATE;
      //           end
      //         else
      //           begin
      //             next_fsm_state = WRONG_FRAME_STATE;
      //           end
      //       end
      //   end

      WRONG_FRAME_STATE:
        begin
          next_fsm_state = LAST_STATE;
        end

      LAST_STATE:
        begin
          if ((en_i == 'h1) && (frame_last_i == 'h1))
            begin
              if (wrong_frame == 'h1)
                begin
                  next_fsm_state = IDLE_STATE;
                end
              else
                begin
                  next_fsm_state = FIFO_FINISH_STATE;
                end
            end
        end

      FIFO_FINISH_STATE:
        begin
          if (fifo_empty_i == 'h1)
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
          fifo_wr_en_o  = '0;
          fifo_data_o   = '0; // hell shit funout
          fifo_rst_n_o  = '0;
          frame_valid_o = '0;
        end

      MAC_STATE:
        begin
          fifo_wr_en_o  = 'h1;
          fifo_data_o   = frame_i;
          fifo_rst_n_o  = 'h1;
          frame_valid_o = '0;
        end
        
      ETHERTYPE_VERSION_STATE:
        begin
          fifo_wr_en_o  = 'h1;
          fifo_data_o   = frame_i;
          fifo_rst_n_o  = 'h1;
          frame_valid_o = '0;
        end

      PROTOCOL_STATE:
        begin
          fifo_wr_en_o  = 'h1;
          fifo_data_o   = frame_i;
          fifo_rst_n_o  = 'h1;
          frame_valid_o = '0;
        end

      DEST_IPV4_1_STATE:
        begin
          fifo_wr_en_o  = 'h1;
          fifo_data_o   = frame_i;
          fifo_rst_n_o  = 'h1;
          frame_valid_o = '0;
        end

      DEST_IPV4_2_STATE:
        begin
          fifo_wr_en_o  = 'h1;
          fifo_data_o   = frame_i;
          fifo_rst_n_o  = 'h1;
          frame_valid_o = '0;
        end

      WRONG_FRAME_STATE:
        begin
          fifo_wr_en_o  = '0;
          fifo_data_o   = '0;
          fifo_rst_n_o  = '0;
          frame_valid_o = '0;
        end

      LAST_STATE:
        begin
          fifo_rst_n_o = 'h1;

          if (wrong_frame == 'h1)
            begin
              fifo_wr_en_o  = '0;
              fifo_data_o   = '0;
              frame_valid_o = '0;
            end
          else
            begin
              fifo_wr_en_o  = 'h1;
              fifo_data_o   = frame_i;
              frame_valid_o = 'h1;
            end
        end

      FIFO_FINISH_STATE:
        begin
          fifo_wr_en_o  = '0;
          fifo_data_o   = '0;
          fifo_rst_n_o  = 'h1;
          frame_valid_o = 'h1;
        end

      default:
        begin
          fifo_wr_en_o  = '0;
          fifo_data_o   = '0;
          fifo_rst_n_o  = '0;
          frame_valid_o = '0;
        end
      
      endcase

    end


endmodule