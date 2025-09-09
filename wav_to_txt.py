# wav_to_txt.py
import wave, sys

if len(sys.argv) < 3:
    print("Usage: python wav_to_txt.py input.wav output_samples.txt")
    sys.exit(1)

inwav = sys.argv[1]
outtxt = sys.argv[2]

with wave.open(inwav,'rb') as w:
    nch = w.getnchannels()
    sampwidth = w.getsampwidth()
    fr = w.getframerate()
    nframes = w.getnframes()
    print("channels:",nch,"sampwidth:",sampwidth,"fr:",fr,"frames:",nframes)
    if sampwidth != 2:
        print("Warning: sample width != 16-bit; behaviour may be unexpected.")
    raw = w.readframes(nframes)

# Interpret as signed 16-bit little-endian
import struct
fmt = '<' + 'h'*(len(raw)//2)
samples = struct.unpack(fmt, raw)

# If stereo, convert to mono by averaging channels
if nch == 2:
    samples = [(samples[i] + samples[i+1])//2 for i in range(0,len(samples),2)]

with open(outtxt,'w') as f:
    for s in samples:
        f.write(str(int(s)) + '\n')

print("Wrote", len(samples), "samples to", outtxt)
