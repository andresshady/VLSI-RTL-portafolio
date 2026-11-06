`timescale 1ns/100ps
// ---------------------------------------------------------------------------
// One-hot rotating shift register.
// Resets to ...0001 and rotates left by one position on every i_valid pulse.
// ---------------------------------------------------------------------------
module shiftreg
#(
    parameter NB_LED = 4
)
(
    output [NB_LED-1:0] o_led,
    input               i_valid,
    input               i_reset,    // synchronous, active high
    input               clock
);

    reg [NB_LED-1:0] shiftreg;

    always @(posedge clock) begin
        if (i_reset)
            shiftreg <= {{NB_LED-1{1'b0}}, 1'b1};
        else if (i_valid)
            shiftreg <= {shiftreg[NB_LED-2:0], shiftreg[NB_LED-1]};   // rotate left
        else
            shiftreg <= shiftreg;
    end

    assign o_led = shiftreg;

endmodule
