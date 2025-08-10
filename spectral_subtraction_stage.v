// Simplified Spectral Subtraction Stage
module spectral_subtraction_stage(
    input  wire         clk,
    input  wire         rst_n,
    input  wire signed [15:0] audio_in,
    input  wire         audio_valid,
    output reg signed [15:0] audio_out,
    output reg          audio_ready
);
    parameter integer NOISE_LEN = 256; // Number of samples for noise estimate
    reg [31:0] noise_sum;
    reg [15:0] noise_est;
    reg [7:0]  count;
    reg        noise_ready;

    wire [15:0] abs_sample = (audio_in[15] ? -audio_in : audio_in);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            noise_sum   <= 0;
            count       <= 0;
            noise_est   <= 0;
            noise_ready <= 0;
            audio_out   <= 0;
            audio_ready <= 0;
        end else if (audio_valid) begin
            if (!noise_ready) begin
                // Accumulate noise estimate
                noise_sum <= noise_sum + abs_sample;
                count <= count + 1;
                if (count == NOISE_LEN-1) begin
                    noise_est   <= noise_sum >> 8; // divide by 256
                    noise_ready <= 1;
                end
                audio_ready <= 0;
            end else begin
                // Subtract noise estimate
                if (audio_in >= 0) begin
                    if (audio_in > noise_est)
                        audio_out <= audio_in - noise_est;
                    else
                        audio_out <= 0;
                end else begin
                    if (audio_in < -noise_est)
                        audio_out <= audio_in + noise_est;
                    else
                        audio_out <= 0;
                end
                audio_ready <= 1;
            end
        end else begin
            audio_ready <= 0;
        end
    end
endmodule
