module FsmDetect (
    input  wire clk,
    input  wire reset,
    input  wire serial_in,
    output reg  unlock
);

    // Binary state encoding (2 flip-flops)
    localparam S0 = 2'b00; // No progress
    localparam S1 = 2'b01; // Saw "1"
    localparam S2 = 2'b10; // Saw "10"
    localparam S3 = 2'b11; // Saw "101" (unlock)

    reg [1:0] state, next_state;

    // Block 1: Clocked block for state register (synchronous reset)
    always @(posedge clk) begin
        if (reset) begin
            state <= S0;
        end else begin
            state <= next_state;
        end
    end

    // Block 2: Combinational block for next_state and output
    always @(*) begin
        // Default assignments to prevent latches
        next_state = S0;
        unlock     = 1'b0;

        case (state)
            S0: begin
                unlock = 1'b0;
                if (serial_in)
                    next_state = S1;
                else
                    next_state = S0;
            end

            S1: begin
                unlock = 1'b0;
                if (serial_in)
                    next_state = S1;
                else
                    next_state = S2;
            end

            S2: begin
                unlock = 1'b0;
                if (serial_in)
                    next_state = S3;
                else
                    next_state = S0;
            end

            S3: begin
                unlock = 1'b1;
                // Overlapping condition from '101'
                if (serial_in)
                    next_state = S1; // '101' + '1' -> suffix '1'
                else
                    next_state = S2; // '101' + '0' -> suffix '10'
            end

            default: begin
                next_state = S0;
                unlock     = 1'b0;
            end
        endcase
    end

endmodule