`timescale 1ns/100ps

module tb_iir_filter ();

    reg  signed [7:0]   i_x;
    reg                 clk;
    reg                 i_rst_n;
    wire signed [15:0]  o_y;        // S(16,4) format: real value = o_y / 16

    // o_y converted to decimal to read it directly in the waveforms
    real                y_real;
    always @(*) y_real = $itor(o_y) / 16.0;

    initial begin
        clk = 1'b0;
        i_x = 8'sd0;
        i_rst_n = 1'b0;

        // reset asserted for 5 clock cycles
        #50;
        @(negedge clk);
        i_rst_n = 1'b1;

        // 1) Impulse response: x = 1 for ONE cycle only
        //    expected o_y (one cycle later): 16, -8, 16, 22, 15, 12, 9, 7 ...
        //    in decimal: 1, -0.5, 1, 1.375, 0.9375, 0.75, 0.5625, 0.4375 ...
        #50;
        @(negedge clk);
        i_x = 8'sd1;

        @(negedge clk);
        i_x = 8'sd0;

        // 2) Step of 127 for 80 cycles
        //    o_y converges to 16251 (1015.6875); ideal 8*127 = 1016
        #100;
        @(negedge clk);
        i_x = 8'sd127;

        // 3) Step of -128 for 80 cycles
        //    o_y converges to -16384 (-1024); ideal 8*(-128) = -1024
        #800;
        @(negedge clk);
        i_x = 8'h80;         // -128 (written in hex: 8'sd128 does not fit in 8 signed bits)

        // 4) Positive worst case: 127 held, then -128 for one cycle and 127 for one cycle
        //    o_y peak = 18291 (1143.1875); needs 12 integer bits
        #800;
        @(negedge clk);
        i_x = 8'sd127;

        #800;
        @(negedge clk);
        i_x = 8'h80;         // -128 (written in hex: 8'sd128 does not fit in 8 signed bits)

        @(negedge clk);
        i_x = 8'sd127;

        // 5) Negative worst case: -128 held, then 127 for one cycle and -128 for one cycle
        //    o_y peak = -18424 (-1151.5)
        @(negedge clk);
        i_x = 8'h80;         // -128 (written in hex: 8'sd128 does not fit in 8 signed bits)

        #800;
        @(negedge clk);
        i_x = 8'sd127;

        @(negedge clk);
        i_x = 8'h80;         // -128 (written in hex: 8'sd128 does not fit in 8 signed bits)

        // 6) Asynchronous reset during operation: o_y goes to 0
        //    without waiting for the rising edge
        #50;
        @(negedge clk);
        #2;
        i_rst_n = 1'b0;

        #50;
        @(negedge clk);
        i_x = 8'sd0;
        i_rst_n = 1'b1;

        // 7) Individual values, one cycle each
        //    expected o_y: 160, -400, 1120, -580, 550, 850, 482 ...
        //    in decimal: 10, -25, 70, -36.25, 34.375, 53.125, 30.125 ...
        #50;
        @(negedge clk);
        i_x = 8'sd10;

        @(negedge clk);
        i_x = -8'sd20;

        @(negedge clk);
        i_x = 8'sd50;

        @(negedge clk);
        i_x = -8'sd5;

        @(negedge clk);
        i_x = 8'sd0;

        #200;
        $finish;
    end
    always #5 clk = ~clk;

iir_filter
u_iir_filter
(
    .clk     (clk),
    .i_rst_n (i_rst_n),
    .i_x     (i_x),
    .o_y     (o_y)
);

endmodule
