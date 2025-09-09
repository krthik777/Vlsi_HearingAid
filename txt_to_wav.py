# txt_to_wav.py
import wave, sys, struct

if len(sys.argv) < 4:
    print("Usage: python txt_to_wav.py input_samples.txt output.wav sample_rate")
    sys.exit(1)

infile = sys.argv[1]
outwav = sys.argv[2]
sr = int(sys.argv[3])

samples = []
with open(infile,'r') as f:
    for line in f:
        line = line.strip()
        if not line: continue
        samples.append(int(line))

# pack as signed 16-bit little-endian
with wave.open(outwav,'w') as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(sr)
    data = struct.pack('<' + 'h'*len(samples), *samples)
    w.writeframes(data)

print("Wrote", len(samples), "samples to", outwav)
