module Basys3_Top (
    input  wire       clk,      // Onboard 100MHz clock (W5)
    input  wire [0:0] sw,       // sw[0] = serial_in (V17)
    input  wire       btnC,     // btnC  = manual clock pulse (U18)
    input  wire       btnU,     // btnU  = synchronous reset (T18)
    output wire [0:0] led       // led[0]= unlock indicator (U16)
);

    // Simple single-pulse synchronizer for btnC
    reg btn_sync_0, btn_sync_1, btn_prev;
    wire step_pulse;

    always @(posedge clk) begin
        btn_sync_0 <= btnC;
        btn_sync_1 <= btn_sync_0;
        btn_prev   <= btn_sync_1;
    end

    // Generates a 1-clock-cycle pulse when button is pressed
    assign step_pulse = btn_sync_1 & ~btn_prev;

    // Instantiate FSM Detector using pulsed clock enable
    reg [1:0] state, next_state;

    localparam S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;

    always @(posedge clk) begin
        if (btnU) begin
            state <= S0;
        end else if (step_pulse) begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = S0;
        case (state)
            S0: next_state = sw[0] ? S1 : S0;
            S1: next_state = sw[0] ? S1 : S2;
            S2: next_state = sw[0] ? S3 : S0;
            S3: next_state = sw[0] ? S1 : S2;
            default: next_state = S0;
        endcase
    end

    assign led[0] = (state == S3);

endmodule
