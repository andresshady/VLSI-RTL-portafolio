module top
#(
    parameter NB_LED = 4,
    parameter NB_SW = 4,
    parameter NB_COUNTER = 32
)
(
    output [NB_LED -1:0] o_led,
    output [NB_LED -1:0] o_led_g,
    output [NB_LED -1:0] o_led_b,

    input  [NB_SW -1:0] i_sw,
    input        i_reset,
    input        clock

);
 //var
wire connect_value;
wire[NB_LED -1:0] connect_led;
wire [3:0] led_g;
wire [3:0] led_b;
wire selmux;
wire [3:0] w_sw;
wire [3:0] w_viosw;
wire       w_reset;
wire       w_vioreset;

assign w_reset = (selmux)? w_vioreset : i_reset;
assign w_sw =    (selmux)? w_viosw : i_sw;

 
count #(
    .NB_SW(NB_SW-1),
    .NB_COUNTER(NB_COUNTER)
)
u_count
(
    .o_valid(connect_value),
    .i_sw(w_sw[NB_SW -2:0]),
    .i_reset(~w_reset),
    .clock(clock)

);



shiftreg #(
    .NB_LED(NB_LED)
)
u_shiftreg
(
    .o_led(connect_led),
    .i_valid(connect_value),
    .i_reset(~w_reset),
    .clock(clock)
);


assign o_led = connect_led;
assign led_g = (w_sw[NB_SW-2]) ? connect_led : 4'b0000;
assign led_b = (w_sw[NB_SW-1]) ? 4'b0000  : connect_led;

assign o_led_g = led_g;
assign o_led_b = led_b;

ILA
u_ila
(
  .clk_0 (clock),
  .probe0_0 (connect_led)
);


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