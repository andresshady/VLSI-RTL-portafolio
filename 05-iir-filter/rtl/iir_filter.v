`timescale 1ns/100ps
// ---------------------------------------------------------------------------
// IIR filter, direct form I
//
//   y[n] = x[n] - x[n-1] + x[n-2] + x[n-3] + 0.5 y[n-1] + 0.25 y[n-2]
//
// Formats (signed fixed point, S(total bits, fractional bits)):
//   x       : S(8,0)   signed integer, range [-128, 127]
//   fir     : S(10,0)  sum of 4 samples, range [-511, 509]
//   y       : S(16,4)  12 integer bits + 4 fractional bits
//
// The multiplications by 0.5 and 0.25 are implemented as arithmetic
// shifts (>>> 1 and >>> 2). The output is registered: o_y shows y[n]
// one clock cycle after x[n] is applied.
// ---------------------------------------------------------------------------
module iir_filter #(
    parameter NB_X  = 8,             // input width
    parameter NB_Y  = 16,            // output width
    parameter NBF_Y = 4              // output fractional bits
)(
    input  wire                   clk,
    input  wire                   i_rst_n,    // asynchronous reset, active low
    input  wire signed [NB_X-1:0] i_x,
    output wire signed [NB_Y-1:0] o_y
);

    localparam NB_FIR = NB_X + 2;    // 4 terms -> grows log2(4) = 2 bits

    // Delay lines
    reg  signed [NB_X-1:0] x1, x2, x3;   // x[n-1], x[n-2], x[n-3]
    reg  signed [NB_Y-1:0] y1, y2;       // y[n-1], y[n-2]

    // FIR part (numerator): all operands are signed -> sign extension
    wire signed [NB_FIR-1:0] fir = i_x - x1 + x2 + x3;

    // Align the integer FIR sum to the y format: append NBF_Y zeros on the right
    // (the sign is extended on assignment because the expression is signed)
    wire signed [NB_Y-1:0] fir_al = $signed({fir, {NBF_Y{1'b0}}});

    // Recursive part: 0.5*y[n-1] and 0.25*y[n-2] with arithmetic shifts
    wire signed [NB_Y-1:0] y1_half    = y1 >>> 1;
    wire signed [NB_Y-1:0] y2_quarter = y2 >>> 2;

    // Combinational output y[n]
    wire signed [NB_Y-1:0] y = fir_al + y1_half + y2_quarter;

    always @(posedge clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            x1 <= {NB_X{1'b0}};
            x2 <= {NB_X{1'b0}};
            x3 <= {NB_X{1'b0}};
            y1 <= {NB_Y{1'b0}};
            y2 <= {NB_Y{1'b0}};
        end
        else begin
            x1 <= i_x;
            x2 <= x1;
            x3 <= x2;
            y1 <= y;
            y2 <= y1;
        end
    end

    assign o_y = y1;

endmodule
