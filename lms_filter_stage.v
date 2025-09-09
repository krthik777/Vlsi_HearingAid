// lms_filter_stage.v
// Functional LMS adaptive FIR filter (Verilog-2001, Icarus-compatible)
//
// Fixed-point conventions:
// - Samples and weights are Q1.15 signed (16-bit).
// - Output y[n] = sum_i w[i]*x[n-i], scaled back to Q1.15 via >>> 15.
// - LMS update: w[i] = w[i] + mu * e[n] * x[n-i]
//   We compute tmp = (e*x) >>> 15 (keep Q1.15), then w += (mu*tmp) >>> 15.
//
// Notes:
// - Choose STEP_SIZE (mu) small enough for stability, e.g. 0x0100 (~0.0039) to 0x0400 (~0.0156).
// - FILTER_ORDER ~ 16..64 typically. Larger => slower convergence but more modeling capacity.

`timescale 1ns/1ps
module lms_filter_stage #(
    parameter integer FILTER_ORDER = 16,
    parameter integer DATA_WIDTH   = 16,
    // STEP_SIZE in Q1.15 (0x4000 ~ 0.5). Start small (0x0100..0x0400).
    parameter signed [15:0] STEP_SIZE = 16'h0100
)(
    input  wire                           clk,
    input  wire                           rst_n,
    input  wire signed [DATA_WIDTH-1:0]   audio_in,     // x[n]
    input  wire                           audio_valid,
    output reg  signed [DATA_WIDTH-1:0]   audio_out,    // y[n]
    output reg                            audio_ready
);

    // Delay line and weights
    reg signed [DATA_WIDTH-1:0] delay_line [0:FILTER_ORDER-1];
    reg signed [DATA_WIDTH-1:0] weights    [0:FILTER_ORDER-1];

    integer i;

    // Wide accumulators / temporaries
    reg signed [63:0] acc;            // MAC accumulator
    reg signed [31:0] prod32;         // 16x16 -> 32
    reg signed [31:0] e_times_x_q15;  // (e*x) >>> 15 -> Q1.15 in 32 bits
    reg signed [47:0] mu_mul_tmp;     // STEP_SIZE (16) * e_times_x_q15 (32) -> 48
    reg signed [31:0] w_update_q15;   // (mu*tmp) >>> 15 -> back to Q1.15 (approx 16-bit)
    reg signed [15:0] y_q15;          // saturated 16-bit filter output
    reg signed [15:0] error_q15;      // e[n] = d[n] - y[n]; here d[n] = audio_in (ALE mode)

    // 16-bit signed saturation from a wider value
    function [15:0] sat16;
        input signed [31:0] vin;
        begin
            if (vin > 32'sd32767)      sat16 = 16'sd32767;
            else if (vin < -32'sd32768) sat16 = -16'sd32768;
            else                        sat16 = vin[15:0];
        end
    endfunction

    // 16-bit signed saturation from 64-bit (for MAC result after scaling)
    function [15:0] sat16_from64;
        input signed [63:0] vin64;
        reg   signed [31:0] vin32;
        begin
            vin32 = vin64[31:0]; // we will apply scaling before calling this
            if (vin32 > 32'sd32767)       sat16_from64 = 16'sd32767;
            else if (vin32 < -32'sd32768) sat16_from64 = -16'sd32768;
            else                           sat16_from64 = vin32[15:0];
        end
    endfunction

    // Reset logic
    integer r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (r = 0; r < FILTER_ORDER; r = r + 1) begin
                delay_line[r] <= 0;
                weights[r]    <= 0;
            end
            audio_out   <= 0;
            audio_ready <= 0;
        end else begin
            // Default deassert ready unless we produce a sample this cycle
            audio_ready <= 0;

            if (audio_valid) begin
                // Shift delay line: newest sample at index 0
                for (i = FILTER_ORDER-1; i > 0; i = i - 1) begin
                    delay_line[i] <= delay_line[i-1];
                end
                delay_line[0] <= audio_in;

                // Compute filter output: acc = sum(weights[i] * delay_line[i])
                acc = 64'sd0;
                for (i = 0; i < FILTER_ORDER; i = i + 1) begin
                    // sign-extend to 32-bit before multiply to avoid unintended unsigned
                    prod32 = $signed(weights[i]) * $signed(delay_line[i]); // 16x16 -> 32
                    acc = acc + {{32{prod32[31]}}, prod32};                // accumulate as 64
                end

                // Scale back to Q1.15: (sum of Q1.15 * Q1.15) -> Q2.30; >>>15 -> Q1.15
                // Note: acc currently holds sum of 32-bit products with implicit Q2.30.
                // We right-shift by 15 to return to Q1.15 for 16-bit output.
                y_q15 = sat16_from64( acc >>> 15 );

                // Output and ready
                audio_out   <= y_q15;
                audio_ready <= 1'b1;

                // Error (Adaptive Line Enhancer mode): desired d[n] ≡ input x[n]
                // e[n] = d[n] - y[n] = x[n] - y[n]
                error_q15 = $signed(audio_in) - $signed(y_q15);

                // LMS weight update: w[i] = w[i] + mu * e * x_i
                // tmp = (e * x_i) >>> 15  (keep Q1.15)
                // delta = (mu * tmp) >>> 15  (Q1.15)
                for (i = 0; i < FILTER_ORDER; i = i + 1) begin
                    prod32       = $signed(error_q15) * $signed(delay_line[i]);    // 16x16 -> 32 (Q2.30)
                    e_times_x_q15= $signed(prod32) >>> 15;                         // -> Q1.15 (32-bit)
                    mu_mul_tmp   = $signed({{16{STEP_SIZE[15]}}, STEP_SIZE}) * $signed(e_times_x_q15); // 16x32 -> 48
                    w_update_q15 = $signed(mu_mul_tmp >>> 15);                     // -> Q1.15 (approx 32)

                    // Saturating add back into 16-bit weight
                    weights[i] <= sat16( $signed({{16{weights[i][15]}}, weights[i]}) + $signed(w_update_q15) );
                end
            end
        end
    end

endmodule
