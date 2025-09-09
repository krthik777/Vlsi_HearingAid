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
├── wav_to_txt.py                     # Converts .wav → input_samples.txt
├── txt_to_wav.py                     # Converts output_samples.txt → .wav
├── input_samples.txt                 # Input audio samples
├── output_samples.txt                # Processed samples after noise removal
└── README.md                         # Project documentation
```

---

## ⚙ Requirements
- [Icarus Verilog](https://bleyer.org/icarus/) (compile & simulation)  
- [GTKWave](http://gtkwave.sourceforge.net/) (optional waveform viewer)  
- [Python 3](https://www.python.org/) with `numpy` and `soundfile`  
- [FFmpeg](https://ffmpeg.org/) (for audio conversion & playback)  

---

## 🚀 Workflow

### 1. Convert input audio to `.wav` format
```bash
ffmpeg -i input.mp3 -ac 1 -ar 16000 -sample_fmt s16 output.wav
```

### 2. Convert `.wav` to text samples
```bash
python wav_to_txt.py output.wav input_samples.txt
```

### 3. Run Verilog simulation
```bash
iverilog -g2012 -o hearing_aid_sim hearing_aid_processor.v spectral_subtraction_stage.v lms_filter_stage.v hearing_aid_file_tb.v
vvp hearing_aid_sim
```

### 4. Convert simulation output back to `.wav`
```bash
python txt_to_wav.py output_samples.txt output.wav 16000
```

### 5. Play denoised output
```bash
ffplay -nodisp -autoexit output.wav
```

---

## 🔧 Parameters You Can Tune
- `NOISE_LEN` in `spectral_subtraction_stage.v` → Number of samples used for noise estimation  
- `FILTER_ORDER` in `lms_filter_stage.v` → Number of FIR filter taps  
- `STEP_SIZE` in `lms_filter_stage.v` → LMS adaptation step size  

---

## ⚠ Notes
- Ensure `input_samples.txt` has **more samples than `NOISE_LEN`**, otherwise no output will be produced.  
- The output is written sample-by-sample into `output_samples.txt`.  
- Use `txt_to_wav.py` and `ffplay` to quickly check results.  

---
