/*--------------------------------------------------
| engineer : A. Shimko
|
| module   : uart_tx_ctrl.sv
|
| testbench: uart_tx_ctrl_tb.sv
| 
| brief    :
|
| todo     :
|
| 14.04.22 : add (uart_tx_ctrl.sv): created
| 19.04.22 : fix (uart_tx_ctrl.sv): corrected names of the signals
| 19.04.22 : add (uart_tx_ctrl.sv): added stop bit number 
| 25.04.22 : fix (uart_tx_ctrl.sv): replaced a one always blocks style fsm to a three always blocks one
| 28.04.22 : add (uart_tx_ctrl.sv): added fifo_rd_en_o signal for controlling data fifo
|
*/

/*
uart_tx_ctrl #
(
    .DATA_SIZE_WIDTH ()  // default: 4 
)
uart_tx_ctrl_inst                         
(
    .clk_i            (),
    .s_rst_n_i        (),

    .en_i             (),

    .baud_tick_i      (),

    .data_bit_num_i   (), // width: PACK_SIZE_WIDTH
    .stop_bit_num_i   (),

    .mux_sel_o        (),
    .bd_gen_en_o      (),
    .piso_wr_en_o     (), 
    .piso_en_o        (),

    .fifo_rd_en_o     (),

    .data_o           ()
);
*/

`timescale 1ns / 1ps

module uart_tx_ctrl #
(
    parameter integer DATA_SIZE_WIDTH = 4
)
(
    input  logic                           clk_i,
    input  logic                           s_rst_n_i,

    input  logic                           en_i,

    input  logic                           baud_tick_i,

    input  logic [DATA_SIZE_WIDTH - 1 : 0] data_bit_num_i,
    input  logic                           stop_bit_num_i,
    
    output logic                           mux_sel_o,
    output logic                           baud_gen_en_o,
    output logic                           piso_wr_en_o,
    output logic                           piso_en_o,

    output logic                           fifo_rd_en_o,

    output logic                           data_o
);
    localparam integer FSM_STATE_NUM   = 4;
    localparam integer FSM_STATE_WIDTH = $clog2(FSM_STATE_NUM);

    enum reg [FSM_STATE_WIDTH - 1 : 0] {
        FSM_IDLE,
        FSM_START, 
        FSM_SEND,
        FSM_STOP
    } fsm_state, fsm_next_state; 

    logic [DATA_SIZE_WIDTH - 1 : 0] counter;

    logic [DATA_SIZE_WIDTH - 1 : 0] data_bit_num;
    logic                           stop_bit_num;

    always_ff @ (posedge clk_i) begin
        if (s_rst_n_i == 1'b0) begin
            fsm_state <= FSM_IDLE;
        end else begin
           fsm_state <= fsm_next_state;
        end
    end

    always_comb begin
        fsm_next_state = fsm_state;

        case (fsm_state) 
            FSM_IDLE: begin
                if (en_i == 1'b1) begin
                    fsm_next_state = FSM_START;
                end
            end

            FSM_START: begin
                if (baud_tick_i == 1'b1) begin
                    fsm_next_state = FSM_SEND;
                end
            end

            FSM_SEND: begin
                if ((baud_tick_i == 1'b1) && (counter == data_bit_num)) begin
                    fsm_next_state = FSM_STOP;
                end 
            end

            FSM_STOP: begin
                if ((baud_tick_i == 1'b1) && (counter == stop_bit_num)) begin
                    if (en_i == 1'b1) begin
                        fsm_next_state = FSM_START;
                    end else begin
                        fsm_next_state = FSM_IDLE;
                    end
                end
            end

            default: begin
                fsm_next_state = FSM_IDLE;
            end
        endcase 
    end

    always_ff @ (posedge clk_i) begin
        if (s_rst_n_i == 1'b0) begin
            mux_sel_o     <= 1'b0;
            baud_gen_en_o <= 1'b0;
            piso_wr_en_o  <= 1'b0;
            piso_en_o     <= 1'b0;

            data_o        <= 1'b1;
            counter       <= '0;

            data_bit_num  <= '0;
            stop_bit_num  <= 1'b0;

            fifo_rd_en_o  <= 1'b0;
        end else begin
            case (fsm_state) 
            FSM_IDLE: begin
                if (en_i == 1'b1) begin
                    baud_gen_en_o <= 1'b1;

                    piso_wr_en_o  <= 1'b1;
  
                    data_o        <= 1'b0;

                    data_bit_num  <= data_bit_num_i - 1'b1;
                    stop_bit_num  <= stop_bit_num_i;

                    fifo_rd_en_o  <= 1'b1;
                end
            end

            FSM_START: begin
                piso_wr_en_o <= 1'b0;
                fifo_rd_en_o <= 1'b0;

                if (baud_tick_i == 1'b1) begin

                    mux_sel_o <= 1'b1;
                    piso_en_o <= 1'b1;
                end
            end

            FSM_SEND: begin
                mux_sel_o <= 1'b1;

                if (baud_tick_i == 1'b1) begin
                    counter <= counter + 1'b1;

                    if (counter == data_bit_num) begin
                        mux_sel_o <= 1'b0;
                        piso_en_o <= 1'b0;
                        data_o    <= 1'b1;
                        counter   <= '0;
                    end
                end 
            end

            FSM_STOP: begin
                if (baud_tick_i == 1'b1) begin
                    counter <= counter + 1'b1;

                    if (counter == stop_bit_num) begin
                        if (en_i == 1'b1) begin

                            data_o  <= 1'b0;
                            counter <= '0;

                            piso_wr_en_o  <= 1'b1;

                            fifo_rd_en_o  <= 1'b1;
                        end else begin
                            baud_gen_en_o <= 1'b0;
                        end
                    end
                end
            end

            default: begin
                baud_gen_en_o <= 1'b0;
            end
            endcase 
        end
    end
endmodule