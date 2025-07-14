// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

module testbench;

    logic clk = 0, reset = 1;
    logic start_tx, busy, rx_done;
    logic [7:0] data_in, data_out;
    logic tx;

    // Clock generation
    always #5 clk = ~clk;  // 100MHz

    uart_tx tx_inst (
        .clk(clk),
        .reset(reset),
        .start_tx(start_tx),
        .data_in(data_in),
        .tx(tx),
        .busy(busy)
    );

    uart_rx rx_inst (
        .clk(clk),
        .reset(reset),
        .rx(tx),
        .data_out(data_out),
        .rx_done(rx_done)
    );

    initial begin
        $dumpfile("uart_loopback_wave.vcd");
        $dumpvars(0);

        reset = 1;
        #20;
        reset = 0;

        data_in = 8'hA5; // example byte
        start_tx = 1;
        #10;
        start_tx = 0;

        wait(rx_done);
        #10;

        if (data_out == data_in)
            $display("✅ PASS: TX→RX Loopback successful. Data: %h", data_out);
        else
            $display("❌ FAIL: TX→RX mismatch. Sent: %h, Received: %h", data_in, data_out);

        $finish;
    end

endmodule
Added design from EDA Playground
