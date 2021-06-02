module uart_tx # 
(
    parameter integer MAX_DATA_BIT_NUM = 8
)
(
    input  wire                                    clk_i                 ,
    input  wire                                    s_rst_n_i             ,
    input  wire                                    enable_i              ,
    
    output wire                                    piso_en_o             ,
    output wire                                    piso_data_we_o        ,
    input  wire                                    piso_serial_i         ,

    output wire                                    data_bit_cnter_en_o   ,
    output wire                                    data_bit_cnter_rst_n_o,
    input  wire                                    data_bit_num_i        ,
    input  wire [$clog2(MAX_DATA_BIT_NUM) - 1 : 0] data_bit_cnter_val_i  ,
    
    input wire                                     stop_bit_num_i        ,
    
    output wire                                    baud_gen_cnter_en_o   ,
    output wire                                    baud_gen_cnter_rst_n_o,
    input  wire                                    baud_tick_i           ,
    
    output wire                                    start_complete_o      ,
    output wire                                    data_complete_o       ,
    output wire                                    tx_complete_o         ,

    output wire                                    tx_o
);

    localparam integer                 FSM_STATE_NUM = 4;
    localparam [FSM_STATE_NUM - 1 : 0] IDLE_STATE    = 0;        
    localparam [FSM_STATE_NUM - 1 : 0] START_STATE   = 1;
    localparam [FSM_STATE_NUM - 1 : 0] SEND_STATE    = 2;
    localparam [FSM_STATE_NUM - 1 : 0] STOP_STATE    = 3; 
    
    wire [MAX_DATA_BIT_NUM - 1 : 0] data_bit_num;     
    
    reg                           piso_en            ;
    reg                           piso_data_we       ;
    
    reg                           data_bit_cnter_en  ;

    reg                           baud_gen_counter_en;
   
    reg                           stop_bit_num       ;
    
    reg                           start_complete     ;
    reg                           data_complete      ;
    reg                           tx_complete        ;

    reg [FSM_STATE_NUM - 1 : 0]   fsm_state          ; 
    
    assign piso_en_o              = ((1'h1 == piso_en) && (1'h1 ==  baud_tick_i))                   ;
    assign piso_data_we_o         = piso_data_we                                                    ;
    
    assign data_bit_num           = data_bit_num_i ? 4'h7 : 4'h8                                    ;
    assign data_bit_cnter_en_o    = ((1'h1 == data_bit_cnter_en) && (1'h1 == baud_tick_i))          ;
    assign data_bit_cnter_rst_n_o = ~((1'h0 == s_rst_n_i) || (data_bit_num == data_bit_cnter_val_i));

    assign baud_gen_cnter_en_o    = baud_gen_counter_en                                             ;
    assign baud_gen_cnter_rst_n_o = ~((1'h0 == s_rst_n_i) || (1'h1 == baud_tick_i))                 ;
    
    assign start_complete_o       = start_complete;
    assign data_complete_o        = data_complete;
    assign tx_complete_o          = tx_complete;
    
    assign tx_o                   = (START_STATE == fsm_state) ? 1'h0 : 
                                    (SEND_STATE == fsm_state)  ? piso_serial_i : 1'h1               ;

    always @(posedge clk_i) begin
        if (1'h0 == s_rst_n_i) begin
            piso_en             <= 1'h0;
            piso_data_we        <= 1'h0;
            
            data_bit_cnter_en   <= 1'h0;
            
            baud_gen_counter_en <= 1'h0;
            
            stop_bit_num        <= 1'h0;
            start_complete      <= 1'h0;
            data_complete       <= 1'h0;
            tx_complete         <= 1'h0;
            
            fsm_state           <= IDLE_STATE;
        end
        else begin
            case (fsm_state)
            IDLE_STATE: begin
                if (1'h1 == enable_i) begin
                    baud_gen_counter_en <= 1'h1;
                    
                    start_complete      <= 1'h0;
                    data_complete       <= 1'h0;
                    tx_complete         <= 1'h0;
                    
                    fsm_state           <= START_STATE;
                end
            end
            START_STATE: begin
                tx_complete <= 1'h0;
                
                if (1'h1 == baud_tick_i) begin
                    piso_en           <= 1'h1;
                    piso_data_we      <= 1'h1;
                    
                    data_bit_cnter_en <= 1'h1;
                    
                    stop_bit_num      <= stop_bit_num_i;
                    start_complete    <= 1'h1;
                    
                    fsm_state         <= SEND_STATE;
                end
            end
            SEND_STATE: begin
                piso_data_we <= 1'h0;
                
                if (1'h1 == baud_tick_i) begin
                    if ((data_bit_num - 1) == data_bit_cnter_val_i) begin 
                       piso_en           <= 1'h0;
                       
                       data_bit_cnter_en <= 1'h0;
                       data_complete     <= 1'h1;
                       
                       fsm_state         <= STOP_STATE; 
                    end 
                end
            end
            STOP_STATE: begin
                if (1'h1 == baud_tick_i) begin
                    if (1'h1 == stop_bit_num) begin
                      stop_bit_num <= 1'h0;
                    end 
                    else begin                                                        
                        baud_gen_counter_en <= 1'h0;
                        tx_complete         <= 1'h1;
                        
                        fsm_state           <= IDLE_STATE;
                    end
                end
            end 
            default : begin
                piso_en             <= 1'h0;
                piso_data_we        <= 1'h0;
                
                data_bit_cnter_en   <= 1'h0;
                
                baud_gen_counter_en <= 1'h0; 
                stop_bit_num        <= 1'h0;
                tx_complete         <= 1'h0;
                
                fsm_state           <= IDLE_STATE; 
            end
            endcase
        end
    end
endmodule