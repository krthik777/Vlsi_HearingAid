// hearing_aid_processor.v
// Top-level: chains spectral subtraction and LMS filter

module hearing_aid_processor (
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire signed [15:0]   audio_in,
    input  wire                 audio_valid,
    output wire signed [15:0]   audio_out,
    output wire                 audio_ready
);

    // Wires between stages
    wire signed [15:0] stage1_out;
    wire               stage1_ready;

    spectral_subtraction_stage u_stage1 (
        .clk(clk), .rst_n(rst_n),
        .audio_in(audio_in),
        .audio_valid(audio_valid),
        .audio_out(stage1_out),
        .audio_ready(stage1_ready)
    );

    lms_filter_stage u_stage2 (
        .clk(clk), .rst_n(rst_n),
        .audio_in(stage1_out),
        .audio_valid(stage1_ready),
        .audio_out(audio_out),
        .audio_ready(audio_ready)
    );

endmodule
