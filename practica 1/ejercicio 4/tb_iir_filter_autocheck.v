`timescale 1ns/100ps
// ---------------------------------------------------------------------------
// Testbench autoverificable del filtro IIR del ejercicio 4.
//
// Compara la salida del DUT contra dos modelos de referencia:
//   1. Modelo bit-exacto en enteros (mismo formato S(16,4) y mismos
//      desplazamientos): la salida debe coincidir bit a bit.
//   2. Modelo ideal con numeros reales: mide el error de cuantizacion,
//      que debe estar en [0, 5*2^-4] = [0, 0.3125].
// Al final imprime la cantidad de errores (debe ser 0).
// ---------------------------------------------------------------------------
module tb_iir_filter_autocheck;

    localparam NB_X  = 8;
    localparam NB_Y  = 16;
    localparam NBF_Y = 4;
    localparam real LSB     = 1.0 / (1 << NBF_Y);
    localparam real ERR_MAX = 5.0 * LSB;           // cota teorica del error

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

    // Reloj de 100 MHz
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Estado de los modelos de referencia
    integer rx1, rx2, rx3, ry1, ry2;      // bit-exacto (y escalado por 2^NBF_Y)
    real    fx1, fx2, fx3, fy1, fy2;      // ideal

    integer errores, muestras, i, k;
    real    err, err_max_obs, y_real, y_max, y_min;
    integer ry;
    real    fy;
    reg     verbose;

    task reset_modelos;
        begin
            rx1 = 0; rx2 = 0; rx3 = 0; ry1 = 0; ry2 = 0;
            fx1 = 0.0; fx2 = 0.0; fx3 = 0.0; fy1 = 0.0; fy2 = 0.0;
        end
    endtask

    // Aplica una muestra, espera el flanco y verifica la salida registrada.
    // Se llama siempre en un flanco de bajada y termina en el siguiente, asi
    // cada flanco de subida procesa exactamente una muestra del modelo.
    task muestra;
        input integer xin;
        begin
            i_x = xin;

            // Modelo bit-exacto: mismas operaciones que el hardware
            ry = ((xin - rx1 + rx2 + rx3) <<< NBF_Y) + (ry1 >>> 1) + (ry2 >>> 2);
            // Modelo ideal
            fy = xin - fx1 + fx2 + fx3 + 0.5 * fy1 + 0.25 * fy2;

            @(posedge clk);
            #1;

            y_real = $itor(o_y) * LSB;
            err    = fy - y_real;
            muestras = muestras + 1;
            if (err > err_max_obs) err_max_obs = err;
            if (y_real > y_max) y_max = y_real;
            if (y_real < y_min) y_min = y_real;

            if (o_y !== ry[NB_Y-1:0] || ry > 32767 || ry < -32768) begin
                errores = errores + 1;
                $display("ERROR bit-exacto: x=%4d  o_y=%10.4f  esperado=%10.4f",
                         xin, y_real, $itor(ry) * LSB);
            end
            if (err < -1e-9 || err > ERR_MAX + 1e-9) begin
                errores = errores + 1;
                $display("ERROR de cuantizacion: x=%4d  o_y=%10.4f  ideal=%10.4f  err=%7.4f",
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

        errores = 0; muestras = 0; err_max_obs = 0.0;
        y_max = -1.0e9; y_min = 1.0e9; verbose = 0;
        i_x = 0;
        reset_modelos;

        // Reset inicial
        i_rst_n = 1'b0;
        repeat (3) @(posedge clk);
        @(negedge clk) i_rst_n = 1'b1;

        // 1. Respuesta al impulso
        $display("\n1) Impulso (x[0] = 1): h[n] = 1, -0.5, 1, 1.375, 0.9375, 0.8125 ...");
        verbose = 1;
        muestra(1);
        for (i = 0; i < 7; i = i + 1) muestra(0);
        verbose = 0;
        for (i = 0; i < 40; i = i + 1) muestra(0);

        // 2. Escalones: ganancia DC = 8
        $display("\n2) Escalon de 127 (ideal: 8*127 = 1016)");
        for (i = 0; i < 80; i = i + 1) muestra(127);
        $display("   o_y final = %0.4f", y_real);
        $display("   Escalon de -128 (ideal: 8*(-128) = -1024)");
        for (i = 0; i < 80; i = i + 1) muestra(-128);
        $display("   o_y final = %0.4f", y_real);

        // 3. Peor caso: secuencia que maximiza |y| (norma L1 = 9)
        $display("\n3) Peor caso positivo (ideal: 1143.5, fuera del rango de 11 bits)");
        for (i = 0; i < 80; i = i + 1) muestra(127);
        muestra(-128);
        muestra(127);
        $display("   o_y = %0.4f", y_real);
        $display("   Peor caso negativo (ideal: -1151.5)");
        for (i = 0; i < 80; i = i + 1) muestra(-128);
        muestra(127);
        muestra(-128);
        $display("   o_y = %0.4f", y_real);

        // 4. Reset asincrono en medio de la operacion
        $display("\n4) Reset asincrono entre flancos");
        #2 i_rst_n = 1'b0;               // 2 ns despues del flanco de bajada
        #1 if (o_y !== 0) begin
            errores = errores + 1;
            $display("   ERROR: o_y no se limpio con el reset asincrono");
        end
        else $display("   o_y = 0 inmediatamente, sin esperar el flanco: OK");
        @(negedge clk) i_rst_n = 1'b1;
        reset_modelos;

        // 5. Estimulo aleatorio
        $display("\n5) 20000 muestras aleatorias en [-128, 127]");
        for (i = 0; i < 20000; i = i + 1) begin
            k = $random;
            muestra($signed(k[7:0]));
        end

        // 6. Aleatorio con valores extremos (estresa la ganancia)
        $display("6) 20000 muestras aleatorias en {-128, 127}");
        for (i = 0; i < 20000; i = i + 1) begin
            k = $random;
            muestra(k[0] ? 127 : -128);
        end

        $display("\n----------------------------------------------");
        $display("Muestras verificadas : %0d", muestras);
        $display("Errores              : %0d", errores);
        $display("Error max vs ideal   : %0.4f  (cota teorica %0.4f)", err_max_obs, ERR_MAX);
        $display("Rango de o_y         : [%0.4f, %0.4f]", y_min, y_max);
        $display("----------------------------------------------");
        $finish;
    end

endmodule
