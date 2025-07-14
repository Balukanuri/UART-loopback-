// Code your design here
// design.sv

// UART Transmitter Module
module uart_tx (
    input logic clk,
    input logic reset,
    input logic start_tx,
    input logic [7:0] data_in,
    output logic tx,
    output logic busy
);
    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;
    logic [7:0] shift_reg;
    logic [2:0] bit_index;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            tx <= 1;
            busy <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1;
                    busy <= 0;
                    if (start_tx) begin
                        shift_reg <= data_in;
                        bit_index <= 0;
                        busy <= 1;
                        state <= START;
                    end
                end
                START: begin
                    tx <= 0;
                    state <= DATA;
                end
                DATA: begin
                    tx <= shift_reg[bit_index];
                    bit_index <= bit_index + 1;
                    if (bit_index == 7)
                        state <= STOP;
                end
                STOP: begin
                    tx <= 1;
                    busy <= 0;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule


// UART Receiver Module
module uart_rx (
    input logic clk,
    input logic reset,
    input logic rx,
    output logic [7:0] data_out,
    output logic rx_done
);
    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;
    logic [7:0] buffer;
    logic [2:0] bit_index;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            rx_done <= 0;
            data_out <= 0;
        end else begin
            case (state)
                IDLE: begin
                    rx_done <= 0;
                    if (!rx) state <= START;
                end
                START: begin
                    state <= DATA;
                    bit_index <= 0;
                end
                DATA: begin
                    buffer[bit_index] <= rx;
                    bit_index <= bit_index + 1;
                    if (bit_index == 7)
                        state <= STOP;
                end
                STOP: begin
                    if (rx == 1) begin
                        data_out <= buffer;
                        rx_done <= 1;
                    end
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
Added design from EDA Playground
