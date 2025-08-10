# Hearing Aid Noise Removal – Verilog Simulation

## 📌 Overview
This project implements a **dual-stage noise removal system for hearing aids** in Verilog, based on the design from the paper *"Real-Time Noise Removal System for Hearing Aids: VLSI Implementation and Design Methodology"*.

The architecture consists of:
1. **Spectral Subtraction Stage** – Estimates background noise from initial samples and subtracts it from the incoming audio.
2. **LMS Adaptive Filter Stage** – Performs adaptive filtering to further suppress residual noise.

A **Verilog testbench** simulates the system with a noisy sine wave input, and waveform output can be viewed using GTKWave.

---

## 🗂 Project Structure
```
├── hearing_aid_processor.v           # Top-level module integrating both stages
├── spectral_subtraction_stage.v      # Stage 1: Noise estimation & subtraction
├── lms_filter_stage.v                 # Stage 2: LMS adaptive FIR filter
├── hearing_aid_testbench.v           # Testbench for simulation
└── README.md                         # Project documentation
```

---

## ⚙ Requirements
- [Icarus Verilog](https://bleyer.org/icarus/) (for compiling & simulation)
- [GTKWave](http://gtkwave.sourceforge.net/) (for waveform viewing)

---

## 🚀 Getting Started

### 1. Clone this repository
```bash
git clone https://github.com/yourusername/hearing-aid-verilog.git
cd hearing-aid-verilog
```

### 2. Compile the project
```bash
iverilog -o hearing_aid_sim hearing_aid_processor.v spectral_subtraction_stage.v lms_filter_stage.v hearing_aid_testbench.v
```

### 3. Run the simulation
```bash
vvp hearing_aid_sim
```

If `$dumpfile` and `$dumpvars` are included in the testbench, a file `hearing_aid.vcd` will be generated.

### 4. View waveforms in GTKWave
```bash
gtkwave hearing_aid.vcd
```

---

## 🖥 Testbench Description
- **Clock:** 100 MHz
- **Reset:** Active low, held for first 100 ns
- **Stimulus:**
  - First 256 samples = noise only (for noise estimation)
  - Then: sine wave + random noise
- **Output:** Printed to console when `audio_ready` is asserted

---

## 🔧 Parameters You Can Tune
- `NOISE_LEN` in `spectral_subtraction_stage.v` → Number of samples used for noise estimation
- `FILTER_ORDER` in `lms_filter_stage.v` → Number of FIR filter taps
- `STEP_SIZE` in `lms_filter_stage.v` → LMS adaptation step size

---

## 📊 Example Console Output
```
Time 2600: Input=512, Output=480
Time 2700: Input=498, Output=470
...
```

---

## 📜 License
This project is released under the MIT License – see [LICENSE](LICENSE) for details.

---

## 🙌 Acknowledgements
- Based on the dual-stage noise removal methodology described in the provided research paper.
- Thanks to the open-source Verilog toolchain community.
