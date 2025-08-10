// LMS Adaptive Filter Stage
module lms_filter_stage #(
    parameter FILTER_ORDER = 16,
    parameter DATA_WIDTH   = 16,
    parameter STEP_SIZE    = 16'h0100   // μ = 1/256
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire signed [DATA_WIDTH-1:0] audio_in,
    input  wire                  audio_valid,
    output reg signed [DATA_WIDTH-1:0] audio_out,
    output reg                   audio_ready
);
    reg signed [DATA_WIDTH-1:0] weights [0:FILTER_ORDER-1];
    reg signed [DATA_WIDTH-1:0] delay_line [0:FILTER_ORDER-1];
    reg signed [DATA_WIDTH-1:0] desired_signal;
    reg signed [2*DATA_WIDTH-1:0] filter_output_acc;
    reg signed [DATA_WIDTH-1:0] filter_output, error_signal;
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < FILTER_ORDER; i=i+1) begin
                weights[i] <= 0;
                delay_line[i] <= 0;
            end
            filter_output <= 0;
            audio_out <= 0;
            audio_ready <= 0;
        end else if (audio_valid) begin
            // Shift delay line
            for (i = FILTER_ORDER-1; i > 0; i=i-1) begin
                delay_line[i] <= delay_line[i-1];
            end
            delay_line[0] <= audio_in;

            // Compute filter output (MAC)
            filter_output_acc = 0;
            for (i = 0; i < FILTER_ORDER; i=i+1) begin
                filter_output_acc = filter_output_acc + weights[i] * delay_line[i];
            end
            filter_output <= filter_output_acc[2*DATA_WIDTH-2:DATA_WIDTH-1];

            // Desired signal: delayed version
            desired_signal <= delay_line[FILTER_ORDER/2];

            // Error calculation
            error_signal <= desired_signal - filter_output;

            // Update weights (LMS)
            for (i = 0; i < FILTER_ORDER; i=i+1) begin
                weights[i] <= weights[i] + ((STEP_SIZE * error_signal * delay_line[i]) >>> 16);
            end

            // Output
            audio_out <= filter_output;
            audio_ready <= 1;
        end else begin
            audio_ready <= 0;
        end
    end
endmodule
