// ---------------------------------------------------------------------------
// Ejercicio 4 - Filtro IIR en forma directa I
//
//   y[n] = x[n] - x[n-1] + x[n-2] + x[n-3] + 0.5 y[n-1] + 0.25 y[n-2]
//
// Formatos (punto fijo con signo, S(bits totales, bits fraccionarios)):
//   x       : S(8,0)   entero con signo, rango [-128, 127]
//   fir     : S(10,0)  suma de 4 muestras, rango [-511, 509]
//   y       : S(16,4)  12 bits enteros + 4 fraccionarios
//
// Las multiplicaciones por 0.5 y 0.25 se hacen con desplazamientos
// aritmeticos (>>> 1 y >>> 2). La salida esta registrada: o_y muestra
// y[n] un ciclo de reloj despues de presentar x[n].
// ---------------------------------------------------------------------------
module iir_filter #(
    parameter NB_X  = 8,             // bits de la entrada
    parameter NB_Y  = 16,            // bits de la salida
    parameter NBF_Y = 4              // bits fraccionarios de la salida
)(
    input  wire                   clk,
    input  wire                   i_rst_n,    // reset asincrono, activo en bajo
    input  wire signed [NB_X-1:0] i_x,
    output wire signed [NB_Y-1:0] o_y
);

    localparam NB_FIR = NB_X + 2;    // 4 terminos -> crecen log2(4) = 2 bits

    // Lineas de retardo
    reg  signed [NB_X-1:0] x1, x2, x3;   // x[n-1], x[n-2], x[n-3]
    reg  signed [NB_Y-1:0] y1, y2;       // y[n-1], y[n-2]

    // Parte FIR (numerador): todos los operandos son signed -> extension de signo
    wire signed [NB_FIR-1:0] fir = i_x - x1 + x2 + x3;

    // Alinear el FIR entero al formato de y: agregar NBF_Y ceros a la derecha
    // (el signo se extiende al asignar porque la expresion es signed)
    wire signed [NB_Y-1:0] fir_al = $signed({fir, {NBF_Y{1'b0}}});

    // Parte recursiva: 0.5*y[n-1] y 0.25*y[n-2] con desplazamiento aritmetico
    wire signed [NB_Y-1:0] y1_half    = y1 >>> 1;
    wire signed [NB_Y-1:0] y2_quarter = y2 >>> 2;

    // Salida combinacional y[n]
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
