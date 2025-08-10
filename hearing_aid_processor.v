// Top-level dual-stage hearing aid noise removal processor
module hearing_aid_processor(
    input  wire         clk,
    input  wire         rst_n,
    input  wire signed [15:0] audio_in,
    input  wire         audio_valid,
    output wire signed [15:0] audio_out,
    output wire         audio_ready
);
    // Internal connections
    wire signed [15:0] stage1_out, stage2_out;
    wire stage1_ready, stage2_ready;

    // Stage 1: Spectral subtraction
    spectral_subtraction_stage stage1 (
        .clk(clk), .rst_n(rst_n),
        .audio_in(audio_in),
        .audio_valid(audio_valid),
        .audio_out(stage1_out),
        .audio_ready(stage1_ready)
    );

    // Stage 2: LMS adaptive filter
    lms_filter_stage stage2 (
        .clk(clk), .rst_n(rst_n),
        .audio_in(stage1_out),
        .audio_valid(stage1_ready),
        .audio_out(stage2_out),
        .audio_ready(stage2_ready)
    );

    // Output assignment
    assign audio_out   = stage2_out;
    assign audio_ready = stage2_ready;
endmodule
