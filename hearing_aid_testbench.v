// Testbench for the hearing aid processor
module hearing_aid_testbench;
    reg         clk, rst_n;
    reg signed [15:0] audio_in;
    reg         audio_valid;
    wire signed [15:0] audio_out;
    wire        audio_ready;
    real        phase;

    // Instantiate DUT
    hearing_aid_processor dut (
        .clk(clk), .rst_n(rst_n),
        .audio_in(audio_in), .audio_valid(audio_valid),
        .audio_out(audio_out), .audio_ready(audio_ready)
    );

    // Clock generation (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        $dumpfile("hearing_aid.vcd");          // Name of VCD file to create
        $dumpvars(0, hearing_aid_testbench);   // Dump all signals in the testbench
        rst_n = 0;
        audio_valid = 0;
        audio_in = 0;
        phase = 0.0;
        #100; // Reset duration
        rst_n = 1;

        repeat (1000) begin
            @(posedge clk);
            // Sine wave + noise
            phase = phase + 0.05;
            audio_in    <= $rtoi(1000.0 * $sin(phase)) + ($random % 512);
            audio_valid <= 1;
            @(posedge clk);
            audio_valid <= 0;
            repeat (4) @(posedge clk);
        end

        $finish;
    end

    // Output monitor
    always @(posedge clk) begin
        if (audio_ready) begin
            $display("Time %0t: Input=%d, Output=%d",
                     $time, audio_in, audio_out);
        end
    end
endmodule
