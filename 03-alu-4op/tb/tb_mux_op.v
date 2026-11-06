`timescale 1ns/100ps

module tb_mux_op ();

    reg [15:0]  i_dataA;
    reg [15:0]  i_dataB;
    wire [15:0] o_dataC;

    reg  [1:0]  i_sel;

    initial begin
        i_dataA = 16'b0;
        i_dataB = 16'b0;
        i_sel = 2'b00;

        // apply one test vector every 50 ns
        #50;
        i_dataA = 16'd10;
        i_dataB = 16'd5;
        i_sel = 2'b00;

         #50;
        i_dataA = 16'd40;
        i_dataB = 16'd100;
        i_sel = 2'b00;

         #50;
        i_dataA = 16'd10;
        i_dataB = 16'd5;
        i_sel = 2'b01;

         #50;
        i_dataA = 16'd10;
        i_dataB = 16'd10;
        i_sel = 2'b10;

         #50;
        i_dataA = 16'd10;
        i_dataB = 16'd5;
        i_sel = 2'b10;

         #50;
        i_dataA = 16'd10;
        i_dataB = 16'd10;
        i_sel = 2'b11;

         #50;
        i_dataA = 16'd10;
        i_dataB = 16'd5;
        i_sel = 2'b11;

        #50;
        $finish;
    end

mux_op
u_mux_op
(
    .i_dataA (i_dataA),
    .i_dataB (i_dataB),
    .i_sel   (i_sel),
    .o_dataC  (o_dataC)
);

endmodule
