# FPGA Audio Analyzer

FPGA-based real-time audio spectrum analyzer and musical note detector implemented in SystemVerilog on a Digilent Basys 3.

The system captures audio from an ICS-43434 I2S MEMS microphone, processes the signal directly on the FPGA, performs spectral analysis using a 2048-point DFT, and identifies the dominant musical note on the Basys 3 seven-segment display.

## Demo

[[VIDEO / GIF HERE]](https://github.com/user-attachments/assets/bf25cad5-806e-4fc8-86c4-709ea70afff9)

The demo shows the FPGA identifying notes as a musical E major scale is played into the microphone.

## System Architecture

```text
ICS-43434 I2S Microphone
        ↓
24-bit I2S Receiver
        ↓
FIR Low-Pass Filter
        ↓
4× Decimation
        ↓
2048-Sample Buffer
        ↓
2048-Point DFT
        ↓
Magnitude / Peak Detection
        ↓
Frequency-to-Note Mapping
        ↓
Basys 3 Seven-Segment Display
```

## Hardware

- Digilent Basys 3
- Xilinx Artix-7 XC7A35T FPGA
- ICS-43434 I2S MEMS microphone
- 100 MHz onboard clock

## Current Implementation

1. Captures 24-bit digital audio through I2S
2. Low-pass filters audio to prevent aliasing from high frequency waves
3. Decimates the audio stream by 4
4. Buffers 2048 audio samples
5. Computes a 2048-point DFT using multiply-accumulate operations
6. Maps the detected highest-magnitude frequency bin to a musical pitch
7. Displays the detected note on the FPGA's seven-segment display

## Current Results

The system can detect individual musical notes from live microphone input and display the detected pitch class in real time.

## Future Work

### FFT Implementation

The 2048-point DFT requires O(N²) operations. The next step is replacing the DFT module with a radix-2 FFT while maintaining the same surrounding audio-processing pipeline.

A 2048-point radix-2 FFT would reduce the computational complexity from roughly 4.2 million DFT operations to approximately 11,264 butterfly operations across 11 stages, significantly improving processing speed.

The current architecture of the program supports the direct replacement of a DFT algorithm with an FFT without the need to change surrounding modules.

### Multiple-Note Detection

The current implementation selects the strongest spectral component.

Future versions will retain multiple significant spectral peaks and account for harmonic relationships, allowing several simultaneously played notes to be identified.

This would extend the system from a single-note detector toward real-time polyphonic audio analysis.
