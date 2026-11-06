`timescale 1ns/100ps
// ---------------------------------------------------------------------------
// LED shifter - top level (Digilent Arty A7-35T)
//
// A counter generates an enable pulse every R0..R3 clock cycles; each pulse
// rotates a one-hot shift register shown on the LEDs.
//   i_sw[0]   : run / pause
//   i_sw[2:1] : shift period (R0..R3)
//   i_sw[3:2] : RGB LED color (see README)
//   i_reset   : active-low reset (CK_RST button)
//
// A VIO core can take over the switches and reset from Vivado (selmux = 1),
// and an ILA core captures the LED pattern for in-system debug.
// ---------------------------------------------------------------------------
module top
#(
    parameter NB_LED     = 4,
    parameter NB_SW      = 4,
    parameter NB_COUNTER = 32
)
(
    output [NB_LED-1:0] o_led,
    output [NB_LED-1:0] o_led_g,
    output [NB_LED-1:0] o_led_b,

    input  [NB_SW-1:0]  i_sw,
    input               i_reset,
    input               clock
);

    wire              connect_value;   // shift enable from the counter
    wire [NB_LED-1:0] connect_led;     // shift register state
    wire [NB_LED-1:0] led_g;
    wire [NB_LED-1:0] led_b;
    wire              selmux;          // 1: inputs come from the VIO
    wire [NB_SW-1:0]  w_sw;
    wire [NB_SW-1:0]  w_viosw;
    wire              w_reset;
    wire              w_vioreset;

    // Input source select: board switches/button or VIO
    assign w_reset = (selmux) ? w_vioreset : i_reset;
    assign w_sw    = (selmux) ? w_viosw    : i_sw;

    count
    #(
        .NB_SW      (NB_SW-1),
        .NB_COUNTER (NB_COUNTER)
    )
    u_count
    (
        .o_valid (connect_value),
        .i_sw    (w_sw[NB_SW-2:0]),
        .i_reset (~w_reset),           // active-low button -> active-high reset
        .clock   (clock)
    );

    shiftreg
    #(
        .NB_LED (NB_LED)
    )
    u_shiftreg
    (
        .o_led   (connect_led),
        .i_valid (connect_value),
        .i_reset (~w_reset),
        .clock   (clock)
    );

    // Outputs
    assign o_led   = connect_led;
    assign led_g   = (w_sw[NB_SW-2]) ? connect_led : {NB_LED{1'b0}};
    assign led_b   = (w_sw[NB_SW-1]) ? {NB_LED{1'b0}} : connect_led;
    assign o_led_g = led_g;
    assign o_led_b = led_b;

    // Integrated Logic Analyzer (Vivado IP, block design "ILA")
    ILA
    u_ila
    (
        .clk_0    (clock),
        .probe0_0 (connect_led)
    );

    // Virtual Input/Output (Vivado IP, block design "VIO")
    VIO
    u_vio
    (
        .clk_0        (clock),
        .probe_in0_0  (connect_led),
        .probe_in1_0  (led_g),
        .probe_in2_0  (led_b),
        .probe_out0_0 (selmux),
        .probe_out1_0 (w_vioreset),
        .probe_out2_0 (w_viosw)
    );

endmodule
