`timescale 1ns/100ps

module tb_top ();

    parameter NB_LED = 4;
    parameter NB_SW  =  4;
    parameter NB_COUNTER = 12;
    // DUT inputs are reg, outputs are wire
    wire [NB_LED -1:0] o_led;
    wire [NB_LED -1:0] o_led_g;
    wire [NB_LED -1:0] o_led_b;

    reg  [NB_SW -1:0]  i_sw;
    reg                i_reset;
    reg                clock;

    initial begin
        clock = 1'b0;
        i_sw  = 4'b0000;
        i_reset = 1'b0;
        // hold reset (active low) for 5 clock cycles
        #50;
        @(posedge clock);
        i_reset = 1'b1;

        #50;
        @(posedge clock);
        i_sw = 4'b0001;

        #10000;
        @(posedge clock);
        i_sw = 4'b0011;

        #10000;
        @(posedge clock);
        i_sw = 4'b0001;

        #10000;
        @(posedge clock);
        i_sw = 4'b0111;

        #10000;
        @(posedge clock);
        i_sw = 4'b1001;

        #10000;
        @(posedge clock);
        i_sw = 4'b1011;

        #10000;
        @(posedge clock);
        i_sw = 4'b1101;

        #10000;
        @(posedge clock);
        i_sw = 4'b1111;

        #10000;
        $finish;

    end

    always #5 clock = ~clock;

top #(
    .NB_LED      (NB_LED),
    .NB_SW       (NB_SW),
    .NB_COUNTER  (NB_COUNTER)
)
u_top
(
    .o_led   (o_led  ),
    .o_led_g (o_led_g),
    .o_led_b (o_led_b),
    .i_sw    (i_sw   ),
    .i_reset (i_reset),
    .clock   (clock  )
);
endmodule
