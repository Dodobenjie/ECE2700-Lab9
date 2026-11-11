module ShiftDetect (
    input  wire clk,
    input  wire reset,
    input  wire serial_in,
    output wire unlock
);

    reg [2:0] shift;

    // Shift register logic (synchronous reset)
    always @(posedge clk) begin
        if (reset) begin
            shift <= 3'b000;
        end else begin
            shift <= {shift[1:0], serial_in};
        end
    end

    // Combinational comparison
    assign unlock = (shift == 3'b101);

endmodule