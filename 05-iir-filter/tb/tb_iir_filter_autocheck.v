`timescale 1ns/100ps
// ---------------------------------------------------------------------------
// Self-checking testbench for the IIR filter.
//
// Compares the DUT output against two reference models:
//   1. Bit-exact integer model (same S(16,4) format and same shifts):
//      the output must match bit for bit.
//   2. Ideal real-number model: measures the quantization error,
//      which must lie in [0, 5*2^-4] = [0, 0.3125].
// Prints the number of errors at the end (must be 0).
// ---------------------------------------------------------------------------
module tb_iir_filter_autocheck;

    localparam NB_X  = 8;
    localparam NB_Y  = 16;
    localparam NBF_Y = 4;
    localparam real LSB     = 1.0 / (1 << NBF_Y);
    localparam real ERR_MAX = 5.0 * LSB;           // theoretical error bound

    reg                    clk;
    reg                    i_rst_n;
    reg  signed [NB_X-1:0] i_x;
    wire signed [NB_Y-1:0] o_y;

    iir_filter #(.NB_X(NB_X), .NB_Y(NB_Y), .NBF_Y(NBF_Y)) dut (
        .clk     (clk),
        .i_rst_n (i_rst_n),
        .i_x     (i_x),
        .o_y     (o_y)
    );

    // 100 MHz clock
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Reference model state
    integer rx1, rx2, rx3, ry1, ry2;      // bit-exact (y scaled by 2^NBF_Y)
    real    fx1, fx2, fx3, fy1, fy2;      // ideal

    integer errors, n_samples, i, k;
    real    err, err_max_obs, y_real, y_max, y_min;
    integer ry;
    real    fy;
    reg     verbose;

    task reset_models;
        begin
            rx1 = 0; rx2 = 0; rx3 = 0; ry1 = 0; ry2 = 0;
            fx1 = 0.0; fx2 = 0.0; fx3 = 0.0; fy1 = 0.0; fy2 = 0.0;
        end
    endtask

    // Applies one sample, waits for the clock edge and checks the registered output.
    // Always called on a falling edge and returns on the next one, so each
    // rising edge processes exactly one model sample.
    task apply_sample;
        input integer xin;
        begin
            i_x = xin;

            // Bit-exact model: same operations as the hardware
            ry = ((xin - rx1 + rx2 + rx3) <<< NBF_Y) + (ry1 >>> 1) + (ry2 >>> 2);
            // Ideal model
            fy = xin - fx1 + fx2 + fx3 + 0.5 * fy1 + 0.25 * fy2;

            @(posedge clk);
            #1;

            y_real = $itor(o_y) * LSB;
            err    = fy - y_real;
            n_samples = n_samples + 1;
            if (err > err_max_obs) err_max_obs = err;
            if (y_real > y_max) y_max = y_real;
            if (y_real < y_min) y_min = y_real;

            if (o_y !== ry[NB_Y-1:0] || ry > 32767 || ry < -32768) begin
                errors = errors + 1;
                $display("ERROR bit-exact: x=%4d  o_y=%10.4f  expected=%10.4f",
                         xin, y_real, $itor(ry) * LSB);
            end
            if (err < -1e-9 || err > ERR_MAX + 1e-9) begin
                errors = errors + 1;
                $display("ERROR quantization: x=%4d  o_y=%10.4f  ideal=%10.4f  err=%7.4f",
                         xin, y_real, fy, err);
            end
            if (verbose)
                $display("  x=%4d   o_y=%10.4f   ideal=%10.4f   error=%7.4f", xin, y_real, fy, err);

            rx3 = rx2; rx2 = rx1; rx1 = xin; ry2 = ry1; ry1 = ry;
            fx3 = fx2; fx2 = fx1; fx1 = xin; fy2 = fy1; fy1 = fy;

            @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("tb_iir_filter_autocheck.vcd");
        $dumpvars(0, tb_iir_filter_autocheck);

        errors = 0; n_samples = 0; err_max_obs = 0.0;
        y_max = -1.0e9; y_min = 1.0e9; verbose = 0;
        i_x = 0;
        reset_models;

        // Initial reset
        i_rst_n = 1'b0;
        repeat (3) @(posedge clk);
        @(negedge clk) i_rst_n = 1'b1;

        // 1. Impulse response
        $display("\n1) Impulse (x[0] = 1): h[n] = 1, -0.5, 1, 1.375, 0.9375, 0.8125 ...");
        verbose = 1;
        apply_sample(1);
        for (i = 0; i < 7; i = i + 1) apply_sample(0);
        verbose = 0;
        for (i = 0; i < 40; i = i + 1) apply_sample(0);

        // 2. Steps: DC gain = 8
        $display("\n2) Step of 127 (ideal: 8*127 = 1016)");
        for (i = 0; i < 80; i = i + 1) apply_sample(127);
        $display("   final o_y = %0.4f", y_real);
        $display("   Step of -128 (ideal: 8*(-128) = -1024)");
        for (i = 0; i < 80; i = i + 1) apply_sample(-128);
        $display("   final o_y = %0.4f", y_real);

        // 3. Worst case: sequence that maximizes |y| (L1 norm = 9)
        $display("\n3) Positive worst case (ideal: 1143.5, outside the 11-bit range)");
        for (i = 0; i < 80; i = i + 1) apply_sample(127);
        apply_sample(-128);
        apply_sample(127);
        $display("   o_y = %0.4f", y_real);
        $display("   Negative worst case (ideal: -1151.5)");
        for (i = 0; i < 80; i = i + 1) apply_sample(-128);
        apply_sample(127);
        apply_sample(-128);
        $display("   o_y = %0.4f", y_real);

        // 4. Asynchronous reset during operation
        $display("\n4) Asynchronous reset between clock edges");
        #2 i_rst_n = 1'b0;               // 2 ns after the falling edge
        #1 if (o_y !== 0) begin
            errors = errors + 1;
            $display("   ERROR: o_y was not cleared by the asynchronous reset");
        end
        else $display("   o_y = 0 immediately, without waiting for the clock edge: OK");
        @(negedge clk) i_rst_n = 1'b1;
        reset_models;

        // 5. Random stimulus
        $display("\n5) 20000 random samples in [-128, 127]");
        for (i = 0; i < 20000; i = i + 1) begin
            k = $random;
            apply_sample($signed(k[7:0]));
        end

        // 6. Random extreme values (stresses the gain)
        $display("6) 20000 random samples in {-128, 127}");
        for (i = 0; i < 20000; i = i + 1) begin
            k = $random;
            apply_sample(k[0] ? 127 : -128);
        end

        $display("\n----------------------------------------------");
        $display("Samples checked      : %0d", n_samples);
        $display("Errors               : %0d", errors);
        $display("Max error vs ideal   : %0.4f  (theoretical bound %0.4f)", err_max_obs, ERR_MAX);
        $display("o_y range            : [%0.4f, %0.4f]", y_min, y_max);
        $display("----------------------------------------------");
        $finish;
    end

endmodule
