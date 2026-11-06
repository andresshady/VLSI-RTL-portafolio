`timescale 1ns/100ps
// ---------------------------------------------------------------------------
// Simulation-only stubs for the Vivado ILA and VIO block designs.
// They let tb_top run in any Verilog simulator (e.g. Icarus Verilog)
// without the Xilinx IP libraries. The VIO stub drives selmux = 0, so the
// design takes its inputs from the testbench (board switches and button).
// Do not add this file to the Vivado synthesis sources.
// ---------------------------------------------------------------------------
module ILA (
    input       clk_0,
    input [3:0] probe0_0
);
endmodule

module VIO (
    input        clk_0,
    input  [3:0] probe_in0_0,
    input  [3:0] probe_in1_0,
    input  [3:0] probe_in2_0,
    output       probe_out0_0,
    output       probe_out1_0,
    output [3:0] probe_out2_0
);
    assign probe_out0_0 = 1'b0;
    assign probe_out1_0 = 1'b1;
    assign probe_out2_0 = 4'b0000;
endmodule
