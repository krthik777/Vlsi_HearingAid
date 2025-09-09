// hearing_aid_file_tb.v
// Testbench: reads audio samples from text file, writes processed output to text file

`timescale 1ns/1ps
module hearing_aid_file_tb;

    // For simulation we can choose cycles-per-sample to speed up runs.
    // Set CYCLES_PER_SAMPLE = 1 to produce one sample per clock (fast simulation).
    parameter integer CLK_FREQ_HZ        = 100_000_000;
    parameter integer SAMPLE_RATE_HZ     = 16000;
    parameter integer CYCLES_PER_SAMPLE  = 1;

    reg clk;
    reg rst_n;
    reg signed [15:0] audio_in;
    reg audio_valid;
    wire signed [15:0] audio_out;
    wire audio_ready;

    hearing_aid_processor dut (
        .clk(clk), .rst_n(rst_n),
        .audio_in(audio_in), .audio_valid(audio_valid),
        .audio_out(audio_out), .audio_ready(audio_ready)
    );

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz
    end

    // Sample rate tick (simpler counter for faster simulation).
    // CYCLES_PER_SAMPLE controls how many clock cycles elapse per audio sample.
    // For fast simulation set to 1 (one sample produced each clk).
    reg [31:0] sample_cycle_cnt;
    reg sample_tick;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sample_cycle_cnt <= 0;
            sample_tick <= 0;
        end else begin
            if (sample_cycle_cnt + 1 >= CYCLES_PER_SAMPLE) begin
                sample_cycle_cnt <= 0;
                sample_tick <= 1;
            end else begin
                sample_cycle_cnt <= sample_cycle_cnt + 1;
                sample_tick <= 0;
            end
        end
    end

    // File I/O
    integer infile, outfile;
    integer ret;
    reg signed [31:0] temp32;
    reg eof_flag;

    initial begin
        infile  = $fopen("input_samples.txt","r");
        outfile = $fopen("output_samples.txt","w");
        if (infile==0 || outfile==0) begin
            $display("File open error");
            $finish;
        end

        rst_n = 0; audio_in=0; audio_valid=0; eof_flag=0;
        repeat(20) @(posedge clk);
        rst_n = 1;

        while (!eof_flag) begin
            @(posedge clk);
            if (sample_tick) begin
                ret = $fscanf(infile,"%d\n",temp32);
                if (ret!=1) begin
                    eof_flag = 1;
                    audio_valid <= 0;
                end else begin
                    if (temp32>32767) temp32=32767;
                    else if (temp32<-32768) temp32=-32768;
                    audio_in    <= temp32[15:0];
                    audio_valid <= 1;
                end
            end else begin
                audio_valid <= 0;
            end

            if (audio_ready) begin
                $fwrite(outfile,"%0d\n",audio_out);
            end
        end

        $fclose(infile);
        $fclose(outfile);
        $display("Simulation done, output_samples.txt written.");
        #100 $finish;
    end

endmodule
