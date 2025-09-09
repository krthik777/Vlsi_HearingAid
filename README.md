# Hearing Aid Noise Removal – Verilog Simulation

## 📌 Overview
This project implements a **dual-stage noise removal system for hearing aids** in Verilog, based on the design from the paper *"Real-Time Noise Removal System for Hearing Aids: VLSI Implementation and Design Methodology"*.

The architecture consists of:  
1. **Spectral Subtraction Stage** – Estimates background noise from initial samples and subtracts it from the incoming audio.  
2. **LMS Adaptive Filter Stage** – Performs adaptive filtering to further suppress residual noise.  

A **Verilog testbench** simulates the system with input audio samples (from a file) and writes the processed output to another file.  

---

## 🗂 Project Structure
```
├── hearing_aid_processor.v           # Top-level module integrating both stages
├── spectral_subtraction_stage.v      # Stage 1: Noise estimation & subtraction
├── lms_filter_stage.v                # Stage 2: LMS adaptive FIR filter
├── hearing_aid_file_tb.v             # Testbench: reads samples from file, writes results
├── input_samples.txt                 # Input audio samples (signed integers, one per line)
├── output_samples.txt                # Output samples after processing
└── README.md                         # Project documentation
```

---

## ⚙ Requirements
- [Icarus Verilog](https://bleyer.org/icarus/) (for compiling & simulation)  
- [GTKWave](http://gtkwave.sourceforge.net/) (optional, for waveform viewing if VCD dump is added)  
- A script/tool to convert `.wav` or `.mp3` audio into **16-bit signed integer PCM samples** for `input_samples.txt`.  

---

## 🚀 Getting Started

### 1. Clone this repository
```bash
git clone https://github.com/yourusername/hearing-aid-verilog.git
cd hearing-aid-verilog
```

### 2. Prepare input samples
Convert your `.wav` / `.mp3` file into 16-bit signed integers (e.g., using Python or MATLAB) and save them into:
```
input_samples.txt
```
Each line should contain one integer sample in the range `-32768` to `32767`.

### 3. Compile the project
```bash
iverilog -g2012 -o hearing_aid_sim hearing_aid_processor.v spectral_subtraction_stage.v lms_filter_stage.v hearing_aid_file_tb.v
```

### 4. Run the simulation
```bash
vvp hearing_aid_sim
```

This will read from `input_samples.txt` and generate `output_samples.txt`.

### 5. (Optional) View waveforms in GTKWave
If `$dumpfile`/`$dumpvars` are enabled in the testbench:
```bash
gtkwave hearing_aid.vcd
```

---

## 🔧 Parameters You Can Tune
- `NOISE_LEN` in `spectral_subtraction_stage.v` → Number of samples used for noise estimation  
- `FILTER_ORDER` in `lms_filter_stage.v` → Number of FIR filter taps  
- `STEP_SIZE` in `lms_filter_stage.v` → LMS adaptation step size  

---

## ⚠ Notes
- Make sure `input_samples.txt` contains **more samples than `NOISE_LEN`**, otherwise no output will be produced.  
- The output is written sample-by-sample into `output_samples.txt`.  
- Use external tools to convert `output_samples.txt` back into an audio file for listening tests.  

---
