`timescale 1ns / 1ps

module tb_FsmDetect;

    reg clk;
    reg reset;
    reg serial_in;
    wire unlock;

    FsmDetect uut (
        .clk(clk),
        .reset(reset),
        .serial_in(serial_in),
        .unlock(unlock)
    );

    always #5 clk = ~clk;

    reg [4:0] test_data = 5'b10101;
    integer i;

    initial begin
        clk = 0;
        reset = 1;
        serial_in = 0;

        #10;
        @(posedge clk);
        #1;
        reset = 0;

        $display("--- Starting FsmDetect Simulation ---");
        $display("Cycle | serial_in | state | unlock");

        for (i = 4; i >= 0; i = i - 1) begin
            serial_in = test_data[i];
            @(posedge clk);
            #1;
            $display("  %0d   |     %b     |  %b   |   %b", 5 - i, serial_in, uut.state, unlock);
        end

        #20;
        $finish;
    end

endmodule
