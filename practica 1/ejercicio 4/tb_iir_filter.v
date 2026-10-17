`timescale 1ns/100ps

module tb_iir_filter ();

    reg  signed [7:0]   i_x;
    reg                 clk;
    reg                 i_rst_n;
    wire signed [15:0]  o_y;        // formato S(16,4): valor real = o_y / 16

    // o_y convertido a decimal para verlo directamente en las formas de onda
    real                y_real;
    always @(*) y_real = $itor(o_y) / 16.0;



    initial begin
        clk = 1'b0;
        i_x = 8'sd0;
        i_rst_n = 1'b0;



        // reset activo durante 5 ciclos de reloj
        #50;
        @(negedge clk);
        i_rst_n = 1'b1;


        // 1) Respuesta al impulso: x = 1 durante UN solo ciclo
        //    o_y esperado (un ciclo despues): 16, -8, 16, 22, 15, 12, 9, 7 ...
        //    en decimal: 1, -0.5, 1, 1.375, 0.9375, 0.75, 0.5625, 0.4375 ...
        #50;
        @(negedge clk);
        i_x = 8'sd1;

        @(negedge clk);
        i_x = 8'sd0;


        // 2) Escalon de 127 durante 80 ciclos
        //    o_y converge a 16251 (1015.6875); ideal 8*127 = 1016
        #100;
        @(negedge clk);
        i_x = 8'sd127;


        // 3) Escalon de -128 durante 80 ciclos
        //    o_y converge a -16384 (-1024); ideal 8*(-128) = -1024
        #800;
        @(negedge clk);
        i_x = 8'h80;         // -128 (escrito en hex: 8'sd128 no cabe en 8 bits con signo)


        // 4) Peor caso positivo: 127 sostenido, luego -128 un ciclo y 127 un ciclo
        //    pico de o_y = 18291 (1143.1875); necesita 12 bits enteros
        #800;
        @(negedge clk);
        i_x = 8'sd127;

        #800;
        @(negedge clk);
        i_x = 8'h80;         // -128 (escrito en hex: 8'sd128 no cabe en 8 bits con signo)

        @(negedge clk);
        i_x = 8'sd127;


        // 5) Peor caso negativo: -128 sostenido, luego 127 un ciclo y -128 un ciclo
        //    pico de o_y = -18424 (-1151.5)
        @(negedge clk);
        i_x = 8'h80;         // -128 (escrito en hex: 8'sd128 no cabe en 8 bits con signo)

        #800;
        @(negedge clk);
        i_x = 8'sd127;

        @(negedge clk);
        i_x = 8'h80;         // -128 (escrito en hex: 8'sd128 no cabe en 8 bits con signo)


        // 6) Reset asincrono en medio de la operacion: o_y pasa a 0
        //    sin esperar el flanco de subida
        #50;
        @(negedge clk);
        #2;
        i_rst_n = 1'b0;

        #50;
        @(negedge clk);
        i_x = 8'sd0;
        i_rst_n = 1'b1;


        // 7) Valores sueltos, un ciclo cada uno
        //    o_y esperado: 160, -400, 1120, -580, 550, 850, 482 ...
        //    en decimal: 10, -25, 70, -36.25, 34.375, 53.125, 30.125 ...
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
