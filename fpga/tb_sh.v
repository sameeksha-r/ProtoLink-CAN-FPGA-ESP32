`timescale 1ns / 1ps

module tb_sh;

    reg clk = 0;
    reg reset = 1;
    reg [2:0] id_bits;
    reg [1:0] data_bits;
    reg error_inject;

    wire can_out;
    wire tx_led;

    // Instantiate transmitter (SH)
    sh uut_tx (
        .clk(clk),
        .reset(reset),
        .id_bits(id_bits),
        .data_bits(data_bits),
        .error_inject(error_inject),
        .can_out(can_out),
        .tx_led(tx_led)
    );

    // Clock generation (100MHz)
    always #5 clk = ~clk;

    initial begin
        $display("=== TX (Transmitter Only) Testbench ===");

        // Initial reset
        reset = 1;
        id_bits = 3'b000;
        data_bits = 2'b01;
        error_inject = 0;
        #50;
        reset = 0;
        

        // Test Frame 1
        id_bits = 3'b000;
        data_bits = 2'b01;
        error_inject = 0;
        #2000;

        // Test Frame 2
        id_bits = 3'b001;
        data_bits = 2'b10;
        error_inject = 1;
        #2000;

        // Test Frame 3
        id_bits = 3'b010;
        data_bits = 2'b11;
        error_inject = 0;
        #2000;

        // Test Frame 4
        id_bits = 3'b111;
        data_bits = 2'b00;
        error_inject = 0;
        #2000;

        $display("=== Simulation complete ===");
        $stop;
    end

endmodule