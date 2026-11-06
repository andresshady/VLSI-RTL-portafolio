# RTL / VLSI Portfolio

Digital design projects in Verilog by **Andrés Sánchez Beins**: RTL design, testbenches, fixed-point DSP and FPGA implementation on a Digilent Arty A7-35T with Xilinx Vivado 2024.2.

The projects come from the *Advanced Digital Design* course (Fundación Fulgor). Work from the VLSI block of the UCR / Fundación CRUSA Semiconductor Device Design & Packaging Program will be added as it is completed.

## Projects

| # | Project | What it shows | Verification |
|---|---------|---------------|--------------|
| 01 | [LED shifter on FPGA](01-led-shifter-fpga) | Parameterized period counter and rotating shift register, switch-selectable speed, Vivado VIO/ILA cores for in-system debug on the Arty A7 | Directed testbench, on-board debug with ILA/VIO |
| 02 | [Accumulator](02-accumulator) | Adder, 4:1 input select and registered accumulator with overflow flag, mapped to board switches and LEDs | Directed testbench, waveform analysis |
| 03 | [4-operation ALU](03-alu-4op) | 16-bit combinational ALU: add, subtract, AND, OR | Directed testbench |
| 04 | [RTL to block diagram](04-rtl-to-block-diagram) | Block diagram derived from a given Verilog module (muxes, registers, adder, shift-based divide) | Design review |
| 05 | [IIR filter](05-iir-filter) | Fixed-point direct form I IIR filter, S(8,0) input to S(16,4) output, multiplier-free (arithmetic shifts), worst-case range analysis | **Self-checking testbench**: bit-exact and ideal reference models, 40,372 samples, 0 mismatches |

## Repository layout

```
NN-project-name/
├── rtl/            synthesizable Verilog
├── tb/             testbenches
├── constraints/    Arty A7 pin constraints (.xdc), when the design runs on the board
├── ip/             Vivado block designs (ILA / VIO), when used
├── sim/            simulation-only helpers
└── docs/           block diagrams and waveforms
```

## Running the simulations

With [Icarus Verilog](https://steveicarus.github.io/iverilog/) 11 or newer:

```
make sim         # all testbenches
make iir_check   # one target: led, acc, alu, iir, iir_check
make clean
```

In Vivado, create a project inside `vivado/` (ignored by git) and add the `rtl/`, `tb/`, `constraints/` and `ip/` files of the project you want to build.

## Tools

Verilog-2005 · Xilinx Vivado 2024.2 (simulation, synthesis, implementation, ILA/VIO) · Icarus Verilog · Digilent Arty A7-35T (xc7a35ticsg324-1L)
