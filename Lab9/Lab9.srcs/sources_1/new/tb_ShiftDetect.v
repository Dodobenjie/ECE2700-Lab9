`timescale 1ns / 1ps

module tb_ShiftDetect;

    reg clk;
    reg reset;
    reg serial_in;
    wire unlock;

    // Instantiate unit under test (UUT)
    ShiftDetect uut (
        .clk(clk),
        .reset(reset),
        .serial_in(serial_in),
        .unlock(unlock)
    );

    // Clock generation: 10ns period (100 MHz)
    always #5 clk = ~clk;

    // Test sequence array: 1 0 1 0 1
    reg [4:0] test_data = 5'b10101; 
    integer i;

    initial begin
        clk = 0;
        reset = 1;
        serial_in = 0;

        // Apply reset for 2 cycles
        #10;
        @(posedge clk);
        #1;
        reset = 0;

        $display("--- Starting ShiftDetect Simulation ---");
        $display("Cycle | serial_in | shift | unlock");

        // Feed bits 1, 0, 1, 0, 1 (MSB first)
        for (i = 4; i >= 0; i = i - 1) begin
            serial_in = test_data[i];
            @(posedge clk);
            #1; // Sample shortly after clock edge
            $display("  %0d   |     %b     |  %b  |   %b", 5 - i, serial_in, uut.shift, unlock);
        end

        #20;
        $finish;
    end

endmodule